-- Fixed identities are assigned once under the same host/room lock as startup.
-- Keep this catalog aligned with BotProfile.profiles in Flutter.
create or replace function private.start_with_bots(game uuid) returns void
language plpgsql security definer set search_path='' as $$
declare
 g public.games; n int; bot_index int := 0; profile jsonb; member jsonb; normalized jsonb := '[]';
 catalog constant jsonb := '[
  {"name":"Patxi","bot_personality":"conservative","avatar_config":{"skin":0,"hair":0,"glasses":1,"top":2,"background_color":1,"hair_color":4}},
  {"name":"Mikel","bot_personality":"balanced","avatar_config":{"skin":1,"hair":0,"glasses":0,"top":1,"background_color":0,"hair_color":0}},
  {"name":"Txomin","bot_personality":"bluffer","avatar_config":{"skin":2,"hair":2,"glasses":2,"top":0,"background_color":3,"hair_color":5}}
 ]';
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
 -- Also normalize legacy waiting rooms that already contain some bots.
 for member in select value from jsonb_array_elements(g.players) loop
  if member->>'is_bot' = 'true' then
   if bot_index>=3 then raise exception 'Un joueur humain est requis'; end if;
   member:=member || (catalog->bot_index);
   bot_index:=bot_index+1;
  end if;
  normalized:=normalized || jsonb_build_array(member);
 end loop;
 g.players:=normalized;
 n:=jsonb_array_length(g.players);
 while n<4 loop
  profile := catalog->bot_index;
  g.players:=g.players || jsonb_build_array(profile || jsonb_build_object(
    'id','bot_'||n,'seat',n,'is_host',false,'is_bot',true));
  n:=n+1; bot_index:=bot_index+1;
 end loop;
 update public.games set players=g.players,status='ready' where id=game;
end;
$$;
