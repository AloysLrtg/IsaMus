import {handleWebhook} from './handler.ts';
function assert(v:unknown,m:string){if(!v)throw new Error(m);}
Deno.test('webhook requires its server secret',async()=>{
  Deno.env.set('REVENUECAT_WEBHOOK_SECRET','test-secret');
  const result=await handleWebhook(new Request('https://example.test',{method:'POST',headers:{Authorization:'Bearer attacker'},body:'{}'}));
  assert(result.status===401,'unauthenticated webhook accepted');
});
Deno.test('refund re-fetches current entitlement state and revokes inventory',async()=>{
  Deno.env.set('REVENUECAT_WEBHOOK_SECRET','test-secret');Deno.env.set('REVENUECAT_SECRET_KEY','test-key');Deno.env.set('SUPABASE_URL','https://example.test');Deno.env.set('SUPABASE_SERVICE_ROLE_KEY','server-test');
  const old=globalThis.fetch;let updates=0;
  try{
    globalThis.fetch=(async(input:RequestInfo|URL,init?:RequestInit)=>{
      if(String(input).includes('api.revenuecat.com'))return Response.json({subscriber:{entitlements:{}}});
      const body=JSON.parse(init?.body as string);assert(body.items.length===0,'refund kept the paid item');assert(body.vip_until===null,'refund kept VIP');updates++;return new Response(null,{status:204});
    }) as typeof fetch;
    const result=await handleWebhook(new Request('https://example.test',{method:'POST',headers:{Authorization:'Bearer test-secret'},body:JSON.stringify({event:{type:'CANCELLATION',app_user_id:'00000000-0000-4000-8000-000000000001',items:['gold']}})}));
    assert(result.status===200 && updates===1,'refund not synchronized');
  }finally{globalThis.fetch=old;}
});
