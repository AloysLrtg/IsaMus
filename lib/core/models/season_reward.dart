/// Definitions come from Supabase. A null free amount denotes an empty slot.
class SeasonReward {
  const SeasonReward({
    required this.tier,
    required this.freeCoins,
    required this.vipCoins,
    this.vipCosmetic,
    this.vipCosmeticPlaceholder,
  });
  final int tier;
  final int? freeCoins;
  final int vipCoins;
  final String? vipCosmetic;
  final String? vipCosmeticPlaceholder;
  bool get hasFreeReward => freeCoins != null && freeCoins! > 0;
  bool get hasVipReward => vipCoins > 0 || vipCosmetic != null;
  bool get hasCosmeticPreview => vipCosmeticPlaceholder != null;

  factory SeasonReward.fromJson(Map json) {
    int positive(Object? value) => value is int && value > 0 ? value : 0;
    String? text(Object? value) =>
        value is String && value.isNotEmpty ? value : null;
    final tier = json['tier'];
    if (tier is! int || tier < 1 || tier > 30) {
      throw const FormatException('Palier invalide');
    }
    final free = positive(json['free_coins']);
    return SeasonReward(
      tier: tier,
      freeCoins: free == 0 ? null : free,
      vipCoins: positive(json['vip_coins']),
      vipCosmetic: text(json['vip_cosmetic']),
      vipCosmeticPlaceholder: text(json['vip_cosmetic_placeholder']),
    );
  }
}
