insert into public.cosmetics(id,kind,label,free) values
('shop_hair_bald','avatar_hair','Chauve',false),
('shop_hair_mohawk','avatar_hair','Crête',false) on conflict(id) do nothing;
insert into public.shop_items(item_id,cost,description) values
('shop_hair_bald',100,'Le crâne dégagé, sans couche de cheveux.'),
('shop_hair_mohawk',250,'Une crête centrée, visible de face.') on conflict(item_id) do nothing;
alter table public.profiles drop constraint profiles_avatar_config_valid;
alter table public.profiles add constraint profiles_avatar_config_valid check (
 jsonb_typeof(avatar_config)='object'
 and avatar_config ?& array['skin','hair','glasses','top','background_color','hair_color','border','exclusive_hat']
 and avatar_config - array['skin','hair','glasses','top','background_color','hair_color','border','exclusive_hat']='{}'::jsonb
 and avatar_config->'skin' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'hair' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'4'::jsonb,'5'::jsonb)
 and avatar_config->'glasses' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb)
 and avatar_config->'top' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb)
 and avatar_config->'background_color' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb,'5'::jsonb,'6'::jsonb,'7'::jsonb,'8'::jsonb,'9'::jsonb,'10'::jsonb,'11'::jsonb)
 and avatar_config->'hair_color' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb,'5'::jsonb)
 and avatar_config->'border' in ('"none"'::jsonb,'"bronze"'::jsonb,'"silver"'::jsonb,'"gold"'::jsonb,'"diamond"'::jsonb)
 and avatar_config->'exclusive_hat' in ('"none"'::jsonb,'"txapela"'::jsonb,'"crown"'::jsonb,'"cap"'::jsonb,'"beanie"'::jsonb)
);


create or replace function private.validate_avatar_rewards() returns trigger language plpgsql security definer set search_path='' as $$
declare part text; item text;
begin
 new.avatar_config:=jsonb_build_object('border',case when tg_op='UPDATE' then old.avatar_config->>'border' else 'none' end,
 'exclusive_hat',case when tg_op='UPDATE' then old.avatar_config->>'exclusive_hat' else 'none' end)||new.avatar_config;
 if new.avatar_config->>'border'<>'none' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id='league_border_'||(new.avatar_config->>'border')) then raise exception 'Bordure non possédée'; end if;
 if new.avatar_config->>'exclusive_hat'<>'none' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id=(case when new.avatar_config->>'exclusive_hat' in ('cap','beanie') then 'shop_hat_' else 'league_hat_' end)||(new.avatar_config->>'exclusive_hat')) then raise exception 'Couvre-chef non possédé'; end if;
 for part,item in select * from (values ('glasses','shop_glasses_fine'),('top','shop_top_striped')) as required(part,item) loop
   if new.avatar_config->>part='3' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id=item) then raise exception 'Accessoire non possédé'; end if;
 end loop;
 if new.avatar_config->>'glasses'='4' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id='shop_glasses_round') then raise exception 'Accessoire non possédé'; end if;
 if new.avatar_config->>'hair' in ('4','5') and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id=case when new.avatar_config->>'hair'='4' then 'shop_hair_bald' else 'shop_hair_mohawk' end) then raise exception 'Coiffure non possédée'; end if;
 return new;
end $$;
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
 when c.kind='avatar_hair' then avatar_config||jsonb_build_object('hair',case when item='shop_hair_bald' then 4 else 5 end)
 when c.kind='avatar_top' then avatar_config||jsonb_build_object('top',3)
 when c.kind='avatar_glasses' then avatar_config||jsonb_build_object('glasses',case when item='shop_glasses_round' then 4 else 3 end)
 when c.kind='exclusive_hat' then avatar_config||jsonb_build_object('exclusive_hat',replace(replace(item,'league_hat_',''),'shop_hat_','')) else avatar_config end where id=auth.uid();
end $$;


