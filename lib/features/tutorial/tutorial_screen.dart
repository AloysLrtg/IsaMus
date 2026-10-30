import '../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/mus_game_controller.dart';
import '../../core/engine/mus_game_state.dart';
import '../../core/engine/mus_table_feedback.dart';
import '../game/game_screen.dart';
import '../home/main_dashboard_screen.dart';
import 'tutorial_game_controller.dart';
import 'tutorial_actions_view.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});
  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      musGameControllerProvider.overrideWith(TutorialGameController.new),
      musTableFeedbackProvider.overrideWith(MusTableFeedback.new),
      musTurnTimeoutProvider.overrideWithValue(null),
      musBotsEnabledProvider.overrideWithValue(false),
      musEmptyPhaseDelayProvider.overrideWithValue(const Duration(seconds: 2)),
      musBidResolutionDelayProvider.overrideWithValue(
        const Duration(seconds: 2),
      ),
    ],
    child: const _TutorialTable(),
  );
}

class _TutorialTable extends ConsumerStatefulWidget {
  const _TutorialTable();
  @override
  ConsumerState<_TutorialTable> createState() => _TutorialTableState();
}

class _TutorialTableState extends ConsumerState<_TutorialTable> {
  bool _scheduled = false;
  bool _explaining = false;
  final _seen = <String>{};
  TutorialGameController get controller =>
      ref.read(musGameControllerProvider.notifier) as TutorialGameController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.startTutorial();
        _schedule();
      }
    });
  }

  void _schedule() {
    if (_scheduled || _explaining) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final turn = ref.read(musGameControllerProvider);
      setState(() {});
      try {
        if (_explaining || !controller.guided) return;
        if (_seen.contains('intro') && turn.currentPlayer <= 0) {
          await controller.pauseForReading();
          if (!mounted ||
              !controller.guided ||
              !identical(turn, ref.read(musGameControllerProvider))) {
            return;
          }
        }
        if (_seen.add('intro')) {
          await _explain(
            'mus',
            AppLocalizations.of(context)!.menuMusOrMintza,
            AppLocalizations.of(context)!
                .menuAtTheStartOfEachHandEachPlayerChooses,
          );
          if (!mounted) return;
          await _explain(
            'mise',
            AppLocalizations.of(context)!.menuBettingPasoAndEmbido,
            AppLocalizations.of(context)!.menuInEachPhaseYouCanBetStonesForYour,
          );
          if (!mounted) return;
          await _explain(
            'reply',
            AppLocalizations.of(context)!.menuRespondingTiraAndIduki,
            AppLocalizations.of(context)!
                .menuWhenFacingABetIdukiAcceptsTheCardsWill,
          );
          if (!mounted) return;
          await _explain(
            'hordago',
            AppLocalizations.of(context)!.menuHordagoTheWholeRound,
            AppLocalizations.of(context)!
                .menuHordagoPutsTheEntireRoundAtStakeIfAccepted,
          );
          if (!mounted) return;
        }
        final s = ref.read(musGameControllerProvider);
        final key = s.phase == MusPhase.bidding
            ? s.bidding?.phase == BidPhase.jeu &&
                      s.bidding?.stage == BidStage.responding &&
                      s.currentPlayer == 0
                  ? 'jeu-call'
                  : s.bidding?.phase.name
            : s.phase.name;
        final lesson = key == 'jeu-call'
            ? (
                AppLocalizations.of(context)!.menuYourTurnToCall,
                AppLocalizations.of(context)!
                    .menuYourOpponentRaisesBy8TheBetGoesFrom,
              )
            : s.phase == MusPhase.roundScoring
            ? (
                AppLocalizations.of(context)!.roundScoring,
                AppLocalizations.of(context)!
                    .menuTheCardsAreRevealedBetsAndPointsForPairs,
              )
            : switch (s.bidding?.phase) {
                BidPhase.grand => (
                  AppLocalizations.of(context)!.menuHighHandia,
                  AppLocalizations.of(context)!
                      .menuCompareCardsFromHighestToLowestTheKingIs,
                ),
                BidPhase.petit => (
                  AppLocalizations.of(context)!.menuLowTtipia,
                  AppLocalizations.of(context)!
                      .menuNowCompareTheLowestCardsTheAceIsBest,
                ),
                BidPhase.paires => (
                  AppLocalizations.of(context)!.menuPairsPareak,
                  AppLocalizations.of(context)!
                      .menuTwoMatchingCardsMakeAPairThreeMakeMediak,
                ),
                BidPhase.jeu => (
                  AppLocalizations.of(context)!.menuGameJoko,
                  AppLocalizations.of(context)!
                      .menuFaceCardsAreWorth10AndOtherCardsTheir,
                ),
                _ => null,
              };
        if (lesson != null && _seen.add(key!)) {
          await _explain(key, lesson.$1, lesson.$2);
          if (!mounted) return;
        }
        if (s.phase == MusPhase.roundScoring && _seen.add('complete')) {
          _explaining = true;
          final freePlay = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              final theme = Theme.of(ctx);
              return PopScope(
                canPop: false,
                child: AlertDialog(
                  key: const ValueKey('tutorial-complete'),
                  icon: Icon(
                    Icons.emoji_events_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(AppLocalizations.of(context)!.menuYourTurnToPlay),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .menuYouHaveLearnedYourWayAroundTheTable,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.menuKeepPlayingAgainstTheBotsAllActionsAreAvailable,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        AppLocalizations.of(context)!.menuReturnToMenu,
                      ),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        AppLocalizations.of(context)!
                            .menuFinishThisGameFreePlay,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
          _explaining = false;
          if (!mounted) return;
          if (freePlay == true) {
            controller.continueFreely();
          } else {
            // Popping the scoped tutorial disposes its controller and timers.
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => const MainDashboardScreen(),
                ),
                (_) => false,
              );
            }
          }
          return;
        }
        await controller.playBotStep();
      } finally {
        _scheduled = false;
        if (mounted) {
          setState(() {});
          if (!identical(turn, ref.read(musGameControllerProvider))) {
            _schedule();
          }
        }
      }
    });
  }

  Future<void> _explain(String key, String title, String text) async {
    _explaining = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          key: ValueKey('tutorial-lesson-$key'),
          icon: Icon(
            Icons.school_rounded,
            color: Theme.of(ctx).colorScheme.primary,
          ),
          title: Text(title),
          content: SingleChildScrollView(child: Text(text)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.menuGotIt),
            ),
          ],
        ),
      ),
    );
    _explaining = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(musGameControllerProvider, (_, next) {
      if (next.phase == MusPhase.dealing) _seen.clear();
      _schedule();
    });
    return TutorialInteractionGate(
      enabled: !_scheduled && !_explaining,
      child: const GameScreen(mode: 'tutorial'),
    );
  }
}
