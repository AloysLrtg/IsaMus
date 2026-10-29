import { entitledItems, handleRequest, vipExpiry } from './handler.ts';
import { handleRequest as deleteAccount } from '../delete-account/handler.ts';
function assert(value: unknown, message: string) { if (!value) throw new Error(message); }
Deno.test('lifetime and unexpired entitlements only, with a fixed allowlist', () => {
  const now=Date.parse('2026-10-26T00:00:00Z');
  assert(JSON.stringify(entitledItems({gold:{expires_date:null},ruby:{expires_date:'2020-01-01T00:00:00Z'},admin:{expires_date:null}},now))==='["gold"]','expired or unknown entitlement accepted');
  assert(entitledItems({gold:{}},now).length===0,'missing expiry must fail closed');
});
Deno.test('purchase sync ignores supplied player and item identifiers', async () => {
  const original=globalThis.fetch; const calls: string[]=[];
  Deno.env.set('SUPABASE_URL','https://example.test');Deno.env.set('SUPABASE_ANON_KEY','public-test');Deno.env.set('SUPABASE_SERVICE_ROLE_KEY','server-test');Deno.env.set('REVENUECAT_SECRET_KEY','revenue-test');
  try {
    globalThis.fetch=(async (input:RequestInfo|URL,init?:RequestInit)=>{
      const url=String(input);calls.push(url);
      if(url.endsWith('/auth/v1/user'))return Response.json({id:'verified-user',is_anonymous:false});
      if(url.includes('api.revenuecat.com')){assert(url.endsWith('/verified-user'),'unverified identity queried');return Response.json({subscriber:{entitlements:{gold:{expires_date:null}}}});}
      assert(url.endsWith('/rpc/sync_purchases'),'non-atomic purchase sync');
      const body=JSON.parse(init?.body as string);assert(body.vip_until===null,'forged VIP');assert(body.player==='verified-user','request body forged identity');assert(JSON.stringify(body.items)==='["gold"]','client granted items');return new Response(null,{status:204});
    }) as typeof fetch;
    const response=await handleRequest(new Request('https://example.test',{method:'POST',headers:{Authorization:'Bearer verified'},body:JSON.stringify({player:'victim',items:['ruby']})}));
    assert(response.status===200 && calls.length===3,'sync failed');
  } finally { globalThis.fetch=original; }
});
Deno.test('invalid session cannot call purchase validation or deletion RPC',async()=>{
  const original=globalThis.fetch;let calls=0;
  try{
    globalThis.fetch=(async()=>{calls++;return new Response(null,{status:401});}) as typeof fetch;
    const req=()=>new Request('https://example.test',{method:'POST',headers:{Authorization:'Bearer invalid'}});
    assert((await handleRequest(req())).status===401,'sync accepted invalid session');
    assert((await deleteAccount(req())).status===401,'delete accepted invalid session');
    assert(calls===2,'privileged endpoint invoked');
  }finally{globalThis.fetch=original;}
});
Deno.test('failed purchase verification never changes inventory',async()=>{
  const original=globalThis.fetch;let calls=0;
  try{
    globalThis.fetch=(async()=>++calls===1?Response.json({id:'verified-user',is_anonymous:false}):new Response(null,{status:503})) as typeof fetch;
    const response=await handleRequest(new Request('https://example.test',{method:'POST',headers:{Authorization:'Bearer verified'}}));
    assert(response.status===502 && calls===2,'failed verification mutated inventory');
  }finally{globalThis.fetch=original;}
});

Deno.test('VIP requires verified finite expiry; grace periods allowed, refunds revoked',()=>{
 const now=Date.parse('2026-10-28T00:00:00Z');
 assert(vipExpiry({entitlements:{vip:{expires_date:null}}},now)===null,'permanent VIP accepted');
 assert(vipExpiry({entitlements:{vip:{expires_date:'broken'}}},now)===null,'invalid expiry');
 assert(vipExpiry({entitlements:{vip:{expires_date:'2026-10-01T00:00:00Z'}}},now)===null,'expired VIP');
 assert(vipExpiry({entitlements:{vip:{expires_date:'2026-11-01T00:00:00Z'}}},now)!==null,'active VIP rejected');
 assert(vipExpiry({entitlements:{vip:{expires_date:'2026-10-01T00:00:00Z',product_identifier:'monthly'}},subscriptions:{monthly:{grace_period_expires_date:'2026-11-01T00:00:00Z'}}},now)!==null,'grace period rejected');
 assert(vipExpiry({entitlements:{vip:{expires_date:'2026-11-01T00:00:00Z',product_identifier:'monthly'}},subscriptions:{monthly:{refunded_at:'2026-10-27T00:00:00Z'}}},now)===null,'refund retained VIP');
});
