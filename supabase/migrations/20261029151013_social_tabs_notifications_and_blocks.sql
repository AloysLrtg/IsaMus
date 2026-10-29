-- Preserve existing friendships and the API used by installed clients.
create table if not exists public.friendships (
 id uuid primary key default gen_random_uuid(),
 user_id_1 uuid not null references public.profiles(id) on delete cascade,
 user_id_2 uuid not null references public.profiles(id) on delete cascade,
 status text not null default 'pending',
 created_at timestamptz not null default now(),
 check(user_id_1<>user_id_2)
);
-- Read aliases cannot diverge from the original sender/receiver UUIDs.
-- Requests continue to insert user_id_1/user_id_2 for backwards compatibility.
alter table public.friendships add column sender_id uuid generated always as (user_id_1) stored;
alter table public.friendships add column receiver_id uuid generated always as (user_id_2) stored;
alter table public.friendships drop constraint if exists friendships_status_check;
alter table public.friendships add constraint friendships_status_check check(status in ('pending','accepted','declined'));
create unique index if not exists friendships_pair on public.friendships(least(user_id_1,user_id_2),greatest(user_id_1,user_id_2));
create index if not exists friendships_recipient on public.friendships(user_id_2,status);
create index if not exists friendships_sender on public.friendships(user_id_1,status);
alter table public.friendships enable row level security;
revoke all on public.friendships from anon,authenticated;
grant select on public.friendships to authenticated;
grant insert(user_id_1,user_id_2),update(status),delete on public.friendships to authenticated;
drop policy if exists friends_read on public.friendships;
drop policy if exists friends_request on public.friendships;
drop policy if exists friends_accept on public.friendships;
drop policy if exists friends_remove on public.friendships;
create policy friends_read on public.friendships for select to authenticated using((select auth.uid()) in (user_id_1,user_id_2));
create policy friends_request on public.friendships for insert to authenticated with check(user_id_1=(select auth.uid()) and status='pending');
create policy friends_accept on public.friendships for update to authenticated using(user_id_2=(select auth.uid()) and status='pending') with check(user_id_2=(select auth.uid()) and status in ('accepted','declined'));
create policy friends_remove on public.friendships for delete to authenticated using((select auth.uid()) in (user_id_1,user_id_2));

-- Directional blocks; either direction prevents new social contact.
create table public.blocked_users (
 blocker_id uuid not null references public.profiles(id) on delete cascade,
 blocked_id uuid not null references public.profiles(id) on delete cascade,
 created_at timestamptz not null default now(),
 primary key(blocker_id,blocked_id),check(blocker_id<>blocked_id)
);
create index blocked_users_recipient on public.blocked_users(blocked_id,blocker_id);
alter table public.blocked_users enable row level security;
revoke all on public.blocked_users from public,anon,authenticated;
grant select on public.blocked_users to authenticated;
create policy blocks_own_read on public.blocked_users for select to authenticated using(blocker_id=(select auth.uid()));
create function private.social_pair_lock(a uuid,b uuid) returns void language sql set search_path='' as $$
 select pg_advisory_xact_lock(hashtextextended(least(a,b)::text||':'||greatest(a,b)::text,74812003))
$$;
create function private.social_pair_blocked(a uuid,b uuid) returns boolean language sql volatile security definer set search_path='' as $$
 select exists(select 1 from public.blocked_users where (blocker_id=a and blocked_id=b) or (blocker_id=b and blocked_id=a))
$$;
revoke all on function private.social_pair_lock(uuid,uuid),private.social_pair_blocked(uuid,uuid) from public,anon,authenticated;

create function private.guard_social_contact() returns trigger language plpgsql security definer set search_path='' as $$
declare a uuid; b uuid;
begin
 if tg_table_name='friendships' then a:=new.user_id_1;b:=new.user_id_2;
 else a:=new.sender_id;b:=new.recipient_id; end if;
 -- Only inserts acquire the pair lock: updates already hold a row lock.
 -- This order avoids cycles with block_user's pair-lock then row cleanup.
 if new.status in ('pending','accepted') then
   if tg_op='INSERT' then perform private.social_pair_lock(a,b); end if;
   if private.social_pair_blocked(a,b) then raise exception 'Contact indisponible' using errcode='42501'; end if;
 end if;
 return new;
