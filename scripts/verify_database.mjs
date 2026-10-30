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
let manualMonthApplied=false;
const monthlyParts=['league_avatar_ownership','league_results_and_finish_lock','shared_monthly_calendar','monthly_season_rollover'];
const migrationDir=new URL('../supabase/migrations/',import.meta.url);
for(const file of readdirSync(migrationDir).filter(f=>f.endsWith('.sql')).sort()) {
 if(file.includes('shop_categories_free_backgrounds') || file.includes('front_facing_hair_and_palette')) continue; // Legacy assertions precede retirement below.
 if(process.env.MANUAL_MONTHLY_SQL==='1' && monthlyParts.some(name=>file.includes(name))) {
  if(!manualMonthApplied) await db.exec(readFileSync(new URL('./manual_monthly_seasons.sql',import.meta.url),'utf8'));
  manualMonthApplied=true; continue;
 }
 if(file.includes('layered_avatars')) {
  await db.exec(`insert into auth.users(id) values('00000000-0000-4000-8000-000000000006');
  insert into profiles(id,username,avatar_config) values('00000000-0000-4000-8000-000000000006','Migration', '{"skin":2,"eyes":1,"mouth":2,"head":1}');`);
 }
 if(file.includes('avatar_palette_and_mode_statistics')) {
  await db.exec(`insert into auth.users(id) values('00000000-0000-4000-8000-000000000006');
  insert into profiles(id,username,elo,games_played,games_won,avatar_config) values('00000000-0000-4000-8000-000000000006','Stats migration',1300,4,2,'{"skin":2,"hair":1,"glasses":2,"top":1}');
  insert into games(join_code,status,players) values('OLDST','finished','[{"id":"00000000-0000-4000-8000-000000000006","seat":0},{"id":"bot_1","is_bot":true},{"id":"bot_2","is_bot":true},{"id":"bot_3","is_bot":true}]');
  insert into match_results(game_id,user_id,won,mode,elo_before,elo_after) select id,'00000000-0000-4000-8000-000000000006',false,'casual',1400,1300 from games where join_code='OLDST';`);
 }
 if(file.includes('spaced_free_season_rewards')) {
  await db.exec(`insert into auth.users(id,raw_user_meta_data) values('00000000-0000-4000-8000-000000000060','{"username":"Legacy season"}');
   update profiles set level=30,vip_expires_at=now()+interval '1 day' where username='Legacy season';
   select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000060',false);
   select private.claim_season_pass('season_1',1,false);
   select private.claim_season_pass('season_1',15,true);`);
 }
 if(file.includes('shop_accessories_and_card_patterns')) {
  await db.exec(`insert into auth.users(id,raw_user_meta_data) values('00000000-0000-4000-8000-000000000080','{"username":"Retired borders"}');
  insert into inventory(user_id,cosmetic_id) values('00000000-0000-4000-8000-000000000080','shop_border_emerald'),('00000000-0000-4000-8000-000000000080','shop_border_amethyst');
  update profiles set coins=5,avatar_config=avatar_config||'{"border":"emerald"}' where username='Retired borders';`);
 }
 if(file.includes('xp_only_matches_and_quests')) {
  await db.exec(`insert into auth.users(id,raw_user_meta_data) values('00000000-0000-4000-8000-000000000091','{"username":"Legacy coin quest"}');
  update profiles set coins=777,level=2,xp=410 where username='Legacy coin quest';
  insert into user_progress(user_id,quest_id,week_start,progress,rewarded) values('00000000-0000-4000-8000-000000000091','play_week',date_trunc('week',now() at time zone 'UTC')::date,5,true);`);
 }
 if(process.env.MANUAL_XP_SQL==='1' && file.includes('xp_only_matches_and_quests')) await db.exec(readFileSync(new URL('./manual_xp_economy.sql',import.meta.url),'utf8'));
 else if(process.env.MANUAL_SHOP_SQL==='1' && file.includes('shop_accessories_and_card_patterns')) await db.exec(readFileSync(new URL('./manual_shop_accessories.sql',import.meta.url),'utf8'));
 else if(file.includes('visible_keinuak_and_random_solo_bots')) {
  await db.exec(`insert into auth.users(id,raw_user_meta_data) values('00000000-0000-4000-8000-000000000093','{"username":"Opaque glasses"}');
  insert into inventory(user_id,cosmetic_id) values('00000000-0000-4000-8000-000000000093','shop_glasses_gold'),('00000000-0000-4000-8000-000000000093','shop_hat_cap');
  update profiles set coins=12,avatar_config=avatar_config||'{"glasses":3,"exclusive_hat":"cap"}' where username='Opaque glasses';`);
 }
 if(process.env.MANUAL_DUO_SQL==='1' && file.includes('unique_friend_requests_and_duo_invitations')) await db.exec(readFileSync(new URL('./manual_duo_invitations.sql',import.meta.url),'utf8'));
 else if(process.env.MANUAL_SOCIAL_SQL==='1' && file.includes('social_tabs_notifications_and_blocks')) await db.exec(readFileSync(new URL('./manual_social_tabs_and_blocks.sql',import.meta.url),'utf8'));
 else if(process.env.MANUAL_MATCHMAKING_SQL==='1' && file.includes('public_matchmaking_and_private_teams')) await db.exec(readFileSync(new URL('./manual_matchmaking_and_teams.sql',import.meta.url),'utf8'));
 else await db.exec(readFileSync(new URL(file,migrationDir),'utf8'));
 if(file.includes('visible_keinuak_and_random_solo_bots')) {
  const beforeRefund=(await db.query("select coins,avatar_config from profiles where username='Opaque glasses'")).rows[0];
  assert.equal(beforeRefund.coins,262);assert.equal(beforeRefund.avatar_config.glasses,0);assert.equal(beforeRefund.avatar_config.exclusive_hat,'cap');
  assert.equal((await db.query("select count(*)::int n from cosmetics where id='shop_glasses_gold'")).rows[0].n,0);
  assert.equal((await db.query("select count(*)::int n from inventory where cosmetic_id='shop_glasses_gold'")).rows[0].n,0);
  const cleanup=readFileSync(new URL(file,migrationDir),'utf8').split('-- Existing transparent')[0];await db.exec(cleanup);
  assert.equal((await db.query("select coins from profiles where username='Opaque glasses'")).rows[0].coins,262);
  await db.exec("delete from profiles where username='Opaque glasses';delete from auth.users where id='00000000-0000-4000-8000-000000000093'");
 }

 if(file.includes('xp_only_matches_and_quests')) {
  const historical=(await db.query("select coins,level,xp from profiles where username='Legacy coin quest'")).rows[0];
  assert.deepEqual(historical,{coins:777,level:2,xp:410});
  await db.exec("select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000091',false)");
  assert.deepEqual((await db.query("select claim_quest_reward('play_week') r")).rows[0].r,{xp:0,already_claimed:true});
  assert.deepEqual((await db.query("select coins,level,xp from profiles where username='Legacy coin quest'")).rows[0],historical);
  await db.exec("delete from profiles where username='Legacy coin quest'; delete from auth.users where id='00000000-0000-4000-8000-000000000091'; select set_config('request.jwt.claim.sub','',false)");
 }
 if(file.includes('shop_accessories_and_card_patterns')) {
   const retired=(await db.query("select coins,avatar_config from profiles where username='Retired borders'")).rows[0];
   assert.equal(retired.coins,705);assert.equal(retired.avatar_config.border,'none');
   assert.equal((await db.query("select count(*)::int n from inventory where user_id='00000000-0000-4000-8000-000000000080'")).rows[0].n,0);
   await db.exec("delete from profiles where username='Retired borders'; delete from auth.users where id='00000000-0000-4000-8000-000000000080'");
 }

 if(file.includes('spaced_free_season_rewards')) {
  assert.equal((await db.query("select coins from profiles where username='Legacy season'")).rows[0].coins,645);
  assert.equal((await db.query("select count(*)::int n from season_pass_claims where user_id='00000000-0000-4000-8000-000000000060'")).rows[0].n,2);
  await db.exec(`select set_config('request.jwt.claims','{"role":"service_role"}',false);
   select private.sync_inventory('00000000-0000-4000-8000-000000000060',ARRAY[]::text[]);`);
  assert.equal((await db.query("select count(*)::int n from inventory where user_id='00000000-0000-4000-8000-000000000060' and cosmetic_id='gold'")).rows[0].n,1);
  await db.exec("delete from profiles where username='Legacy season'; delete from auth.users where id='00000000-0000-4000-8000-000000000060'; select set_config('request.jwt.claim.sub','',false); select set_config('request.jwt.claims','{}',false)");
 }
 if(file.includes('avatar_palette_and_mode_statistics')) {
  const migrated=(await db.query("select * from profiles where username='Stats migration'")).rows[0];
  assert.equal(migrated.peak_elo,1400);assert.equal(migrated.solo_played,1);assert.equal(migrated.solo_won,0);
  assert.equal(migrated.games_played,4);assert.equal(migrated.avatar_config.hair_color,1);assert.equal(migrated.avatar_config.background_color,0);
  await db.exec("delete from games where join_code='OLDST'; delete from profiles where username='Stats migration'; delete from auth.users where id='00000000-0000-4000-8000-000000000006'");
 }
 if(file.includes('layered_avatars')) {
  assert.deepEqual((await db.query("select avatar_config from profiles where username='Migration'")).rows[0].avatar_config, {skin:2,hair:1,glasses:1,top:2});
  await db.exec("delete from profiles where username='Migration'; delete from auth.users where id='00000000-0000-4000-8000-000000000006'");
 }
}
const ids = [1,2,3,4,5].map(n => `00000000-0000-4000-8000-${String(n).padStart(12,'0')}`);
for (const [i,id] of ids.entries()) {
 await db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2::jsonb)',[id,JSON.stringify({username:`Test ${i}`})]);
}
await db.exec("update profiles set elo=1200,peak_elo=1200 where username like 'Test %'");
let checks = 0;
const finishDefinition=(await db.query("select pg_get_functiondef('private.finish_game(uuid)'::regprocedure) d")).rows[0].d;
const rolloverDefinition=(await db.query("select pg_get_functiondef('private.end_current_season()'::regprocedure) d")).rows[0].d;
assert.equal(finishDefinition.match(/pg_advisory_xact_lock_shared\((\d+)\)/)[1],rolloverDefinition.match(/pg_advisory_xact_lock\((\d+)\)/)[1]);checks++;

