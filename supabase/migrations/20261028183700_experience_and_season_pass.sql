-- Lifetime levels use 500 XP per level, with the remainder stored in xp.
-- Historic results are already settled; no retrospective XP or coin payout.
alter table public.profiles
 add column level integer not null default 1 check(level>=1),
 add column xp integer not null default 0 check(xp>=0 and xp<500);
alter table public.match_results add column xp_earned integer not null default 0 check(xp_earned>=0);

create table public.seasons (
 id text primary key, title text not null, starts_at timestamptz not null,
 ends_at timestamptz not null, preview boolean not null default true,
 check(ends_at>starts_at)
);
-- This initial 20-day schedule is a preview, not a published commercial season.
insert into public.seasons values('season_1','Saison 1',now(),now()+interval '20 days',true);
create table public.season_rewards (
 season_id text not null references public.seasons(id), tier integer not null check(tier between 1 and 30),
 free_coins integer not null check(free_coins>0), vip_coins integer not null check(vip_coins>0),
 vip_cosmetic text references public.cosmetics(id), primary key(season_id,tier)
);
insert into public.season_rewards
 select 'season_1',n,20+n*5,40+n*10,case n when 15 then 'gold' when 30 then 'ruby' else null end
 from generate_series(1,30) n;
create index season_rewards_cosmetic_idx on public.season_rewards(vip_cosmetic) where vip_cosmetic is not null;
create table public.season_pass_claims (
 user_id uuid not null references public.profiles(id) on delete cascade,
 season_id text not null, tier integer not null, vip_track boolean not null,
 coins integer not null check(coins>0), cosmetic_id text references public.cosmetics(id),
 claimed_at timestamptz not null default now(),
 primary key(user_id,season_id,tier,vip_track),
 foreign key(season_id,tier) references public.season_rewards(season_id,tier)
);
create index season_claims_reward_idx on public.season_pass_claims(season_id,tier);
create index season_claims_cosmetic_idx on public.season_pass_claims(cosmetic_id) where cosmetic_id is not null;
alter table public.seasons enable row level security;
alter table public.season_rewards enable row level security;
alter table public.season_pass_claims enable row level security;
revoke all on public.seasons,public.season_rewards,public.season_pass_claims from public,anon,authenticated;
grant select on public.seasons,public.season_rewards,public.season_pass_claims to authenticated;
create policy seasons_read on public.seasons for select to authenticated using(true);
create policy season_rewards_read on public.season_rewards for select to authenticated using(true);
create policy season_claims_own on public.season_pass_claims for select to authenticated using(user_id=(select auth.uid()));

create function private.claim_season_pass(season text,tier_number integer,premium boolean) returns jsonb
 language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); pr public.profiles; reward public.season_rewards; amount integer; item text; inserted integer;
begin
 if player is null then raise exception 'Authentication required'; end if;
 if tier_number is null or tier_number not between 1 and 30 or premium is null then raise exception 'Palier invalide'; end if;
 perform 1 from public.seasons where id=season and starts_at<=now() and ends_at>now() for share;
 if not found then raise exception 'Saison indisponible'; end if;
 select * into strict pr from public.profiles where id=player for update;
 if pr.level<tier_number then raise exception 'Niveau insuffisant'; end if;
 if premium and not coalesce(pr.vip_expires_at>now(),false) then raise exception 'VIP requis'; end if;
 select * into strict reward from public.season_rewards where season_id=season and tier=tier_number;
 amount:=(case when premium then reward.vip_coins else reward.free_coins end)*(case when pr.vip_expires_at>now() then 3 else 1 end);
 item:=case when premium then reward.vip_cosmetic else null end;
 insert into public.season_pass_claims(user_id,season_id,tier,vip_track,coins,cosmetic_id)
 values(player,season,tier_number,premium,amount,item) on conflict do nothing;
 get diagnostics inserted=row_count;
 if inserted=0 then return jsonb_build_object('coins',0,'cosmetic',null,'already_claimed',true); end if;
 update public.profiles set coins=coins+amount where id=player;
 if item is not null then insert into public.inventory(user_id,cosmetic_id) values(player,item) on conflict do nothing; end if;
 return jsonb_build_object('coins',amount,'cosmetic',item,'already_claimed',false);
end $$;
create function public.claim_season_pass(season text,tier_number integer,premium boolean default false) returns jsonb
 language sql security invoker set search_path='' as $$select private.claim_season_pass(season,tier_number,premium)$$;
