import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/features/avatar/player_avatar_view.dart';
import 'package:isamus/features/avatar/avatar_palette.dart';

void main() {
  test('Les douze fonds sont gratuits et persistants', () {
    expect(AvatarPalette.backgrounds.length, 12);
    expect(AvatarPalette.backgroundLabels.length, 12);
    for (var i = 0; i < 12; i++) {
      expect(AvatarConfig.cosmeticIdFor(AvatarPart.backgroundColor, i), isNull);
      final config = const AvatarConfig().withOption(
        AvatarPart.backgroundColor,
        i,
      );
      expect(AvatarConfig.fromJson(config.toJson()).backgroundColor, i);
    }
  });
  test('Le Mulet ancien est normalisé et les montures sont disponibles', () {
    expect(AvatarConfig.fromJson({'hair': 3}).hair, 0);
    expect(AvatarConfig.countFor(AvatarPart.glasses), 5);
  });
  for (final style in [AvatarConfig.baldHair, AvatarConfig.mohawkHair]) {
    testWidgets('Coupe de face $style : couche de cheveux contrôlée', (
      tester,
    ) async {
      final config = const AvatarConfig().withOption(AvatarPart.hair, style);
      expect(AvatarConfig.fromJson(config.toJson()).hair, style);
      await tester.pumpWidget(
        MaterialApp(
          home: Center(child: PlayerAvatarView(config: config)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(
          ValueKey(
            style == AvatarConfig.baldHair ? 'avatar-bald' : 'avatar-mohawk',
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widgetList<Image>(find.byType(Image))
            .where(
              (image) =>
                  (image.image as AssetImage).assetName.contains('/hair_'),
            ),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    });
  }
  for (final hat in [ExclusiveHat.cap, ExclusiveHat.beanie]) {
    testWidgets('Accessoires superposés avec ${hat.name}', (tester) async {
      final config = AvatarConfig(
        hair: 2,
        top: 3,
        glasses: 1,
        exclusiveHat: hat,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Center(child: PlayerAvatarView(config: config, size: 96)),
        ),
      );
      await tester.pumpAndSettle();
      final assets = tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as AssetImage).assetName)
          .toList();
      for (final layer in ['hair_2', 'top_3', 'glasses_1', 'hat_${hat.name}']) {
        expect(assets, contains('assets/avatars/$layer.png'));
      }
      expect(
        find.byKey(ValueKey('avatar-hat-fallback-${hat.name}')),
        findsOneWidget,
      );
      // The hat is painted after the portrait, with facial expressions below it.
      expect(
        assets.indexOf('assets/avatars/hat_${hat.name}.png'),
        greaterThan(assets.indexOf('assets/avatars/hair_2.png')),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
