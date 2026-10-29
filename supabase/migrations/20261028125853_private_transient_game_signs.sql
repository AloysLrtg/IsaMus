-- Per-sender topics bind the emitter to its authenticated UUID. Participants
-- can observe gestures; only the host topic may also animate server-roster bots.
create function private.can_use_game_sign_topic(topic text, sending boolean)
returns boolean language plpgsql stable security invoker set search_path='' as $$
declare room uuid; owner text;
begin
 if auth.uid() is null or topic !~ '^game-signs:[0-9a-fA-F-]{36}:[0-9a-fA-F-]{36}$' then return false; end if;
 begin room:=split_part(topic,':',2)::uuid; owner:=split_part(topic,':',3)::uuid::text;
 exception when invalid_text_representation then return false; end;
 if sending and owner<>auth.uid()::text then return false; end if;
 return exists(select 1 from public.games g
   where g.id=room and g.status in ('ready','playing')
   and g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text))
   and exists(select 1 from jsonb_array_elements(g.players) p where p->>'id'=owner
     and not coalesce((p->>'is_bot')::boolean,false)));
end $$;
revoke all on function private.can_use_game_sign_topic(text,boolean) from public,anon;
grant execute on function private.can_use_game_sign_topic(text,boolean) to authenticated;
create policy game_signs_read on realtime.messages for select to authenticated
 using(extension='broadcast' and (select private.can_use_game_sign_topic(realtime.topic(),false)));
create policy game_signs_write on realtime.messages for insert to authenticated
 with check(extension='broadcast' and (select private.can_use_game_sign_topic(realtime.topic(),true)));

-- Strip legacy sign fields from every subsequent game write, including old clients.
-- This trigger cannot broadcast and never changes version/turn/card fields.
create function private.strip_persisted_signs() returns trigger
language plpgsql security invoker set search_path='' as $$
begin
 if new.game_state is not null then new.game_state:=new.game_state-'signs'-'signRevisions'; end if;
 return new;
end $$;
revoke all on function private.strip_persisted_signs() from public,anon,authenticated;
create trigger strip_persisted_signs before insert or update of game_state on public.games
 for each row execute function private.strip_persisted_signs();
update public.games set game_state=game_state-'signs'-'signRevisions'
 where game_state ? 'signs' or game_state ? 'signRevisions';