// Auth signup creates profiles transactionally; metadata cannot set scores or privileges.
const newUser='00000000-0000-4000-8000-000000000010';
await db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2::jsonb)',[newUser,JSON.stringify({username:'  Nouvelle Ane  ',elo:9999,ranked_won:999,role:'admin',level:99,xp:499})]);
const createdProfile=(await db.query('select * from profiles where id=$1',[newUser])).rows[0];
assert.equal(createdProfile.username,'Nouvelle Ane');checks++;
assert.equal(createdProfile.elo,800);assert.equal(createdProfile.ranked_won,0);checks++;
assert.equal(createdProfile.level,1);assert.equal(createdProfile.xp,0);checks++;
assert.equal(createdProfile.sound_enabled,true);assert.equal(createdProfile.peak_elo,800);checks++;
await assert.rejects(()=>db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2::jsonb)',['00000000-0000-4000-8000-000000000011',JSON.stringify({username:'Nouvelle Ane'})]));checks++;
assert.equal((await db.query("select count(*)::int n from auth.users where id='00000000-0000-4000-8000-000000000011'")).rows[0].n,0);checks++;
await assert.rejects(()=>db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2::jsonb)',['00000000-0000-4000-8000-000000000012',JSON.stringify({username:' '.repeat(3)})]));checks++;
await assert.rejects(()=>db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2::jsonb)',['00000000-0000-4000-8000-000000000012',JSON.stringify({username:'x'.repeat(25)})]));checks++;
for (const suffix of ['013','014']) {
 const id='00000000-0000-4000-8000-000000000'+suffix;
 await db.query('insert into auth.users(id) values($1)',[id]);
 const p=(await db.query('select username from profiles where id=$1',[id])).rows[0];
 assert.match(p.username,/^Joueur [a-z0-9]{4}$/);assert.equal(p.username.length,11);checks++;
}
assert.equal((await db.query("select count(distinct username)::int n from profiles where id in ('00000000-0000-4000-8000-000000000013','00000000-0000-4000-8000-000000000014')")).rows[0].n,2);checks++;
assert.equal((await db.query("select username from profiles where id='00000000-0000-4000-8000-000000000013'")).rows[0].username,'Joueur 0000');checks++;
// A registered player may already own the first four UUID characters.
const reservedGuestId='bbbbbbbb-0000-4000-8000-000000000001';
await db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2::jsonb)',[reservedGuestId,JSON.stringify({username:'Joueur abcd'})]);
const collisionIds=Array.from({length:32},(_,i)=>`abcd0000-0000-4000-8000-${String(i+1).padStart(12,'0')}`);
for(const id of collisionIds) {
 await db.query('insert into auth.users(id) values($1)',[id]);
 const name=(await db.query('select username from profiles where id=$1',[id])).rows[0].username;
 assert.match(name,/^Joueur [a-z0-9]{4}$/);assert.equal(name.length,11);
 assert.notEqual(name,'Joueur abcd');checks++;
}
assert.equal((await db.query('select count(distinct username)::int n from profiles where id=any($1::uuid[])',[collisionIds])).rows[0].n,32);checks++;
assert.equal((await db.query('select username from profiles where id=$1',[reservedGuestId])).rows[0].username,'Joueur abcd');checks++;
await db.query('delete from profiles where id=any($1::uuid[])',[[reservedGuestId,...collisionIds]]);
await db.query('delete from auth.users where id=any($1::uuid[])',[[reservedGuestId,...collisionIds]]);
assert.equal((await db.query("select has_function_privilege('anon','private.create_profile_for_auth_user()','EXECUTE') allowed")).rows[0].allowed,false);checks++;
assert.equal((await db.query("select has_function_privilege('authenticated','private.create_profile_for_auth_user()','EXECUTE') allowed")).rows[0].allowed,false);checks++;
await db.exec("delete from profiles where id in ('00000000-0000-4000-8000-000000000010','00000000-0000-4000-8000-000000000013','00000000-0000-4000-8000-000000000014'); delete from auth.users where id in ('00000000-0000-4000-8000-000000000010','00000000-0000-4000-8000-000000000013','00000000-0000-4000-8000-000000000014')");
// Exercise the real Auth role boundary: it has no direct profiles privileges.
await db.exec("set role supabase_auth_admin");
await assert.rejects(()=>db.exec("insert into public.profiles(id,username) values('00000000-0000-4000-8000-000000000015','Auth role')"));checks++;
await db.exec(`insert into auth.users(id,raw_user_meta_data) values('00000000-0000-4000-8000-000000000015','{"username":"Auth role"}')`);
await db.exec('reset role');
assert.equal((await db.query("select username from profiles where id='00000000-0000-4000-8000-000000000015'")).rows[0].username,'Auth role');checks++;
await db.exec("update auth.users set raw_user_meta_data='{\"username\":\"Forged update\",\"elo\":9999}' where id='00000000-0000-4000-8000-000000000015'");
assert.equal((await db.query("select username from profiles where id='00000000-0000-4000-8000-000000000015'")).rows[0].username,'Auth role');checks++;
await db.exec("delete from profiles where id='00000000-0000-4000-8000-000000000015'; delete from auth.users where id='00000000-0000-4000-8000-000000000015'");

async function as(id, fn, role='authenticated') {
 await db.exec('begin');
 try {
  await db.exec(`set local role ${role}`);
  await db.query("select set_config('request.jwt.claim.sub',$1,true),set_config('request.jwt.claims',$2,true)",[id||'',JSON.stringify({sub:id,role})]);
  const result=await fn();await db.exec('commit');return result;
 }catch(e){await db.exec('rollback');throw e;}
}
async function denied(id,sql,args=[]){await assert.rejects(()=>as(id,()=>db.query(sql,args)));checks++;}
// Language is constrained, writable only by its owner, and defaults for old profiles.
assert.equal((await db.query('select language from profiles where id=$1',[ids[0]])).rows[0].language,'fr');checks++;
for(const language of ['fr','eu','es','en']) {
 await as(ids[0],()=>db.query('update profiles set language=$1 where id=$2',[language,ids[0]]));
 assert.equal((await db.query('select language from profiles where id=$1',[ids[0]])).rows[0].language,language);checks++;
}
assert.equal((await as(ids[1],()=>db.query("update profiles set language='es' where id=$1 returning id",[ids[0]]))).rows.length,0);checks++;
await denied(ids[0],"update profiles set language='de' where id=$1",[ids[0]]);
await denied(ids[0],"update profiles set language=null where id=$1",[ids[0]]);
assert.equal((await as(null,()=>db.query("update profiles set language='eu' where id=$1 returning id",[ids[0]]))).rows.length,0);checks++;
await assert.rejects(()=>as(null,()=>db.query("update profiles set language='eu' where id=$1",[ids[0]]),'anon'));checks++;

