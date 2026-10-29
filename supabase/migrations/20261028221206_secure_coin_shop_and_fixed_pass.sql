-- Fixed pass amounts. Prior claims and balances are never recalculated.
update public.season_rewards set free_coins=case when tier%5=0 then 50 else null end,vip_coins=100;

alter table public.cosmetics drop constraint cosmetics_kind_check;
alter table public.cosmetics add constraint cosmetics_kind_check check(kind in ('avatar','card_back','table_theme','avatar_border','exclusive_hat','quick_chat'));
insert into public.cosmetics(id,kind,label,free) values
 ('shop_border_emerald','avatar_border','Cadre Émeraude',false),
 ('shop_border_amethyst','avatar_border','Cadre Améthyste',false),
 ('shop_back_emerald','card_back','Dos Émeraude',false),
 ('shop_back_violet','card_back','Dos Violet',false),
 ('shop_chat_eskerrik','quick_chat','Eskerrik asko !',false),
 ('shop_chat_rematch','quick_chat','La revanche ?',false);
create table public.shop_items (
 item_id text primary key references public.cosmetics(id),
 cost integer not null check(cost>0), enabled boolean not null default true,
 description text not null
);
insert into public.shop_items(item_id,cost,description) values
 ('shop_border_emerald',300,'Un anneau émeraude autour de votre avatar.'),
 ('shop_border_amethyst',400,'Une bordure violette à afficher à la table.'),
 ('shop_back_emerald',250,'Un dos de cartes vert émeraude.'),
 ('shop_back_violet',250,'Un dos de cartes violet.'),
 ('shop_chat_eskerrik',150,'Remerciez les autres joueurs en un clic.'),
 ('shop_chat_rematch',150,'Proposez une nouvelle partie à la table.');
alter table public.shop_items enable row level security;
revoke all on public.shop_items from public,anon,authenticated;
grant select on public.shop_items to authenticated;
create policy shop_read on public.shop_items for select to authenticated using(enabled);

-- p_cost detects a stale catalogue; it never determines the charged price.
create function private.buy_shop_item(p_item_id text,p_cost integer) returns jsonb language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); price integer; balance integer;
begin
 if player is null then raise exception 'Authentication required'; end if;
 select cost into price from public.shop_items where item_id=p_item_id and enabled for share;
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
create function public.buy_shop_item(p_item_id text,p_cost integer) returns jsonb language sql security invoker set search_path='' as $$select private.buy_shop_item(p_item_id,p_cost)$$;
revoke all on function private.buy_shop_item(text,integer),public.buy_shop_item(text,integer) from public,anon;
grant execute on function private.buy_shop_item(text,integer),public.buy_shop_item(text,integer) to authenticated;

alter table public.profiles drop constraint profiles_avatar_config_valid;
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
 and avatar_config->'border' in ('"none"'::jsonb,'"bronze"'::jsonb,'"silver"'::jsonb,'"gold"'::jsonb,'"diamond"'::jsonb,'"emerald"'::jsonb,'"amethyst"'::jsonb)
 and avatar_config->'exclusive_hat' in ('"none"'::jsonb,'"txapela"'::jsonb,'"crown"'::jsonb)
);

create or replace function private.validate_avatar_rewards() returns trigger language plpgsql security definer set search_path='' as $$
begin
 -- Older clients may omit the two keys; never silently remove equipped rewards.
 new.avatar_config:=jsonb_build_object('border',case when tg_op='UPDATE' then old.avatar_config->>'border' else 'none' end,
 'exclusive_hat',case when tg_op='UPDATE' then old.avatar_config->>'exclusive_hat' else 'none' end)||new.avatar_config;
 if new.avatar_config->>'border'<>'none' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id=(case when new.avatar_config->>'border' in ('emerald','amethyst') then 'shop_border_' else 'league_border_' end)||(new.avatar_config->>'border')) then
  raise exception 'Bordure non possédée'; end if;
 if new.avatar_config->>'exclusive_hat'<>'none' and not exists(select 1 from public.inventory where user_id=new.id and cosmetic_id='league_hat_'||(new.avatar_config->>'exclusive_hat')) then
  raise exception 'Couvre-chef non possédé'; end if;
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
 avatar_config=case when c.kind='avatar_border' then avatar_config||jsonb_build_object('border',replace(replace(item,'league_border_',''),'shop_border_',''))
 when c.kind='exclusive_hat' then avatar_config||jsonb_build_object('exclusive_hat',replace(item,'league_hat_','')) else avatar_config end where id=auth.uid();
end $$;


create or replace function private.claim_season_pass(season text,tier_number integer,premium boolean) returns jsonb
 language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); pr public.profiles; reward public.season_rewards; amount integer; item text; inserted integer;
begin
 if player is null then raise exception 'Authentication required'; end if;
 if tier_number is null or tier_number not between 1 and 30 or premium is null then raise exception 'Palier invalide'; end if;
 perform 1 from public.seasons where id=season and start_date<=now() and end_date>now() and closed_at is null for share;
 if not found then raise exception 'Saison indisponible'; end if;
 select * into strict pr from public.profiles where id=player for update;
 if pr.level<tier_number then raise exception 'Niveau insuffisant'; end if;
 if premium and not coalesce(pr.vip_expires_at>now(),false) then raise exception 'VIP requis'; end if;
 select * into strict reward from public.season_rewards where season_id=season and tier=tier_number;
 if not premium and reward.free_coins is null then raise exception 'Aucune récompense gratuite à ce palier'; end if;
 amount:=(case when premium then reward.vip_coins else reward.free_coins end);
 item:=case when premium then reward.vip_cosmetic else null end;
 insert into public.season_pass_claims(user_id,season_id,tier,vip_track,coins,cosmetic_id)
 values(player,season,tier_number,premium,amount,item) on conflict do nothing;
 get diagnostics inserted=row_count;
 if inserted=0 then return jsonb_build_object('coins',0,'cosmetic',null,'already_claimed',true); end if;
 update public.profiles set coins=coins+amount where id=player;
 if item is not null then insert into public.inventory(user_id,cosmetic_id) values(player,item) on conflict do nothing; end if;
 return jsonb_build_object('coins',amount,'cosmetic',item,'already_claimed',false);
end $$;

