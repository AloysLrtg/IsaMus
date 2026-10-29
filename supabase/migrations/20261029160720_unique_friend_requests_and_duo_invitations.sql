-- Keep the stronger, unordered pair index; expose the requested SQL constraint too.
alter table public.friendships add constraint friendships_sender_receiver_unique unique(sender_id,receiver_id);
alter table public.game_invitations add column mode text not null default 'private' check(mode in ('private','casual','ranked'));
alter table public.games add column duo_reservations jsonb not null default '[]' check(jsonb_typeof(duo_reservations)='array' and jsonb_array_length(duo_reservations)<=2);

create function private.live_duo_reservations(g public.games) returns jsonb language sql volatile security definer set search_path='' as $$
 select coalesce(jsonb_agg(r),'[]') from jsonb_array_elements(g.duo_reservations) r where exists(
  select 1 from public.game_invitations i where i.id=(r->>'invitation_id')::uuid and i.game_id=g.id and i.mode=g.mode and i.status='pending' and i.expires_at>now() and i.sender_id::text=r->>'sender_id' and i.recipient_id::text=r->>'recipient_id'
 ) and g.players @> jsonb_build_array(jsonb_build_object('id',r->>'sender_id'))
$$;
revoke all on function private.live_duo_reservations(public.games) from public,anon,authenticated;

create or replace function private.find_public_game(p_mode text) returns jsonb language plpgsql security definer set search_path='' as $$
declare g public.games;pr public.profiles;target integer;attempt integer;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if p_mode is null or p_mode not in ('casual','ranked') then raise exception 'Mode public invalide'; end if;
 select * into strict pr from public.profiles where id=auth.uid();
 perform pg_advisory_xact_lock(74812002);
 select * into g from public.games where is_public and status in ('waiting','ready','playing') and players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) order by created_at,id limit 1 for update;
 if found then
  if g.mode<>p_mode then raise exception 'Une autre partie publique est déjà en cours'; end if;
  return to_jsonb(g)||jsonb_build_object('local_seat',(select (p->>'seat')::int from jsonb_array_elements(g.players) p where p->>'id'=auth.uid()::text));
 end if;
 select * into g from public.games x where x.is_public and x.mode=p_mode and x.status='waiting' and x.game_state is null and exists(
  select 1 from generate_series(0,3) s where not exists(select 1 from jsonb_array_elements(x.players) p where (p->>'seat')::int=s) and not exists(select 1 from jsonb_array_elements(private.live_duo_reservations(x)) r where (r->>'seat')::int=s)
 ) order by created_at,id limit 1 for update;
 if not found then
  for attempt in 1..5 loop
   begin
    insert into public.games(join_code,status,mode,is_public,players) values(upper(substr(replace(gen_random_uuid()::text,'-',''),1,5)),'waiting',p_mode,true,jsonb_build_array(jsonb_build_object('id',pr.id,'name',pr.username,'seat',0,'is_host',true,'is_bot',false,'avatar_config',pr.avatar_config))) returning * into g;
    return to_jsonb(g)||jsonb_build_object('local_seat',0);
   exception when unique_violation then if attempt=5 then raise exception 'Recherche indisponible'; end if;
   end;
  end loop;
 end if;
 g.duo_reservations:=private.live_duo_reservations(g);
 select s into target from generate_series(0,3) s where not exists(select 1 from jsonb_array_elements(g.players) p where (p->>'seat')::int=s) and not exists(select 1 from jsonb_array_elements(g.duo_reservations) r where (r->>'seat')::int=s) order by s limit 1;
 if target is null then raise exception 'Partie complète'; end if;
 update public.games set duo_reservations=g.duo_reservations,players=g.players||jsonb_build_array(jsonb_build_object('id',pr.id,'name',pr.username,'seat',target,'is_host',false,'is_bot',false,'avatar_config',pr.avatar_config)),status=case when jsonb_array_length(g.players)=3 then 'ready' else 'waiting' end where id=g.id returning * into g;
 return to_jsonb(g)||jsonb_build_object('local_seat',target);
end $$;