assert.deepEqual((await db.query('select avatar_config from profiles where id=$1',[ids[0]])).rows[0].avatar_config,{skin:0,glasses:0,top:0,hair:0,background_color:0,hair_color:0,border:'none',exclusive_hat:'none'});checks++;
await as(ids[0],()=>db.query('update profiles set avatar_config=$1 where id=$2',[JSON.stringify({skin:2,glasses:1,top:2,hair:1,background_color:5,hair_color:4}),ids[0]]));
assert.deepEqual((await db.query('select avatar_config from profiles where id=$1',[ids[0]])).rows[0].avatar_config,{skin:2,glasses:1,top:2,hair:1,background_color:5,hair_color:4,border:'none',exclusive_hat:'none'});checks++;
assert.equal((await as(ids[1],()=>db.query("update profiles set avatar_config='{\"skin\":1,\"glasses\":1,\"top\":1,\"hair\":1}' where id=$1 returning id",[ids[0]]))).rows.length,0);checks++;
for(const bad of [null,[],{}, {skin:0,glasses:0,top:0,hair:3}, {skin:'0',glasses:0,top:0,hair:0,background_color:0,hair_color:0}, {skin:0,glasses:0,top:0,hair:0,extra:1}, {skin:0,glasses:0,top:0,hair:0,background_color:6}, {skin:0,glasses:0,top:0,hair:0,hair_color:6}]) {
 await denied(ids[0],'update profiles set avatar_config=$1 where id=$2',[JSON.stringify(bad&&typeof bad==='object'&&!Array.isArray(bad)?{background_color:0,hair_color:0,...bad}:bad),ids[0]]);
}
await denied(ids[0],"update profiles set elo=9999 where id=$1",[ids[0]]);
await denied(ids[0],"update profiles set games_won=99 where id=$1",[ids[0]]);
await denied(ids[0],"insert into inventory(user_id,cosmetic_id) values($1,'gold')",[ids[0]]);
await denied(ids[0],"select public.sync_inventory($1,array['gold'])",[ids[0]]);
await denied(ids[0],"select public.erase_account($1)",[ids[1]]);
const game=(await as(ids[0],()=>db.query("select find_public_game('ranked') r"))).rows[0].r.id;
for(const id of ids.slice(1,4)) await as(id,()=>db.query("select find_public_game('ranked')"));
const topic=`game-signs:${game}:${ids[0]}`;
assert.equal((await as(ids[0],()=>db.query('select private.can_use_game_sign_topic($1,true) allowed',[topic]))).rows[0].allowed,true);checks++;
assert.equal((await as(ids[1],()=>db.query('select private.can_use_game_sign_topic($1,false) allowed',[topic]))).rows[0].allowed,true);checks++;
assert.equal((await as(ids[1],()=>db.query('select private.can_use_game_sign_topic($1,true) allowed',[topic]))).rows[0].allowed,false);checks++;
assert.equal((await as(ids[4],()=>db.query('select private.can_use_game_sign_topic($1,false) allowed',[topic]))).rows[0].allowed,false);checks++;
assert.equal((await as(ids[0],()=>db.query("select private.can_use_game_sign_topic('game-signs:malformed:fake',true) allowed"))).rows[0].allowed,false);checks++;
await as(ids[0],async()=>{await db.query("select set_config('realtime.topic',$1,true)",[topic]);await db.exec("insert into realtime.messages(id,extension) values(1,'broadcast')");});checks++;
await assert.rejects(()=>as(ids[1],async()=>{await db.query("select set_config('realtime.topic',$1,true)",[topic]);await db.exec("insert into realtime.messages(id,extension) values(2,'broadcast')");}));checks++;
await assert.rejects(()=>as(ids[4],async()=>{await db.query("select set_config('realtime.topic',$1,true)",[`game-signs:${game}:${ids[4]}`]);await db.exec("insert into realtime.messages(id,extension) values(3,'broadcast')");}));checks++;
await denied(ids[4],"select join_game('TEST1')");
assert.equal((await as(ids[4],()=>db.query('select * from games where id=$1',[game]))).rows.length,0);checks++;
await denied(ids[1],"update games set game_state='{}' where id=$1",[game]);
await denied(ids[1],"select publish_game_state($1,$2)",[game,JSON.stringify({version:1,lastActionSeat:0,currentPlayer:1})]);
const finalState={signs:{'0':'twoKings'},signRevisions:{'0':3},version:1,phase:'gameOver',tantto:[40,10],manches:[0,0],currentPlayer:0,lastActionSeat:0,players:ids.slice(0,4).map((id,seat)=>({seat,name:`Test ${seat}`}))};
await as(ids[0],()=>db.query('select publish_game_state($1,$2)',[game,JSON.stringify(finalState)]));
const persisted=(await db.query('select game_state from games where id=$1',[game])).rows[0].game_state;
assert.equal('signs' in persisted,false);assert.equal('signRevisions' in persisted,false);assert.equal(persisted.version,1);checks++;
await denied(ids[1],'select finish_game($1)',[game]);
await as(ids[0],()=>db.query('select finish_game($1)',[game]));
await as(ids[0],()=>db.query('select finish_game($1)',[game]));
const results=(await db.query('select * from match_results where game_id=$1 order by user_id',[game])).rows;
assert.equal(results.length,4);assert.deepEqual(results.map(r=>r.elo_after),[1216,1184,1216,1184]);checks+=2;
assert.deepEqual((await db.query('select games_played from profiles where id=any($1::uuid[])',[ids.slice(0,4)])).rows.map(r=>r.games_played),[1,1,1,1]);checks++;
assert.equal((await as(ids[0],()=>db.query('select private.can_use_game_sign_topic($1,true) allowed',[topic]))).rows[0].allowed,true);checks++;
assert.equal((await as(ids[4],()=>db.query('select private.can_use_game_sign_topic($1,false) allowed',[topic]))).rows[0].allowed,false);checks++;
await as(ids[0],async()=>{await db.query("select set_config('realtime.topic',$1,true)",[topic]);await db.exec("insert into realtime.messages(id,extension) values(91,'broadcast')");});checks++;
const rankedStats=(await db.query('select ranked_played,ranked_won,peak_elo from profiles where id=any($1::uuid[]) order by id',[ids.slice(0,4)])).rows;
assert.deepEqual(rankedStats.map(p=>p.ranked_played),[1,1,1,1]);checks++;
assert.deepEqual(rankedStats.map(p=>p.ranked_won),[1,0,1,0]);checks++;
assert.deepEqual(rankedStats.map(p=>p.peak_elo),[1216,1200,1216,1200]);checks++;
for(const column of ['peak_elo','casual_played','casual_won','ranked_played','ranked_won','solo_played','solo_won']) await denied(ids[0],`update profiles set ${column}=9999 where id=$1`,[ids[0]]);
const friend=await as(ids[0],async()=>(await db.query('insert into friendships(user_id_1,user_id_2) values($1,$2) returning id',[ids[0],ids[1]])).rows[0].id);
const rejectedUpdate=await as(ids[0],()=>db.query("update friendships set status='accepted' where id=$1 returning id",[friend]));
assert.equal(rejectedUpdate.rows.length,0);checks++;
await as(ids[1],()=>db.query("update friendships set status='accepted' where id=$1",[friend]));
assert.equal((await as(ids[2],()=>db.query('select * from friendships'))).rows.length,0);checks++;
await denied(ids[1],'insert into friendships(user_id_1,user_id_2) values($1,$2)',[ids[1],ids[0]]);
// Social card compatibility aliases and requester/recipient permissions.
assert.deepEqual((await as(ids[0],()=>db.query('select sender_id,receiver_id from friendships where id=$1',[friend]))).rows[0],{sender_id:ids[0],receiver_id:ids[1]});checks++;
await denied(ids[0],'insert into friendships(user_id_1,user_id_2) values($1,$2)',[ids[2],ids[3]]);
await denied(ids[0],'insert into friendships(user_id_1,user_id_2) values($1,$1)',[ids[0]]);
await denied(ids[0],"insert into friendships(user_id_1,user_id_2,status) values($1,$2,'accepted')",[ids[0],ids[3]]);
await denied(ids[0],'update friendships set sender_id=$1 where id=$2',[ids[2],friend]);
const declineFriend=await as(ids[2],async()=>(await db.query('insert into friendships(user_id_1,user_id_2) values($1,$2) returning id',[ids[2],ids[3]])).rows[0].id);
assert.equal((await as(ids[2],()=>db.query("update friendships set status='declined' where id=$1 returning id",[declineFriend]))).rows.length,0);checks++;
assert.equal((await as(ids[4],()=>db.query("update friendships set status='accepted' where id=$1 returning id",[declineFriend]))).rows.length,0);checks++;
await as(ids[3],()=>db.query("update friendships set status='declined' where id=$1",[declineFriend]));
assert.equal((await as(ids[2],()=>db.query('select status from friendships where id=$1',[declineFriend]))).rows[0].status,'declined');checks++;
assert.equal((await as(ids[0],()=>db.query('select * from friendships where id=$1',[declineFriend]))).rows.length,0);checks++;
assert.equal((await as(ids[1],()=>db.query("update friendships set status='declined' where id=$1 returning id",[friend]))).rows.length,0);checks++;
await assert.rejects(()=>as(null,()=>db.query('select * from friendships'),'anon'));checks++;
const privateGame=await as(ids[0],async()=> (await db.query("insert into games(join_code,mode,players) values('TEST2','private',$1) returning id",[JSON.stringify([{id:ids[0],name:'Test 0',seat:0,is_host:true}])])).rows[0].id);
await denied(ids[0],'select invite_friend($1,$2)',[ids[2],privateGame]);
await as(ids[0],()=>db.query('select invite_friend($1,$2)',[ids[1],privateGame]));
const invitation=(await as(ids[1],()=>db.query('select * from game_invitations'))).rows[0].id;
await denied(ids[2],'select accept_invitation($1)',[invitation]);
await as(ids[1],()=>db.query('select accept_invitation($1)',[invitation]));
assert.equal((await db.query('select jsonb_array_length(players) as count from games where id=$1',[privateGame])).rows[0].count,2);checks++;
await denied(ids[0],"select equip_cosmetic('gold')");
await as(ids[0],()=>db.query("select equip_cosmetic('ocean')"));
await as(null,()=>db.query('select sync_inventory($1,$2)',[ids[0],['gold']]),'service_role');
await as(ids[0],()=>db.query("select equip_cosmetic('gold')"));
await as(null,()=>db.query('select sync_inventory($1,$2)',[ids[0],[]]),'service_role');
assert.equal((await db.query('select card_back from profiles where id=$1',[ids[0]])).rows[0].card_back,'classic');checks++;
await denied(ids[1],'select close_game($1)',[privateGame]);
await denied(ids[4],'select close_game($1)',[privateGame]);
await denied(null,'select close_game($1)',[privateGame]);
await as(ids[0],()=>db.query('select close_game($1)',[privateGame]));
await as(ids[0],()=>db.query('select close_game($1)',[privateGame]));
assert.equal((await db.query('select status from games where id=$1',[privateGame])).rows[0].status,'cancelled');checks++;
await denied(ids[0],'select publish_game_state($1,$2)',[privateGame,JSON.stringify(finalState)]);
await denied(ids[0],'select finish_game($1)',[privateGame]);
await denied(ids[2],"select join_game('TEST2')");
await as(ids[0],()=>db.query('select close_game($1)',[game]));
assert.equal((await db.query('select status from games where id=$1',[game])).rows[0].status,'finished');checks++;
const botsGame=await as(ids[1],async()=> (await db.query("insert into games(join_code,mode,players) values('BOTS1','casual',$1) returning id",[JSON.stringify([{id:ids[1],name:'Test 1',seat:0,is_host:true}])])).rows[0].id);
await denied(ids[0],'select start_with_bots($1)',[botsGame]);
await as(ids[1],()=>db.query('select start_with_bots($1)',[botsGame]));
const roster=(await db.query('select players from games where id=$1',[botsGame])).rows[0].players;
assert.equal(roster.length,4);checks++;
assert.deepEqual(roster.slice(1).map(p=>p.name).sort(),['Mikel','Patxi','Txomin']);checks++;
assert.deepEqual(roster.slice(1).map(p=>p.bot_personality).sort(),['balanced','bluffer','conservative']);checks++;
assert.deepEqual([...roster.slice(1)].sort((a,b)=>['Patxi','Mikel','Txomin'].indexOf(a.name)-['Patxi','Mikel','Txomin'].indexOf(b.name)).map(p=>p.avatar_config),[
 {skin:0,hair:0,glasses:1,top:2,background_color:1,hair_color:4},
 {skin:1,hair:0,glasses:0,top:1,background_color:0,hair_color:0},
 {skin:2,hair:2,glasses:2,top:0,background_color:3,hair_color:5}
]);checks++;