revoke all on function private.claim_season_pass(text,integer,boolean),public.claim_season_pass(text,integer,boolean) from public,anon;
grant execute on function private.claim_season_pass(text,integer,boolean),public.claim_season_pass(text,integer,boolean) to authenticated;

-- Retire weekly pass payouts, but retain their ledger for audit/history.
create or replace function private.claim_pass(tier_number integer,premium boolean) returns integer language plpgsql security definer set search_path='' as $$
begin raise exception 'Le pass hebdomadaire est terminé. Mettez à jour votre application pour le Pass de Saison.'; end $$;

create or replace function private.retention_status() returns jsonb language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); week date:=date_trunc('week',now() at time zone 'UTC')::date; current_season public.seasons; result jsonb;
begin
 if player is null then raise exception 'Authentication required'; end if;
 select * into current_season from public.seasons where starts_at<=now() and ends_at>now() order by starts_at desc,id limit 1;
 select jsonb_build_object('coins',coins,'level',level,'xp',xp,'vip',coalesce(vip_expires_at>now(),false),'week_start',week,
  'quests',(select coalesce(jsonb_agg(to_jsonb(q)||jsonb_build_object('progress',coalesce(p.progress,0),'rewarded',coalesce(p.rewarded,false)) order by q.id),'[]') from public.quests q left join public.user_progress p on p.quest_id=q.id and p.user_id=player and p.week_start=week where q.enabled),
  'season',case when current_season.id is null then null else to_jsonb(current_season) end,
  'rewards',(select coalesce(jsonb_agg(to_jsonb(r) order by tier),'[]') from public.season_rewards r where season_id=current_season.id),
  'claims',(select coalesce(jsonb_agg(jsonb_build_object('tier',tier,'vip_track',vip_track)),'[]') from public.season_pass_claims where user_id=player and season_id=current_season.id))
 into strict result from public.profiles where id=player;
 return result;
end $$;

-- Keep permanent season cosmetics when RevenueCat revokes a separate purchase.
create or replace function private.sync_inventory(player uuid, items text[]) returns void language plpgsql security definer set search_path='' as $$
begin
 if (auth.jwt()->>'role') is distinct from 'service_role' then raise exception 'Server only'; end if;
 perform 1 from public.profiles where id=player for update;
 if not found then return; end if;
 delete from public.inventory i where i.user_id=player and cosmetic_id in(select id from public.cosmetics where not free)
 and not(cosmetic_id=any(items)) and not exists(select 1 from public.season_pass_claims c where c.user_id=player and c.cosmetic_id=i.cosmetic_id);
 insert into public.inventory(user_id,cosmetic_id) select player,id from public.cosmetics where not free and id=any(items) on conflict do nothing;
 update public.profiles p set
 card_back=case when p.card_back='gold' and not exists(select 1 from public.inventory where user_id=player and cosmetic_id='gold') then 'classic' else p.card_back end,
 table_theme=case when p.table_theme='ruby' and not exists(select 1 from public.inventory where user_id=player and cosmetic_id='ruby') then 'green' else p.table_theme end where id=player;
end $$;

create or replace function private.apply_match_rewards(game uuid) returns void language plpgsql security definer set search_path='' as $$
declare r record; q record; p public.user_progress; multiplier integer; earned integer; gained_xp integer; week date := date_trunc('week',now() at time zone 'UTC')::date;
begin
 for r in select * from public.match_results where game_id=game and not rewards_settled order by user_id for update loop
  select case when vip_expires_at>now() then 3 else 1 end into strict multiplier from public.profiles where id=r.user_id for update;
  gained_xp:=(case when r.won then 100 else 40 end)*(case when multiplier=3 then 2 else 1 end);
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
  update public.profiles set coins=coins+earned,level=level+(xp+gained_xp)/500,xp=(xp+gained_xp)%500 where id=r.user_id;
  update public.match_results set coins_earned=earned,xp_earned=gained_xp,rewards_settled=true where game_id=game and user_id=r.user_id;
 end loop;
end $$;
revoke all on function private.apply_match_rewards(uuid) from public,anon,authenticated,service_role;

-- Current clients call this name; finish_game remains compatible and idempotent.
create function public.record_game_result(game uuid) returns void language sql security invoker set search_path='' as $$select private.finish_game(game)$$;
revoke all on function public.record_game_result(uuid) from public,anon;
grant execute on function public.record_game_result(uuid) to authenticated;
