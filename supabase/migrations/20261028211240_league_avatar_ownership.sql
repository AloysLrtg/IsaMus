alter table public.profiles alter column elo set default 800;
alter table public.profiles alter column peak_elo set default 800;

alter table public.cosmetics drop constraint cosmetics_kind_check;
alter table public.cosmetics add constraint cosmetics_kind_check check(kind in ('avatar','card_back','table_theme','avatar_border','exclusive_hat'));
insert into public.cosmetics(id,kind,label,free) values
 ('league_border_bronze','avatar_border','Bordure Bronze',false),
 ('league_border_silver','avatar_border','Bordure Argent',false),
 ('league_border_gold','avatar_border','Bordure Or',false),
 ('league_border_diamond','avatar_border','Bordure Diamant',false),
 ('league_hat_txapela','exclusive_hat','Txapela de ligue',false),
 ('league_hat_crown','exclusive_hat','Couronne de ligue',false);

alter table public.profiles drop constraint profiles_avatar_config_valid;
update public.profiles set avatar_config=avatar_config||'{"border":"none","exclusive_hat":"none"}'::jsonb;
alter table public.profiles alter column avatar_config set default
 '{"skin":0,"hair":0,"glasses":0,"top":0,"background_color":0,"hair_color":0,"border":"none","exclusive_hat":"none"}'::jsonb;
alter table public.profiles add constraint profiles_avatar_config_valid check (
 jsonb_typeof(avatar_config)='object'
 and avatar_config ?& array['skin','hair','glasses','top','background_color','hair_color','border','exclusive_hat']
 and avatar_config - array['skin','hair','glasses','top','background_color','hair_color','border','exclusive_hat']='{}'::jsonb
 and avatar_config->'skin' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'hair' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'glasses' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'top' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'background_color' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb,'5'::jsonb)
 and avatar_config->'hair_color' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb,'5'::jsonb)
 and avatar_config->'border' in ('"none"'::jsonb,'"bronze"'::jsonb,'"silver"'::jsonb,'"gold"'::jsonb,'"diamond"'::jsonb)
 and avatar_config->'exclusive_hat' in ('"none"'::jsonb,'"txapela"'::jsonb,'"crown"'::jsonb)
);
create function private.validate_avatar_rewards() returns trigger language plpgsql security definer set search_path='' as $$
begin
 -- Older clients may omit the two keys; never silently remove equipped rewards.
 new.avatar_config:=jsonb_build_object('border',case when tg_op='UPDATE' then old.avatar_config->>'border' else 'none' end,
 'exclusive_hat',case when tg_op='UPDATE' then old.avatar_config->>'exclusive_hat' else 'none' end)||new.avatar_config;
 if new.avatar_config->>'border'<>'none' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id='league_border_'||(new.avatar_config->>'border')) then
  raise exception 'Bordure non possédée'; end if;
 if new.avatar_config->>'exclusive_hat'<>'none' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id='league_hat_'||(new.avatar_config->>'exclusive_hat')) then
  raise exception 'Couvre-chef non possédé'; end if;
 return new;
end $$;
revoke all on function private.validate_avatar_rewards() from public,anon,authenticated,service_role;
create trigger profiles_validate_avatar_rewards before insert or update of avatar_config on public.profiles for each row execute function private.validate_avatar_rewards();

create or replace function private.equip_cosmetic(item text) returns void language plpgsql security definer set search_path='' as $$
declare c public.cosmetics;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into strict c from public.cosmetics where id=item;
 if not c.free and not exists(select 1 from public.inventory where user_id=auth.uid() and cosmetic_id=item) then raise exception 'Cosmétique non possédé'; end if;
 update public.profiles set avatar=case when c.kind='avatar' then item else avatar end,
 card_back=case when c.kind='card_back' then item else card_back end,
 table_theme=case when c.kind='table_theme' then item else table_theme end,
 avatar_config=case when c.kind='avatar_border' then avatar_config||jsonb_build_object('border',replace(item,'league_border_',''))
 when c.kind='exclusive_hat' then avatar_config||jsonb_build_object('exclusive_hat',replace(item,'league_hat_','')) else avatar_config end where id=auth.uid();
end $$;

create or replace function private.sync_inventory(player uuid, items text[]) returns void language plpgsql security definer set search_path='' as $$
begin
 if (auth.jwt()->>'role') is distinct from 'service_role' then raise exception 'Server only'; end if;
 perform 1 from public.profiles where id=player for update;
 if not found then return; end if;
 delete from public.inventory i where i.user_id=player and cosmetic_id in(select id from public.cosmetics where not free and product_id is not null)
 and not(cosmetic_id=any(items)) and not exists(select 1 from public.season_pass_claims c where c.user_id=player and c.cosmetic_id=i.cosmetic_id);
 insert into public.inventory(user_id,cosmetic_id) select player,id from public.cosmetics where not free and product_id is not null and id=any(items) on conflict do nothing;
 update public.profiles p set
 card_back=case when p.card_back='gold' and not exists(select 1 from public.inventory where user_id=player and cosmetic_id='gold') then 'classic' else p.card_back end,
 table_theme=case when p.table_theme='ruby' and not exists(select 1 from public.inventory where user_id=player and cosmetic_id='ruby') then 'green' else p.table_theme end where id=player;
end $$;