assert.equal(new Set(roster.map(p=>JSON.stringify(p.avatar_config))).size,4);checks++;
for(const bot of roster.slice(1)) {
 assert.equal(bot.is_bot,true);
 assert.deepEqual(Object.keys(bot.avatar_config).sort(),['background_color','glasses','hair','hair_color','skin','top']);
 assert.equal(Object.entries(bot.avatar_config).every(([key,n])=>Number.isInteger(n)&&n>=0&&n<(key.endsWith('_color')?6:3)),true);
}checks++;
await as(ids[1],()=>db.query('select start_with_bots($1)',[botsGame]));
assert.deepEqual((await db.query('select players from games where id=$1',[botsGame])).rows[0].players,roster);checks++;
const mixed=await as(ids[0],async()=> (await db.query("insert into games(join_code,mode,players) values('BOTS2','private',$1) returning id",[JSON.stringify([{id:ids[0],name:'Test 0',seat:0,is_host:true}])])).rows[0].id);
await as(ids[1],()=>db.query("select join_game('BOTS2')"));
await as(ids[0],()=>db.query('select start_with_bots($1)',[mixed]));
await as(ids[0],()=>db.query('select start_private_game($1)',[mixed]));
const mixedRoster=(await db.query('select players from games where id=$1',[mixed])).rows[0].players;
assert.deepEqual(mixedRoster.slice(0,2).map(p=>p.id),[ids[0],ids[1]]);checks++;
assert.equal(new Set(mixedRoster.slice(2).map(p=>p.bot_personality)).size,2);checks++;
// Legacy partial waiting roster, seeded only by the isolated DB owner.
const partial=(await db.query("insert into games(join_code,mode,players) values('BOTSP','casual',$1) returning id",[JSON.stringify([{id:ids[0],name:'Test 0',seat:0,is_host:true},{id:'bot_1',seat:1,is_bot:true,name:'Old bot',bot_personality:'bluffer'}])])).rows[0].id;
await as(ids[0],()=>db.query('select start_with_bots($1)',[partial]));
const partialRoster=(await db.query('select players from games where id=$1',[partial])).rows[0].players;
assert.deepEqual(partialRoster.slice(1).map(p=>p.name).sort(),['Mikel','Patxi','Txomin']);checks++;
assert.equal(new Set(partialRoster.slice(1).map(p=>p.bot_personality)).size,3);checks++;
await as(ids[1],()=>db.query('select publish_game_state($1,$2)',[botsGame,JSON.stringify({...finalState,players:roster})]));
await as(ids[1],()=>db.query('select finish_game($1)',[botsGame]));
await as(ids[1],()=>db.query('select finish_game($1)',[botsGame]));
const solo=(await db.query('select solo_played,solo_won,ranked_played,elo,peak_elo from profiles where id=$1',[ids[1]])).rows[0];
assert.deepEqual(solo,{solo_played:1,solo_won:1,ranked_played:1,elo:1184,peak_elo:1200});checks++;
assert.equal((await db.query('select mode from match_results where game_id=$1',[botsGame])).rows[0].mode,'solo');checks++;
for(const mode of ['casual','private']) {
 const room=await as(ids[2],async()=>(await db.query('insert into games(join_code,mode,players) values($1,$2,$3) returning id',[mode.toUpperCase(),mode,JSON.stringify([{id:ids[2],name:'Test 2',seat:0,is_host:true}])])).rows[0].id);
 if(mode==='private') await as(ids[3],()=>db.query('select join_game($1)',[mode.toUpperCase()]));
 else await db.query('update games set players=players||$1::jsonb where id=$2',[JSON.stringify([{id:ids[3],seat:1,is_host:false,is_bot:false}]),room]);
 await as(ids[2],()=>db.query('select start_with_bots($1)',[room]));
 if(mode==='private') await as(ids[2],()=>db.query('select start_private_game($1)',[room]));
 const roomPlayers=(await db.query('select players from games where id=$1',[room])).rows[0].players;
 await as(ids[2],()=>db.query('select publish_game_state($1,$2)',[room,JSON.stringify({...finalState,players:roomPlayers})]));
 await as(ids[2],()=>db.query('select finish_game($1)',[room]));
}
assert.deepEqual((await db.query('select casual_played,casual_won,solo_played,peak_elo from profiles where id=$1',[ids[2]])).rows[0],{casual_played:2,casual_won:2,solo_played:0,peak_elo:1216});checks++;
assert.equal((await db.query('select casual_won from profiles where id=$1',[ids[3]])).rows[0].casual_won,0);checks++;
// Public matchmaking and private team draft: no public room is joined by code.
const queueUsers=Array.from({length:10},(_,i)=>`00000000-0000-4000-8000-${String(100+i).padStart(12,'0')}`);
for(const [i,id] of queueUsers.entries()) await db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2)',[id,JSON.stringify({username:`Queue ${i}`})]);
const findPublic=(i,mode='casual')=>as(queueUsers[i],async()=>(await db.query('select find_public_game($1) value',[mode])).rows[0].value);
const leaveQueue=(i,id)=>as(queueUsers[i],()=>db.query('select leave_public_queue($1)',[id]));
for(const [sql,args] of [["select find_public_game('casual')",[]],['select leave_public_queue($1)',[game]],['select choose_private_team($1,0)',[game]],['select start_private_game($1)',[game]]]) {
 await assert.rejects(()=>as(null,()=>db.query(sql,args),'anon'));checks++;
}
let queue=await findPublic(0);
assert.equal(queue.is_public,true);checks++;
assert.equal(queue.players[0].name,'Queue 0');checks++;
assert.equal(queue.local_seat,0);checks++;
const again=await findPublic(0);
assert.equal(again.id,queue.id);checks++;
assert.equal(again.players.length,1);checks++;
await denied(queueUsers[0],"select find_public_game('ranked')");
await denied(queueUsers[0],"select find_public_game('private')");
await denied(queueUsers[0],"select find_public_game(null)");
await denied(queueUsers[0],"update games set is_public=true where id=$1",[queue.id]);
const rankedQueue=await findPublic(1,'ranked');
assert.notEqual(rankedQueue.id,queue.id);checks++;
await leaveQueue(1,rankedQueue.id);
assert.equal((await db.query('select status from games where id=$1',[rankedQueue.id])).rows[0].status,'cancelled');checks++;
assert.equal((await findPublic(2)).id,queue.id);checks++;
await findPublic(3);
await leaveQueue(0,queue.id);
await leaveQueue(0,queue.id); // Network retries are harmless.
queue=(await db.query('select * from games where id=$1',[queue.id])).rows[0];
assert.equal(queue.status,'waiting');checks++;
assert.equal(queue.players[0].id,queueUsers[2]);checks++;
assert.equal(queue.players[0].seat,1);checks++;
assert.equal(queue.players.filter(p=>p.is_host).length,1);checks++;
assert.equal((await as(queueUsers[0],()=>db.query('select * from games where id=$1',[queue.id]))).rows.length,0);checks++;
await denied(queueUsers[2],'select start_with_bots($1)',[queue.id]);
await denied(queueUsers[2],'select choose_private_team($1,0)',[queue.id]);
await denied(queueUsers[2],'select start_private_game($1)',[queue.id]);
await denied(queueUsers[0],'select join_game($1)',[queue.join_code]);
assert.equal((await findPublic(4)).local_seat,0);checks++;
queue=await findPublic(5);
assert.equal(queue.status,'ready');checks++;
assert.equal(queue.players.length,4);checks++;
assert.equal(new Set(queue.players.map(p=>p.seat)).size,4);checks++;
assert.equal(queue.players.some(p=>p.is_bot),false);checks++;
await denied(queueUsers[2],'select leave_public_queue($1)',[queue.id]);
const overflow=await findPublic(6);
assert.notEqual(overflow.id,queue.id);checks++;
await leaveQueue(6,overflow.id);
await denied(queueUsers[4],'select publish_game_state($1,$2)',[queue.id,JSON.stringify({...finalState,lastActionSeat:0})]);
await as(queueUsers[2],()=>db.query('select publish_game_state($1,$2)',[queue.id,JSON.stringify({...finalState,lastActionSeat:1,players:queue.players})]));
assert.equal((await db.query('select status from games where id=$1',[queue.id])).rows[0].status,'playing');checks++;
await as(queueUsers[2],()=>db.query('select close_game($1)',[queue.id]));
const draft=await as(queueUsers[0],async()=>(await db.query("insert into games(join_code,mode,players) values('DRAFT','private',$1) returning id",[JSON.stringify([{id:queueUsers[0],name:'Queue 0',seat:0,is_host:true}])])).rows[0].id);
await as(queueUsers[0],()=>db.query('select choose_private_team($1,1)',[draft]));
await denied(queueUsers[0],'select start_private_game($1)',[draft]);
for(const i of [7,8,9]) await as(queueUsers[i],()=>db.query("select join_game('DRAFT')"));
let draftRow=(await db.query('select * from games where id=$1',[draft])).rows[0];
assert.equal(draftRow.status,'waiting');checks++;
assert.equal(draftRow.players[0].team,1);checks++;
await denied(queueUsers[6],'select choose_private_team($1,0)',[draft]);
await denied(queueUsers[0],'select choose_private_team($1,2)',[draft]);
await denied(queueUsers[7],'select start_private_game($1)',[draft]);
// A full room may be temporarily unbalanced; only 2+2 can start.
for(const i of [0,7,8]) await as(queueUsers[i],()=>db.query('select choose_private_team($1,0)',[draft]));
await as(queueUsers[9],()=>db.query('select choose_private_team($1,1)',[draft]));
await denied(queueUsers[0],'select start_private_game($1)',[draft]);
assert.equal((await db.query('select status from games where id=$1',[draft])).rows[0].status,'waiting');checks++;
await as(queueUsers[0],()=>db.query('select choose_private_team($1,1)',[draft]));
await as(queueUsers[0],()=>db.query('select start_private_game($1)',[draft]));
draftRow=(await db.query('select * from games where id=$1',[draft])).rows[0];
assert.equal(draftRow.status,'ready');checks++;
assert.equal(draftRow.players[0].seat,1);checks++;
assert.equal(draftRow.players[0].is_host,true);checks++;
assert.equal(draftRow.players.filter(p=>p.seat%2===0).length,2);checks++;
assert.equal(new Set(draftRow.players.map(p=>p.seat)).size,4);checks++;
await denied(queueUsers[0],'select choose_private_team($1,0)',[draft]);
await denied(queueUsers[7],'select publish_game_state($1,$2)',[draft,JSON.stringify({...finalState,lastActionSeat:0})]);
await as(queueUsers[0],()=>db.query('select publish_game_state($1,$2)',[draft,JSON.stringify({...finalState,lastActionSeat:1,players:draftRow.players})]));
await as(queueUsers[0],()=>db.query('select finish_game($1)',[draft]));
assert.equal((await db.query('select won from match_results where game_id=$1 and user_id=$2',[draft,queueUsers[0]])).rows[0].won,false);checks++;
assert.equal((await db.query('select won from match_results where game_id=$1 and user_id=$2',[draft,queueUsers[7]])).rows[0].won,true);checks++;
// Retention: server-owned wallet, weekly quests, VIP expiry and idempotent claims.
const rewardUsers=[20,21,22,23,24].map(n=>`00000000-0000-4000-8000-${String(n).padStart(12,'0')}`);
for(const [i,id] of rewardUsers.entries()) await db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2::jsonb)',[id,JSON.stringify({username:`Rewards ${i}`})]);
await denied(rewardUsers[0],'update profiles set coins=999999 where id=$1',[rewardUsers[0]]);
await denied(rewardUsers[0],"update profiles set vip_expires_at=now()+interval '100 years' where id=$1",[rewardUsers[0]]);
await denied(rewardUsers[0],"select sync_purchases($1,ARRAY[]::text[],now()+interval '1 day')",[rewardUsers[0]]);
await denied(rewardUsers[0],"insert into user_progress values($1,'play_week',date_trunc('week',now() at time zone 'UTC')::date,5,true)",[rewardUsers[0]]);
await as(null,()=>db.query("select sync_purchases($1,ARRAY[]::text[],now()+interval '1 day')",[rewardUsers[0]]),'service_role');
const rewardRoster=rewardUsers.slice(0,4).map((id,seat)=>({id,seat,is_host:seat===0,name:`Rewards ${seat}`}));
let rewardGame;
for(let i=0;i<5;i++) {
 rewardGame=(await db.query("insert into games(join_code,mode,status,players,game_state) values($1,'ranked','playing',$2,$3) returning id",[`QUEST${i}`,JSON.stringify(rewardRoster),JSON.stringify({...finalState,players:rewardRoster})])).rows[0].id;
 await as(rewardUsers[0],()=>db.query('select finish_game($1)',[rewardGame]));
}
const wallet=async id=>(await db.query('select coins from profiles where id=$1',[id])).rows[0].coins;
assert.equal(await wallet(rewardUsers[0]),0);checks++;
assert.equal(await wallet(rewardUsers[2]),0);checks++;
await as(rewardUsers[0],()=>db.query('select finish_game($1)',[rewardGame]));
assert.equal(await wallet(rewardUsers[0]),0);checks++;
const status=(await as(rewardUsers[0],()=>db.query('select retention_status() s'))).rows[0].s;
assert.equal(status.vip,true);assert.equal(status.quests.every(q=>q.rewarded),true);checks++;
assert.equal((await as(rewardUsers[2],()=>db.query('select * from user_progress where user_id=$1',[rewardUsers[0]]))).rows.length,0);checks++;
// Neither wins, losses nor automatic quest completions mint any coins.
assert.equal((await db.query('select count(*)::int n from match_results where coins_earned<>0')).rows[0].n,0);checks++;
assert.equal((await db.query('select count(*)::int n from profiles where id=any($1::uuid[]) and coins<>0',[rewardUsers])).rows[0].n,0);checks++;
const vipQuestLedger=(await db.query('select sum(xp_earned)::int total from user_progress where user_id=$1',[rewardUsers[0]])).rows[0].total;
assert.equal(vipQuestLedger,2250);checks++;
assert.equal(status.quests.every(q=>q.reward_xp>0 && q.earned_xp>0),true);checks++;
const beforeQuestReplay=(await db.query('select level,xp,coins from profiles where id=$1',[rewardUsers[0]])).rows[0];
const replay=(await as(rewardUsers[0],()=>db.query("select claim_quest_reward('play_week') r"))).rows[0].r;
assert.deepEqual(replay,{xp:0,already_claimed:true});checks++;
assert.deepEqual((await db.query('select level,xp,coins from profiles where id=$1',[rewardUsers[0]])).rows[0],beforeQuestReplay);checks++;

