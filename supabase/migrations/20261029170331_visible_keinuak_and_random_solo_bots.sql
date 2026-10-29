-- Drain concurrent purchases and equipment writes before retiring the item.
lock table public.shop_items, public.cosmetics in exclusive mode;
lock table public.profiles in access exclusive mode;

-- Retire opaque glasses, restore visible eyes and refund each owned item once.
update public.profiles set avatar_config=jsonb_set(avatar_config,'{glasses}','0') where avatar_config->>'glasses'='3';
with retired as (
 delete from public.inventory where cosmetic_id='shop_glasses_gold' returning user_id
) update public.profiles p set coins=p.coins+250 where p.id in (select user_id from retired);
delete from public.shop_items where item_id='shop_glasses_gold';
delete from public.cosmetics where id='shop_glasses_gold';
-- Existing transparent frames (0/1/2) remain legal. Old clients cannot re-equip opaque lenses.
alter table public.profiles add constraint profiles_keinuak_visible_eyes check (avatar_config->'glasses' in ('0'::jsonb,'1'::jsonb,'2'::jsonb));

create or replace function private.start_with_bots(game uuid) returns void
language plpgsql security definer set search_path='' as $$
declare
 g public.games; target integer; chosen_team integer; n int; bot_index int := 0; profile jsonb; member jsonb; normalized jsonb := '[]';
 catalog jsonb := '[
  {"name":"Patxi","bot_personality":"conservative","avatar_config":{"skin":0,"hair":0,"glasses":1,"top":2,"background_color":1,"hair_color":4}},
  {"name":"Mikel","bot_personality":"balanced","avatar_config":{"skin":1,"hair":0,"glasses":0,"top":1,"background_color":0,"hair_color":0}},
  {"name":"Txomin","bot_personality":"bluffer","avatar_config":{"skin":2,"hair":2,"glasses":2,"top":0,"background_color":3,"hair_color":5}}
 ]';
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict g from public.games where id=game for update;
 if g.players->0->>'id' is distinct from auth.uid()::text then raise exception 'Hôte requis'; end if;
 if g.status<>'waiting' then return; end if;
 if g.is_public then raise exception 'Les bots sont interdits dans la file publique'; end if;
 if g.mode='ranked' then raise exception 'Quatre joueurs humains requis en mode classé'; end if;
 -- Shuffle whole identities once; names, personalities and avatars stay paired.
 select jsonb_agg(value order by random()) into catalog from jsonb_array_elements(catalog);
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
  member:=member||jsonb_build_object('is_host',member->>'id'=g.players->0->>'id');
  normalized:=normalized || jsonb_build_array(member);
 end loop;
 g.players:=normalized;
 n:=jsonb_array_length(g.players);
 while n<4 loop
  select s into target from generate_series(0,3) s where not exists(select 1 from jsonb_array_elements(g.players) p where (p->>'seat')::int=s) order by s limit 1;
  select case when count(*) filter(where coalesce((p->>'team')::int,(p->>'seat')::int%2)=0)<=count(*) filter(where coalesce((p->>'team')::int,(p->>'seat')::int%2)=1) then 0 else 1 end into chosen_team from jsonb_array_elements(g.players) p;
  profile := catalog->bot_index;
  g.players:=g.players || jsonb_build_array(profile || jsonb_build_object(
    'id','bot_'||target,'seat',target,'team',chosen_team,'is_host',false,'is_bot',true));
  n:=n+1; bot_index:=bot_index+1;
 end loop;
 update public.games set players=g.players,status=case when g.mode='private' then 'waiting' else 'ready' end where id=game;
end;
$$;

-- Keep authenticated table members connected for the post-match debrief.
create or replace function private.can_use_game_sign_topic(topic text, sending boolean)
returns boolean language plpgsql stable security invoker set search_path='' as $$
declare room uuid; owner text;
begin
 if auth.uid() is null or topic !~ '^game-signs:[0-9a-fA-F-]{36}:[0-9a-fA-F-]{36}$' then return false; end if;
 begin room:=split_part(topic,':',2)::uuid; owner:=split_part(topic,':',3)::uuid::text;
 exception when invalid_text_representation then return false; end;
 if sending and owner<>auth.uid()::text then return false; end if;
 return exists(select 1 from public.games g
   where g.id=room and g.status in ('ready','playing','finished')
   and g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text))
   and exists(select 1 from jsonb_array_elements(g.players) p where p->>'id'=owner
     and not coalesce((p->>'is_bot')::boolean,false)));
end $$;
