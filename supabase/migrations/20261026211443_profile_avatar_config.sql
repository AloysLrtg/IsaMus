-- Appearance IDs are separate from future transient game expressions/signs.
alter table public.profiles add column avatar_config jsonb not null
  default '{"skin":0,"eyes":0,"mouth":0,"head":0}'::jsonb;
alter table public.profiles add constraint profiles_avatar_config_valid check (
  jsonb_typeof(avatar_config)='object'
  and avatar_config ?& array['skin','eyes','mouth','head']
  and avatar_config - array['skin','eyes','mouth','head'] = '{}'::jsonb
  and avatar_config->'skin' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
  and avatar_config->'eyes' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
  and avatar_config->'mouth' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
  and avatar_config->'head' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
);
-- Existing profiles_update RLS restricts this column to the profile owner.
grant update(avatar_config) on public.profiles to authenticated;
