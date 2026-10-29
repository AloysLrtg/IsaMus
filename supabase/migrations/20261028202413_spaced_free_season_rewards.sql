-- Null means no free reward, not a zero-value claimable reward.
-- Existing claim ledgers, wallet balances and earned cosmetics are preserved.
alter table public.season_rewards alter column free_coins drop not null;
alter table public.season_rewards add column vip_cosmetic_placeholder text;
update public.season_rewards set
 free_coins=case when tier%5=0 then 20+tier*5 else null end,
 vip_cosmetic=null,
 vip_cosmetic_placeholder=case when tier in (10,20,30) then 'season_1_cosmetic_'||tier::text else null end
where season_id='season_1';

create or replace function private.claim_season_pass(season text,tier_number integer,premium boolean) returns jsonb
 language plpgsql security definer set search_path='' as $$
declare player uuid:=auth.uid(); pr public.profiles; reward public.season_rewards; amount integer; item text; inserted integer;
begin
 if player is null then raise exception 'Authentication required'; end if;
 if tier_number is null or tier_number not between 1 and 30 or premium is null then raise exception 'Palier invalide'; end if;
 perform 1 from public.seasons where id=season and starts_at<=now() and ends_at>now() for share;
 if not found then raise exception 'Saison indisponible'; end if;
 select * into strict pr from public.profiles where id=player for update;
 if pr.level<tier_number then raise exception 'Niveau insuffisant'; end if;
 if premium and not coalesce(pr.vip_expires_at>now(),false) then raise exception 'VIP requis'; end if;
 select * into strict reward from public.season_rewards where season_id=season and tier=tier_number;
 if not premium and reward.free_coins is null then raise exception 'Aucune récompense gratuite à ce palier'; end if;
 amount:=(case when premium then reward.vip_coins else reward.free_coins end)*(case when pr.vip_expires_at>now() then 3 else 1 end);
 item:=case when premium then reward.vip_cosmetic else null end;
 insert into public.season_pass_claims(user_id,season_id,tier,vip_track,coins,cosmetic_id)
 values(player,season,tier_number,premium,amount,item) on conflict do nothing;
 get diagnostics inserted=row_count;
 if inserted=0 then return jsonb_build_object('coins',0,'cosmetic',null,'already_claimed',true); end if;
 update public.profiles set coins=coins+amount where id=player;
 if item is not null then insert into public.inventory(user_id,cosmetic_id) values(player,item) on conflict do nothing; end if;
 return jsonb_build_object('coins',amount,'cosmetic',item,'already_claimed',false);
end $$;