// XP is server-owned, winner/loser rates differ, VIP doubles XP only.
const progression=async id=>(await db.query('select level,xp from profiles where id=$1',[id])).rows[0];
assert.deepEqual(await progression(rewardUsers[0]),{level:7,xp:250});checks++;
assert.deepEqual(await progression(rewardUsers[2]),{level:4,xp:125});checks++;
assert.deepEqual(await progression(rewardUsers[1]),{level:1,xp:450});checks++;
await denied(rewardUsers[0],'update profiles set level=30,xp=499 where id=$1',[rewardUsers[0]]);
await denied(null,'select record_game_result($1)',[rewardGame],'anon');
await denied(rewardUsers[4],'select record_game_result($1)',[rewardGame]);
await as(rewardUsers[0],()=>db.query('select record_game_result($1)',[rewardGame]));
assert.deepEqual(await progression(rewardUsers[0]),{level:7,xp:250});checks++;
assert.equal(status.rewards.length,30);assert.equal(status.season.title,'Saison 1');checks++;
const claimSeason=(id,tier,vip=false)=>as(id,()=>db.query("select claim_season_pass('season_1',$1,$2) r",[tier,vip])).then(r=>r.rows[0].r);
await denied(rewardUsers[2],"select claim_season_pass('season_1',1,true)");
await denied(rewardUsers[0],"select claim_season_pass('season_1',1,false)");
assert.equal((await claimSeason(rewardUsers[0],1,true)).coins,100);checks++;
assert.equal((await claimSeason(rewardUsers[0],1,true)).coins,0);checks++;
assert.equal(await wallet(rewardUsers[0]),100);checks++;
await denied(rewardUsers[0],"select claim_season_pass('season_1',4,false)");
await denied(rewardUsers[0],"select claim_season_pass('season_1',31,false)");
await denied(rewardUsers[0],"select claim_season_pass('missing',1,false)");
await denied(rewardUsers[0],'select claim_pass(1,false)');
await denied(rewardUsers[4],"select claim_season_pass('season_1',1,false)");
assert.equal((await as(rewardUsers[4],()=>db.query('select retention_status() s'))).rows[0].s.quests.every(q=>q.progress===0),true);checks++;
assert.equal((await as(rewardUsers[2],()=>db.query('select * from season_pass_claims where user_id=$1',[rewardUsers[0]]))).rows.length,0);checks++;
await denied(rewardUsers[0],"insert into season_pass_claims(user_id,season_id,tier,vip_track,coins) values($1,'season_1',30,false,99999)",[rewardUsers[0]]);
await as(null,()=>db.query("select sync_purchases($1,ARRAY[]::text[],now()-interval '1 minute')",[rewardUsers[0]]),'service_role');
assert.equal((await as(rewardUsers[0],()=>db.query('select retention_status() s'))).rows[0].s.vip,false);checks++;
await denied(rewardUsers[0],"select claim_season_pass('season_1',2,true)");
rewardGame=(await db.query("insert into games(join_code,mode,status,players,game_state) values('NO_VIP','ranked','playing',$1,$2) returning id",[JSON.stringify(rewardRoster),JSON.stringify({...finalState,players:rewardRoster})])).rows[0].id;
await as(rewardUsers[0],()=>db.query('select finish_game($1)',[rewardGame]));
assert.equal(await wallet(rewardUsers[0]),100);checks++;
assert.equal((await db.query('select coins_earned from match_results where game_id=$1 and user_id=$2',[rewardGame,rewardUsers[0]])).rows[0].coins_earned,0);checks++;
assert.deepEqual(await progression(rewardUsers[0]),{level:7,xp:350});checks++;
assert.equal((await db.query('select xp_earned from match_results where game_id=$1 and user_id=$2',[rewardGame,rewardUsers[0]])).rows[0].xp_earned,100);checks++;
await db.query('update profiles set level=7,xp=490 where id=$1',[rewardUsers[2]]);
const carryGame=(await db.query("insert into games(join_code,mode,status,players,game_state) values('XPCARRY','ranked','playing',$1,$2) returning id",[JSON.stringify(rewardRoster),JSON.stringify({...finalState,players:rewardRoster})])).rows[0].id;
await as(rewardUsers[0],()=>db.query('select record_game_result($1)',[carryGame]));
assert.deepEqual(await progression(rewardUsers[2]),{level:8,xp:90});checks++;
await denied(rewardUsers[0],'select private.end_current_season()');
await denied(rewardUsers[0],"update profiles set avatar_config=avatar_config||'{\"border\":null}' where id=$1",[rewardUsers[0]]);
await denied(rewardUsers[0],'select end_current_season()');
await denied(null,'select end_current_season()',[],'anon');
assert.equal((await as(null,()=>db.query('select end_current_season() r'),'service_role')).rows[0].r.closed,false);checks++;
// Public quest validation: server-owned progress, XP carry, no coin credit.
const questPlayer='00000000-0000-4000-8000-000000000090';
await db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2::jsonb)',[questPlayer,JSON.stringify({username:'Quest XP claims'})]);
await db.query('update profiles set xp=490,coins=123 where id=$1',[questPlayer]);
await denied(questPlayer,"select claim_quest_reward('play_week')");
await denied(questPlayer,"select private.award_quest_xp($1,'play_week')",[rewardUsers[0]]);
await assert.rejects(()=>as(null,()=>db.query("select claim_quest_reward('play_week')"),'anon'));checks++;
await db.query("insert into user_progress(user_id,quest_id,week_start,progress) values($1,'play_week',date_trunc('week',now() at time zone 'UTC')::date-7,5)",[questPlayer]);
await denied(questPlayer,"select claim_quest_reward('play_week')");
await db.query("insert into user_progress(user_id,quest_id,week_start,progress) values($1,'play_week',date_trunc('week',now() at time zone 'UTC')::date,4)",[questPlayer]);
await denied(questPlayer,"select claim_quest_reward('play_week')");
await denied(questPlayer,"update user_progress set progress=5 where user_id=$1",[questPlayer]);
await db.query("update user_progress set progress=5 where user_id=$1 and week_start=date_trunc('week',now() at time zone 'UTC')::date",[questPlayer]);
const claimQuest=async()=> (await as(questPlayer,()=>db.query("select claim_quest_reward('play_week') r"))).rows[0].r;
assert.deepEqual(await claimQuest(),{xp:250,already_claimed:false});checks++;
assert.deepEqual(await progression(questPlayer),{level:2,xp:240});checks++;
assert.equal(await wallet(questPlayer),123);checks++;
assert.deepEqual(await claimQuest(),{xp:0,already_claimed:true});checks++;
assert.deepEqual(await progression(questPlayer),{level:2,xp:240});checks++;
// VIP quest boost is XP x2 and the actual receipt survives VIP expiration.
await as(null,()=>db.query("select sync_purchases($1,ARRAY[]::text[],now()+interval '1 day')",[questPlayer]),'service_role');
await db.query("insert into user_progress(user_id,quest_id,week_start,progress) values($1,'ranked_wins',date_trunc('week',now() at time zone 'UTC')::date,2)",[questPlayer]);
assert.equal((await as(questPlayer,()=>db.query("select claim_quest_reward('ranked_wins') r"))).rows[0].r.xp,1000);checks++;
assert.deepEqual(await progression(questPlayer),{level:4,xp:240});checks++;
assert.equal(await wallet(questPlayer),123);checks++;
await as(null,()=>db.query("select sync_purchases($1,ARRAY[]::text[],now()-interval '1 day')",[questPlayer]),'service_role');
const actualQuest=(await as(questPlayer,()=>db.query('select retention_status() r'))).rows[0].r.quests.find(q=>q.id==='ranked_wins');
assert.equal(actualQuest.earned_xp,1000);checks++;
await denied(questPlayer,"select claim_quest_reward('missing')");

