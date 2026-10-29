import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';

import 'mus_game_controller_test.dart' show basicHands, table;

void main() {
  late ProviderContainer container;
  late MusGameController c;
  MusGameState s() => container.read(musGameControllerProvider);
  setUp(() {
    container = ProviderContainer(
      overrides: [
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
        musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        musBidResolutionDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    c = container.read(musGameControllerProvider.notifier);
    c.configureMultiplayer(
      players: [
        {'seat': 0, 'name': 'Joueur 1', 'is_host': true},
        {'seat': 3, 'name': 'Joueur 2'},
        {'seat': 1, 'name': 'Joueur 3'},
        {'seat': 2, 'name': 'Joueur 4'},
      ],
    );
    c.startGame(hands: basicHands);
    c.chooseMus(0, MusChoice.mintza);
  });
  test('Joueur 1 Mise -> Joueur 2 Tira -> partenaire Joueur 3 -> Tira -> fin de phase', () {
    c.act(0, BidActionType.embido, amount: 2);
    expect(s().currentPlayer, 3);
    c.act(3, BidActionType.tira);
    expect(s().bidding!.phase, BidPhase.grand);
    expect(s().currentPlayer, 1);
    expect(s().bidding!.partnerDecides, isTrue);
    expect(s().bidding!.responderIndex, 1);
    expect(s().outcomes.containsKey(BidPhase.grand), isFalse);
    expect(s().tantto, [0, 0]);
    expect(
      s().bidHistory[BidPhase.grand]!.last.type,
      BidActionType.nereGatikTira,
    );
    expect(
      container.read(musTableFeedbackProvider).speeches[3]!.action,
      BidActionType.nereGatikTira,
    );
    final restored = MusGameState.fromJson(s().toJson());
    expect(restored.bidding!.refusalAction, BidActionType.tira);
    expect(restored.currentPlayer, 1);
    c.act(1, BidActionType.tira);
    expect(s().outcomes[BidPhase.grand]!.kind, OutcomeKind.refused);
    expect(s().tantto, [1, 0]);
    expect(s().bidding!.phase, BidPhase.petit);
    expect(s().bidHistory[BidPhase.grand]!.skip(1).map((a) => a.type), [
      BidActionType.nereGatikTira,
      BidActionType.tira,
    ]);
  });
  test('Le partenaire peut accepter après le premier Tira', () {
    c.act(0, BidActionType.embido, amount: 2);
    c.act(3, BidActionType.tira);
    c.act(1, BidActionType.iduki);
    expect(s().outcomes[BidPhase.grand]!.kind, OutcomeKind.accepted);
    expect(s().outcomes[BidPhase.grand]!.stake, 2);
    expect(s().tantto, [0, 0]);
  });
  test('Une relance remet le choix des deux adversaires à zéro', () {
    c.act(0, BidActionType.embido, amount: 2);
    c.act(3, BidActionType.tira);
    c.act(1, BidActionType.gehiago, amount: 2);
    expect(s().bidding!.canDeferRefusal, isTrue);
    expect(s().currentPlayer, 0);
    c.act(0, BidActionType.tira);
    expect(s().currentPlayer, 2);
    expect(s().outcomes, isEmpty);
    c.act(2, BidActionType.iduki);
    expect(s().outcomes[BidPhase.grand]!.stake, 4);
  });
  test('Hordago : le premier refus laisse aussi la décision au partenaire', () {
    c.act(0, BidActionType.hordago);
    c.act(3, BidActionType.tira);
    expect(s().currentPlayer, 1);
    expect(s().tantto, [0, 0]);
    c.act(1, BidActionType.tira);
    expect(s().outcomes[BidPhase.grand]!.kind, OutcomeKind.refused);
    expect(s().tantto, [1, 0]);
  });
  test(
    'Un unique répondant admissible aux paires peut refuser directement',
    () {
      final hands = table([
        [12, 7, 7, 1],
        [11, 7, 6, 1],
        [10, 6, 4, 2],
        [7, 5, 5, 3],
      ]);
      c.startGame(hands: hands);
      c.chooseMus(0, MusChoice.mintza);
      for (var phase = 0; phase < 2; phase++) {
        for (final seat in [...s().bidding!.participants]) {
          c.act(seat, BidActionType.paso);
        }
      }
      expect(s().bidding!.phase, BidPhase.paires);
      c.act(0, BidActionType.embido, amount: 2);
      expect(s().bidding!.responders, [3]);
      expect(s().bidding!.canDeferRefusal, isFalse);
      c.act(3, BidActionType.tira);
      expect(s().outcomes[BidPhase.paires]!.kind, OutcomeKind.refused);
    },
  );
}
