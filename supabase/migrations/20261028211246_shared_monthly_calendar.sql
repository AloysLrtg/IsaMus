-- Evolve the existing season calendar in place; do not recreate its ledgers.
alter table public.seasons rename column title to name;
alter table public.seasons rename column starts_at to start_date;
alter table public.seasons rename column ends_at to end_date;
alter table public.seasons add column closed_at timestamptz;
update public.seasons set
 start_date=date_trunc('month',now() at time zone 'Europe/Paris') at time zone 'Europe/Paris',
 end_date=(date_trunc('month',now() at time zone 'Europe/Paris')+interval '1 month') at time zone 'Europe/Paris',
 preview=false where id='season_1';
create function public.active_season() returns jsonb language sql stable security invoker set search_path='' as $$
 select (select to_jsonb(s) from public.seasons s where start_date<=now() and end_date>now() and closed_at is null order by start_date desc,id limit 1)
$$;
revoke all on function public.active_season() from public,anon;
grant execute on function public.active_season() to authenticated;

create or replace function private.retention_status() returns jsonb language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); week date:=date_trunc('week',now() at time zone 'UTC')::date; current_season public.seasons; result jsonb;
begin
 if player is null then raise exception 'Authentication required'; end if;
 select * into current_season from public.seasons where start_date<=now() and end_date>now() and closed_at is null order by start_date desc,id limit 1;
 select jsonb_build_object('coins',coins,'level',level,'xp',xp,'vip',coalesce(vip_expires_at>now(),false),'week_start',week,
  'quests',(select coalesce(jsonb_agg(to_jsonb(q)||jsonb_build_object('progress',coalesce(p.progress,0),'rewarded',coalesce(p.rewarded,false)) order by q.id),'[]') from public.quests q left join public.user_progress p on p.quest_id=q.id and p.user_id=player and p.week_start=week where q.enabled),
  'season',case when current_season.id is null then null else to_jsonb(current_season)||jsonb_build_object('title',current_season.name,'starts_at',current_season.start_date,'ends_at',current_season.end_date) end,
  'rewards',(select coalesce(jsonb_agg(to_jsonb(r) order by tier),'[]') from public.season_rewards r where season_id=current_season.id),
  'claims',(select coalesce(jsonb_agg(jsonb_build_object('tier',tier,'vip_track',vip_track)),'[]') from public.season_pass_claims where user_id=player and season_id=current_season.id))
 into strict result from public.profiles where id=player;
 return result;
end $$;

create or replace function private.claim_season_pass(season text,tier_number integer,premium boolean) returns jsonb
 language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); pr public.profiles; reward public.season_rewards; amount integer; item text; inserted integer;
begin
 if player is null then raise exception 'Authentication required'; end if;
 if tier_number is null or tier_number not between 1 and 30 or premium is null then raise exception 'Palier invalide'; end if;
 perform 1 from public.seasons where id=season and start_date<=now() and end_date>now() and closed_at is null for share;
 if not found then raise exception 'Saison indisponible'; end if;
 select * into strict pr from public.profiles where id=player for update;
 if pr.level<tier_number then raise exception 'Niveau insuffisant'; end if;
 if premium and not coalesce(pr.vip_expires_at>now(),false) then raise exception 'VIP requis'; end if;
 select * into strict reward from public.season_rewards where season_id=season and tier=tier_number;
 if not premium and reward.free_coins is null then raise exception 'Aucune récompense gratuite à ce palier'; end if;
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

