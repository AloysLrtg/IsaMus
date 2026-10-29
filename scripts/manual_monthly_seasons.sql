-- IsaMus : installation manuelle des quatre migrations mensuelles en attente.
-- À exécuter une seule fois dans le SQL Editor du projet existant.
-- Cette installation ne lance PAS end_current_season() et ne remet aucun Elo à zéro.
BEGIN;

-- 20261028211240_league_avatar_ownership.sql
alter table public.profiles alter column elo set default 800;
alter table public.profiles alter column peak_elo set default 800;

alter table public.cosmetics drop constraint cosmetics_kind_check;
alter table public.cosmetics add constraint cosmetics_kind_check check(kind in ('avatar','card_back','table_theme','avatar_border','exclusive_hat'));
insert into public.cosmetics(id,kind,label,free) values
 ('league_border_bronze','avatar_border','Bordure Bronze',false),
 ('league_border_silver','avatar_border','Bordure Argent',false),
 ('league_border_gold','avatar_border','Bordure Or',false),
 ('league_border_diamond','avatar_border','Bordure Diamant',false),
 ('league_hat_txapela','exclusive_hat','Txapela de ligue',false),
 ('league_hat_crown','exclusive_hat','Couronne de ligue',false);

alter table public.profiles drop constraint profiles_avatar_config_valid;
update public.profiles set avatar_config=avatar_config||'{"border":"none","exclusive_hat":"none"}'::jsonb;
alter table public.profiles alter column avatar_config set default
 '{"skin":0,"hair":0,"glasses":0,"top":0,"background_color":0,"hair_color":0,"border":"none","exclusive_hat":"none"}'::jsonb;
alter table public.profiles add constraint profiles_avatar_config_valid check (
 jsonb_typeof(avatar_config)='object'
 and avatar_config ?& array['skin','hair','glasses','top','background_color','hair_color','border','exclusive_hat']
 and avatar_config - array['skin','hair','glasses','top','background_color','hair_color','border','exclusive_hat']='{}'::jsonb
 and avatar_config->'skin' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'hair' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'glasses' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'top' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'background_color' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb,'5'::jsonb)
 and avatar_config->'hair_color' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb,'5'::jsonb)
 and avatar_config->'border' in ('"none"'::jsonb,'"bronze"'::jsonb,'"silver"'::jsonb,'"gold"'::jsonb,'"diamond"'::jsonb)
 and avatar_config->'exclusive_hat' in ('"none"'::jsonb,'"txapela"'::jsonb,'"crown"'::jsonb)
);
create function private.validate_avatar_rewards() returns trigger language plpgsql security definer set search_path='' as $$
begin
 -- Older clients may omit the two keys; never silently remove equipped rewards.
 new.avatar_config:=jsonb_build_object('border',case when tg_op='UPDATE' then old.avatar_config->>'border' else 'none' end,
 'exclusive_hat',case when tg_op='UPDATE' then old.avatar_config->>'exclusive_hat' else 'none' end)||new.avatar_config;
 if new.avatar_config->>'border'<>'none' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id='league_border_'||(new.avatar_config->>'border')) then
  raise exception 'Bordure non possédée'; end if;
 if new.avatar_config->>'exclusive_hat'<>'none' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id='league_hat_'||(new.avatar_config->>'exclusive_hat')) then
  raise exception 'Couvre-chef non possédé'; end if;
 return new;
end $$;
revoke all on function private.validate_avatar_rewards() from public,anon,authenticated,service_role;
create trigger profiles_validate_avatar_rewards before insert or update of avatar_config on public.profiles for each row execute function private.validate_avatar_rewards();

create or replace function private.equip_cosmetic(item text) returns void language plpgsql security definer set search_path='' as $$
declare c public.cosmetics;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict c from public.cosmetics where id=item;
 if not c.free and not exists(select 1 from public.inventory where user_id=auth.uid() and cosmetic_id=item) then raise exception 'Cosmétique non possédé'; end if;
 update public.profiles set avatar=case when c.kind='avatar' then item else avatar end,
 card_back=case when c.kind='card_back' then item else card_back end,
 table_theme=case when c.kind='table_theme' then item else table_theme end,
 avatar_config=case when c.kind='avatar_border' then avatar_config||jsonb_build_object('border',replace(item,'league_border_',''))
 when c.kind='exclusive_hat' then avatar_config||jsonb_build_object('exclusive_hat',replace(item,'league_hat_','')) else avatar_config end where id=auth.uid();
end $$;

create or replace function private.sync_inventory(player uuid, items text[]) returns void language plpgsql security definer set search_path='' as $$
begin
 if (auth.jwt()->>'role') is distinct from 'service_role' then raise exception 'Server only'; end if;
 perform 1 from public.profiles where id=player for update;
 if not found then return; end if;
 delete from public.inventory i where i.user_id=player and cosmetic_id in(select id from public.cosmetics where not free and product_id is not null)
 and not(cosmetic_id=any(items)) and not exists(select 1 from public.season_pass_claims c where c.user_id=player and c.cosmetic_id=i.cosmetic_id);
 insert into public.inventory(user_id,cosmetic_id) select player,id from public.cosmetics where not free and product_id is not null and id=any(items) on conflict do nothing;
 update public.profiles p set
 card_back=case when p.card_back='gold' and not exists(select 1 from public.inventory where user_id=player and cosmetic_id='gold') then 'classic' else p.card_back end,
 table_theme=case when p.table_theme='ruby' and not exists(select 1 from public.inventory where user_id=player and cosmetic_id='ruby') then 'green' else p.table_theme end where id=player;
