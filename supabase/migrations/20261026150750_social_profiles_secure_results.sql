-- MVP upgrade. Host-authoritative gameplay remains a trust boundary.
create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

alter table public.profiles add column avatar text not null default 'mus';
alter table public.profiles add column card_back text not null default 'classic';
alter table public.profiles add column table_theme text not null default 'green';
alter table public.profiles add column sound_enabled boolean not null default true;

create table public.cosmetics (
 id text primary key, kind text not null check(kind in ('avatar','card_back','table_theme')),
 label text not null, free boolean not null default false, product_id text unique
);
insert into public.cosmetics values
 ('mus','avatar','Mus',true,null), ('sun','avatar','Soleil',true,null), ('mountain','avatar','Montagne',true,null),
 ('classic','card_back','Classique',true,null), ('blue','card_back','Bleu',true,null),
 ('gold','card_back','Or',false,'isamus.card_back.gold'),
 ('green','table_theme','Vert',true,null), ('ocean','table_theme','Océan',true,null),
 ('ruby','table_theme','Rubis',false,'isamus.table.ruby');
create table public.inventory (
 user_id uuid references public.profiles(id) on delete cascade,
 cosmetic_id text references public.cosmetics(id), acquired_at timestamptz not null default now(),
 primary key(user_id,cosmetic_id)
);
create table public.friendships (
 id uuid primary key default gen_random_uuid(),
 user_id_1 uuid not null references public.profiles(id) on delete cascade,
 user_id_2 uuid not null references public.profiles(id) on delete cascade,
 status text not null default 'pending' check(status in ('pending','accepted')),
 created_at timestamptz not null default now(), check(user_id_1 <> user_id_2)
);
create unique index friendships_pair on public.friendships(least(user_id_1,user_id_2),greatest(user_id_1,user_id_2));
create index friendships_recipient on public.friendships(user_id_2,status);
create index friendships_sender on public.friendships(user_id_1,status);
create table public.game_invitations (
 id uuid primary key default gen_random_uuid(),
 sender_id uuid not null references public.profiles(id) on delete cascade,
 recipient_id uuid not null references public.profiles(id) on delete cascade,
 game_id uuid not null references public.games(id) on delete cascade,
 status text not null default 'pending' check(status in ('pending','accepted','declined')),
 expires_at timestamptz not null default now() + interval '10 minutes',
 created_at timestamptz not null default now(), unique(game_id,recipient_id)
);
create index invitations_recipient on public.game_invitations(recipient_id,status);
create index invitations_sender on public.game_invitations(sender_id);
create table public.match_results (
 game_id uuid not null references public.games(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 won boolean not null, mode text not null, elo_before integer not null,
 elo_after integer not null, finished_at timestamptz not null default now(),
 primary key(game_id,user_id)
);
create index results_history on public.match_results(user_id,finished_at desc);
create index profiles_leaderboard on public.profiles(elo desc,id);

alter table public.cosmetics enable row level security;
alter table public.inventory enable row level security;
alter table public.friendships enable row level security;
alter table public.game_invitations enable row level security;
alter table public.match_results enable row level security;
revoke all on public.cosmetics, public.inventory, public.friendships, public.game_invitations, public.match_results from anon, authenticated;
grant select on public.cosmetics, public.inventory, public.friendships, public.game_invitations, public.match_results to authenticated;
grant insert(user_id_1,user_id_2) on public.friendships to authenticated;
grant update(status), delete on public.friendships to authenticated;
grant update(status) on public.game_invitations to authenticated;
create policy cosmetics_read on public.cosmetics for select to authenticated using(true);
create policy inventory_own on public.inventory for select to authenticated using(user_id=(select auth.uid()));
create policy results_own on public.match_results for select to authenticated using(user_id=(select auth.uid()));
create policy friends_read on public.friendships for select to authenticated using((select auth.uid()) in(user_id_1,user_id_2));
create policy friends_request on public.friendships for insert to authenticated with check(user_id_1=(select auth.uid()) and status='pending');
create policy friends_accept on public.friendships for update to authenticated using(user_id_2=(select auth.uid()) and status='pending') with check(user_id_2=(select auth.uid()) and status='accepted');
create policy friends_remove on public.friendships for delete to authenticated using((select auth.uid()) in(user_id_1,user_id_2));
create policy invitations_read on public.game_invitations for select to authenticated using((select auth.uid()) in(sender_id,recipient_id));
create policy invitations_respond on public.game_invitations for update to authenticated using(recipient_id=(select auth.uid()) and status='pending') with check(recipient_id=(select auth.uid()) and status in ('accepted','declined'));

-- Protect ratings and inventory from all client writes, including profile insertion.
revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant insert(id,username), update(username,sound_enabled) on public.profiles to authenticated;
drop policy "Lecture publique" on public.profiles;
drop policy "Création par l'utilisateur" on public.profiles;
drop policy "Mise à jour par l'utilisateur" on public.profiles;
create policy profiles_read on public.profiles for select to authenticated using(true);
create policy profiles_create on public.profiles for insert to authenticated with check(id=(select auth.uid()) and length(trim(username)) between 1 and 24);
create policy profiles_update on public.profiles for update to authenticated using(id=(select auth.uid())) with check(id=(select auth.uid()) and length(trim(username)) between 1 and 24);

create function private.equip_cosmetic(item text) returns void language plpgsql security definer set search_path='' as $$
declare c public.cosmetics;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict c from public.cosmetics where id=item;
 if not c.free and not exists(select 1 from public.inventory where user_id=auth.uid() and cosmetic_id=item) then raise exception 'Cosmétique non possédé'; end if;
 update public.profiles set avatar=case when c.kind='avatar' then item else avatar end,
 card_back=case when c.kind='card_back' then item else card_back end,
 table_theme=case when c.kind='table_theme' then item else table_theme end where id=auth.uid();
end $$;
create function public.equip_cosmetic(item text) returns void language sql security invoker set search_path='' as $$select private.equip_cosmetic(item)$$;

-- Membership is read from the server row, never from user-supplied metadata.
drop policy "Allow all access" on public.games;
revoke all on public.games from anon, authenticated;
grant select on public.games to authenticated;
grant insert(join_code,status,mode,players) on public.games to authenticated;
create policy games_member_read on public.games for select to authenticated using(players @> jsonb_build_array(jsonb_build_object('id',(select auth.uid())::text)));
create policy games_host_create on public.games for insert to authenticated with check(
 auth.uid() is not null and exists(select 1 from public.profiles where id=(select auth.uid())) and status='waiting' and mode in ('casual','ranked','private') and game_state is null and
 jsonb_array_length(players)=1 and players->0->>'id'=auth.uid()::text and (players->0->>'seat')::int=0 and coalesce((players->0->>'is_bot')::boolean,false)=false
);
create function private.join_game(code text) returns uuid language plpgsql security definer set search_path='' as $$
declare g public.games; p text; n int;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select username into strict p from public.profiles where id=auth.uid();
 select * into g from public.games where join_code=upper(trim(code)) for update;
 if not found then raise exception 'Partie introuvable'; end if;
 if g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) then return g.id; end if;
 n:=jsonb_array_length(g.players);
 if g.status<>'waiting' or n>=4 then raise exception 'Partie complète ou déjà commencée'; end if;
 update public.games set players=g.players || jsonb_build_array(jsonb_build_object('id',auth.uid(),'name',p,'seat',n,'is_host',false,'is_bot',false)), status=case when n=3 then 'ready' else 'waiting' end where id=g.id;
 return g.id;
