const cors = { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info', 'Access-Control-Allow-Methods': 'POST, OPTIONS' };
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { ...cors, 'Content-Type': 'application/json' } });

export function entitledItems(entitlements: Record<string, { expires_date?: string | null }>, now = Date.now()): string[] {
  return ['gold', 'ruby'].filter((id) => {
    const entitlement = entitlements[id];
    return entitlement && (entitlement.expires_date === null || (typeof entitlement.expires_date === 'string' && Date.parse(entitlement.expires_date) > now));
  });
}

type RevenueSubscriber = {
  entitlements?: Record<string, {expires_date?:string|null; grace_period_expires_date?:string|null; product_identifier?:string}>;
  subscriptions?: Record<string, {refunded_at?:string|null; grace_period_expires_date?:string|null}>;
};
export function vipExpiry(subscriber: RevenueSubscriber, now=Date.now()): string|null {
  const key=Deno.env.get('REVENUECAT_VIP_ENTITLEMENT') || 'vip';
  const entitlement=subscriber.entitlements?.[key];
  if(!entitlement || typeof entitlement.expires_date!=='string') return null;
  const expiration=Date.parse(entitlement.expires_date);
  if(!Number.isFinite(expiration)) return null;
  const subscription=entitlement.product_identifier ? subscriber.subscriptions?.[entitlement.product_identifier] : undefined;
  if(subscription?.refunded_at) return null;
  const grace=Date.parse(subscription?.grace_period_expires_date || entitlement.grace_period_expires_date || '');
  const until=Number.isFinite(grace) ? Math.max(expiration,grace) : expiration;
  return until>now ? new Date(until).toISOString() : null;
}

export async function handleRequest(req: Request): Promise<Response> {
  if (req.method === 'OPTIONS') return new Response(null, { headers: cors });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  try {
    const url = Deno.env.get('SUPABASE_URL')!;
    const authorization = req.headers.get('Authorization');
    if (!authorization) return json({ error: 'Authentication required' }, 401);
    const auth = await fetch(`${url}/auth/v1/user`, { headers: { Authorization: authorization, apikey: Deno.env.get('SUPABASE_ANON_KEY')! }, signal: AbortSignal.timeout(10000) });
    if (!auth.ok) return json({ error: 'Invalid session' }, 401);
    const user = await auth.json();
    if (!user.id || user.is_anonymous) return json({ error: 'Secure your account first' }, 403);
    const key = Deno.env.get('REVENUECAT_SECRET_KEY');
    if (!key) return json({ error: 'Store validation is not configured' }, 503);
    // The player ID is taken exclusively from verified Auth, never from the request body.
    const customer = await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(user.id)}`, { headers: { Authorization: `Bearer ${key}` }, signal: AbortSignal.timeout(10000) });
    if (!customer.ok) return json({ error: 'Purchase verification unavailable' }, 502);
    const body = await customer.json();
    if (!body.subscriber?.entitlements || typeof body.subscriber.entitlements !== 'object') return json({ error: 'Invalid verification response' }, 502);
    const items = entitledItems(body.subscriber.entitlements);
    const vip_until = vipExpiry(body.subscriber);
    const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const result = await fetch(`${url}/rest/v1/rpc/sync_purchases`, { method: 'POST', headers: { Authorization: `Bearer ${service}`, apikey: service, 'Content-Type': 'application/json' }, body: JSON.stringify({ player: user.id, items, vip_until }), signal: AbortSignal.timeout(10000) });
    if (!result.ok) return json({ error: 'Inventory update failed' }, 500);
    return json({ items, vip_expires_at: vip_until });
  } catch (_) { return json({ error: 'Service unavailable' }, 503); }
}
