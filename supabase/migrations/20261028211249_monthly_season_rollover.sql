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

