-- Auth inserts run as supabase_auth_admin, which cannot satisfy profiles RLS.
-- This non-exposed, trigger-only function has the narrow elevated operation
-- needed to create that user's profile. Metadata is never used for permissions.
create function private.create_profile_for_auth_user()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  chosen text;
  fallback text := 'Joueur ' || left(replace(new.id::text, '-', ''), 17);
  attempt integer := 0;
begin
  if jsonb_typeof(new.raw_user_meta_data->'username') = 'string' then
    chosen := btrim(new.raw_user_meta_data->>'username');
    if char_length(chosen) not between 1 and 24 then
      raise check_violation using message = 'Le pseudo doit contenir de 1 à 24 caractères.';
    end if;
    -- A requested username is preserved exactly after trimming; duplicate
    -- names abort the signup transaction instead of renaming another profile.
    insert into public.profiles(id, username) values (new.id, chosen);
  else
    -- Anonymous sign-ins and legacy clients have no username metadata.
    -- ON CONFLICT handles concurrent fallback-name collisions without a race.
    loop
      chosen := case when attempt = 0 then fallback
        else left(fallback, 18) || '-' || lpad(attempt::text, 5, '0') end;
      insert into public.profiles(id, username) values (new.id, chosen)
        on conflict (username) do nothing;
      exit when found;
      attempt := attempt + 1;
      if attempt > 99999 then
        raise unique_violation using message = 'Aucun pseudo automatique disponible.';
      end if;
    end loop;
  end if;
  return new;
end;
$$;
revoke all on function private.create_profile_for_auth_user() from public, anon, authenticated, service_role;

create trigger on_auth_user_created
  after insert on auth.users for each row
  execute function private.create_profile_for_auth_user();
