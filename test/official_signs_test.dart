import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_sign.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/models/card.dart' as mus;
import 'package:isamus/features/avatar/player_avatar_view.dart';

List<mus.Card> hand(List<int> values) => [
  for (var i = 0; i < values.length; i++)
    mus.Card(values[i], mus.Suit.values[i]),
];

void main() {
  test('29 après les paires seulement ; Dobliak reste disponible avant', () {
    final h = hand([12, 11, 7, 2]);
    expect(availableMusSigns(h), isEmpty);
    expect(availableMusSigns(h, pairsResolved: true), [MusSign.twentyNine]);
    for (final phase in BidPhase.values) {
      final state = MusGameState.initial().copyWith(
        phase: MusPhase.bidding,
        hands: [h, h, h, h],
        bidding: BiddingState(phase: phase, participants: const [0, 1, 2, 3]),
      );
      expect(
        state.availableSignsForSeat(0).contains(MusSign.twentyNine),
        phase == BidPhase.jeu || phase == BidPhase.point,
      );
    }
    expect(availableMusSigns(hand([7, 7, 6, 6])), contains(MusSign.dobliak));
  });

  test('30 et 31 ont des annonces distinctes ; Jeu interdit à 31', () {
    final thirty = availableMusSigns(hand([12, 11, 7, 3]));
    final thirtyOne = availableMusSigns(hand([12, 11, 10, 1]));
    expect(thirty, contains(MusSign.thirty));
    expect(thirty, isNot(contains(MusSign.thirtyOne)));
    expect(thirtyOne, contains(MusSign.thirtyOne));
    expect(thirtyOne, isNot(contains(MusSign.game)));
    expect(availableMusSigns(hand([12, 11, 10, 2])), contains(MusSign.game));
    expect(parseMusSign('blind'), isNull);
    expect(parseMusSign('31'), MusSign.thirtyOne);
    expect(parseMusSign('2 As'), MusSign.twoAces);
  });

  for (final entry in {
    '2 Rois': ['eyes_normal', 'mouth_bite', 'brows_normal'],
    '2 As': ['eyes_normal', 'mouth_tongue', 'brows_normal'],
    'Mediak': ['eyes_normal', 'mouth_side', 'brows_normal'],
    'Dobliak': ['eyes_normal', 'mouth_both_sides', 'brows_normal'],
    '29': ['eyes_normal', 'mouth_both_sides', 'brows_normal'],
    '30': ['eyes_wink', 'mouth_normal', 'brows_normal'],
    '31': ['eyes_wink', 'mouth_normal', 'brows_normal'],
    'Jeu': ['eyes_normal', 'mouth_normal', 'brows_raised'],
  }.entries) {
    testWidgets(
      '${entry.key} remplace le composant facial sans emoji et expire',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PlayerAvatarView(
              config: const AvatarConfig(),
              currentSign: entry.key,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        List<String> assets() => tester
            .widgetList<Image>(find.byType(Image))
            .map((image) => (image.image as AssetImage).assetName)
            .toList();
        for (final part in entry.value) {
          expect(assets(), contains('assets/avatars/$part.png'));
        }
        expect(find.byType(Text), findsNothing);
        expect(
          find.byKey(const ValueKey('avatar-fallback-eyes')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('avatar-fallback-mouth')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('avatar-fallback-brows')),
          findsOneWidget,
        );
        final before = tester
            .widget<CustomPaint>(
              find.byKey(const ValueKey('avatar-fallback-mouth')),
            )
            .painter;
        await tester.pump(const Duration(milliseconds: 100));
        final after = tester
            .widget<CustomPaint>(
              find.byKey(const ValueKey('avatar-fallback-mouth')),
            )
            .painter!;
        expect(after.shouldRepaint(before!), isTrue);
        await tester.pump(const Duration(seconds: 2));
        expect(find.byKey(const ValueKey('avatar-current-sign')), findsNothing);
        for (final part in ['eyes', 'mouth', 'brows']) {
          expect(assets(), contains('assets/avatars/${part}_normal.png'));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
