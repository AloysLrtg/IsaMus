-- IsaMus: public matchmaking and private team selection.
-- ALREADY DEPLOYED on nakbrpgecwpphyynsdor (remote version 20261029125711).
-- Review/reference copy: do not run again on that project.
-- Independent of the pending shop/XP migrations.
BEGIN;

-- Explicit visibility: legacy/solo rooms never enter public matchmaking.
alter table public.games add column is_public boolean not null default false;
alter table public.games add constraint public_modes check(not is_public or mode in ('casual','ranked'));
create index games_public_waiting on public.games(mode,created_at,id) where is_public and status='waiting';

create index games_public_active_members on public.games using gin(players jsonb_path_ops) where is_public and status in ('waiting','ready','playing');

create function private.find_public_game(p_mode text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare g public.games; pr public.profiles; target integer; attempt integer;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if p_mode is null or p_mode not in ('casual','ranked') then raise exception 'Mode public invalide'; end if;
 select * into strict pr from public.profiles where id=auth.uid();
 -- Short, global queue lock: prevents duplicate joins across both public modes.
 perform pg_advisory_xact_lock(74812002);
 select * into g from public.games where is_public and status in ('waiting','ready','playing') and players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) order by created_at,id limit 1 for update;
 if found then
  if g.mode<>p_mode then raise exception 'Une autre partie publique est déjà en cours'; end if;
  return to_jsonb(g)||jsonb_build_object('local_seat',(select (p->>'seat')::int from jsonb_array_elements(g.players) p where p->>'id'=auth.uid()::text));
 end if;
 select * into g from public.games where is_public and mode=p_mode and status='waiting' and game_state is null and jsonb_array_length(players)<4 order by created_at,id limit 1 for update;
 if not found then
  for attempt in 1..5 loop
   begin
    insert into public.games(join_code,status,mode,is_public,players) values(upper(substr(replace(gen_random_uuid()::text,'-',''),1,5)),'waiting',p_mode,true,
      jsonb_build_array(jsonb_build_object('id',pr.id,'name',pr.username,'seat',0,'is_host',true,'is_bot',false,'avatar_config',pr.avatar_config))) returning * into g;
    return to_jsonb(g)||jsonb_build_object('local_seat',0);
   exception when unique_violation then
    if attempt=5 then raise exception 'Recherche indisponible. Réessayez.'; end if;
   end;
  end loop;
 end if;
 select s into target from generate_series(0,3) s where not exists(select 1 from jsonb_array_elements(g.players) p where (p->>'seat')::int=s) order by s limit 1;
 if target is null then raise exception 'Partie complète'; end if;
 update public.games set players=g.players||jsonb_build_array(jsonb_build_object('id',pr.id,'name',pr.username,'seat',target,'is_host',false,'is_bot',false,'avatar_config',pr.avatar_config)),
 status=case when jsonb_array_length(g.players)=3 then 'ready' else 'waiting' end where id=g.id returning * into g;
 return to_jsonb(g)||jsonb_build_object('local_seat',target);
end $$;
create function public.find_public_game(p_mode text) returns jsonb language sql security invoker set search_path='' as $$select private.find_public_game(p_mode)$$;
revoke all on function private.find_public_game(text),public.find_public_game(text) from public,anon;
grant execute on function private.find_public_game(text),public.find_public_game(text) to authenticated;

create function private.leave_public_queue(game uuid) returns void language plpgsql security definer set search_path='' as $$
declare g public.games; remaining jsonb;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform pg_advisory_xact_lock(74812002);
 select * into strict g from public.games where id=game for update;
 if not g.is_public then raise exception 'File publique requise'; end if;
 if not g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) then return; end if;
 if g.status<>'waiting' then raise exception 'La partie est déjà prête'; end if;
 select coalesce(jsonb_agg(p||jsonb_build_object('is_host',n=1) order by n),'[]') into remaining from (
  select p,row_number() over(order by ord) n from jsonb_array_elements(g.players) with ordinality x(p,ord) where p->>'id'<>auth.uid()::text
 ) members;
 update public.games set players=remaining,status=case when jsonb_array_length(remaining)=0 then 'cancelled' else 'waiting' end where id=game;
end $$;
create function public.leave_public_queue(game uuid) returns void language sql security invoker set search_path='' as $$select private.leave_public_queue(game)$$;
revoke all on function private.leave_public_queue(uuid),public.leave_public_queue(uuid) from public,anon;
grant execute on function private.leave_public_queue(uuid),public.leave_public_queue(uuid) to authenticated;