end $$;


-- 20261028211243_league_results_and_finish_lock.sql
create table public.season_league_results (
 user_id uuid not null references public.profiles(id) on delete cascade,
 season_id text not null references public.seasons(id), peak_elo integer not null,
 elo_final integer not null, primary key(user_id,season_id)
);
create index season_league_results_season_idx on public.season_league_results(season_id);
create table public.league_awards (
 user_id uuid not null, season_id text not null, cosmetic_id text not null references public.cosmetics(id),
 awarded_at timestamptz not null default now(), primary key(user_id,season_id,cosmetic_id),
 foreign key(user_id,season_id) references public.season_league_results(user_id,season_id) on delete cascade
);
create index league_awards_cosmetic_idx on public.league_awards(cosmetic_id);
alter table public.season_league_results enable row level security;
alter table public.league_awards enable row level security;
revoke all on public.season_league_results,public.league_awards from public,anon,authenticated;
grant select on public.season_league_results,public.league_awards to authenticated;
create policy league_results_own on public.season_league_results for select to authenticated using(user_id=(select auth.uid()));
create policy league_awards_own on public.league_awards for select to authenticated using(user_id=(select auth.uid()));

create or replace function private.finish_game(game uuid) returns void language plpgsql security definer set search_path='' as $$
declare g public.games; winner int; p record; before_elo int; opponent numeric; delta int; ranked boolean; result_mode text;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform pg_advisory_xact_lock_shared(74812001);
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
  before_elo:=coalesce(p.elo,800);
  select avg(coalesce(pr.elo,800)) into opponent from jsonb_array_elements(g.players) x join public.profiles pr on pr.id::text=x->>'id' where (x->>'seat')::int%2<>p.seat%2;
  delta:=case when ranked then round(32*((case when p.seat%2=winner then 1 else 0 end)-1/(1+power(10,(coalesce(opponent,800)-before_elo)/400))))::int else 0 end;
  insert into public.match_results(game_id,user_id,won,mode,elo_before,elo_after) values(game,p.id,p.seat%2=winner,result_mode,before_elo,greatest(0,before_elo+delta));
 end loop;
 update public.profiles pr set elo=r.elo_after,
   peak_elo=greatest(pr.peak_elo,coalesce(pr.elo,800),r.elo_after),
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

-- 20261028211246_shared_monthly_calendar.sql
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


-- 20261028211249_monthly_season_rollover.sql
-- Admin/service only. Safe to retry; refuses to close a season before its end.
create function private.end_current_season() returns jsonb language plpgsql security definer set search_path='' as $$
declare s public.seasons; month_start timestamptz; month_end timestamptz; next_id text; players integer; awards integer;
begin
 perform pg_advisory_xact_lock(74812001);
 select * into s from public.seasons where closed_at is null and end_date<=now() order by end_date,id limit 1 for update;
 if not found then return jsonb_build_object('closed',false); end if;
 perform 1 from public.profiles order by id for update;
 insert into public.season_league_results(user_id,season_id,peak_elo,elo_final)
 select id,s.id,peak_elo,elo from public.profiles;
 insert into public.league_awards(user_id,season_id,cosmetic_id)
 select r.user_id,s.id,t.item from public.season_league_results r
 cross join (values(1000,'league_border_bronze'),(1200,'league_border_silver'),(1400,'league_border_gold'),(1600,'league_hat_txapela')) t(threshold,item)
 where r.season_id=s.id and r.peak_elo>=t.threshold on conflict do nothing;
 get diagnostics awards=row_count;
 insert into public.inventory(user_id,cosmetic_id) select user_id,cosmetic_id from public.league_awards where season_id=s.id on conflict do nothing;
 update public.profiles set elo=800,peak_elo=800;
 get diagnostics players=row_count;
 update public.seasons set closed_at=now() where id=s.id;
 month_start:=date_trunc('month',now() at time zone 'Europe/Paris') at time zone 'Europe/Paris';
 month_end:=(date_trunc('month',now() at time zone 'Europe/Paris')+interval '1 month') at time zone 'Europe/Paris';
 next_id:='season_'||to_char(month_start at time zone 'Europe/Paris','YYYY_MM');
 insert into public.seasons(id,name,start_date,end_date,preview)
 values(next_id,'Saison '||to_char(month_start at time zone 'Europe/Paris','YYYY-MM'),month_start,month_end,false) on conflict(id) do nothing;
 insert into public.season_rewards(season_id,tier,free_coins,vip_coins,vip_cosmetic,vip_cosmetic_placeholder)
 select next_id,tier,free_coins,vip_coins,vip_cosmetic,case when vip_cosmetic_placeholder is not null then next_id||'_cosmetic_'||tier else null end
 from public.season_rewards where season_id=s.id on conflict do nothing;
 return jsonb_build_object('closed',true,'season_id',s.id,'next_season_id',next_id,'players',players,'awards',awards);
end $$;
create function public.end_current_season() returns jsonb language sql security invoker set search_path='' as $$select private.end_current_season()$$;
revoke all on function private.end_current_season(),public.end_current_season() from public,anon,authenticated;
grant execute on function private.end_current_season(),public.end_current_season() to service_role;


COMMIT;
