-- Money and VIP authority stays on the server; clients have read-only access.
alter table public.profiles add column coins integer not null default 0 check(coins>=0), add column vip_expires_at timestamptz;
alter table public.match_results add column coins_earned integer not null default 0 check(coins_earned>=0), add column rewards_settled boolean not null default true;
alter table public.match_results alter column rewards_settled set default false;
create table public.quests (
 id text primary key, title text not null, target integer not null check(target>0), reward integer not null check(reward>0),
 mode text check(mode in ('ranked','casual','solo','private')), wins_only boolean not null default false, enabled boolean not null default true
);
insert into public.quests(id,title,target,reward,mode,wins_only) values
 ('play_week','Terminer 5 parties',5,50,null,false),('win_week','Gagner 3 parties',3,75,null,true),('ranked_wins','Gagner 2 parties classées',2,100,'ranked',true);
create table public.user_progress (
 user_id uuid not null references public.profiles(id) on delete cascade, quest_id text not null references public.quests(id),
 week_start date not null check(extract(isodow from week_start)=1), progress integer not null default 0 check(progress>=0), rewarded boolean not null default false,
 primary key(user_id,quest_id,week_start)
);
create table public.pass_claims (
 user_id uuid not null references public.profiles(id) on delete cascade, week_start date not null,
 tier integer not null check(tier between 1 and 3), vip_track boolean not null, coins integer not null check(coins>0),
 primary key(user_id,week_start,tier,vip_track)
);
alter table public.quests enable row level security;
alter table public.user_progress enable row level security;
alter table public.pass_claims enable row level security;
revoke all on public.quests,public.user_progress,public.pass_claims from public,anon,authenticated;
grant select on public.quests,public.user_progress,public.pass_claims to authenticated;
create policy quests_read on public.quests for select to authenticated using(enabled);
create policy progress_read on public.user_progress for select to authenticated using(user_id=(select auth.uid()));
create policy pass_read on public.pass_claims for select to authenticated using(user_id=(select auth.uid()));

create function private.apply_match_rewards(game uuid) returns void language plpgsql security definer set search_path='' as $$
declare r record; q record; p public.user_progress; multiplier integer; earned integer; week date := date_trunc('week',now() at time zone 'UTC')::date;
begin
 for r in select * from public.match_results where game_id=game and not rewards_settled order by user_id for update loop
  select case when vip_expires_at>now() then 3 else 1 end into strict multiplier from public.profiles where id=r.user_id for update;
  earned:=(10+case when r.won then 10 else 0 end)*multiplier;
  for q in select * from public.quests where enabled and (mode is null or mode=r.mode) and (not wins_only or r.won) order by id loop
   insert into public.user_progress(user_id,quest_id,week_start) values(r.user_id,q.id,week) on conflict do nothing;
   select * into strict p from public.user_progress where user_id=r.user_id and quest_id=q.id and week_start=week for update;
   if not p.rewarded then
    p.progress:=least(q.target,p.progress+1);
    if p.progress=q.target then earned:=earned+q.reward*multiplier; end if;
    update public.user_progress set progress=p.progress,rewarded=(p.progress=q.target) where user_id=r.user_id and quest_id=q.id and week_start=week;
   end if;
  end loop;
  update public.profiles set coins=coins+earned where id=r.user_id;
  update public.match_results set coins_earned=earned,rewards_settled=true where game_id=game and user_id=r.user_id;
 end loop;
end $$;
revoke all on function private.apply_match_rewards(uuid) from public,anon,authenticated,service_role;

create function private.claim_pass(tier_number integer,premium boolean) returns integer language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); week date:=date_trunc('week',now() at time zone 'UTC')::date; played integer; vip boolean; amount integer; inserted integer;
begin
 if player is null then raise exception 'Authentication required'; end if;
 if tier_number not between 1 and 3 or tier_number is null or premium is null then raise exception 'Palier invalide'; end if;
 select coalesce(vip_expires_at>now(),false) into strict vip from public.profiles where id=player for update;
 if premium and not vip then raise exception 'VIP requis'; end if;
 select progress into played from public.user_progress where user_id=player and quest_id='play_week' and week_start=week;
 if coalesce(played,0)<(array[1,3,5])[tier_number] then raise exception 'Objectif non atteint'; end if;
 amount:=(array[20,40,60])[tier_number]*(case when vip then 3 else 1 end);
 insert into public.pass_claims values(player,week,tier_number,premium,amount) on conflict do nothing;
 get diagnostics inserted=row_count;
 if inserted=0 then return 0; end if;
 update public.profiles set coins=coins+amount where id=player;
 return amount;
end $$;
create function public.claim_pass(tier_number integer,premium boolean default false) returns integer language sql security invoker set search_path='' as $$ select private.claim_pass(tier_number,premium) $$;
revoke all on function private.claim_pass(integer,boolean),public.claim_pass(integer,boolean) from public,anon;
grant execute on function private.claim_pass(integer,boolean),public.claim_pass(integer,boolean) to authenticated;