// Server Solo lineups vary, and each identity retains its name/personality/avatar.
await db.query('select setseed(0.41)');
const soloLineups=new Set();
for(let n=0;n<12;n++) {
 const round=(await db.query("insert into games(mode,join_code,players) values('casual',$1,$2) returning id",['RAND'+n,JSON.stringify([{id:ids[0],name:'Test 0',seat:0,is_host:true}])])).rows[0].id;
 await as(ids[0],()=>db.query('select start_with_bots($1)',[round]));
 const bots=(await db.query('select players from games where id=$1',[round])).rows[0].players.slice(1);
 soloLineups.add(bots.map(p=>p.name).join(','));
 assert.equal(new Set(bots.map(p=>p.bot_personality)).size,3);checks++;
 for(const bot of bots) assert.equal(bot.bot_personality,({Patxi:'conservative',Mikel:'balanced',Txomin:'bluffer'})[bot.name]);checks++;
 await as(ids[0],()=>db.query('select close_game($1)',[round]));
}
assert.equal(soloLineups.size>1,true);checks++;

// Shop prices and ownership are authoritative, including stale/replayed purchases.
const buyer='00000000-0000-4000-8000-000000000070', poor='00000000-0000-4000-8000-000000000071';
for(const [id,name] of [[buyer,'Shop buyer'],[poor,'Shop low balance']]) await db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2::jsonb)',[id,JSON.stringify({username:name})]);
await db.query('update profiles set coins=1000 where id=$1',[buyer]);
await db.query('update profiles set coins=10 where id=$1',[poor]);
const buy=async(id,item,cost)=>(await as(id,()=>db.query('select buy_shop_item($1,$2) receipt',[item,cost]))).rows[0].receipt;
assert.equal((await as(buyer,()=>db.query('select * from shop_items'))).rows.length,8);checks++;
await assert.rejects(()=>as(null,()=>db.query('select * from shop_items'),'anon'));checks++;
await assert.rejects(()=>as(null,()=>db.query("select buy_shop_item('shop_hair_mullet',300)"),'anon'));checks++;
await assert.rejects(()=>buy(poor,'shop_hair_mullet',300),/Fonds insuffisants/);checks++;
assert.equal(await wallet(poor),10);checks++;
assert.equal((await db.query('select * from inventory where user_id=$1',[poor])).rows.length,0);checks++;
for(const cost of [1,0,-300,null]) {await assert.rejects(()=>buy(buyer,'shop_hair_mullet',cost),/Prix modifié/);checks++;}
for(const item of ['unknown','league_border_gold']) {await assert.rejects(()=>buy(buyer,item,1),/Article indisponible/);checks++;}
await denied(buyer,"insert into shop_items values('fake',1,true,'Fake')");
await denied(buyer,"update shop_items set cost=1 where item_id='shop_hair_mullet'");
await denied(buyer,"insert into inventory(user_id,cosmetic_id) values($1,'shop_hair_mullet')",[buyer]);
await denied(buyer,'update profiles set coins=99999 where id=$1',[buyer]);
await denied(buyer,"update profiles set avatar_config=avatar_config||'{\"hair\":3}' where id=$1",[buyer]);
assert.deepEqual(await buy(buyer,'shop_hair_mullet',300),{item_id:'shop_hair_mullet',coins_remaining:700});checks++;
await assert.rejects(()=>buy(buyer,'shop_hair_mullet',300),/déjà possédé/);checks++;
assert.equal(await wallet(buyer),700);checks++;
assert.equal((await db.query('select * from inventory where user_id=$1',[buyer])).rows.length,1);checks++;
await as(buyer,()=>db.query("select equip_cosmetic('shop_hair_mullet')"));
assert.equal((await db.query('select avatar_config from profiles where id=$1',[buyer])).rows[0].avatar_config.hair,3);checks++;
await denied(buyer,"update profiles set avatar_config=avatar_config||'{\"top\":3}' where id=$1",[buyer]);
assert.equal((await buy(buyer,'shop_back_violet',250)).coins_remaining,450);checks++;
await as(buyer,()=>db.query("select equip_cosmetic('shop_back_violet')"));
assert.equal((await db.query('select card_back from profiles where id=$1',[buyer])).rows[0].card_back,'shop_back_violet');checks++;
await as(buyer,()=>db.query("select equip_cosmetic('classic')"));
assert.equal((await db.query('select card_back from profiles where id=$1',[buyer])).rows[0].card_back,'classic');checks++;
assert.equal((await db.query("select count(*)::int n from inventory where user_id=$1 and cosmetic_id='classic'",[buyer])).rows[0].n,0);checks++;

assert.equal((await buy(buyer,'shop_chat_eskerrik',150)).coins_remaining,300);checks++;
await db.exec("update shop_items set enabled=false where item_id='shop_chat_rematch'");
assert.equal((await as(buyer,()=>db.query('select * from shop_items'))).rows.length,7);checks++;
await assert.rejects(()=>buy(buyer,'shop_chat_rematch',150),/Article indisponible/);checks++;
await db.exec("update shop_items set enabled=true where item_id='shop_chat_rematch'; update shop_items set cost=350 where item_id='shop_top_striped'");
await assert.rejects(()=>buy(buyer,'shop_top_striped',400),/Prix modifié/);checks++;
await db.exec("update shop_items set cost=300 where item_id='shop_top_striped'");
await as(null,()=>db.query("select sync_purchases($1,ARRAY[]::text[],null)",[buyer]),'service_role');
assert.equal((await db.query('select * from inventory where user_id=$1',[buyer])).rows.length,3);checks++;
assert.equal(await wallet(buyer),300);checks++;

for(const [item,cost] of [['shop_top_striped',300],['shop_hat_cap',200],['shop_hat_beanie',200]]) {
  await denied(poor,'select equip_cosmetic($1)',[item]);
}
await db.query('update profiles set coins=coins+1000 where id=$1',[buyer]);
for(const [item,cost] of [['shop_top_striped',300],['shop_hat_cap',200],['shop_hat_beanie',200]]) {
  await buy(buyer,item,cost); await as(buyer,()=>db.query('select equip_cosmetic($1)',[item]));
}
const dressed=(await db.query('select avatar_config from profiles where id=$1',[buyer])).rows[0].avatar_config;
assert.deepEqual([dressed.hair,dressed.top,dressed.glasses,dressed.exclusive_hat],[3,3,0,'beanie']);checks++;
await as(buyer,()=>db.query(`update profiles set avatar_config=jsonb_set(jsonb_set(avatar_config,'{glasses}','0'),'{exclusive_hat}','"none"') where id=$1`,[buyer]));
const unequipped=(await db.query('select avatar_config from profiles where id=$1',[buyer])).rows[0].avatar_config;
assert.deepEqual([unequipped.hair,unequipped.top,unequipped.glasses,unequipped.exclusive_hat],[3,3,0,'none']);checks++;
assert.equal((await db.query("select count(*)::int n from inventory where user_id=$1 and cosmetic_id='shop_hat_beanie'",[buyer])).rows[0].n,1);checks++;

