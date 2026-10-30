import '../../l10n/app_localizations.dart';

/// Resolve server-owned identifiers at display time so locale changes stay live.
String catalogName(AppLocalizations l10n, String id, String fallback) =>
    switch (id) {
      'mus' => 'Mus',
      'sun' => l10n.catalogSun,
      'mountain' => l10n.catalogMountain,
      'classic' => l10n.classicCardBack,
      'blue' => l10n.catalogBlue,
      'gold' => l10n.oros,
      'green' => l10n.catalogGreen,
      'ocean' => l10n.catalogOcean,
      'ruby' => l10n.catalogRuby,
      'league_border_bronze' => l10n.menuBronzeBorder,
      'league_border_silver' => l10n.menuSilverBorder,
      'league_border_gold' => l10n.menuGoldBorder,
      'league_border_diamond' => l10n.catalogDiamondBorder,
      'league_hat_txapela' => l10n.catalogLeagueTxapela,
      'league_hat_crown' => l10n.catalogLeagueCrown,
      'shop_border_emerald' => l10n.catalogEmeraldBorder,
      'shop_border_amethyst' => l10n.catalogAmethystBorder,
      'shop_back_emerald' => l10n.catalogEmeraldBack,
      'shop_back_violet' => l10n.catalogVioletBack,
      'shop_chat_eskerrik' => l10n.catalogEskerrik,
      'shop_chat_rematch' => l10n.catalogRematch,
      'shop_hair_mullet' => l10n.catalogMullet,
      'shop_top_striped' => l10n.catalogStriped,
      'shop_glasses_gold' => l10n.catalogGoldGlasses,
      'shop_hat_cap' => l10n.catalogCap,
      'shop_hat_beanie' => l10n.catalogBeanie,
      'shop_glasses_fine' => l10n.menuGoldFrames,
      'shop_glasses_round' => l10n.catalogRoundGlasses,
      'shop_back_ocean' => l10n.catalogOceanBack,
      'shop_back_coral' => l10n.catalogCoralBack,
      'shop_hair_bald' => l10n.menuBald,
      'shop_hair_mohawk' => l10n.menuMohawk,
      _ => l10n.localeName == 'fr' ? fallback : l10n.catalogUnknown,
    };

String catalogDescription(AppLocalizations l10n, String id, String fallback) =>
    switch (id) {
      'shop_border_emerald' => l10n.catalogEmeraldBorderDescription,
      'shop_border_amethyst' => l10n.catalogAmethystBorderDescription,
      'shop_back_emerald' => l10n.catalogEmeraldBackDescription,
      'shop_back_violet' => l10n.catalogVioletBackDescription,
      'shop_chat_eskerrik' => l10n.catalogEskerrikDescription,
      'shop_chat_rematch' => l10n.catalogRematchDescription,
      'shop_hair_mullet' => l10n.catalogMulletDescription,
      'shop_top_striped' => l10n.catalogStripedDescription,
      'shop_glasses_gold' => l10n.catalogGoldGlassesDescription,
      'shop_hat_cap' => l10n.catalogCapDescription,
      'shop_hat_beanie' => l10n.catalogBeanieDescription,
      'shop_glasses_fine' => l10n.catalogFineGlassesDescription,
      'shop_glasses_round' => l10n.catalogRoundGlassesDescription,
      'shop_back_ocean' => l10n.catalogOceanBackDescription,
      'shop_back_coral' => l10n.catalogCoralBackDescription,
      'shop_hair_bald' => l10n.catalogBaldDescription,
      'shop_hair_mohawk' => l10n.catalogMohawkDescription,
      _ => l10n.localeName == 'fr' ? fallback : l10n.catalogUnknownDescription,
    };

String questTitle(AppLocalizations l10n, Map quest) {
  final count = (quest['target'] ?? 0).toString();
  return switch (quest['id']) {
    'play_week' => l10n.questPlay(count),
    'win_week' => l10n.questWin(count),
    'ranked_wins' => l10n.questRanked(count),
    _ =>
      l10n.localeName == 'fr'
          ? quest['title']?.toString() ?? l10n.questGeneric
          : l10n.questGeneric,
  };
}

String seasonTitle(AppLocalizations l10n, Map? season) {
  if (season == null) return l10n.menuNoActiveSeason;
  final name = (season['name'] ?? season['title'])?.toString();
  final monthly = RegExp(r'^Saison (\d{4}-\d{2})$').firstMatch(name ?? '');
  if (monthly != null) return l10n.seasonName(monthly.group(1)!);
  final start = DateTime.tryParse(
    (season['start_date'] ?? season['starts_at'])?.toString() ?? '',
  );
  if (l10n.localeName == 'fr' && name != null) return name;
  if (start != null) {
    return l10n.seasonName(
      '${start.year}-${start.month.toString().padLeft(2, '0')}',
    );
  }
  return l10n.seasonPassTitle;
}
