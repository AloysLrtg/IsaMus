import 'dart:math';

import 'mus_sign.dart';
import 'bot_profile.dart';
import 'bot_hand_strength.dart';
import '../models/card.dart';
import 'mus_evaluator.dart';
import 'mus_game_state.dart';

sealed class MusBotDecision {
  const MusBotDecision();
}

class BotMusDecision extends MusBotDecision {
  const BotMusDecision(this.choice);
  final MusChoice choice;
}

class BotDiscardDecision extends MusBotDecision {
  BotDiscardDecision(List<int> indices) : indices = List.unmodifiable(indices);
  final List<int> indices;
}

class BotBidDecision extends MusBotDecision {
  const BotBidDecision(this.action, {this.amount = 0});
  final BidActionType action;
  final int amount;
}

/// Personalities use only their own hand and truthful partner signals.
class MusBotAI {
  const MusBotAI({this.random, this.bluffProbability = .4})
    : assert(bluffProbability >= 0 && bluffProbability <= 1);
  final Random? random;
  final double bluffProbability;
  static final _fallbackRandom = Random();
  Random get _rng => random ?? _fallbackRandom;

  double strength(List<Card> hand, BidPhase phase) =>
      BotHandStrength.evaluate(hand)[phase]!;

  /// No personality can invent a sign. Controller validates this again at send.
  MusSign? chooseSign(MusGameState state, int seat) {
    final truthful = state.availableSignsForSeat(seat);
    if (truthful.isEmpty) return null;
    final relevant = switch (state.bidding?.phase) {
      BidPhase.grand => MusSign.twoKings,
      BidPhase.petit => MusSign.twoAces,
      BidPhase.paires => MusSign.dobliak,
      BidPhase.jeu => MusSign.thirtyOne,
      BidPhase.point => MusSign.thirty,
      null => null,
    };
    return relevant != null && truthful.contains(relevant)
        ? relevant
        : truthful.first;
  }

  MusBotDecision? decide(
    MusGameState state,
    int seat, {
    BotPersonality? personality,
  }) {
    if (seat < 0 || seat > 3 || state.currentPlayer != seat) return null;
    final hand = state.hands[seat];
    if (hand.length != handSize) return null;
    final character =
        personality ??
        (seat < state.players.length
            ? state.players[seat].botPersonality
            : null) ??
        BotPersonality.balanced;
    final pairs = evaluatePaires(hand);
    final game = evaluateJeuEtPoint(hand);
    switch (state.phase) {
      case MusPhase.musDecision:
        final best = BotHandStrength.evaluate(hand).values.reduce(max);
        final threshold = character == BotPersonality.balanced ? 70 : 75;
        final bluff =
            character == BotPersonality.bluffer &&
            best <= threshold &&
            _rng.nextDouble() < bluffProbability;
        return BotMusDecision(
          best > threshold || bluff ? MusChoice.mintza : MusChoice.mus,
        );
      case MusPhase.discarding:
        // Préserver un Jeu constitué ainsi que les paires, même petites.
        if (game.hasJeu || pairs.type == PairesType.doubles) {
          return BotDiscardDecision([]);
        }
        return BotDiscardDecision([
          for (var i = 0; i < hand.length; i++)
            if (hand[i].value < 10 &&
                hand.where((card) => card.value == hand[i].value).length == 1)
              i,
        ]);
      case MusPhase.bidding:
        final bidding = state.bidding;
        if (bidding == null ||
            !bidding.participants.contains(seat) ||
            bidding.currentPlayer != seat) {
          return null;
        }
        final force = strength(hand, bidding.phase);
        // Conservative always folds a weak hand, independently of bluff RNG,
        // partner gestures or the size of the opposing stake.
        if (character == BotPersonality.conservative) {
          return bidding.stage == BidStage.opening
              ? BotBidDecision(
                  force > 75 ? BidActionType.embido : BidActionType.paso,
                  amount: force > 75 ? 2 : 0,
                )
              : BotBidDecision(
                  force > 75 ? BidActionType.iduki : BidActionType.tira,
                );
        }
        if (character == BotPersonality.bluffer &&
            force < 30 &&
            !bidding.isHordago &&
            _rng.nextDouble() < bluffProbability) {
          if (_rng.nextBool()) {
            return const BotBidDecision(BidActionType.hordago);
          }
          return BotBidDecision(
            bidding.stage == BidStage.opening
                ? BidActionType.embido
                : BidActionType.gehiago,
            amount: 8 + _rng.nextInt(5),
          );
        }
        final partner = state.signs[(seat + 2) % 4];
        final support = switch (bidding.phase) {
          BidPhase.grand => partner == MusSign.twoKings,
          BidPhase.petit => partner == MusSign.twoAces,
          BidPhase.paires =>
            partner == MusSign.dobliak || partner == MusSign.mediak,
          BidPhase.jeu =>
            partner == MusSign.thirtyOne || partner == MusSign.game,
          BidPhase.point =>
            partner == MusSign.thirty || partner == MusSign.twentyNine,
        };
        final confidence = support ? max(force, 80.0) : force;
        if (bidding.stage == BidStage.opening) {
          return confidence >= 60
              ? const BotBidDecision(BidActionType.embido, amount: 2)
              : const BotBidDecision(BidActionType.paso);
        }
        final exceptional = switch (bidding.phase) {
          BidPhase.grand => hand.where((c) => c.value == 12).length >= 3,
          BidPhase.petit => hand.where((c) => c.value == 1).length >= 3,
          BidPhase.paires => pairs.type == PairesType.doubles,
          BidPhase.jeu => game.total == 31 || partner == MusSign.thirtyOne,
          BidPhase.point => game.total == 30,
        };
        final required = bidding.isHordago
            ? 97.0
            : min(90.0, 60 + max(0, bidding.currentBid - 2) * 2.0);
        if (confidence >= required || bidding.isHordago && exceptional) {
          return const BotBidDecision(BidActionType.iduki);
        }
        return BotBidDecision(bidding.refusalAction);
      case MusPhase.dealing:
      case MusPhase.roundScoring:
      case MusPhase.gameOver:
        return null;
    }
  }
}