assert.equal(await wallet(buyer),600);checks++;
await db.exec("update shop_items set enabled=true where item_id='shop_border_emerald'");
await assert.rejects(()=>buy(buyer,'shop_border_emerald',300),/Article indisponible/);checks++;
assert.equal((await as(buyer,()=>db.query("select * from shop_items where item_id='shop_border_emerald'"))).rows.length,0);checks++;
await db.exec("update shop_items set enabled=false where item_id='shop_border_emerald'");
// Six real free rewards, thirty VIP rewards; placeholders never grant inventory.
const seasonDefinitions=(await db.query("select * from season_rewards where season_id='season_1' order by tier")).rows;
assert.deepEqual(seasonDefinitions.filter(r=>r.free_coins!==null).map(r=>r.tier),[5,10,15,20,25,30]);checks++;
assert.equal(seasonDefinitions.filter(r=>r.vip_coins===100).length,30);checks++;
assert.equal(seasonDefinitions.filter(r=>r.free_coins!==null).every(r=>r.free_coins===50),true);checks++;
assert.deepEqual(seasonDefinitions.filter(r=>r.vip_cosmetic_placeholder!==null).map(r=>r.tier),[10,20,30]);checks++;
assert.equal(seasonDefinitions.every(r=>r.vip_cosmetic===null),true);checks++;
await db.query('update profiles set level=30 where id=$1',[rewardUsers[0]]);
await as(null,()=>db.query("select sync_purchases($1,ARRAY[]::text[],now()+interval '1 day')",[rewardUsers[0]]),'service_role');
assert.equal((await claimSeason(rewardUsers[0],5)).coins,50);checks++;
assert.equal((await claimSeason(rewardUsers[0],5)).coins,0);checks++;
const previewClaim=await claimSeason(rewardUsers[0],10,true);
assert.equal(previewClaim.cosmetic,null);assert.equal(previewClaim.coins,100);checks++;
assert.equal((await db.query('select count(*)::int n from inventory where user_id=$1',[rewardUsers[0]])).rows[0].n,0);checks++;
await as(null,()=>db.query("select sync_purchases($1,ARRAY[]::text[],now()-interval '1 minute')",[rewardUsers[0]]),'service_role');
await denied(rewardUsers[0],"select claim_season_pass('season_1',20,true)");
await db.exec("update seasons set start_date=(date_trunc('month',now() at time zone 'Europe/Paris')-interval '1 month') at time zone 'Europe/Paris',end_date=date_trunc('month',now() at time zone 'Europe/Paris') at time zone 'Europe/Paris' where id='season_1'");
await denied(rewardUsers[0],"select claim_season_pass('season_1',30,false)");
assert.equal((await as(rewardUsers[0],()=>db.query('select retention_status() s'))).rows[0].s.season,null);checks++;
// Close only a due season; peak, not current Elo, determines permanent rewards.
for(const [id,peak] of [[ids[0],999],[ids[1],1000],[ids[2],1200],[ids[3],1400],[rewardUsers[0],1600]])
 await db.query('update profiles set elo=850,peak_elo=$2 where id=$1',[id,peak]);
