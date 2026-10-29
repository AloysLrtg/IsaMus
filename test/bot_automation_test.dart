import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_sign.dart';
import 'package:isamus/core/models/card.dart';

const delay = Duration(milliseconds: 1700);

class SignalRandom implements Random {
  SignalRandom(this.send);
  final bool send;
  @override
  bool nextBool() => send;
  @override
  int nextInt(int max) => 0;
  @override
  double nextDouble() => .999999;
}

List<List<Card>> table(List<List<int>> values) => [
  for (var seat = 0; seat < 4; seat++)
    [
      for (var i = 0; i < 4; i++)
        Card(values[seat][i], Suit.values[(seat + i) % 4]),
    ],
];
final weakHands = table([
  [1, 4, 6, 7],
  [2, 4, 6, 7],
  [3, 4, 6, 7],
  [2, 5, 6, 7],
]);
final signalHands = table([
  [12, 12, 1, 1],
  [2, 4, 6, 7],
  [12, 12, 12, 1],
  [2, 5, 6, 7],
]);

Future<void> withGame(
  WidgetTester tester,
  Future<void> Function(MusGameController, MusGameState Function()) run, {
  bool signal = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      musRandomProvider.overrideWithValue(Random(42)),
      musBotRandomProvider.overrideWithValue(SignalRandom(signal)),
      musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
    ],
  );
  try {
    await run(
      container.read(musGameControllerProvider.notifier),
      () => container.read(musGameControllerProvider),
    );
  } finally {
    container.dispose();
    await tester.pump();
  }
}