end $$;
create function public.join_game(code text) returns uuid language sql security invoker set search_path='' as $$ select private.join_game(code) $$;
create function private.start_with_bots(game uuid) returns void language plpgsql security definer set search_path='' as $$
declare g public.games; n int;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict g from public.games where id=game for update;
 if g.players->0->>'id'<>auth.uid()::text then raise exception 'Hôte requis'; end if;
 if g.status<>'waiting' then return; end if;
 if g.mode='ranked' then raise exception 'Quatre joueurs humains requis en mode classé'; end if;
 n:=jsonb_array_length(g.players);
 while n<4 loop
  g.players:=g.players || jsonb_build_array(jsonb_build_object('id','bot_'||n,'name','Bot '||n,'seat',n,'is_host',false,'is_bot',true)); n:=n+1;
 end loop;
 update public.games set players=g.players,status='ready' where id=game;
end $$;
create function public.start_with_bots(game uuid) returns void language sql security invoker set search_path='' as $$ select private.start_with_bots(game) $$;

create function private.publish_game_state(game uuid, payload jsonb) returns void language plpgsql security definer set search_path='' as $$
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
 if seat<>0 and ((payload->>'lastActionSeat')::int is distinct from seat or
    ((g.game_state->>'currentPlayer')::int is distinct from seat and
     (payload - 'version' - 'signs' - 'lastActionSeat') is distinct from (g.game_state - 'version' - 'signs' - 'lastActionSeat'))) then raise exception 'Tour invalide'; end if;
 update public.games set game_state=payload,status='playing' where id=game;
