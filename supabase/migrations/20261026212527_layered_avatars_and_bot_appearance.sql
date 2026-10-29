-- Preserve the selected option IDs from the prototype when changing categories.
alter table public.profiles drop constraint profiles_avatar_config_valid;
update public.profiles set avatar_config=jsonb_build_object(
  'skin',avatar_config->'skin','hair',avatar_config->'head',
  'glasses',avatar_config->'eyes','top',avatar_config->'mouth');
alter table public.profiles alter column avatar_config set default
  '{"skin":0,"hair":0,"glasses":0,"top":0}'::jsonb;
alter table public.profiles add constraint profiles_avatar_config_valid check (
  jsonb_typeof(avatar_config)='object'
  and avatar_config ?& array['skin','hair','glasses','top']
  and avatar_config - array['skin','hair','glasses','top'] = '{}'::jsonb
  and avatar_config->'skin' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
  and avatar_config->'hair' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
  and avatar_config->'glasses' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
  and avatar_config->'top' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
);

-- Persist the canonical bot portraits once, under the existing game row lock.
-- The public wrapper and existing restricted grants remain unchanged.
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
    select jsonb_build_object('skin',i/27,'hair',(i/9)%3,'glasses',(i/3)%3,'top',i%3) cfg
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