void main() {
  testWidgets('Bots 1, 2, 3 parlent à 1,7 s, jamais à la place du joueur 0', (
    tester,
  ) async {
    await withGame(tester, (c, s) async {
      c.startGame(hands: weakHands);
      await tester.pump(const Duration(seconds: 3));
      expect(s().musVotes, isEmpty);
      c.chooseMus(0, MusChoice.mus);
      await tester.pump(const Duration(milliseconds: 1699));
      expect(s().currentPlayer, 2);
      await tester.pump(const Duration(milliseconds: 1));
      expect(s().currentPlayer, 3);
      await tester.pump(delay);
      expect(s().currentPlayer, 1);
      await tester.pump(delay);
      expect(s().phase, MusPhase.discarding);
      expect(s().currentPlayer, 0);
      c.discard(0, []);
      for (final seat in [3, 2, 1]) {
        await tester.pump(delay);
        if (seat != 1) expect(s().discardSelections[seat], [0, 1, 2, 3]);
      }
      expect(s().phase, MusPhase.musDecision);
      expect(s().currentPlayer, 0);
      expect(s().hands.every((hand) => hand.length == 4), isTrue);
    });
  });

  testWidgets('Une nouvelle partie annule le tour différé précédent', (
    tester,
  ) async {
    await withGame(tester, (c, s) async {
      c.startGame(eskuIndex: 1, hands: weakHands);
      await tester.pump(const Duration(seconds: 1));
      c.startGame(hands: signalHands);
      await tester.pump(const Duration(seconds: 3));
      expect(s().currentPlayer, 0);
      expect(s().musVotes, isEmpty);
    });
  });

  testWidgets('Une action manuelle remplace le délai sans double action', (
    tester,
  ) async {
    await withGame(tester, (c, s) async {
      c.startGame(eskuIndex: 1, hands: weakHands);
      await tester.pump(const Duration(seconds: 1));
      c.chooseMus(1, MusChoice.mus);
      await tester.pump(const Duration(milliseconds: 700));
      expect(s().currentPlayer, 3);
      await tester.pump(const Duration(seconds: 1));
      expect(s().currentPlayer, 0);
      expect(s().musVotes, hasLength(2));
    });
  });

  testWidgets('Un signe ne retarde pas le bot et disparaît après 2 s', (
    tester,
  ) async {
    await withGame(tester, (c, s) async {
      c.startGame(eskuIndex: 1, hands: signalHands);
      await tester.pump(const Duration(seconds: 1));
      c.sendSignForSeat(0, MusSign.twoKings);
      await tester.pump(const Duration(milliseconds: 700));
      expect(s().currentPlayer, 3);
      expect(s().signs[0], MusSign.twoKings);
      await tester.pump(const Duration(milliseconds: 1299));
      expect(s().signs[0], MusSign.twoKings);
      await tester.pump(const Duration(milliseconds: 1));
      expect(s().signs, isEmpty);
    });
  });

  testWidgets(
    'Remplacer un signe renouvelle ses 2 s, sans expiration prématurée',
    (tester) async {
      await withGame(tester, (c, s) async {
        c.startGame(hands: signalHands);
        c.sendSignForSeat(0, MusSign.twoKings);
        await tester.pump(const Duration(seconds: 1));
        c.sendSignForSeat(0, MusSign.twoAces);
        await tester.pump(const Duration(seconds: 1));
        expect(s().signs[0], MusSign.twoAces);
        await tester.pump(const Duration(seconds: 1));
        expect(s().signs, isEmpty);
        expect(() => c.sendSignForSeat(0, MusSign.thirtyOne), throwsStateError);
        expect(() => c.sendSignForSeat(2, MusSign.game), throwsStateError);
      });
    },
  );

  testWidgets('Le partenaire peut envoyer un signe sincère au début du Mus', (
    tester,
  ) async {
    await withGame(tester, (c, s) async {
      c.startGame(hands: signalHands);
      expect(s().signs[2], MusSign.twoKings);
      await tester.pump(const Duration(seconds: 2));
      expect(s().signs, isEmpty);
      c.startGame(hands: weakHands);
      expect(s().signs, isEmpty);
    }, signal: true);
  });

  testWidgets('Décompte puis nouvelle donne : aucune action ou signe périmé', (
    tester,
  ) async {
    await withGame(tester, (c, s) async {
      c.startGame(hands: signalHands);
      c.sendSignForSeat(0, MusSign.twoKings);
      c.chooseMus(0, MusChoice.mintza);
      c.act(0, BidActionType.hordago);
      c.act(3, BidActionType.iduki);
      expect(s().phase, MusPhase.roundScoring);
      expect(s().signs, isEmpty);
      // ignore: invalid_use_of_protected_member
      c.state = s().copyWith(tantto: [0, 0]);
      final snapshot = s();
      await tester.pump(const Duration(seconds: 3));
      expect(identical(s(), snapshot), isTrue);
      c.nextHand(hands: weakHands);
      expect(s().eskuIndex, 3);
      await tester.pump(delay);
      expect(s().currentPlayer, 1);
    });
  });

  testWidgets('Une donne entière progresse automatiquement jusqu’au décompte', (
    tester,
  ) async {
    await withGame(tester, (c, s) async {
      c.startGame();
      for (
        var step = 0;
        step < 80 && s().phase != MusPhase.roundScoring;
        step++
      ) {
        if (s().currentPlayer != 0) {
          await tester.pump(delay);
        } else if (s().phase == MusPhase.musDecision) {
          c.chooseMus(0, MusChoice.mintza);
        } else if (s().phase == MusPhase.bidding) {
          c.act(
            0,
            s().bidding!.stage == BidStage.opening
                ? BidActionType.paso
                : BidActionType.iduki,
          );
        } else {
          fail('Phase inattendue : ${s().phase}');
        }
      }
      expect(s().phase, MusPhase.roundScoring);
      expect(s().scoreLog, isNotEmpty);
    });
  });

  testWidgets('Destruction : les délais des bots et signes sont annulés', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [musBotRandomProvider.overrideWithValue(SignalRandom(true))],
    );
    container
        .read(musGameControllerProvider.notifier)
        .startGame(eskuIndex: 1, hands: signalHands);
    container.dispose();
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });
}
