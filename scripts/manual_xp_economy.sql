-- Migration 20261029114221_xp_only_matches_and_quests
-- IsaMus : XP pour les parties et quêtes ; pièces uniquement dans le Pass de Saison.
-- À exécuter une seule fois dans le SQL Editor du projet nakbrpgecwpphyynsdor.
-- Indépendant de la migration des accessoires de boutique. Soldes historiques conservés.
begin;
-- New rewards only: keep historical wallets, receipts and completed quests.
alter table public.quests add column reward_xp integer not null default 250 check(reward_xp>0);
update public.quests set reward_xp=case id when 'play_week' then 250 when 'win_week' then 375 when 'ranked_wins' then 500 else reward*5 end;
alter table public.user_progress add column xp_earned integer not null default 0 check(xp_earned>=0);
alter table public.match_results add column quest_xp_earned integer not null default 0 check(quest_xp_earned>=0);

-- Internal helper: the game host can settle all participants, but clients cannot
-- choose the recipient, progress, reward amount or week.
create function private.award_quest_xp(player uuid, quest text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare q public.quests; p public.user_progress; amount integer; boost integer;
 current_week date:=date_trunc('week',now() at time zone 'UTC')::date;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select case when vip_expires_at>now() then 2 else 1 end into strict boost from public.profiles where id=player for update;
 select * into q from public.quests where id=quest and enabled;
 if not found then raise exception 'Quête indisponible'; end if;
 select * into p from public.user_progress where user_id=player and quest_id=quest and week_start=current_week for update;
 if not found then raise exception 'Objectif non atteint'; end if;
 if p.rewarded then return jsonb_build_object('xp',0,'already_claimed',true); end if;
 if p.progress<q.target then raise exception 'Objectif non atteint'; end if;
 amount:=q.reward_xp*boost;
 update public.profiles set level=level+(xp+amount)/500,xp=(xp+amount)%500 where id=player;
 update public.user_progress set rewarded=true,xp_earned=amount where user_id=player and quest_id=quest and week_start=current_week;
 return jsonb_build_object('xp',amount,'already_claimed',false);
end $$;
revoke all on function private.award_quest_xp(uuid,text) from public,anon,authenticated,service_role;

create function private.claim_quest_reward(p_quest_id text) returns jsonb
language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 return private.award_quest_xp(auth.uid(),p_quest_id);
end $$;
create function public.claim_quest_reward(p_quest_id text) returns jsonb
language sql security invoker set search_path='' as $$select private.claim_quest_reward(p_quest_id)$$;
revoke all on function private.claim_quest_reward(text),public.claim_quest_reward(text) from public,anon;
grant execute on function private.claim_quest_reward(text),public.claim_quest_reward(text) to authenticated;

-- record_game_result and the legacy finish_game both call this helper.
-- Row locks and rewards_settled make the entire settlement atomic/idempotent.
create or replace function private.apply_match_rewards(game uuid) returns void
language plpgsql security definer set search_path='' as $$
declare r record; q record; p public.user_progress; boost integer; base_xp integer; quest_xp integer; receipt jsonb;
 current_week date:=date_trunc('week',now() at time zone 'UTC')::date;
begin
 for r in select * from public.match_results where game_id=game and not rewards_settled order by user_id for update loop
  select case when vip_expires_at>now() then 2 else 1 end into strict boost from public.profiles where id=r.user_id for update;
  base_xp:=(case when r.won then 100 else 40 end)*boost;
  quest_xp:=0;
  for q in select * from public.quests where enabled and (mode is null or mode=r.mode) and (not wins_only or r.won) order by id loop
   insert into public.user_progress(user_id,quest_id,week_start) values(r.user_id,q.id,current_week) on conflict do nothing;
   select * into strict p from public.user_progress where user_id=r.user_id and quest_id=q.id and week_start=current_week for update;
   if not p.rewarded then
    p.progress:=least(q.target,p.progress+1);
    update public.user_progress set progress=p.progress where user_id=r.user_id and quest_id=q.id and week_start=current_week;
    if p.progress=q.target then
     receipt:=private.award_quest_xp(r.user_id,q.id);
     quest_xp:=quest_xp+(receipt->>'xp')::integer;
    end if;
   end if;
  end loop;
  update public.profiles set level=level+(xp+base_xp)/500,xp=(xp+base_xp)%500 where id=r.user_id;
  update public.match_results set coins_earned=0,xp_earned=base_xp+quest_xp,quest_xp_earned=quest_xp,rewards_settled=true where game_id=game and user_id=r.user_id;
 end loop;
end $$;
revoke all on function private.apply_match_rewards(uuid) from public,anon,authenticated,service_role;

create or replace function private.retention_status() returns jsonb language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); week date:=date_trunc('week',now() at time zone 'UTC')::date; current_season public.seasons; result jsonb;
begin
 if player is null then raise exception 'Authentication required'; end if;
 select * into current_season from public.seasons where start_date<=now() and end_date>now() and closed_at is null order by start_date desc,id limit 1;
 select jsonb_build_object('coins',coins,'level',level,'xp',xp,'vip',coalesce(vip_expires_at>now(),false),'week_start',week,
  'quests',(select coalesce(jsonb_agg(to_jsonb(q)||jsonb_build_object('progress',coalesce(p.progress,0),'rewarded',coalesce(p.rewarded,false),'earned_xp',coalesce(p.xp_earned,0)) order by q.id),'[]') from public.quests q left join public.user_progress p on p.quest_id=q.id and p.user_id=player and p.week_start=week where q.enabled),
  'season',case when current_season.id is null then null else to_jsonb(current_season)||jsonb_build_object('title',current_season.name,'starts_at',current_season.start_date,'ends_at',current_season.end_date) end,
  'rewards',(select coalesce(jsonb_agg(to_jsonb(r) order by tier),'[]') from public.season_rewards r where season_id=current_season.id),
  'claims',(select coalesce(jsonb_agg(jsonb_build_object('tier',tier,'vip_track',vip_track)),'[]') from public.season_pass_claims where user_id=player and season_id=current_season.id))
 into strict result from public.profiles where id=player;
 return result;
end $$;


commit;
