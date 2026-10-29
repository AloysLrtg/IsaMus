-- Add palette IDs while preserving the prototype's previous cut-dependent tint.
alter table public.profiles drop constraint profiles_avatar_config_valid;
update public.profiles set avatar_config=avatar_config || jsonb_build_object('background_color',0,'hair_color',avatar_config->'hair');
alter table public.profiles alter column avatar_config set default '{"skin":0,"hair":0,"glasses":0,"top":0,"background_color":0,"hair_color":0}'::jsonb;
alter table public.profiles add constraint profiles_avatar_config_valid check (
 jsonb_typeof(avatar_config)='object'
 and avatar_config ?& array['skin','hair','glasses','top','background_color','hair_color']
 and avatar_config - array['skin','hair','glasses','top','background_color','hair_color'] = '{}'::jsonb
 and avatar_config->'skin' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'hair' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'glasses' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'top' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'background_color' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb,'5'::jsonb)
 and avatar_config->'hair_color' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb,'5'::jsonb)
);

alter table public.profiles
 add column peak_elo integer not null default 1200,
 add column casual_played integer not null default 0,
 add column casual_won integer not null default 0,
 add column ranked_played integer not null default 0,
 add column ranked_won integer not null default 0,
 add column solo_played integer not null default 0,
 add column solo_won integer not null default 0;
alter table public.profiles add constraint profiles_mode_statistics_valid check (
 peak_elo>=0 and casual_won>=0 and casual_won<=casual_played
 and ranked_won>=0 and ranked_won<=ranked_played and solo_won>=0 and solo_won<=solo_played
);
-- No new client UPDATE/INSERT grants: statistics remain server-owned under RLS.

-- Recover the mode of recorded Solo matches; do not invent missing history.
update public.match_results r set mode='solo' from public.games g
 where r.game_id=g.id and r.mode<>'ranked' and jsonb_array_length(g.players)=4
 and (select count(*) from jsonb_array_elements(g.players) x where coalesce((x->>'is_bot')::boolean,false))=3;
update public.profiles p set
 peak_elo=greatest(1200,coalesce(p.elo,1200),coalesce((select max(greatest(r.elo_before,r.elo_after)) from public.match_results r where r.user_id=p.id),1200)),
 casual_played=(select count(*) from public.match_results r where r.user_id=p.id and r.mode not in ('ranked','solo')),
 casual_won=(select count(*) from public.match_results r where r.user_id=p.id and r.mode not in ('ranked','solo') and r.won),
 ranked_played=(select count(*) from public.match_results r where r.user_id=p.id and r.mode='ranked'),
 ranked_won=(select count(*) from public.match_results r where r.user_id=p.id and r.mode='ranked' and r.won),
 solo_played=(select count(*) from public.match_results r where r.user_id=p.id and r.mode='solo'),
 solo_won=(select count(*) from public.match_results r where r.user_id=p.id and r.mode='solo' and r.won);

create or replace function private.start_with_bots(game uuid) returns void
language plpgsql security definer set search_path='' as $$
declare g public.games; n int; appearance jsonb;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict g from public.games where id=game for update;
 if g.players->0->>'id' is distinct from auth.uid()::text then raise exception 'Hôte requis'; end if;
 if g.status<>'waiting' then return; end if;
 if g.mode='ranked' then raise exception 'Quatre joueurs humains requis en mode classé'; end if;
 select jsonb_agg(case when pr.id is null then x.p else
   x.p || jsonb_build_object('avatar_config',pr.avatar_config) end order by x.ord)
 into g.players from jsonb_array_elements(g.players) with ordinality x(p,ord)
 left join public.profiles pr on pr.id::text=x.p->>'id';
 n:=jsonb_array_length(g.players);
 while n<4 loop
  select cfg into appearance from (
    select jsonb_build_object('skin',i/27,'hair',(i/9)%3,'glasses',(i/3)%3,'top',i%3,'background_color',floor(random()*6)::int,'hair_color',floor(random()*6)::int) cfg
    from generate_series(0,80) i
  ) choices where not exists (
    select 1 from jsonb_array_elements(g.players) p where p->'avatar_config'=cfg
  ) order by random() limit 1;
  g.players:=g.players || jsonb_build_array(jsonb_build_object(
    'id','bot_'||n,'name','Bot '||n,'seat',n,'is_host',false,'is_bot',true,
    'avatar_config',appearance));
  n:=n+1;
 end loop;
 update public.games set players=g.players,status='ready' where id=game;
end $$;

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
 update public.games set status='finished' where id=game;
end $$;
