const cors = { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info', 'Access-Control-Allow-Methods': 'POST, OPTIONS' };
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
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
    if (!user.id) return json({ error: 'Invalid user' }, 401);
    const key = Deno.env.get('REVENUECAT_SECRET_KEY');
    if (key) {
      // Remove the purchase processor's customer record before deleting the local account.
      const result = await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(user.id)}`, { method: 'DELETE', headers: { Authorization: `Bearer ${key}` }, signal: AbortSignal.timeout(10000) });
      if (!result.ok && result.status !== 404) return json({ error: 'Purchase data deletion unavailable; retry later' }, 502);
    }
    const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const result = await fetch(`${url}/rest/v1/rpc/erase_account`, { method: 'POST', headers: { Authorization: `Bearer ${service}`, apikey: service, 'Content-Type': 'application/json' }, body: JSON.stringify({ player: user.id }), signal: AbortSignal.timeout(10000) });
    if (!result.ok) return json({ error: 'Account deletion failed' }, 500);
    return json({ deleted: true });
  } catch (_) { return json({ error: 'Service unavailable' }, 503); }
}
