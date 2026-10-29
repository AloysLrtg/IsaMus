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
            'Mus ou Mintza ?',
            'Au début de chaque donne, chacun choisit Mus pour demander un échange de cartes. Si les quatre joueurs disent Mus, chacun peut défausser puis recevoir de nouvelles cartes. Mintza coupe le Mus : on garde les mains et on commence les enchères. À vous de cliquer sur Mintza : seul le bouton attendu est actif et son contour brille.',
          );
          if (!mounted) return;
          await _explain(
            'mise',
            'Miser : Paso et Embido',
            'Chaque phase permet de miser des pierres pour son équipe. Paso passe la parole sans ouvrir de mise. Embido propose une mise ; Gehiago permet de relancer. Votre équipe peut bluffer sur ses mises, mais jamais envoyer un faux signe.',
          );
          if (!mounted) return;
          await _explain(
            'reply',
            'Répondre : Tira et Iduki',
            'Face à une mise, Iduki accepte : les cartes départageront les équipes au décompte. Tira refuse : la phase s’arrête et l’adversaire marque le refus selon les mises précédentes. Une relance propose au contraire une mise plus forte.',
          );
          if (!mounted) return;
          await _explain(
            'hordago',
            'Hordago : toute la manche',
            'Le Hordago met la manche entière en jeu. S’il est accepté avec Iduki, les mains sont comparées immédiatement pour cette phase et le gagnant remporte la manche. Tira refuse le défi et laisse seulement les points de refus. Vous allez miser 2 au Grand et aux Paires, puis suivre une relance au Jeu. Les autres choix restent grisés jusqu’à la partie libre.',
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
                'À vous de suivre',
                'L’adversaire relance de 8 : la mise passe de 2 à 10 pierres. Cliquez sur Iduki pour accepter. Les cartes décideront du gagnant au décompte.',
              )
            : s.phase == MusPhase.roundScoring
            ? (
                'Décompte',
                'Les cartes sont révélées. On additionne les mises et les points de Paires et de Jeu. La première équipe à 40 pierres gagne la manche.',
              )
            : switch (s.bidding?.phase) {
                BidPhase.grand => (
                  'Grand — Handia',
                  'On compare les cartes de la plus haute à la plus basse. Le Roi est le plus fort. Cliquez sur Enchérir de 2 : vous proposez deux pierres. Un adversaire acceptera cette première mise.',
                ),
                BidPhase.petit => (
                  'Petit — Ttipia',
                  'On compare cette fois les cartes les plus basses. L’As est le meilleur. En cas d’égalité, on compare les suivantes ; l’Esku départage une égalité parfaite.',
                ),
                BidPhase.paires => (
                  'Paires — Pareak',
                  'Deux cartes identiques font une paire ; trois font Mediak ; deux paires ou quatre cartes identiques font Dobliak. Seuls les joueurs avec des paires participent. Vous avez deux Rois : l’annonce Bai confirme votre paire. Cliquez sur Enchérir de 2 pour la défendre.',
                ),
                BidPhase.jeu => (
                  'Jeu — Joko',
                  'Les figures valent 10 et les autres cartes leur valeur. Il faut au moins 31. Le meilleur Jeu est 31, puis 32. Si personne n’a le Jeu, on joue le Point, au plus près de 30. Ici, proposez 2 : un adversaire relancera, et vous apprendrez à suivre avec Iduki.',
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
                  title: const Text('À vous de jouer !'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Vous avez fait le tour de la table.',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Poursuivez cette partie contre les bots : toutes les actions sont disponibles, sans chronomètre et sans conseils. Vous pouvez aussi revenir au menu.',
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Retourner au menu'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Terminer la partie en cours (Libre)'),
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
              child: const Text('J’ai compris'),
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
