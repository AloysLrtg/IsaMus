import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/season_reward.dart';

Map<String, dynamic> definition(int tier) => {
  'tier': tier,
  'free_coins': tier % 5 == 0 ? 50 : null,
  'vip_coins': 100,
  'vip_cosmetic': null,
  'vip_cosmetic_placeholder': [10, 20, 30].contains(tier)
      ? 'season_1_cosmetic_$tier'
      : null,
};

void main() {
  test('Saison 1 : six récompenses gratuites, espacées de cinq paliers', () {
    final rewards = [
      for (var tier = 1; tier <= 30; tier++)
        SeasonReward.fromJson(definition(tier)),
    ];
    expect(rewards.where((r) => r.hasFreeReward).map((r) => r.tier), [
      5,
      10,
      15,
      20,
      25,
      30,
    ]);
    expect(
      rewards.where((r) => r.hasFreeReward).every((r) => r.freeCoins == 50),
      isTrue,
    );
    expect(rewards.every((r) => r.vipCoins == 100), isTrue);
    expect(rewards.first.freeCoins, isNull);
    expect(rewards[4].freeCoins, 50);
  });
  test(
    'VIP : récompense à chaque palier et trois aperçus non distribuables',
    () {
      final rewards = [
        for (var tier = 1; tier <= 30; tier++)
          SeasonReward.fromJson(definition(tier)),
      ];
      expect(rewards.every((r) => r.hasVipReward), isTrue);
      expect(rewards.where((r) => r.hasCosmeticPreview).map((r) => r.tier), [
        10,
        20,
        30,
      ]);
      expect(rewards.every((r) => r.vipCosmetic == null), isTrue);
    },
  );
  test('Un montant gratuit nul ou absent ne crée aucune récompense', () {
    for (final value in [null, 0, -1, '45']) {
      expect(
        SeasonReward.fromJson({...definition(1), 'free_coins': value})
            .hasFreeReward,
        isFalse,
      );
    }
  });
  test(
    'Les anciens objets réels restent distincts des aperçus cosmétiques',
    () {
      final legacy = SeasonReward.fromJson({
        ...definition(15),
        'vip_cosmetic': 'gold',
      });
      expect(legacy.vipCosmetic, 'gold');
      expect(legacy.hasCosmeticPreview, isFalse);
      expect(
        () => SeasonReward.fromJson({...definition(1), 'tier': 31}),
        throwsFormatException,
      );
    },
  );
}
