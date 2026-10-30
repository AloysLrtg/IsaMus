-- Keep automatic guest names at 11 characters, including collision retries.
-- Named signups retain their chosen username and existing validation behavior.
create or replace function private.create_profile_for_auth_user()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  chosen text;
  suffix text := left(replace(new.id::text, '-', ''), 4);
  alphabet constant text := '0123456789abcdefghijklmnopqrstuvwxyz';
  attempt integer := 0;
begin
  if jsonb_typeof(new.raw_user_meta_data->'username') = 'string' then
    chosen := btrim(new.raw_user_meta_data->>'username');
    if char_length(chosen) not between 1 and 24 then
      raise check_violation using message = 'Le pseudo doit contenir de 1 à 24 caractères.';
    end if;
    insert into public.profiles(id, username) values (new.id, chosen);
  else
    loop
      chosen := 'Joueur ' || suffix;
      -- The unique constraint also handles simultaneous signups safely.
      insert into public.profiles(id, username) values (new.id, chosen)
        on conflict (username) do nothing;
      exit when found;
      attempt := attempt + 1;
      if attempt >= 128 then
        raise unique_violation using message = 'Aucun pseudo automatique disponible.';
      end if;
      -- Use all 36 alphanumeric characters on retry, without growing the name.
      select string_agg(substr(alphabet, 1 + floor(random() * 36)::integer, 1), '' order by position)
        into suffix from generate_series(1, 4) as digit(position);
    end loop;
  end if;
  return new;
end;
$$;
revoke all on function private.create_profile_for_auth_user() from public, anon, authenticated, service_role;
