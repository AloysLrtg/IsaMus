import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/bot_ai.dart';
import 'package:isamus/core/engine/bot_profile.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_sign.dart';
import 'package:isamus/core/models/card.dart';

List<Card> hand(List<int> values) => [
  for (var i = 0; i < values.length; i++) Card(values[i], Suit.values[i]),
];

MusGameState situation(
  List<int> values, {
  MusPhase phase = MusPhase.musDecision,
  BiddingState? bidding,
}) => MusGameState.initial().copyWith(
  phase: phase,
  currentPlayer: 1,
  players: [
    for (final p in MusGameState.defaultPlayers())
      p.isBot
          ? p.withBotProfile(BotProfile.forPersonality(BotPersonality.balanced))
          : p,
  ],
  hands: [
    hand([1, 4, 5, 6]),
    hand(values),
    hand([2, 4, 6, 7]),
    hand([3, 5, 6, 7]),
  ],
  bidding: bidding,
);

void main() {
  const ai = MusBotAI();
  test(
    'Mus sur une main faible, Mintza lorsque les probabilités sont favorables',
    () {
      expect(
        (ai.decide(situation([2, 4, 6, 7]), 1) as BotMusDecision).choice,
        MusChoice.mus,
      );
      for (final cards in [
        [12, 12, 4, 6],
        [12, 11, 10, 1],
        [4, 4, 6, 6],
        [1, 1, 4, 7],
      ]) {
        expect(
          (ai.decide(situation(cards), 1) as BotMusDecision).choice,
          MusChoice.mintza,
        );
      }
    },
  );

  test(
    'Défausse : jeter les petites cartes isolées, préserver paires et Jeu',
    () {
      BotDiscardDecision discard(List<int> cards) =>
          ai.decide(situation(cards, phase: MusPhase.discarding), 1)
              as BotDiscardDecision;
      expect(discard([1, 2, 3, 12]).indices, [0, 1, 2]);
      expect(discard([1, 1, 3, 12]).indices, [2]);
      expect(discard([12, 11, 10, 1]).indices, isEmpty);
      expect(discard([3, 3, 4, 4]).indices, isEmpty);
    },
  );

  test('Force adaptée à chaque enchère, Embido toujours à 2', () {
    for (final entry in {
      BidPhase.grand: [12, 12, 2, 4],
      BidPhase.petit: [1, 1, 5, 7],
      BidPhase.paires: [7, 7, 3, 3],
      BidPhase.jeu: [12, 11, 10, 1],
      BidPhase.point: [10, 7, 6, 4],
    }.entries) {
      final b = BiddingState(phase: entry.key, participants: [1, 2, 3, 0]);
      final decision = ai.decide(
        situation(entry.value, phase: MusPhase.bidding, bidding: b),
        1,
      ) as BotBidDecision;
      expect(decision.action, BidActionType.embido);
      expect(decision.amount, 2);
    }
    const petit = BiddingState(
      phase: BidPhase.petit,
      participants: [1, 2, 3, 0],
    );
    expect(
      (ai.decide(
        situation([12, 11, 10, 7], phase: MusPhase.bidding, bidding: petit),
        1,
      ) as BotBidDecision).action,
      BidActionType.paso,
    );
  });

  test(
    'Réponses légales : Iduki, Nere gatik tira puis Tira, même au Hordago',
    () {
      for (final hordago in [false, true]) {
        final bidding = BiddingState(
          phase: BidPhase.grand,
          participants: [0, 1, 2, 3],
          stage: BidStage.responding,
          currentBid: hordago ? 40 : 2,
          isHordago: hordago,
          bidderTeam: 0,
          responders: [1, 3],
        );
        BotBidDecision respond(List<int> cards, BiddingState b) =>
            ai.decide(situation(cards, phase: MusPhase.bidding, bidding: b), 1)
                as BotBidDecision;
        expect(respond([12, 12, 12, 4], bidding).action, BidActionType.iduki);
        expect(
          respond([2, 4, 6, 7], bidding).action,
          BidActionType.nereGatikTira,
        );
        expect(
          respond([2, 4, 6, 7], bidding.copyWith(partnerDecides: true)).action,
          BidActionType.tira,
        );
        expect(
          respond([2, 4, 6, 7], bidding.copyWith(responders: [1])).action,
          BidActionType.tira,
        );
      }
    },
  );

  test('Aucune action hors tour, hors participation ou après décompte', () {
    expect(ai.decide(situation([12, 12, 5, 6]), 2), isNull);
    expect(
      ai.decide(situation([12, 12, 5, 6], phase: MusPhase.roundScoring), 1),
      isNull,
    );
    expect(
      ai.decide(
        situation(
          [12, 12, 5, 6],
          phase: MusPhase.bidding,
          bidding: const BiddingState(
            phase: BidPhase.paires,
            participants: [0, 2],
          ),
        ),
        1,
      ),
      isNull,
    );
  });

  test('Changer les mains adverses ou le talon ne change pas la décision', () {
    final s = situation([2, 4, 6, 7]);
    final changed = s.copyWith(
      hands: [
        hand([12, 12, 12, 12]),
        s.hands[1],
        hand([1, 1, 1, 1]),
        hand([10, 10, 10, 10]),
      ],
      talon: hand([12, 11, 10, 1]),
    );
    expect(
      (ai.decide(s, 1) as BotMusDecision).choice,
      (ai.decide(changed, 1) as BotMusDecision).choice,
    );
  });

  test('Les sept signes sont sincères et 31 exclut le signe Jeu', () {
    expect(availableMusSigns(hand([12, 12, 1, 1])), [
      MusSign.twoKings,
      MusSign.twoAces,
      MusSign.dobliak,
    ]);
    expect(availableMusSigns(hand([12, 12, 12, 1])), [
      MusSign.twoKings,
      MusSign.mediak,
      MusSign.thirtyOne,
    ]);
    expect(availableMusSigns(hand([12, 11, 10, 2])), [MusSign.game]);
    expect(availableMusSigns(hand([3, 3, 2, 2])), [MusSign.dobliak]);
    expect(availableMusSigns(hand([12, 12, 12, 12])), [
      MusSign.twoKings,
      MusSign.dobliak,
      MusSign.game,
    ]);
    expect(availableMusSigns(hand([2, 4, 6, 7])), isEmpty);
    expect(availableMusSigns([]), isEmpty);
  });
}
