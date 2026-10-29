import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/bot_ai.dart';
import 'package:isamus/core/engine/bot_hand_strength.dart';
import 'package:isamus/core/engine/bot_profile.dart';
import 'package:isamus/core/engine/mus_evaluator.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_sign.dart';
import 'package:isamus/core/models/card.dart';

List<Card> cards(List<int> values) => [
  for (var i = 0; i < values.length; i++) Card(values[i], Suit.values[i]),
];
MusGameState situation(
  List<int> values, {
  BidPhase phase = BidPhase.grand,
  bool response = false,
  bool hordago = false,
}) => MusGameState.initial().copyWith(
  phase: MusPhase.bidding,
  currentPlayer: 1,
  hands: [
    cards([1, 4, 5, 6]),
    cards(values),
    cards([2, 4, 6, 7]),
    cards([3, 5, 6, 7]),
  ],
  bidding: BiddingState(
    phase: phase,
    participants: const [1, 2, 3, 0],
    stage: response ? BidStage.responding : BidStage.opening,
    currentBid: response ? (hordago ? 40 : 2) : 0,
    isHordago: hordago,
    bidderTeam: response ? 0 : null,
    responders: response ? const [1] : const [],
  ),
);

class FixedRandom implements Random {
  FixedRandom(this.roll, {this.hordago = true});
  final double roll;
  final bool hordago;
  @override
  double nextDouble() => roll;
  @override
  bool nextBool() => hordago;
  @override
  int nextInt(int max) => 0;
}

class LyingAI extends MusBotAI {
  @override
  MusSign? chooseSign(MusGameState state, int seat) => MusSign.thirtyOne;
}

class SignSpyController extends MusGameController {
  int attempts = 0;
  @override
  Future<void> sendSignForSeat(int seat, MusSign sign) {
    attempts++;
    return super.sendSignForSeat(seat, sign);
  }
}

