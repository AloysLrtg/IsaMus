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
