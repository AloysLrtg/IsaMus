import '../../l10n/app_localizations.dart';

import '../../core/engine/mus_game_controller.dart';
import '../../core/engine/mus_game_state.dart';
import '../../core/models/card.dart';

enum TutorialAction { mintza, betTwo, paso, iduki }

class TutorialGameController extends MusGameController {
  bool guided = true;
  bool _botStepPending = false;

  /// Keep the last speech visible before advancing a guided interaction.
  Future<void> pauseForReading() =>
      Future<void>.delayed(const Duration(seconds: 2));

  String explanation(AppLocalizations l10n) => switch (expectedAction) {
    TutorialAction.mintza => l10n.menuYouHaveTwoKingsAndAGameTotalOf,
    TutorialAction.iduki =>
      l10n.menuYourOpponentRaisesCallIdukiToCompareCardsAt,
    TutorialAction.betTwo when state.bidding?.phase == BidPhase.paires =>
      l10n.menuYouHaveTwoKingsBaiAnnouncesYourPairBet,
    TutorialAction.betTwo when state.bidding?.phase == BidPhase.jeu =>
      l10n.menuYouHave31TheBestGameTotalBet2,
    TutorialAction.betTwo => l10n.menuThisIsHighHandiaYouHaveStrongCardsBet,
    TutorialAction.paso => l10n.menuAtLowYourAceIsFollowedByThreeFace,
    null => l10n.menuWatchTheOtherPlayersAnnouncementsAndResponses,
  };
  @override
  bool get autoAdvanceRounds => !guided;
  @override
  bool get botsEnabled => !guided;

  void continueFreely() {
    if (!guided || state.phase != MusPhase.roundScoring) return;
    guided = false;
    nextHand();
  }

  void startTutorial() {
    guided = true;
    startGame(
      hands: [
        [
          Card(12, Suit.oros),
          Card(12, Suit.copas),
          Card(11, Suit.oros),
          Card(1, Suit.oros),
        ],
        [
          Card(12, Suit.espadas),
          Card(12, Suit.bastos),
          Card(10, Suit.oros),
          Card(1, Suit.copas),
        ],
        [
          Card(11, Suit.copas),
          Card(11, Suit.espadas),
          Card(10, Suit.copas),
          Card(1, Suit.espadas),
        ],
        [
          Card(10, Suit.espadas),
          Card(10, Suit.bastos),
          Card(11, Suit.bastos),
          Card(1, Suit.bastos),
        ],
      ],
    );
  }

  int get currentStake => state.bidding?.currentBid ?? 0;

  TutorialAction? get expectedAction {
    if (!guided || state.currentPlayer != 0) return null;
    if (state.phase == MusPhase.musDecision) return TutorialAction.mintza;
    if (state.phase != MusPhase.bidding || state.bidding == null) return null;
    final bid = state.bidding!;
    if (bid.stage == BidStage.responding) return TutorialAction.iduki;
    return switch (bid.phase) {
      BidPhase.grand ||
      BidPhase.paires ||
      BidPhase.jeu => TutorialAction.betTwo,
      _ => TutorialAction.paso,
    };
  }

  @override
  void chooseMus(int seat, MusChoice choice) {
    if (guided &&
        (seat != 0 ||
            expectedAction != TutorialAction.mintza ||
            choice != MusChoice.mintza)) {
      throw StateError('Expected tutorial action: Mintza');
    }
    super.chooseMus(seat, choice);
  }

  @override
  void discard(int seat, List<int> cardIndices) {
    if (guided) {
      throw StateError('Discarding is disabled in the guided tutorial');
    }
    super.discard(seat, cardIndices);
  }

  @override
  void act(int seat, BidActionType type, {int amount = 0}) {
    if (guided) {
      final allowed =
          seat == 0 &&
          switch (expectedAction) {
            TutorialAction.betTwo =>
              type == BidActionType.embido && amount == 2,
            TutorialAction.paso => type == BidActionType.paso,
            TutorialAction.iduki => type == BidActionType.iduki,
            _ => false,
          };
      if (!allowed) {
        throw StateError('Unexpected guided tutorial action');
      }
    }
    super.act(seat, type, amount: amount);
  }

  Future<void> playBotStep() async {
    final turn = state;
    final seat = turn.currentPlayer;
    if (_botStepPending ||
        !guided ||
        turn.phase != MusPhase.bidding ||
        seat <= 0) {
      return;
    }
    _botStepPending = true;
    try {
      await pauseForReading();
      // A pending lesson must never act on a new turn or a disposed provider.
      if (!ref.mounted || !guided || !identical(state, turn)) return;
      final bid = state.bidding!;
      if (bid.stage == BidStage.responding) {
        if (bid.phase == BidPhase.jeu && bid.bidderTeam == 0) {
          // A real raise in the game engine: 2 + 8 = 10, then seat 0 must call.
          super.act(seat, BidActionType.gehiago, amount: 8);
        } else {
          super.act(seat, BidActionType.iduki);
        }
      } else {
        super.act(seat, BidActionType.paso);
      }
    } finally {
      _botStepPending = false;
    }
  }
}