end $$;
create function public.publish_game_state(game uuid,payload jsonb) returns void language sql security invoker set search_path='' as $$ select private.publish_game_state(game,payload) $$;

create function private.invite_friend(friend uuid,game uuid) returns void language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not exists(select 1 from public.friendships where status='accepted' and (user_id_1=auth.uid() and user_id_2=friend or user_id_2=auth.uid() and user_id_1=friend)) then raise exception 'Ami requis'; end if;
 if not exists(select 1 from public.games g where g.id=game and g.mode='private' and g.status='waiting' and g.players->0->>'id'=auth.uid()::text) then raise exception 'Salon privé ouvert requis'; end if;
 insert into public.game_invitations(sender_id,recipient_id,game_id) values(auth.uid(),friend,game)
 on conflict(game_id,recipient_id) do update set status='pending',expires_at=now()+interval '10 minutes',created_at=now();
end $$;
create function public.invite_friend(friend uuid,game uuid) returns void language sql security invoker set search_path='' as $$select private.invite_friend(friend,game)$$;
create function private.accept_invitation(invitation uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare i public.game_invitations; code text; result uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict i from public.game_invitations where id=invitation and recipient_id=auth.uid() for update;
 if i.status<>'pending' or i.expires_at<now() then raise exception 'Invitation expirée'; end if;
 select join_code into strict code from public.games where id=i.game_id;
 result:=private.join_game(code);
 update public.game_invitations set status='accepted' where id=invitation;
 return result;
end $$;
create function public.accept_invitation(invitation uuid) returns uuid language sql security invoker set search_path='' as $$ select private.accept_invitation(invitation) $$;

-- One transaction per game; locks profiles in UUID order to avoid deadlocks.
create function private.finish_game(game uuid) returns void language plpgsql security definer set search_path='' as $$
declare g public.games; winner int; p record; before_elo int; opponent numeric; delta int; ranked boolean;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict g from public.games where id=game for update;
 if not g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) then raise exception 'Joueur non membre'; end if;
 if exists(select 1 from public.match_results where game_id=game) then return; end if;
 if g.players->0->>'id'<>auth.uid()::text then raise exception 'En attente de la validation de l’hôte'; end if;
 if g.game_state->>'phase' is distinct from 'gameOver' then raise exception 'Partie non terminée'; end if;
 winner:=case when (g.game_state->'tantto'->>0)::int>=40 or (g.game_state->'manches'->>0)::int>=3 then 0 when (g.game_state->'tantto'->>1)::int>=40 or (g.game_state->'manches'->>1)::int>=3 then 1 else null end;
 if winner is null then raise exception 'Résultat invalide'; end if;
 ranked:=g.mode='ranked' and not exists(select 1 from jsonb_array_elements(g.players) x where coalesce((x->>'is_bot')::boolean,false));
 perform 1 from public.profiles where id::text in(select x->>'id' from jsonb_array_elements(g.players) x) order by id for update;
 for p in select pr.id, pr.elo,(x->>'seat')::int as seat from jsonb_array_elements(g.players) x join public.profiles pr on pr.id::text=x->>'id' loop
  before_elo:=coalesce(p.elo,1200);
  select avg(coalesce(pr.elo,1200)) into opponent from jsonb_array_elements(g.players) x join public.profiles pr on pr.id::text=x->>'id' where (x->>'seat')::int%2<>p.seat%2;
  delta:=case when ranked then round(32*((case when p.seat%2=winner then 1 else 0 end)-1/(1+power(10,(coalesce(opponent,1200)-before_elo)/400))))::int else 0 end;
  insert into public.match_results(game_id,user_id,won,mode,elo_before,elo_after) values(game,p.id,p.seat%2=winner,g.mode,before_elo,greatest(0,before_elo+delta));
 end loop;
 update public.profiles pr set elo=r.elo_after,games_played=coalesce(pr.games_played,0)+1,games_won=coalesce(pr.games_won,0)+case when r.won then 1 else 0 end from public.match_results r where r.game_id=game and r.user_id=pr.id;
 update public.games set status='finished' where id=game;
end $$;
create function public.finish_game(game uuid) returns void language sql security invoker set search_path='' as $$ select private.finish_game(game) $$;

