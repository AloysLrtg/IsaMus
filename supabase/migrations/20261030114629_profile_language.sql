-- Persist the interface preference; existing profiles and new accounts default to FR.
alter table public.profiles
  add column if not exists language varchar(2) not null default 'fr';
alter table public.profiles
  add constraint profiles_language_supported check (language in ('fr','eu','es','en'));

-- Keep the existing owner-only profiles_update RLS policy. Column-level grants
-- intentionally do not allow clients to edit Elo or any protected statistics.
grant update(language) on public.profiles to authenticated;