const progressionBefore=(await db.query('select id,coins,xp,level,games_played from profiles order by id')).rows;
const closed=(await as(null,()=>db.query('select end_current_season() r'),'service_role')).rows[0].r;
assert.equal(closed.closed,true);checks++;
assert.equal((await db.query('select count(*)::int n from profiles where elo<>800 or peak_elo<>800')).rows[0].n,0);checks++;
assert.deepEqual((await db.query('select id,coins,xp,level,games_played from profiles order by id')).rows,progressionBefore);checks++;
const awardsFor=async id=>(await db.query('select cosmetic_id from league_awards where user_id=$1 order by cosmetic_id',[id])).rows.map(r=>r.cosmetic_id);
assert.deepEqual(await awardsFor(ids[0]),[]);checks++;
assert.deepEqual(await awardsFor(ids[1]),['league_border_bronze']);checks++;
assert.deepEqual(await awardsFor(ids[2]),['league_border_bronze','league_border_silver']);checks++;
assert.deepEqual(await awardsFor(ids[3]),['league_border_bronze','league_border_gold','league_border_silver']);checks++;
assert.deepEqual(await awardsFor(rewardUsers[0]),['league_border_bronze','league_border_gold','league_border_silver','league_hat_txapela']);checks++;
await denied(ids[1],"update profiles set avatar_config=avatar_config||'{\"border\":\"diamond\"}' where id=$1",[ids[1]]);
await denied(ids[1],"select equip_cosmetic('league_hat_txapela')");
await as(rewardUsers[0],()=>db.query("select equip_cosmetic('league_border_gold')"));
await as(rewardUsers[0],()=>db.query("select equip_cosmetic('league_hat_txapela')"));
assert.equal((await db.query('select avatar_config from profiles where id=$1',[rewardUsers[0]])).rows[0].avatar_config.border,'gold');checks++;
assert.equal((await db.query('select avatar_config from profiles where id=$1',[rewardUsers[0]])).rows[0].avatar_config.exclusive_hat,'txapela');checks++;
await as(null,()=>db.query("select sync_purchases($1,ARRAY[]::text[],null)",[rewardUsers[0]]),'service_role');
assert.equal((await db.query("select count(*)::int n from inventory where user_id=$1 and cosmetic_id like 'league_%'",[rewardUsers[0]])).rows[0].n,4);checks++;
assert.equal((await as(ids[1],()=>db.query('select * from league_awards where user_id=$1',[rewardUsers[0]]))).rows.length,0);checks++;
const active=(await as(ids[1],()=>db.query('select active_season() s'))).rows[0].s;
assert.equal(active.id,closed.next_season_id);checks++;
assert.equal((await db.query('select count(*)::int n from season_rewards where season_id=$1',[active.id])).rows[0].n,30);checks++;
assert.equal((await db.query("select end_date at time zone 'Europe/Paris'=date_trunc('month',end_date at time zone 'Europe/Paris') ok from seasons where id=$1",[active.id])).rows[0].ok,true);checks++;
assert.equal((await as(ids[1],()=>db.query('select retention_status() s'))).rows[0].s.season.end_date,active.end_date);checks++;
await db.query('update profiles set elo=850,peak_elo=850 where id=$1',[ids[1]]);
assert.equal((await as(null,()=>db.query('select end_current_season() r'),'service_role')).rows[0].r.closed,false);checks++;
assert.equal((await db.query('select elo from profiles where id=$1',[ids[1]])).rows[0].elo,850);checks++;
await as(null,()=>db.query('select erase_account($1)',[ids[0]]),'service_role');
assert.equal((await db.query('select * from auth.users where id=$1',[ids[0]])).rows.length,0);checks++;
assert.equal(JSON.stringify((await db.query('select players,game_state from games')).rows).includes(ids[0]),false);checks++;
assert.equal(JSON.stringify((await db.query('select players,game_state from games')).rows).includes('Test 0'),false);checks++;
// Blocks protect DB writes, search and outstanding invitations in both directions.
const blockers=[201,202,203].map(n=>`00000000-0000-4000-8000-${String(n).padStart(12,'0')}`);
for(const [i,id] of blockers.entries())await db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2)',[id,JSON.stringify({username:`Social Block Player ${i}`})]);
const [blockSender,blockReceiver,bystander]=blockers;
const socialSearch=id=>as(id,()=>db.query("select id from search_social_players('Social Block Player')"));
assert.equal((await socialSearch(blockSender)).rows.length,2);checks++;
const socialFriend=await as(blockSender,async()=>(await db.query('insert into friendships(user_id_1,user_id_2) values($1,$2) returning id',[blockSender,blockReceiver])).rows[0].id);
await as(blockReceiver,()=>db.query("update friendships set status='accepted' where id=$1",[socialFriend]));
const blockedRoom=await as(blockSender,async()=>(await db.query("insert into games(join_code,mode,players) values('BLOCK','private',$1) returning id",[JSON.stringify([{id:blockSender,seat:0,is_host:true,name:'Social Block Player 0'}])])).rows[0].id);
await as(blockSender,()=>db.query('select invite_friend($1,$2)',[blockReceiver,blockedRoom]));
const blockedInvitation=(await db.query('select id from game_invitations where game_id=$1',[blockedRoom])).rows[0].id;
await as(blockReceiver,()=>db.query('select block_user($1)',[blockSender]));
await as(blockReceiver,()=>db.query('select block_user($1)',[blockSender]));
assert.equal((await db.query('select count(*)::int n from friendships where id=$1',[socialFriend])).rows[0].n,0);checks++;
assert.equal((await db.query('select status from game_invitations where id=$1',[blockedInvitation])).rows[0].status,'declined');checks++;
assert.equal((await as(blockReceiver,()=>db.query('select * from blocked_users'))).rows.length,1);checks++;
assert.equal((await as(blockSender,()=>db.query('select * from blocked_users'))).rows.length,0);checks++;
assert.deepEqual((await socialSearch(blockSender)).rows.map(r=>r.id),[bystander]);checks++;
assert.deepEqual((await socialSearch(blockReceiver)).rows.map(r=>r.id),[bystander]);checks++;
for(const [sender,receiver] of [[blockSender,blockReceiver],[blockReceiver,blockSender]]) {
 await denied(sender,'insert into friendships(user_id_1,user_id_2) values($1,$2)',[sender,receiver]);
 await denied(sender,'select invite_friend($1,$2)',[receiver,blockedRoom]);
}
await denied(blockReceiver,'select accept_invitation($1)',[blockedInvitation]);
await denied(blockSender,'insert into blocked_users(blocker_id,blocked_id) values($1,$2)',[blockSender,bystander]);
await denied(blockSender,'delete from blocked_users where blocker_id=$1',[blockReceiver]);
await denied(blockSender,'select private.social_pair_blocked($1,$2)',[blockSender,blockReceiver]);
await denied(blockSender,'select block_user($1)',[blockSender]);
await denied(blockSender,'select block_user(null)');
await as(blockSender,()=>db.query('select unblock_user($1)',[blockReceiver]));
assert.equal((await socialSearch(blockSender)).rows.length,1);checks++;
await as(blockReceiver,()=>db.query('select unblock_user($1)',[blockSender]));
assert.equal((await socialSearch(blockSender)).rows.length,2);checks++;
assert.equal((await db.query('select count(*)::int n from friendships where id=$1',[socialFriend])).rows[0].n,0);checks++;
await as(blockSender,()=>db.query('insert into friendships(user_id_1,user_id_2) values($1,$2)',[blockSender,blockReceiver]));
await as(blockSender,()=>db.query('select block_user($1)',[blockReceiver]));
await as(blockReceiver,()=>db.query('select block_user($1)',[blockSender]));
await as(blockSender,()=>db.query('select unblock_user($1)',[blockReceiver]));
await denied(blockSender,'insert into friendships(user_id_1,user_id_2) values($1,$2)',[blockSender,blockReceiver]);
assert.equal((await as(blockSender,()=>db.query("select * from search_social_players('%_')"))).rows.length,0);checks++;
for(const sql of ["select block_user('00000000-0000-4000-8000-000000000201')","select unblock_user('00000000-0000-4000-8000-000000000201')","select * from search_social_players('Social')"]){await assert.rejects(()=>as(null,()=>db.query(sql),'anon'));checks++;}
// Mode-aware invitations reserve partners, including two opposing duos.
assert.equal((await db.query("select pg_get_constraintdef(oid) d from pg_constraint where conrelid='friendships'::regclass and conname='friendships_sender_receiver_unique'")).rows[0].d,'UNIQUE (sender_id, receiver_id)');checks++;
const duoUsers=Array.from({length:28},(_,n)=>`00000000-0000-4000-8000-${String(400+n).padStart(12,'0')}`);
for(const [i,id] of duoUsers.entries())await db.query('insert into auth.users(id,raw_user_meta_data) values($1,$2)',[id,JSON.stringify({username:`Duo ${i}`})]);
for(const [a,b] of [[0,1],[2,3],[4,5],[6,7],[12,13],[16,17],[20,21],[22,23],[24,25]]){
 const fid=await as(duoUsers[a],async()=>(await db.query('insert into friendships(user_id_1,user_id_2) values($1,$2) returning id',[duoUsers[a],duoUsers[b]])).rows[0].id);
 await as(duoUsers[b],()=>db.query("update friendships set status='accepted' where id=$1",[fid]));
}
const modeInvite=(a,b,mode)=>as(duoUsers[a],async()=>(await db.query('select create_mode_invitation($1,$2) r',[duoUsers[b],mode])).rows[0].r);
const inviteRow=async(a,b)=>(await db.query("select * from game_invitations where sender_id=$1 and recipient_id=$2 order by created_at desc limit 1",[duoUsers[a],duoUsers[b]])).rows[0];
const acceptMode=(b,id)=>as(duoUsers[b],async()=>(await db.query('select accept_game_invitation($1) r',[id])).rows[0].r);
const soloFind=(a,mode)=>as(duoUsers[a],async()=>(await db.query('select find_public_game($1) r',[mode])).rows[0].r);
const classicA=await modeInvite(0,1,'casual');
assert.equal(classicA.is_public,true);checks++;
assert.equal(classicA.duo_reservations[0].seat,2);checks++;
assert.equal((await modeInvite(0,1,'casual')).id,classicA.id);checks++;
const classicB=await modeInvite(2,3,'casual');
assert.equal(classicB.id,classicA.id);checks++;
assert.equal(classicB.local_seat,1);checks++;
assert.equal(classicB.duo_reservations.length,2);checks++;
assert.notEqual((await soloFind(8,'casual')).id,classicA.id);checks++;
const firstModeInvite=await inviteRow(0,1);
await denied(duoUsers[22],'select accept_game_invitation($1)',[firstModeInvite.id]);
const acceptedA=await acceptMode(1,firstModeInvite.id);
assert.equal(acceptedA.local_seat,2);checks++;
assert.equal(acceptedA.status,'waiting');checks++;
const acceptedB=await acceptMode(3,(await inviteRow(2,3)).id);
assert.equal(acceptedB.local_seat,3);checks++;
assert.equal(acceptedB.status,'ready');checks++;
assert.equal(acceptedB.duo_reservations.length,0);checks++;
assert.equal(new Set(acceptedB.players.map(p=>p.id)).size,4);checks++;
assert.equal((await acceptMode(1,firstModeInvite.id)).players.length,4);checks++;
const rankedDuo=await modeInvite(4,5,'ranked');
assert.equal((await soloFind(9,'ranked')).local_seat,1);checks++;
assert.equal((await soloFind(10,'ranked')).local_seat,3);checks++;
assert.notEqual((await soloFind(11,'ranked')).id,rankedDuo.id);checks++;
const rankedAccepted=await acceptMode(5,(await inviteRow(4,5)).id);
assert.equal(rankedAccepted.local_seat,2);checks++;
assert.equal(rankedAccepted.status,'ready');checks++;
assert.equal(rankedAccepted.mode,'ranked');checks++;
const privateDuo=await modeInvite(6,7,'private');
assert.equal(privateDuo.is_public,false);checks++;
const privateAccepted=await acceptMode(7,(await inviteRow(6,7)).id);
assert.equal(privateAccepted.id,privateDuo.id);checks++;
assert.equal(privateAccepted.local_seat,1);checks++;
assert.equal(privateAccepted.status,'waiting');checks++;
const declinedDuo=await modeInvite(12,13,'casual');
const declinedInvite=(await inviteRow(12,13)).id;
await denied(duoUsers[22],'select decline_game_invitation($1)',[declinedInvite]);
await as(duoUsers[13],()=>db.query('select decline_game_invitation($1)',[declinedInvite]));
assert.equal((await db.query('select duo_reservations from games where id=$1',[declinedDuo.id])).rows[0].duo_reservations.length,0);checks++;
await soloFind(14,'casual');const released=await soloFind(15,'casual');
assert.equal(released.id,declinedDuo.id);checks++;
assert.equal(released.status,'ready');checks++;
const expiredDuo=await modeInvite(16,17,'casual');const expiredInvite=(await inviteRow(16,17)).id;
await db.query("update game_invitations set expires_at=now()-interval '1 minute' where id=$1",[expiredInvite]);
await soloFind(18,'casual');assert.equal((await soloFind(19,'casual')).local_seat,2);checks++;
await denied(duoUsers[17],'select accept_game_invitation($1)',[expiredInvite]);
const cancelledDuo=await modeInvite(20,21,'casual');const cancelledInvite=(await inviteRow(20,21)).id;
await as(duoUsers[20],()=>db.query('select leave_public_queue($1)',[cancelledDuo.id]));
assert.equal((await db.query('select status from game_invitations where id=$1',[cancelledInvite])).rows[0].status,'declined');checks++;
await denied(duoUsers[21],'select accept_game_invitation($1)',[cancelledInvite]);
await as(duoUsers[22],()=>db.query('select block_user($1)',[duoUsers[23]]));
await denied(duoUsers[22],"select create_mode_invitation($1,'casual')",[duoUsers[23]]);
await denied(duoUsers[24],"select create_mode_invitation($1,'bad')",[duoUsers[25]]);
await denied(duoUsers[24],"select create_mode_invitation($1,'private')",[duoUsers[24]]);
await denied(duoUsers[0],"update game_invitations set mode='ranked' where id=$1",[firstModeInvite.id]);
await denied(duoUsers[0],"update games set duo_reservations='[]' where id=$1",[classicA.id]);
for(const sql of ["select create_mode_invitation('00000000-0000-4000-8000-000000000401','private')",`select accept_game_invitation('${firstModeInvite.id}')`,`select decline_game_invitation('${firstModeInvite.id}')`]){await assert.rejects(()=>as(null,()=>db.query(sql),'anon'));checks++;}
await denied(duoUsers[0],'select private.live_duo_reservations(g) from games g where id=$1',[classicA.id]);
const busyFriend=await as(duoUsers[26],async()=>(await db.query('insert into friendships(user_id_1,user_id_2) values($1,$2) returning id',[duoUsers[26],duoUsers[27]])).rows[0].id);
await as(duoUsers[27],()=>db.query("update friendships set status='accepted' where id=$1",[busyFriend]));
const pendingBusy=await modeInvite(26,27,'casual');await soloFind(27,'ranked');
await denied(duoUsers[27],'select accept_game_invitation($1)',[(await inviteRow(26,27)).id]);
assert.equal((await db.query('select jsonb_array_length(players)::int n from games where id=$1',[pendingBusy.id])).rows[0].n,1);checks++;
// A recipient who joined manually must not occupy two seats in the same game.
const manualDuoRoom=(await db.query("insert into games(join_code,mode,is_public,created_at,players) values('DUOMAN','casual',true,now()-interval '1 day',$1) returning id",[JSON.stringify([{id:duoUsers[24],seat:0,is_host:true,is_bot:false,name:'Duo 24'}])])).rows[0].id;
await modeInvite(24,25,'casual');const manualDuoInvite=(await inviteRow(24,25)).id;
assert.equal((await soloFind(25,'casual')).id,manualDuoRoom);checks++;
await denied(duoUsers[25],'select accept_game_invitation($1)',[manualDuoInvite]);
const manualRoster=(await db.query('select players from games where id=$1',[manualDuoRoom])).rows[0].players;
assert.equal(new Set(manualRoster.map(p=>p.id)).size,manualRoster.length);checks++;
await as(duoUsers[25],()=>db.query('select leave_public_queue($1)',[manualDuoRoom]));
assert.equal((await acceptMode(25,manualDuoInvite)).local_seat,2);checks++;

await assert.rejects(()=>buy(buyer,'shop_glasses_gold',250),/Article indisponible/);checks++;
await denied(buyer,"update profiles set avatar_config=jsonb_set(avatar_config,'{glasses}','3') where id=$1",[buyer]);
await denied(buyer,"select equip_cosmetic('shop_glasses_gold')");

console.log(`Migration applied to isolated PostgreSQL; ${checks} authorization/result assertions passed.`);

await db.exec(readFileSync(new URL('../supabase/migrations/20261029223940_shop_categories_free_backgrounds.sql',import.meta.url),'utf8'));
assert.equal((await db.query("select count(*)::int n from cosmetics where id='shop_hair_mullet'")).rows[0].n,0);
console.log('Retirement migration passed.');
await db.exec(readFileSync(new URL('../supabase/migrations/20261029225734_front_facing_hair_and_palette.sql',import.meta.url),'utf8'));
await db.close();