create or replace function private.join_game(code text) returns uuid language plpgsql security definer set search_path='' as $$
declare g public.games; pr public.profiles; target integer; chosen_team integer;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict pr from public.profiles where id=auth.uid();
 select * into g from public.games where join_code=upper(trim(code)) for update;
 if not found or g.is_public or g.mode is distinct from 'private' then raise exception 'Salon privé introuvable'; end if;
 if g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) then return g.id; end if;
 if g.status<>'waiting' or jsonb_array_length(g.players)>=4 then raise exception 'Partie complète ou déjà commencée'; end if;
 select s into target from generate_series(0,3) s where not exists(select 1 from jsonb_array_elements(g.players) p where (p->>'seat')::int=s) order by s limit 1;
 select case when count(*) filter(where coalesce((p->>'team')::int,(p->>'seat')::int%2)=0)<=count(*) filter(where coalesce((p->>'team')::int,(p->>'seat')::int%2)=1) then 0 else 1 end into chosen_team from jsonb_array_elements(g.players) p;
 update public.games set players=g.players||jsonb_build_array(jsonb_build_object('id',pr.id,'name',pr.username,'seat',target,'team',chosen_team,'is_host',false,'is_bot',false,'avatar_config',pr.avatar_config)) where id=g.id;
 return g.id;
end $$;

create function private.choose_private_team(game uuid,p_team integer) returns void language plpgsql security definer set search_path='' as $$
declare g public.games;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if p_team is null or p_team not in (0,1) then raise exception 'Équipe invalide'; end if;
 select * into strict g from public.games where id=game for update;
 if g.mode is distinct from 'private' or g.is_public or g.status<>'waiting' then raise exception 'Salon privé ouvert requis'; end if;
 if not g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) then raise exception 'Joueur non membre'; end if;
 update public.games set players=(select jsonb_agg((case when p->>'id'=auth.uid()::text then p||jsonb_build_object('team',p_team) else p end)||jsonb_build_object('is_host',ord=1) order by ord) from jsonb_array_elements(g.players) with ordinality x(p,ord)) where id=game;
end $$;
create function public.choose_private_team(game uuid,p_team integer) returns void language sql security invoker set search_path='' as $$select private.choose_private_team(game,p_team)$$;
revoke all on function private.choose_private_team(uuid,integer),public.choose_private_team(uuid,integer) from public,anon;
grant execute on function private.choose_private_team(uuid,integer),public.choose_private_team(uuid,integer) to authenticated;

create function private.start_private_game(game uuid) returns void language plpgsql security definer set search_path='' as $$
declare g public.games; member jsonb; arranged jsonb:='[]'; team integer; a integer:=0; b integer:=0;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict g from public.games where id=game for update;
 if g.mode is distinct from 'private' or g.is_public then raise exception 'Salon privé requis'; end if;
 if g.players->0->>'id' is distinct from auth.uid()::text then raise exception 'Hôte requis'; end if;
 if g.status<>'waiting' then return; end if;
 if jsonb_array_length(g.players)<>4 or
 (select count(distinct p->>'id') from jsonb_array_elements(g.players) p)<>4 or
 (select count(*) from jsonb_array_elements(g.players) p where coalesce((p->>'team')::int,(p->>'seat')::int%2)=0)<>2 or
 (select count(*) from jsonb_array_elements(g.players) p where coalesce((p->>'team')::int,(p->>'seat')::int%2)=1)<>2 then raise exception 'Deux joueurs par équipe sont requis'; end if;
 -- Preserve host-first array order (authorization), assign seating by team.
 for member in select value from jsonb_array_elements(g.players) loop
   team:=coalesce((member->>'team')::int,(member->>'seat')::int%2);
   member:=member||jsonb_build_object('seat',case when team=0 then a*2 else b*2+1 end,'team',team,'is_host',jsonb_array_length(arranged)=0);
   if team=0 then a:=a+1; else b:=b+1; end if;
   arranged:=arranged||jsonb_build_array(member);
 end loop;
 update public.games set players=arranged,status='ready' where id=game;
end $$;
create function public.start_private_game(game uuid) returns void language sql security invoker set search_path='' as $$select private.start_private_game(game)$$;
revoke all on function private.start_private_game(uuid),public.start_private_game(uuid) from public,anon;
grant execute on function private.start_private_game(uuid),public.start_private_game(uuid) to authenticated;

