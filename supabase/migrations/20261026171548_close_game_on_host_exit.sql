-- Keep the row and membership so Realtime can notify every participant.
create function private.close_game(game uuid) returns void
language plpgsql security definer set search_path='' as $$
declare g public.games;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select * into strict g from public.games where id=game for update;
  if g.players->0->>'id' is distinct from auth.uid()::text then
    raise exception 'Seul l’hôte peut fermer le salon';
  end if;
  if g.status in ('cancelled','finished') then return; end if;
  update public.games set status='cancelled',game_state=null where id=game;
  update public.game_invitations set status='declined'
    where game_id=game and status='pending';
end $$;
create function public.close_game(game uuid) returns void
language sql security invoker set search_path='' as $$select private.close_game(game)$$;
revoke all on function private.close_game(uuid),public.close_game(uuid) from public,anon;
grant execute on function private.close_game(uuid),public.close_game(uuid) to authenticated;
