import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/features/game/card_back_view.dart';
import 'package:isamus/features/profile/profile_tab.dart' show backColor;

void main() {
  for (final id in ['classic', 'shop_back_violet', 'shop_back_emerald']) {
    testWidgets('Le dos $id conserve le motif espagnol', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(width: 48, height: 68, child: CardBackView(id: id)),
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/cards/card_back.png'),
          tester.element(find.byType(CardBackView)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.renderObject<RenderImage>(find.byType(RawImage)).image,
        isNotNull,
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        'assets/cards/card_back.png',
      );
      expect(image.color, id == 'classic' ? null : backColor(id));
      expect(image.colorBlendMode, id == 'classic' ? null : BlendMode.color);
      expect(find.byIcon(Icons.style_rounded), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