create function private.create_mode_invitation(p_friend uuid,p_mode text) returns jsonb language plpgsql security definer set search_path='' as $$
declare g public.games;pr public.profiles;i public.game_invitations;sender_seat integer;mate_seat integer;attempt integer;reservation jsonb;
begin
 if auth.uid() is null or p_friend is null or p_friend=auth.uid() then raise exception 'Joueur invalide'; end if;
 if p_mode is null or p_mode not in ('private','casual','ranked') then raise exception 'Mode invalide'; end if;
 -- Queue lock before pair, game and invitation row locks, including private mode.
 perform pg_advisory_xact_lock(74812002);
 perform private.social_pair_lock(auth.uid(),p_friend);
 if private.social_pair_blocked(auth.uid(),p_friend) or not exists(select 1 from public.friendships where status='accepted' and ((user_id_1=auth.uid() and user_id_2=p_friend) or (user_id_2=auth.uid() and user_id_1=p_friend))) then raise exception 'Ami indisponible'; end if;
 select * into strict pr from public.profiles where id=auth.uid();
 if p_mode<>'private' then
  select * into g from public.games where is_public and status in ('waiting','ready','playing') and players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) order by created_at,id limit 1 for update;
  if found then
   if g.mode<>p_mode or g.status<>'waiting' or g.game_state is not null then raise exception 'Une autre partie est en cours'; end if;
   g.duo_reservations:=private.live_duo_reservations(g);
   select (p->>'seat')::int into sender_seat from jsonb_array_elements(g.players) p where p->>'id'=auth.uid()::text;
   if exists(select 1 from jsonb_array_elements(g.duo_reservations) r where r->>'sender_id'=auth.uid()::text and r->>'recipient_id'=p_friend::text) then return to_jsonb(g)||jsonb_build_object('local_seat',sender_seat); end if;
   mate_seat:=(sender_seat+2)%4;
   if exists(select 1 from jsonb_array_elements(g.players) p where (p->>'seat')::int=mate_seat) or exists(select 1 from jsonb_array_elements(g.duo_reservations) r where (r->>'seat')::int=mate_seat) then raise exception 'Équipe complète'; end if;
  else
   select * into g from public.games x where x.is_public and x.mode=p_mode and x.status='waiting' and x.game_state is null and not exists(select 1 from jsonb_array_elements(private.live_duo_reservations(x)) r where r->>'recipient_id'=p_friend::text) and exists(
    select 1 from generate_series(0,1) team where not exists(select 1 from jsonb_array_elements(x.players) p where (p->>'seat')::int%2=team) and not exists(select 1 from jsonb_array_elements(private.live_duo_reservations(x)) r where (r->>'seat')::int%2=team)
   ) order by created_at,id limit 1 for update;
   if found then
    g.duo_reservations:=private.live_duo_reservations(g);
    select team into sender_seat from generate_series(0,1) team where not exists(select 1 from jsonb_array_elements(g.players) p where (p->>'seat')::int%2=team) and not exists(select 1 from jsonb_array_elements(g.duo_reservations) r where (r->>'seat')::int%2=team) order by team limit 1;
    mate_seat:=sender_seat+2;
    g.players:=g.players||jsonb_build_array(jsonb_build_object('id',pr.id,'name',pr.username,'seat',sender_seat,'is_host',false,'is_bot',false,'avatar_config',pr.avatar_config));
   end if;
  end if;
 end if;
 if g.id is null then
  sender_seat:=0;mate_seat:=2;
  for attempt in 1..5 loop
   begin
    insert into public.games(join_code,status,mode,is_public,players) values(upper(substr(replace(gen_random_uuid()::text,'-',''),1,5)),'waiting',p_mode,p_mode<>'private',jsonb_build_array(jsonb_build_object('id',pr.id,'name',pr.username,'seat',0,'is_host',true,'is_bot',false,'team',0,'avatar_config',pr.avatar_config))) returning * into g;
    exit;
   exception when unique_violation then if attempt=5 then raise exception 'Salon indisponible'; end if;
   end;
  end loop;
 end if;
 if p_mode='private' then
  perform private.invite_friend(p_friend,g.id);
 else
  if exists(select 1 from public.games x where x.is_public and x.status in ('waiting','ready','playing') and x.players @> jsonb_build_array(jsonb_build_object('id',p_friend::text))) then raise exception 'Votre ami est déjà en file ou en partie'; end if;
  insert into public.game_invitations(sender_id,recipient_id,game_id,mode) values(auth.uid(),p_friend,g.id,p_mode)
  on conflict(game_id,recipient_id) do update set status='pending',expires_at=now()+interval '10 minutes',created_at=now(),mode=excluded.mode returning * into i;
  if i.sender_id<>auth.uid() then raise exception 'Invitation déjà en attente'; end if;
  reservation:=jsonb_build_object('sender_id',auth.uid(),'recipient_id',p_friend,'seat',mate_seat,'invitation_id',i.id);
  update public.games set players=g.players,duo_reservations=g.duo_reservations||jsonb_build_array(reservation) where id=g.id returning * into g;
 end if;
 return to_jsonb(g)||jsonb_build_object('local_seat',sender_seat);
end $$;
create function public.create_mode_invitation(p_friend uuid,p_mode text) returns jsonb language sql security invoker set search_path='' as $$select private.create_mode_invitation(p_friend,p_mode)$$;
revoke all on function private.create_mode_invitation(uuid,text),public.create_mode_invitation(uuid,text) from public,anon;
grant execute on function private.create_mode_invitation(uuid,text),public.create_mode_invitation(uuid,text) to authenticated;

