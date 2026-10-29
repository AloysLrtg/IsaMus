// Run with PGLITE_MODULE pointing to an installed @electric-sql/pglite module.
// Uses a fresh in-memory database and synthetic identities only.
import { readFileSync, readdirSync } from 'node:fs';
import assert from 'node:assert/strict';
const { PGlite } = await import(process.env.PGLITE_MODULE || '@electric-sql/pglite');
const db = new PGlite();
await db.exec(`
create role anon; create role authenticated; create role service_role bypassrls; create role supabase_auth_admin;
create schema auth; create schema realtime;
create table auth.users(id uuid primary key, raw_user_meta_data jsonb default '{}');
grant usage on schema auth to supabase_auth_admin; grant insert,select on auth.users to supabase_auth_admin;
create table auth.sessions(id uuid primary key default gen_random_uuid(),user_id uuid references auth.users(id));
create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
create function auth.jwt() returns jsonb language sql stable as $$select coalesce(nullif(current_setting('request.jwt.claims',true),''),'{}')::jsonb$$;
grant usage on schema auth,realtime to authenticated,anon,service_role;
create function realtime.topic() returns text language sql stable as $$select current_setting('realtime.topic',true)$$;
create table realtime.messages(id bigint,extension text);
alter table realtime.messages enable row level security;
grant select,insert on realtime.messages to authenticated;
create table public.profiles(id uuid primary key references auth.users(id),username text not null unique,elo integer default 1200,games_played integer default 0,games_won integer default 0,created_at timestamptz default now());
create table public.games(id uuid primary key default gen_random_uuid(),join_code text not null unique,status text default 'waiting',players jsonb default '[]',game_state jsonb,created_at timestamptz default now(),mode text default 'casual');
alter table public.profiles enable row level security; alter table public.games enable row level security;
create policy "Lecture publique" on public.profiles for select using(true);
create policy "Création par l'utilisateur" on public.profiles for insert with check(auth.uid()=id);
create policy "Mise à jour par l'utilisateur" on public.profiles for update using(auth.uid()=id);
create policy "Allow all access" on public.games for all using(true);
grant all on public.games,public.profiles to anon,authenticated;
create publication supabase_realtime;
`);

const user='00000000-0000-4000-8000-000000000001';
for(const file of readdirSync(new URL('../supabase/migrations/',import.meta.url)).filter(f=>f.endsWith('.sql')).sort()) {
 if(file.includes('shop_categories_free_backgrounds')) {
  await db.exec(`insert into auth.users(id,raw_user_meta_data) values('${user}','{"username":"Customization test"}');
   insert into inventory(user_id,cosmetic_id) values('${user}','shop_hair_mullet');
   update profiles set coins=700,avatar_config=jsonb_set(avatar_config,'{hair}','3') where id='${user}';`);
 }
 await db.exec(readFileSync(new URL('../supabase/migrations/'+file,import.meta.url),'utf8'));
}
assert.equal((await db.query("select count(*)::int n from cosmetics where id='shop_hair_mullet'")).rows[0].n,0);
const profile=(await db.query('select coins,avatar_config from profiles where id=$1',[user])).rows[0];
assert.equal(profile.coins,1000); assert.equal(profile.avatar_config.hair,0);
await db.query("select set_config('request.jwt.claim.sub',$1,false)",[user]);
for(let i=0;i<12;i++) await db.query("update profiles set avatar_config=jsonb_set(avatar_config,'{background_color}',$1::jsonb) where id=$2",[String(i),user]);
await assert.rejects(()=>db.query("update profiles set avatar_config=jsonb_set(avatar_config,'{glasses}','4') where id=$1",[user]));
await db.exec("select private.buy_shop_item('shop_glasses_round',200); select private.equip_cosmetic('shop_glasses_round');");
assert.equal((await db.query('select avatar_config from profiles where id=$1',[user])).rows[0].avatar_config.glasses,4);
console.log('Catalogue, remboursement Mulet, 12 fonds gratuits et équipement contrôlé : OK');
await assert.rejects(()=>db.query("update profiles set avatar_config=jsonb_set(avatar_config,'{hair}','5') where id=$1",[user]));
for(const [id,cost,style] of [['shop_hair_bald',100,4],['shop_hair_mohawk',250,5]]) {
 await db.query('select private.buy_shop_item($1,$2)',[id,cost]);
 await db.query('select private.equip_cosmetic($1)',[id]);
 assert.equal((await db.query('select avatar_config from profiles where id=$1',[user])).rows[0].avatar_config.hair,style);
}
console.log('Achat et équipement Chauve/Crête, contrôle de propriété : OK');
await db.close();
