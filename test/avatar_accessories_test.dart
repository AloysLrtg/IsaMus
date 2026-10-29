import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/features/avatar/player_avatar_view.dart';

void main() {
  test('Une ancienne configuration opaque revient à des yeux visibles', () {
    expect(AvatarConfig.fromJson({'glasses': 3}).glasses, 0);
    expect(AvatarConfig.countFor(AvatarPart.glasses), 3);
  });
  for (final hat in [ExclusiveHat.cap, ExclusiveHat.beanie]) {
    testWidgets('Accessoires superposés avec ${hat.name}', (tester) async {
      final config = AvatarConfig(
        hair: 3,
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
      for (final layer in ['hair_3', 'top_3', 'glasses_1', 'hat_${hat.name}']) {
        expect(assets, contains('assets/avatars/$layer.png'));
      }
      expect(
        find.byKey(ValueKey('avatar-hat-fallback-${hat.name}')),
        findsOneWidget,
      );
      // The hat is painted after the portrait, with facial expressions below it.
      expect(
        assets.indexOf('assets/avatars/hat_${hat.name}.png'),
        greaterThan(assets.indexOf('assets/avatars/hair_3.png')),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