-- Private Presence channels expose status only to accepted friends. Only the owner publishes.
create policy presence_read on realtime.messages for select to authenticated using(extension='presence' and (
 realtime.topic()='presence:'||(select auth.uid())::text or exists(select 1 from public.friendships f where f.status='accepted' and
 (f.user_id_1=(select auth.uid()) and realtime.topic()='presence:'||f.user_id_2::text or f.user_id_2=(select auth.uid()) and realtime.topic()='presence:'||f.user_id_1::text))));
create policy presence_write on realtime.messages for insert to authenticated with check(extension='presence' and realtime.topic()='presence:'||(select auth.uid())::text);

-- Explicitly restrict every RPC, including implementation functions.
revoke all on all functions in schema private from public,anon;
grant execute on all functions in schema private to authenticated;
revoke all on function public.equip_cosmetic(text),public.join_game(text),public.start_with_bots(uuid),public.publish_game_state(uuid,jsonb),public.invite_friend(uuid,uuid),public.accept_invitation(uuid),public.finish_game(uuid) from public,anon;
grant execute on function public.equip_cosmetic(text),public.join_game(text),public.start_with_bots(uuid),public.publish_game_state(uuid,jsonb),public.invite_friend(uuid,uuid),public.accept_invitation(uuid),public.finish_game(uuid) to authenticated;

do $$ begin
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='friendships') then alter publication supabase_realtime add table public.friendships; end if;
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='game_invitations') then alter publication supabase_realtime add table public.game_invitations; end if;
end $$;

-- Called only by the authenticated Edge Function after RevenueCat verification.
create function private.sync_inventory(player uuid, items text[]) returns void language plpgsql security definer set search_path='' as $$
begin
 if (auth.jwt()->>'role') is distinct from 'service_role' then raise exception 'Server only'; end if;
 perform 1 from public.profiles where id=player for update;
 if not found then return; end if;
 delete from public.inventory where user_id=player and cosmetic_id in(select id from public.cosmetics where not free) and not(cosmetic_id=any(items));
 insert into public.inventory(user_id,cosmetic_id) select player,id from public.cosmetics where not free and id=any(items) on conflict do nothing;
 update public.profiles p set card_back=case when p.card_back='gold' and not('gold'=any(items)) then 'classic' else p.card_back end,
 table_theme=case when p.table_theme='ruby' and not('ruby'=any(items)) then 'green' else p.table_theme end where id=player;
end $$;
create function public.sync_inventory(player uuid,items text[]) returns void language sql security invoker set search_path='' as $$select private.sync_inventory(player,items)$$;

create function private.erase_account(player uuid) returns void language plpgsql security definer set search_path='' as $$
begin
 if (auth.jwt()->>'role') is distinct from 'service_role' then raise exception 'Server only'; end if;
 -- Remove names and identifiers from retained game snapshots. Other players keep their own history.
 update public.games g set players=(select jsonb_agg(case when x->>'id'=player::text or x->>'seat'=(select member->>'seat' from jsonb_array_elements(g.players) member where member->>'id'=player::text limit 1) then (x-'id'-'name')||'{"id":"deleted","name":"Joueur supprimé"}'::jsonb else x end order by ord) from jsonb_array_elements(g.players) with ordinality t(x,ord)),
 game_state=case when g.game_state is null then null else jsonb_set(g.game_state,'{players}',coalesce((select jsonb_agg(case when x->>'id'=player::text or x->>'seat'=(select member->>'seat' from jsonb_array_elements(g.players) member where member->>'id'=player::text limit 1) then (x-'id'-'name')||'{"id":"deleted","name":"Joueur supprimé"}'::jsonb else x end order by ord) from jsonb_array_elements(coalesce(g.game_state->'players','[]'::jsonb)) with ordinality t(x,ord)),'[]'::jsonb)) end
 where g.players @> jsonb_build_array(jsonb_build_object('id',player::text));
 delete from auth.sessions where user_id=player;
 delete from public.profiles where id=player;
 delete from auth.users where id=player;
end $$;
create function public.erase_account(player uuid) returns void language sql security invoker set search_path='' as $$select private.erase_account(player)$$;
revoke all on function private.sync_inventory(uuid,text[]),private.erase_account(uuid),public.sync_inventory(uuid,text[]),public.erase_account(uuid) from public,anon,authenticated;
grant usage on schema private to service_role;
grant execute on function private.sync_inventory(uuid,text[]),private.erase_account(uuid),public.sync_inventory(uuid,text[]),public.erase_account(uuid) to service_role;
