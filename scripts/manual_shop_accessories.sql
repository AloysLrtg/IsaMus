-- Migration 20261029094535_shop_accessories_and_card_patterns
-- IsaMus : accessoires de boutique. À exécuter une seule fois dans le SQL Editor.
-- Nécessite la migration précédente secure_coin_shop_and_fixed_pass.
begin;
-- Retire store borders. Refund the original price once per owned item.
update public.shop_items set enabled=false where item_id in ('shop_border_emerald','shop_border_amethyst');
update public.profiles set avatar_config=avatar_config||'{"border":"none"}'::jsonb where avatar_config->>'border' in ('emerald','amethyst');
with retired as (
 delete from public.inventory where cosmetic_id in ('shop_border_emerald','shop_border_amethyst') returning user_id,cosmetic_id
), refunds as (
 select user_id,sum(case cosmetic_id when 'shop_border_emerald' then 300 else 400 end)::integer amount from retired group by user_id
) update public.profiles p set coins=p.coins+r.amount from refunds r where p.id=r.user_id;

alter table public.cosmetics drop constraint cosmetics_kind_check;
alter table public.cosmetics add constraint cosmetics_kind_check check(kind in ('avatar','card_back','table_theme','avatar_border','exclusive_hat','quick_chat','avatar_hair','avatar_top','avatar_glasses'));
insert into public.cosmetics(id,kind,label,free) values
 ('shop_hair_mullet','avatar_hair','Coupe Mulet',false),
 ('shop_top_striped','avatar_top','Maillot Rayé Bleu et Blanc',false),
 ('shop_glasses_gold','avatar_glasses','Lunettes de Soleil Dorées',false),
 ('shop_hat_cap','exclusive_hat','Casquette Bleue',false),
 ('shop_hat_beanie','exclusive_hat','Bonnet Cuivré',false);
insert into public.shop_items(item_id,cost,description) values
 ('shop_hair_mullet',300,'Court devant, long derrière : une coupe de caractère.'),
 ('shop_top_striped',300,'Des rayures bleues et blanches pour votre tenue.'),
 ('shop_glasses_gold',250,'Des verres sombres et une monture dorée.'),
 ('shop_hat_cap',200,'Une casquette bleue portée au-dessus des cheveux.'),
 ('shop_hat_beanie',200,'Un bonnet cuivré avec son pompon.');
-- Exclude league borders from both discovery and purchase, even if re-enabled.
drop policy shop_read on public.shop_items;
create policy shop_read on public.shop_items for select to authenticated using(enabled and exists(select 1 from public.cosmetics c where c.id=item_id and c.kind<>'avatar_border'));
create or replace function private.buy_shop_item(p_item_id text,p_cost integer) returns jsonb language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); price integer; balance integer;
begin
 if player is null then raise exception 'Authentication required'; end if;
 select s.cost into price from public.shop_items s join public.cosmetics c on c.id=s.item_id where s.item_id=p_item_id and s.enabled and c.kind<>'avatar_border' for share of s,c;
 if not found then raise exception 'Article indisponible'; end if;
 if p_cost is distinct from price then raise exception 'Prix modifié. Actualisez la boutique.'; end if;
 select coins into strict balance from public.profiles where id=player for update;
 if exists(select 1 from public.inventory where user_id=player and cosmetic_id=p_item_id) then raise exception 'Article déjà possédé'; end if;
 if balance<price then raise exception 'Fonds insuffisants'; end if;
 update public.profiles set coins=coins-price where id=player;
 -- A uniqueness failure also rolls back the debit, including an admin grant race.
 insert into public.inventory(user_id,cosmetic_id) values(player,p_item_id);
 return jsonb_build_object('item_id',p_item_id,'coins_remaining',balance-price);
end $$;
alter table public.profiles drop constraint profiles_avatar_config_valid;
alter table public.profiles add constraint profiles_avatar_config_valid check (
 jsonb_typeof(avatar_config)='object'
 and avatar_config ?& array['skin','hair','glasses','top','background_color','hair_color','border','exclusive_hat']
 and avatar_config - array['skin','hair','glasses','top','background_color','hair_color','border','exclusive_hat']='{}'::jsonb
 and avatar_config->'skin' in ('0'::jsonb,'1'::jsonb,'2'::jsonb)
 and avatar_config->'hair' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb)
 and avatar_config->'glasses' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb)
 and avatar_config->'top' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb)
 and avatar_config->'background_color' in ('0'::jsonb,'1'::jsonb,'2'::jsonb,'3'::jsonb,'4'::jsonb,'5'::jsonb)
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
 for part,item in select * from (values ('hair','shop_hair_mullet'),('glasses','shop_glasses_gold'),('top','shop_top_striped')) as required(part,item) loop
   if new.avatar_config->>part='3' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id=item) then raise exception 'Accessoire non possédé'; end if;
 end loop;
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
 when c.kind='avatar_hair' then avatar_config||jsonb_build_object('hair',3)
 when c.kind='avatar_top' then avatar_config||jsonb_build_object('top',3)
 when c.kind='avatar_glasses' then avatar_config||jsonb_build_object('glasses',3)
 when c.kind='exclusive_hat' then avatar_config||jsonb_build_object('exclusive_hat',replace(replace(item,'league_hat_',''),'shop_hat_','')) else avatar_config end where id=auth.uid();
end $$;



commit;