create function private.retention_status() returns jsonb language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); week date:=date_trunc('week',now() at time zone 'UTC')::date; result jsonb;
begin
 if player is null then raise exception 'Authentication required'; end if;
 select jsonb_build_object('coins',coins,'vip',coalesce(vip_expires_at>now(),false),'week_start',week,
  'quests',(select coalesce(jsonb_agg(to_jsonb(q)||jsonb_build_object('progress',coalesce(p.progress,0),'rewarded',coalesce(p.rewarded,false)) order by q.id),'[]') from public.quests q left join public.user_progress p on p.quest_id=q.id and p.user_id=player and p.week_start=week where q.enabled),
  'claims',(select coalesce(jsonb_agg(jsonb_build_object('tier',tier,'vip_track',vip_track)),'[]') from public.pass_claims where user_id=player and week_start=week)) into strict result from public.profiles where id=player;
 return result;
end $$;
create function public.retention_status() returns jsonb language sql security invoker set search_path='' as $$ select private.retention_status() $$;
revoke all on function private.retention_status(),public.retention_status() from public,anon;
grant execute on function private.retention_status(),public.retention_status() to authenticated;

-- Only a verified RevenueCat snapshot, fetched by Edge, may set expiry.
create function private.sync_purchases(player uuid,items text[],vip_until timestamptz) returns void language plpgsql security definer set search_path='' as $$
begin
 if (auth.jwt()->>'role') is distinct from 'service_role' then raise exception 'Server only'; end if;
 perform private.sync_inventory(player,items);
 update public.profiles set vip_expires_at=vip_until where id=player;
end $$;
create function public.sync_purchases(player uuid,items text[],vip_until timestamptz) returns void language sql security invoker set search_path='' as $$ select private.sync_purchases(player,items,vip_until) $$;
revoke all on function private.sync_purchases(uuid,text[],timestamptz),public.sync_purchases(uuid,text[],timestamptz) from public,anon,authenticated;
grant execute on function private.sync_purchases(uuid,text[],timestamptz),public.sync_purchases(uuid,text[],timestamptz) to service_role;

create or replace function private.finish_game(game uuid) returns void language plpgsql security definer set search_path='' as $$
declare g public.games; winner int; p record; before_elo int; opponent numeric; delta int; ranked boolean; result_mode text;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict g from public.games where id=game for update;
 if not g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) then raise exception 'Joueur non membre'; end if;
 if exists(select 1 from public.match_results where game_id=game) then return; end if;
 if g.players->0->>'id'<>auth.uid()::text then raise exception 'En attente de la validation de l’hôte'; end if;
 if g.game_state->>'phase' is distinct from 'gameOver' then raise exception 'Partie non terminée'; end if;
 winner:=case when (g.game_state->'tantto'->>0)::int>=40 or (g.game_state->'manches'->>0)::int>=3 then 0 when (g.game_state->'tantto'->>1)::int>=40 or (g.game_state->'manches'->>1)::int>=3 then 1 else null end;
 if winner is null then raise exception 'Résultat invalide'; end if;
 result_mode:=case when g.mode='ranked' then 'ranked'
   when jsonb_array_length(g.players)=4 and (select count(*) from jsonb_array_elements(g.players) x where coalesce((x->>'is_bot')::boolean,false))=3 then 'solo'
   else g.mode end;
 ranked:=result_mode='ranked' and not exists(select 1 from jsonb_array_elements(g.players) x where coalesce((x->>'is_bot')::boolean,false));
 perform 1 from public.profiles where id::text in(select x->>'id' from jsonb_array_elements(g.players) x) order by id for update;
 for p in select pr.id, pr.elo,(x->>'seat')::int as seat from jsonb_array_elements(g.players) x join public.profiles pr on pr.id::text=x->>'id' loop
  before_elo:=coalesce(p.elo,1200);
  select avg(coalesce(pr.elo,1200)) into opponent from jsonb_array_elements(g.players) x join public.profiles pr on pr.id::text=x->>'id' where (x->>'seat')::int%2<>p.seat%2;
  delta:=case when ranked then round(32*((case when p.seat%2=winner then 1 else 0 end)-1/(1+power(10,(coalesce(opponent,1200)-before_elo)/400))))::int else 0 end;
  insert into public.match_results(game_id,user_id,won,mode,elo_before,elo_after) values(game,p.id,p.seat%2=winner,result_mode,before_elo,greatest(0,before_elo+delta));
 end loop;
 update public.profiles pr set elo=r.elo_after,
   peak_elo=greatest(pr.peak_elo,coalesce(pr.elo,1200),r.elo_after),
   games_played=coalesce(pr.games_played,0)+1,
   games_won=coalesce(pr.games_won,0)+case when r.won then 1 else 0 end,
   casual_played=pr.casual_played+case when result_mode not in ('ranked','solo') then 1 else 0 end,
   casual_won=pr.casual_won+case when result_mode not in ('ranked','solo') and r.won then 1 else 0 end,
   ranked_played=pr.ranked_played+case when result_mode='ranked' then 1 else 0 end,
   ranked_won=pr.ranked_won+case when result_mode='ranked' and r.won then 1 else 0 end,
   solo_played=pr.solo_played+case when result_mode='solo' then 1 else 0 end,
   solo_won=pr.solo_won+case when result_mode='solo' and r.won then 1 else 0 end
 from public.match_results r where r.game_id=game and r.user_id=pr.id;
 perform private.apply_match_rewards(game);
 update public.games set status='finished' where id=game;
end $$;