-- Fixed identities are assigned once under the same host/room lock as startup.
-- Keep this catalog aligned with BotProfile.profiles in Flutter.
create or replace function private.start_with_bots(game uuid) returns void
language plpgsql security definer set search_path='' as $$
declare
 g public.games; target integer; chosen_team integer; n int; bot_index int := 0; profile jsonb; member jsonb; normalized jsonb := '[]';
 catalog constant jsonb := '[
  {"name":"Patxi","bot_personality":"conservative","avatar_config":{"skin":0,"hair":0,"glasses":1,"top":2,"background_color":1,"hair_color":4}},
  {"name":"Mikel","bot_personality":"balanced","avatar_config":{"skin":1,"hair":0,"glasses":0,"top":1,"background_color":0,"hair_color":0}},
  {"name":"Txomin","bot_personality":"bluffer","avatar_config":{"skin":2,"hair":2,"glasses":2,"top":0,"background_color":3,"hair_color":5}}
 ]';
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict g from public.games where id=game for update;
 if g.players->0->>'id' is distinct from auth.uid()::text then raise exception 'Hôte requis'; end if;
 if g.status<>'waiting' then return; end if;
 if g.is_public then raise exception 'Les bots sont interdits dans la file publique'; end if;
 if g.mode='ranked' then raise exception 'Quatre joueurs humains requis en mode classé'; end if;
 select jsonb_agg(case when pr.id is null then x.p else
   x.p || jsonb_build_object('avatar_config',pr.avatar_config) end order by x.ord)
 into g.players from jsonb_array_elements(g.players) with ordinality x(p,ord)
 left join public.profiles pr on pr.id::text=x.p->>'id';
 -- Also normalize legacy waiting rooms that already contain some bots.
 for member in select value from jsonb_array_elements(g.players) loop
  if member->>'is_bot' = 'true' then
   if bot_index>=3 then raise exception 'Un joueur humain est requis'; end if;
   member:=member || (catalog->bot_index);
   bot_index:=bot_index+1;
  end if;
  member:=member||jsonb_build_object('is_host',member->>'id'=g.players->0->>'id');
  normalized:=normalized || jsonb_build_array(member);
 end loop;
 g.players:=normalized;
 n:=jsonb_array_length(g.players);
 while n<4 loop
  select s into target from generate_series(0,3) s where not exists(select 1 from jsonb_array_elements(g.players) p where (p->>'seat')::int=s) order by s limit 1;
  select case when count(*) filter(where coalesce((p->>'team')::int,(p->>'seat')::int%2)=0)<=count(*) filter(where coalesce((p->>'team')::int,(p->>'seat')::int%2)=1) then 0 else 1 end into chosen_team from jsonb_array_elements(g.players) p;
  profile := catalog->bot_index;
  g.players:=g.players || jsonb_build_array(profile || jsonb_build_object(
    'id','bot_'||target,'seat',target,'team',chosen_team,'is_host',false,'is_bot',true));
  n:=n+1; bot_index:=bot_index+1;
 end loop;
 update public.games set players=g.players,status=case when g.mode='private' then 'waiting' else 'ready' end where id=game;
end;
$$;

create or replace function private.publish_game_state(game uuid, payload jsonb) returns void language plpgsql security definer set search_path='' as $$
declare g public.games; seat int; v bigint;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if octet_length(payload::text)>100000 then raise exception 'État trop volumineux'; end if;
 select * into strict g from public.games where id=game for update;
 select (p->>'seat')::int into seat from jsonb_array_elements(g.players) p where p->>'id'=auth.uid()::text;
 if seat is null then raise exception 'Joueur non membre'; end if;
 if g.status not in ('ready','playing') then raise exception 'Partie inactive'; end if;
 v:=coalesce((g.game_state->>'version')::bigint,0);
 if (payload->>'version')::bigint<=v then return; end if;
 if g.players->0->>'id' is distinct from auth.uid()::text and ((payload->>'lastActionSeat')::int is distinct from seat or
    ((g.game_state->>'currentPlayer')::int is distinct from seat and
     (payload - 'version' - 'signs' - 'lastActionSeat') is distinct from (g.game_state - 'version' - 'signs' - 'lastActionSeat'))) then raise exception 'Tour invalide'; end if;
 update public.games set game_state=payload,status='playing' where id=game;
end $$;

create or replace function private.close_game(game uuid) returns void
language plpgsql security definer set search_path='' as $$
declare g public.games;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if exists(select 1 from public.games where id=game and is_public and status='waiting' and players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text))) then perform private.leave_public_queue(game); return; end if;
  select * into strict g from public.games where id=game for update;
  if g.players->0->>'id' is distinct from auth.uid()::text then
    raise exception 'Seul l’hôte peut fermer le salon';
  end if;
  if g.status in ('cancelled','finished') then return; end if;
  update public.games set status='cancelled',game_state=null where id=game;
  update public.game_invitations set status='declined'
    where game_id=game and status='pending';
end $$;

COMMIT;