end $$;
revoke all on function private.guard_social_contact() from public,anon,authenticated;
create trigger friendships_block_guard before insert or update of status on public.friendships for each row execute function private.guard_social_contact();
create trigger invitations_block_guard before insert or update of status on public.game_invitations for each row execute function private.guard_social_contact();

create function private.block_user(p_user_id uuid) returns void language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null or p_user_id is null or p_user_id=auth.uid() then raise exception 'Joueur invalide'; end if;
 perform private.social_pair_lock(auth.uid(),p_user_id);
 insert into public.blocked_users(blocker_id,blocked_id) values(auth.uid(),p_user_id) on conflict do nothing;
 delete from public.friendships where (user_id_1=auth.uid() and user_id_2=p_user_id) or (user_id_2=auth.uid() and user_id_1=p_user_id);
 update public.game_invitations set status='declined' where status='pending' and ((sender_id=auth.uid() and recipient_id=p_user_id) or (sender_id=p_user_id and recipient_id=auth.uid()));
end $$;
create function public.block_user(p_user_id uuid) returns void language sql security invoker set search_path='' as $$select private.block_user(p_user_id)$$;
create function private.unblock_user(p_user_id uuid) returns void language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform private.social_pair_lock(auth.uid(),p_user_id);
 delete from public.blocked_users where blocker_id=auth.uid() and blocked_id=p_user_id;
end $$;
create function public.unblock_user(p_user_id uuid) returns void language sql security invoker set search_path='' as $$select private.unblock_user(p_user_id)$$;
revoke all on function private.block_user(uuid),public.block_user(uuid),private.unblock_user(uuid),public.unblock_user(uuid) from public,anon;
grant execute on function private.block_user(uuid),public.block_user(uuid),private.unblock_user(uuid),public.unblock_user(uuid) to authenticated;

create function private.search_social_players(p_query text) returns table(id uuid,username text,avatar text,avatar_config jsonb,elo integer) language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if p_query is null or char_length(trim(p_query))<2 or char_length(p_query)>64 then return; end if;
 return query select p.id,p.username,p.avatar,p.avatar_config,p.elo from public.profiles p where p.id<>auth.uid() and strpos(lower(p.username),lower(trim(p_query)))>0 and not private.social_pair_blocked(auth.uid(),p.id) order by lower(p.username),p.id limit 20;
end $$;
create function public.search_social_players(p_query text) returns table(id uuid,username text,avatar text,avatar_config jsonb,elo integer) language sql security invoker set search_path='' as $$select * from private.search_social_players(p_query)$$;
revoke all on function private.search_social_players(text),public.search_social_players(text) from public,anon;
grant execute on function private.search_social_players(text),public.search_social_players(text) to authenticated;

create or replace function private.invite_friend(friend uuid,game uuid) returns void language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform private.social_pair_lock(auth.uid(),friend);
 if private.social_pair_blocked(auth.uid(),friend) then raise exception 'Contact indisponible'; end if;
 if not exists(select 1 from public.friendships where status='accepted' and (user_id_1=auth.uid() and user_id_2=friend or user_id_2=auth.uid() and user_id_1=friend)) then raise exception 'Ami requis'; end if;
 if not exists(select 1 from public.games g where g.id=game and g.mode='private' and g.status='waiting' and g.players->0->>'id'=auth.uid()::text) then raise exception 'Salon privé ouvert requis'; end if;
 insert into public.game_invitations(sender_id,recipient_id,game_id) values(auth.uid(),friend,game)
 on conflict(game_id,recipient_id) do update set status='pending',expires_at=now()+interval '10 minutes',created_at=now();
end $$;
create or replace function private.accept_invitation(invitation uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare i public.game_invitations; code text; result uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict i from public.game_invitations where id=invitation and recipient_id=auth.uid();
 perform private.social_pair_lock(i.sender_id,i.recipient_id);
 select join_code into strict code from public.games where id=i.game_id for update;
 select * into strict i from public.game_invitations where id=invitation and recipient_id=auth.uid() for update;
 if private.social_pair_blocked(i.sender_id,i.recipient_id) or i.status<>'pending' or i.expires_at<now() then raise exception 'Invitation indisponible'; end if;
 select join_code into strict code from public.games where id=i.game_id;
 result:=private.join_game(code);
 update public.game_invitations set status='accepted' where id=invitation;
 return result;
end $$;
do $$begin
 if exists(select 1 from pg_publication where pubname='supabase_realtime') and not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='blocked_users') then alter publication supabase_realtime add table public.blocked_users; end if;
end $$;