create or replace function private.accept_invitation(invitation uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare i public.game_invitations;g public.games;pr public.profiles;r jsonb;target integer;result uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform pg_advisory_xact_lock(74812002);
 select * into strict i from public.game_invitations where id=invitation and recipient_id=auth.uid();
 perform private.social_pair_lock(i.sender_id,i.recipient_id);
 select * into strict g from public.games where id=i.game_id for update;
 select * into strict i from public.game_invitations where id=invitation and recipient_id=auth.uid() for update;
 if private.social_pair_blocked(i.sender_id,i.recipient_id) then raise exception 'Invitation indisponible'; end if;
 if i.status='accepted' and g.status in ('waiting','ready','playing') and g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) then return g.id; end if;
 if i.status<>'pending' or i.expires_at<now() or g.status<>'waiting' then raise exception 'Invitation expirée ou salon fermé'; end if;
 if exists(select 1 from public.games x where x.id<>g.id and x.is_public and x.status in ('waiting','ready','playing') and x.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text))) then raise exception 'Quittez votre file ou partie actuelle'; end if;
 if i.mode='private' then
  result:=private.join_game(g.join_code);
 else
  if not g.is_public or g.mode<>i.mode then raise exception 'Mode incompatible'; end if;
  if g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) then raise exception 'Quittez cette file avant de rejoindre le duo'; end if;
  g.duo_reservations:=private.live_duo_reservations(g);
  select x into r from jsonb_array_elements(g.duo_reservations) x where x->>'invitation_id'=i.id::text and x->>'recipient_id'=auth.uid()::text;
  if r is null then raise exception 'Réservation indisponible'; end if;
  target:=(r->>'seat')::int;
  if exists(select 1 from jsonb_array_elements(g.players) p where (p->>'seat')::int=target) then raise exception 'Place occupée'; end if;
  select * into strict pr from public.profiles where id=auth.uid();
  update public.games set players=g.players||jsonb_build_array(jsonb_build_object('id',pr.id,'name',pr.username,'seat',target,'is_host',false,'is_bot',false,'avatar_config',pr.avatar_config)),duo_reservations=(select coalesce(jsonb_agg(x),'[]') from jsonb_array_elements(g.duo_reservations) x where x->>'invitation_id'<>i.id::text),status=case when jsonb_array_length(g.players)=3 then 'ready' else 'waiting' end where id=g.id;
  update public.game_invitations set status='declined' where recipient_id=auth.uid() and id<>i.id and mode<>'private' and status='pending';
  result:=g.id;
 end if;
 update public.game_invitations set status='accepted' where id=i.id;
 return result;
end $$;
create function private.accept_game_invitation(invitation uuid) returns jsonb language plpgsql security definer set search_path='' as $$
declare game_id uuid;g public.games;target integer;
begin
 game_id:=private.accept_invitation(invitation);
 select * into strict g from public.games where id=game_id;
 select (p->>'seat')::int into target from jsonb_array_elements(g.players) p where p->>'id'=auth.uid()::text;
 if target is null then raise exception 'Joueur absent'; end if;
 return to_jsonb(g)||jsonb_build_object('local_seat',target);
end $$;
create function public.accept_game_invitation(invitation uuid) returns jsonb language sql security invoker set search_path='' as $$select private.accept_game_invitation(invitation)$$;
revoke all on function private.accept_game_invitation(uuid),public.accept_game_invitation(uuid) from public,anon;
grant execute on function private.accept_game_invitation(uuid),public.accept_game_invitation(uuid) to authenticated;

create function private.decline_game_invitation(invitation uuid) returns void language plpgsql security definer set search_path='' as $$
declare i public.game_invitations;g public.games;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform pg_advisory_xact_lock(74812002);
 select * into strict i from public.game_invitations where id=invitation and recipient_id=auth.uid();
 select * into strict g from public.games where id=i.game_id for update;
 select * into strict i from public.game_invitations where id=invitation and recipient_id=auth.uid() for update;
 if i.status<>'pending' then return; end if;
 update public.game_invitations set status='declined' where id=i.id;
 update public.games set duo_reservations=private.live_duo_reservations(g) where id=g.id and g.is_public and g.status='waiting';
end $$;
create function public.decline_game_invitation(invitation uuid) returns void language sql security invoker set search_path='' as $$select private.decline_game_invitation(invitation)$$;
revoke all on function private.decline_game_invitation(uuid),public.decline_game_invitation(uuid) from public,anon;
grant execute on function private.decline_game_invitation(uuid),public.decline_game_invitation(uuid) to authenticated;

create or replace function private.leave_public_queue(game uuid) returns void language plpgsql security definer set search_path='' as $$
declare g public.games;remaining jsonb;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform pg_advisory_xact_lock(74812002);
 select * into strict g from public.games where id=game for update;
 if not g.is_public then raise exception 'File publique requise'; end if;
 if not g.players @> jsonb_build_array(jsonb_build_object('id',auth.uid()::text)) then return; end if;
 if g.status<>'waiting' then raise exception 'La partie est déjà prête'; end if;
 update public.game_invitations set status='declined' where game_id=g.id and sender_id=auth.uid() and status='pending';
 select coalesce(jsonb_agg(p||jsonb_build_object('is_host',n=1) order by n),'[]') into remaining from(select p,row_number() over(order by ord)n from jsonb_array_elements(g.players) with ordinality x(p,ord) where p->>'id'<>auth.uid()::text) members;
 g.players:=remaining;
 update public.games set players=remaining,duo_reservations=private.live_duo_reservations(g),status=case when jsonb_array_length(remaining)=0 then 'cancelled' else 'waiting' end where id=game;
end $$;