void main() {
  test('Le Solo mélange les identités à chaque nouvelle partie, pas entre les donnes', () {
    final c = ProviderContainer(
      overrides: [
        botLineupRandomProvider.overrideWithValue(Random(41)),
        musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        musBidResolutionDelayProvider.overrideWithValue(Duration.zero),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
      ],
    );
    addTearDown(c.dispose);
    final controller = c.read(musGameControllerProvider.notifier);
    final lineups = <String>{};
    for (var i = 0; i < 12; i++) {
      controller.startGame();
      final bots = c.read(musGameControllerProvider).players.skip(1).toList();
      lineups.add(bots.map((p) => p.name).join(','));
      expect(
        bots.map((p) => p.botPersonality).toSet(),
        BotPersonality.values.toSet(),
      );
      for (final bot in bots) {
        final identity = BotProfile.forPersonality(bot.botPersonality!);
        expect(bot.name, identity.name);
        expect(bot.avatarConfig, identity.avatar);
      }
    }
    expect(lineups.length, greaterThan(1));
    final inMatch = c.read(musGameControllerProvider).players;
    controller.chooseMus(0, MusChoice.mintza);
    for (
      var step = 0;
      step < 24 && c.read(musGameControllerProvider).phase == MusPhase.bidding;
      step++
    ) {
      controller.act(
        c.read(musGameControllerProvider).bidding!.currentPlayer,
        BidActionType.paso,
      );
    }
    expect(c.read(musGameControllerProvider).phase, MusPhase.roundScoring);
    controller.nextHand();
    expect(c.read(musGameControllerProvider).players, inMatch);
  });
  test(
    'identités fixes, trois personnalités distinctes et sérialisation stable',
    () {
      final container = ProviderContainer(
        overrides: [
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);
      final c = container.read(musGameControllerProvider.notifier);
      c.startGame();
      final players = container.read(musGameControllerProvider).players;
      expect(players.skip(1).map((p) => p.name).toSet(), {
        'Patxi',
        'Mikel',
        'Txomin',
      });
      expect(
        players.skip(1).map((p) => p.botPersonality).toSet(),
        BotPersonality.values.toSet(),
      );
      expect(players.skip(1).map((p) => p.avatarConfig).toSet(), hasLength(3));
      expect(
        MusGameState.fromJson(
          container.read(musGameControllerProvider).toJson(),
        ).players,
        players,
      );
      c.startGame();
      expect(
        container
            .read(musGameControllerProvider)
            .players
            .skip(1)
            .map((p) => p.name)
            .toSet(),
        {'Patxi', 'Mikel', 'Txomin'},
      );
    },
  );
  test('remplissage mixte attribue les premiers profils disponibles sans changer les humains', () {
    final container = ProviderContainer(
      overrides: [
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
      ],
    );
    addTearDown(container.dispose);
    final c = container.read(musGameControllerProvider.notifier);
    c.configureMultiplayer(
      players: [
        {'seat': 0, 'name': 'Ane', 'is_host': true, 'is_bot': false},
        {'seat': 1, 'name': 'Amaia', 'is_bot': false},
        {'seat': 2, 'is_bot': true},
        {'seat': 3, 'is_bot': true},
      ],
    );
    c.startGame();
    expect(
      container
          .read(musGameControllerProvider)
          .players
          .take(2)
          .map((p) => p.name),
      ['Ane', 'Amaia'],
    );
    expect(
      container
          .read(musGameControllerProvider)
          .players
          .skip(2)
          .map((p) => p.botPersonality)
          .toSet(),
      hasLength(2),
    );
  });
  test(
    'Conservateur : Paso/Tira sur une force <30 même avec partenaire fort',
    () {
      final ai = MusBotAI(random: FixedRandom(0), bluffProbability: 1);
      for (final response in [false, true]) {
        final s = situation([
          4,
          5,
          6,
          7,
        ], response: response).copyWith(signs: {3: MusSign.twoKings});
        expect(ai.strength(s.hands[1], BidPhase.grand), lessThan(30));
        final decision = ai.decide(
          s,
          1,
          personality: BotPersonality.conservative,
        ) as BotBidDecision;
        expect(
          decision.action,
          response ? BidActionType.tira : BidActionType.paso,
        );
      }
      expect(
        (ai.decide(
          situation([4, 5, 6, 7]).copyWith(phase: MusPhase.musDecision),
          1,
          personality: BotPersonality.conservative,
        ) as BotMusDecision).choice,
        MusChoice.mus,
      );
    },
  );
  test('Conservateur : Mintza, mise et Iduki seulement au-dessus de 75', () {
    const ai = MusBotAI();
    final s = situation([12, 12, 12, 12]);
    expect(ai.strength(s.hands[1], BidPhase.grand), 100);
    expect(
      (ai.decide(
        s.copyWith(phase: MusPhase.musDecision),
        1,
        personality: BotPersonality.conservative,
      ) as BotMusDecision).choice,
      MusChoice.mintza,
    );
    expect(
      (ai.decide(
        s,
        1,
        personality: BotPersonality.conservative,
      ) as BotBidDecision).action,
      BidActionType.embido,
    );
    expect(
      (ai.decide(
        situation([12, 12, 12, 12], response: true),
        1,
        personality: BotPersonality.conservative,
      ) as BotBidDecision).action,
      BidActionType.iduki,
    );
  });
  test('Bluffeur : seuil exact 40 %, Hordago ou mise/relance forte sur mauvaise main', () {
    for (final response in [false, true]) {
      for (final hordago in [true, false]) {
        final ai = MusBotAI(random: FixedRandom(.399, hordago: hordago));
        final d = ai.decide(
          situation([4, 5, 6, 7], response: response),
          1,
          personality: BotPersonality.bluffer,
        ) as BotBidDecision;
        expect(
          d.action,
          hordago
              ? BidActionType.hordago
              : response
              ? BidActionType.gehiago
              : BidActionType.embido,
        );
        if (!hordago) expect(d.amount, greaterThanOrEqualTo(8));
      }
    }
    final boundary = MusBotAI(random: FixedRandom(.4));
    expect(
      (boundary.decide(
        situation([4, 5, 6, 7]),
        1,
        personality: BotPersonality.bluffer,
      ) as BotBidDecision).action,
      BidActionType.paso,
    );
    final ai = MusBotAI(random: FixedRandom(0));
    expect(
      (ai.decide(
        situation([4, 5, 6, 7], response: true, hordago: true),
        1,
        personality: BotPersonality.bluffer,
      ) as BotBidDecision).action,
      BidActionType.tira,
    );
  });
  test('aucune personnalité ne consulte les mains adverses ou le talon', () {
    for (final personality in BotPersonality.values) {
      final ai = MusBotAI(random: FixedRandom(0));
      final s = situation([4, 5, 6, 7]);
      final changed = s.copyWith(
        hands: [
          cards([12, 12, 12, 12]),
          s.hands[1],
          cards([1, 1, 1, 1]),
          cards([10, 10, 10, 10]),
        ],
        talon: cards([12, 11, 10, 1]),
      );
      final a = ai.decide(s, 1, personality: personality) as BotBidDecision;
      final b =
          ai.decide(changed, 1, personality: personality) as BotBidDecision;
      expect((a.action, a.amount), (b.action, b.amount));
    }
  });
  test('signes des trois profils toujours vrais, 2/3 ne sont pas As/Rois', () {
    const ai = MusBotAI();
    for (final values in [
      [12, 12, 1, 1],
      [12, 12, 12, 1],
      [3, 3, 2, 2],
      [12, 11, 7, 2],
      [4, 5, 6, 7],
    ]) {
      for (final phase in BidPhase.values) {
        final s = situation(values, phase: phase);
        final sign = ai.chooseSign(s, 1);
        if (sign != null) expect(s.availableSignsForSeat(1), contains(sign));
        if (values.first == 4) expect(sign, isNull);
        if (values.first == 3) {
          expect(sign, isNot(anyOf(MusSign.twoAces, MusSign.twoKings)));
        }
        if (phase == BidPhase.paires) expect(sign, isNot(MusSign.twentyNine));
      }
    }
  });
  testWidgets(
    'le contrôleur refuse même un faux signe proposé par une IA injectée',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          musGameControllerProvider.overrideWith(SignSpyController.new),
          musBotAIProvider.overrideWithValue(LyingAI()),
          musTurnTimeoutProvider.overrideWithValue(null),
        ],
      );
      final c = container.read(
        musGameControllerProvider.notifier,
      ) as SignSpyController;
      c.startGame(
        hands: [
          for (var seat = 0; seat < 4; seat++) cards([4, 5, 6, 7]),
        ],
      );
      expect(c.attempts, 0);
      expect(container.read(musGameControllerProvider).signs, isEmpty);
      expect(() => c.sendSignForSeat(3, MusSign.thirtyOne), throwsStateError);
      container.dispose();
      await tester.pump();
    },
  );
  for (final values in [
    [12, 12, 7, 4],
    [7, 7, 6, 5],
  ]) {
    test('forces exactes comparées aux 58 905 mains adverses pour $values', () {
      final own = cards(values);
      final unseen = Card.fullDeck().where((c) => !own.contains(c)).toList();
      final total = {for (final p in BidPhase.values) p: 0};
      final wins = {for (final p in BidPhase.values) p: 0.0};
      for (var a = 0; a < 33; a++) {
        for (var b = a + 1; b < 34; b++) {
          for (var c = b + 1; c < 35; c++) {
            for (var d = c + 1; d < 36; d++) {
              final other = [unseen[a], unseen[b], unseen[c], unseen[d]];
              for (final p in BidPhase.values) {
                if (p == BidPhase.paires && !evaluatePaires(other).hasPaires ||
                    p == BidPhase.jeu && !evaluateJeuEtPoint(other).hasJeu ||
                    p == BidPhase.point && evaluateJeuEtPoint(other).hasJeu) {
                  continue;
                }
                total[p] = total[p]! + 1;
                if (p == BidPhase.paires && !evaluatePaires(own).hasPaires ||
                    p == BidPhase.jeu && !evaluateJeuEtPoint(own).hasJeu ||
                    p == BidPhase.point && evaluateJeuEtPoint(own).hasJeu) {
                  continue;
                }
                final compare = switch (p) {
                  BidPhase.grand => rawCompareGrand(own, other),
                  BidPhase.petit => rawComparePetit(own, other),
                  BidPhase.paires => rawComparePaires(own, other),
                  BidPhase.jeu => rawCompareJeuEtPoint(
                    own,
                    other,
                    JeuPointMode.jeu,
                  ),
                  BidPhase.point => rawCompareJeuEtPoint(
                    own,
                    other,
                    JeuPointMode.point,
                  ),
                };
                wins[p] =
                    wins[p]! +
                    (compare > 0
                        ? 1.0
                        : compare == 0
                        ? 0.5
                        : 0.0);
              }
            }
          }
        }
      }
      final calculated = BotHandStrength.evaluate(own);
      for (final p in BidPhase.values) {
        expect(calculated[p], closeTo(100 * wins[p]! / total[p]!, 1e-9));
        expect(calculated[p], inInclusiveRange(0, 100));
      }
      expect(total[BidPhase.grand], 58905);
    });
  }
}
