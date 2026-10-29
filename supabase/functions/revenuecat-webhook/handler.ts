import { entitledItems, vipExpiry } from '../sync-purchases/handler.ts';
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{'Content-Type':'application/json'}});
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export async function handleWebhook(req:Request):Promise<Response>{
  if(req.method!=='POST')return json({error:'Method not allowed'},405);
  const secret=Deno.env.get('REVENUECAT_WEBHOOK_SECRET');
  if(!secret)return json({error:'Not configured'},503);
  if(req.headers.get('Authorization')!==`Bearer ${secret}`)return json({error:'Unauthorized'},401);
  try{
    const raw=await req.text();if(raw.length>65536)return json({error:'Payload too large'},413);
    const event=JSON.parse(raw)?.event;
    if(!event || typeof event!=='object')return json({error:'Invalid event'},400);
    // Transfers may affect several identities. The event never directly grants a cosmetic.
    const candidates=[event.app_user_id,...(Array.isArray(event.transferred_from)?event.transferred_from:[]),...(Array.isArray(event.transferred_to)?event.transferred_to:[])];
    const ids=[...new Set(candidates.filter((id):id is string=>typeof id==='string' && uuid.test(id)))];
    if(ids.length>20)return json({error:'Too many identities'},400);
    const key=Deno.env.get('REVENUECAT_SECRET_KEY');
    if(!key)return json({error:'Not configured'},503);
    const service=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const url=Deno.env.get('SUPABASE_URL')!;
    for(const id of ids){
      const response=await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(id)}`,{headers:{Authorization:`Bearer ${key}`},signal:AbortSignal.timeout(10000)});
      if(!response.ok)return json({error:'Verification unavailable'},502);
      const body=await response.json();
      if(!body.subscriber?.entitlements)return json({error:'Invalid verification'},502);
      const items=entitledItems(body.subscriber.entitlements);
      const vip_until=vipExpiry(body.subscriber);
      const result=await fetch(`${url}/rest/v1/rpc/sync_purchases`,{method:'POST',headers:{Authorization:`Bearer ${service}`,apikey:service,'Content-Type':'application/json'},body:JSON.stringify({player:id,items,vip_until}),signal:AbortSignal.timeout(10000)});
      if(!result.ok)return json({error:'Inventory sync failed'},500);
    }
    return json({synchronized:ids.length});
  }catch(_){return json({error:'Service unavailable'},503);}
}
