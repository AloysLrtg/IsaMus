import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_sign.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/network/supabase_repository.dart';

class _FakeRepo implements SupabaseRepository {
  final List<Map<String, dynamic>> pushedStates = [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  Future<void> updateGameState(
    String gameId,
    Map<String, dynamic> gameState,
  ) async {
    pushedStates.add(gameState);
  }
}

void main() {
  void scenario(
    String name,
    Future<void> Function(WidgetTester, ProviderContainer, MusGameController)
    run,
  ) {
    testWidgets(name, (tester) async {
      final container = ProviderContainer(
        overrides: [
          musBotsEnabledProvider.overrideWithValue(false),
          musRandomProvider.overrideWithValue(Random(42)),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      try {
        await run(
          tester,
          container,
          container.read(musGameControllerProvider.notifier),
        );
      } finally {
        container.dispose();
        await tester.pump();
      }
    });
  }

  scenario('À exactement 10 s : Mus automatique et délai suivant neuf', (
    t,
    p,
    c,
  ) async {
    c.startGame();
    await t.pump(const Duration(milliseconds: 9999));
    expect(p.read(musGameControllerProvider).musVotes, isEmpty);
    await t.pump(const Duration(milliseconds: 1));
    expect(p.read(musGameControllerProvider).musVotes, [MusChoice.mus]);
    expect(p.read(musGameControllerProvider).currentPlayer, 2);
    expect(p.read(musTableFeedbackProvider).clock!.seat, 2);
    await t.pump(const Duration(milliseconds: 9999));
    expect(p.read(musGameControllerProvider).currentPlayer, 2);
  });

  scenario('Timeout sans mise : Paso ; deux refus successifs face à Embido', (
    t,
    p,
    c,
  ) async {
    c.startGame();
    c.chooseMus(0, MusChoice.mintza);
    await t.pump(const Duration(seconds: 10));
    expect(
      p.read(musGameControllerProvider).bidHistory[BidPhase.grand]!.single.type,
      BidActionType.paso,
    );
    c.act(3, BidActionType.embido, amount: 2);
    await t.pump(const Duration(seconds: 10));
    expect(
      p.read(musGameControllerProvider).bidHistory[BidPhase.grand]!.last.type,
      BidActionType.nereGatikTira,
    );
    expect(p.read(musGameControllerProvider).currentPlayer, 2);
    expect(p.read(musGameControllerProvider).tantto, [0, 0]);
    await t.pump(const Duration(seconds: 10));
    expect(
      p.read(musGameControllerProvider).outcomes[BidPhase.grand]!.kind,
      OutcomeKind.refused,
    );
    expect(p.read(musGameControllerProvider).tantto[1], 1);
  });
  scenario(
    'Timeout sur Hordago : chaque partenaire refuse, jamais acceptation',
    (t, p, c) async {
      c.startGame();
      c.chooseMus(0, MusChoice.mintza);
      c.act(0, BidActionType.hordago);
      await t.pump(const Duration(seconds: 10));
      expect(p.read(musGameControllerProvider).currentPlayer, 1);
      expect(p.read(musGameControllerProvider).outcomes, isEmpty);
      await t.pump(const Duration(seconds: 10));
      final s = p.read(musGameControllerProvider);
      expect(s.outcomes[BidPhase.grand]!.kind, OutcomeKind.refused);
      expect(s.tantto[0], 1);
      expect(s.manches, [0, 0]);
    },
  );

  scenario('Timeout défausse : garder les quatre cartes', (t, p, c) async {
    c.startGame();
    for (final seat in [0, 2, 3, 1]) {
      c.chooseMus(seat, MusChoice.mus);
    }
    await t.pump(const Duration(seconds: 10));
    expect(p.read(musGameControllerProvider).discardSelections[0], isEmpty);
    expect(p.read(musGameControllerProvider).currentPlayer, 3);
  });

  scenario('Action juste avant expiration : aucune double action', (
    t,
    p,
    c,
  ) async {
    c.startGame();
    await t.pump(const Duration(milliseconds: 9999));
    c.chooseMus(0, MusChoice.mintza);
    await t.pump(const Duration(milliseconds: 1));
    expect(p.read(musGameControllerProvider).currentPlayer, 0);
    expect(
      p.read(musGameControllerProvider).bidHistory[BidPhase.grand],
      isEmpty,
    );
    await t.pump(const Duration(milliseconds: 9999));
    expect(p.read(musGameControllerProvider).currentPlayer, 3);
  });

  scenario(
    'Chat, signes et expiration des bulles ne réinitialisent pas le délai',
    (t, p, c) async {
      c.startGame();
      final clock = p.read(musTableFeedbackProvider).clock;
      await t.pump(const Duration(seconds: 2));
      c.sendQuickChat(0, QuickChat.goodLuck);
      final allowed = availableMusSigns(
        p.read(musGameControllerProvider).hands[0],
      );
      if (allowed.isNotEmpty) c.sendSignForSeat(0, allowed.first);
      expect(identical(p.read(musTableFeedbackProvider).clock, clock), isTrue);
      await t.pump(const Duration(milliseconds: 7999));
      expect(p.read(musGameControllerProvider).currentPlayer, 0);
      await t.pump(const Duration(milliseconds: 1));
      expect(p.read(musGameControllerProvider).currentPlayer, 2);
    },
  );

  scenario('Bulles indépendantes, remplacement et expiration à 2,5 s', (
    t,
    p,
    c,
  ) async {
    c.sendQuickChat(0, QuickChat.aupa);
    c.sendQuickChat(1, QuickChat.goodLuck);
    await t.pump(const Duration(seconds: 1));
    c.sendQuickChat(0, QuickChat.nothing);
    await t.pump(const Duration(milliseconds: 1500));
    expect(p.read(musTableFeedbackProvider).speeches.containsKey(1), isFalse);
    expect(
      p.read(musTableFeedbackProvider).speeches[0]!.chat,
      QuickChat.nothing,
    );
    await t.pump(const Duration(milliseconds: 999));
    expect(p.read(musTableFeedbackProvider).speeches.containsKey(0), isTrue);
    await t.pump(const Duration(milliseconds: 1));
    expect(p.read(musTableFeedbackProvider).speeches, isEmpty);
  });

  scenario('Nouvelle partie : ancien délai et anciennes bulles annulés', (
    t,
    p,
    c,
  ) async {
    c.startGame();
    c.sendQuickChat(0, QuickChat.aupa);
    await t.pump(const Duration(seconds: 4));
    c.startGame();
    expect(p.read(musTableFeedbackProvider).speeches, isEmpty);
    await t.pump(const Duration(seconds: 1));
    expect(p.read(musGameControllerProvider).musVotes, isEmpty);
  });

  scenario(
    'Pas de tour clock au décompte, transition automatique après 8 s si score < 40',
    (t, p, c) async {
      c.startGame();
      c.chooseMus(0, MusChoice.mintza);
      // ignore: invalid_use_of_protected_member
      c.state = p
          .read(musGameControllerProvider)
          .copyWith(phase: MusPhase.roundScoring, tantto: [2, 1]);
      expect(p.read(musGameControllerProvider).phase, MusPhase.roundScoring);
      expect(p.read(musTableFeedbackProvider).clock, isNull);
      final state = p.read(musGameControllerProvider);
      await t.pump(const Duration(seconds: 7));
      expect(identical(p.read(musGameControllerProvider), state), isTrue);
      expect(p.read(musTableFeedbackProvider).clock, isNull);
      await t.pump(const Duration(seconds: 1));
      expect(p.read(musGameControllerProvider).phase, MusPhase.musDecision);
      expect(p.read(musGameControllerProvider).eskuIndex, 3);
      expect(p.read(musTableFeedbackProvider).clock!.seat, 3);
    },
  );

  scenario(
    'Fin de partie (score >= 40 tantto) : récapitulatif pendant 8s puis transition en gameOver',
    (t, p, c) async {
      c.startGame();
      c.chooseMus(0, MusChoice.mintza);
      c.act(0, BidActionType.hordago);
      c.act(3, BidActionType.iduki);
      // Score de 40 tantto atteint (fin de partie)
      expect(p.read(musGameControllerProvider).phase, MusPhase.roundScoring);
      expect(
        p.read(musGameControllerProvider).teamAScore >= 40 ||
            p.read(musGameControllerProvider).teamBScore >= 40,
        isTrue,
      );

      // Pendant les 8 secondes, le jeu reste sur roundScoring pour permettre de voir les scores et cartes
      await t.pump(const Duration(seconds: 4));
      expect(p.read(musGameControllerProvider).phase, MusPhase.roundScoring);

      // À l'expiration des 8s, bascule sur gameOver (sans relancer de nouvelle donne)
      await t.pump(const Duration(seconds: 4));
      expect(p.read(musGameControllerProvider).phase, MusPhase.gameOver);
      expect(p.read(musGameControllerProvider).eskuIndex, 0);

      // Un appel manuel à nextHand() ne fait rien
      c.nextHand();
      expect(p.read(musGameControllerProvider).phase, MusPhase.gameOver);
    },
  );

  testWidgets('Bot lent : timeout avant sa décision, sans action résiduelle', (
    t,
  ) async {
    final p = ProviderContainer(
      overrides: [
        musBotDelayProvider.overrideWithValue(const Duration(seconds: 12)),
      ],
    );
    try {
      final c = p.read(musGameControllerProvider.notifier);
      c.startGame(eskuIndex: 1);
      await t.pump(const Duration(seconds: 10));
      expect(p.read(musGameControllerProvider).musVotes, [MusChoice.mus]);
      expect(p.read(musGameControllerProvider).currentPlayer, 3);
      await t.pump(const Duration(seconds: 2));
      expect(p.read(musGameControllerProvider).currentPlayer, 3);
    } finally {
      p.dispose();
      await t.pump();
    }
  });

  testWidgets(
    'Multijoueur : Le client local s\'auto-applique Paso à 10s et pousse sur Supabase',
    (tester) async {
      final fakeRepo = _FakeRepo();
      final p = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(const Duration(seconds: 10)),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      try {
        final c = p.read(musGameControllerProvider.notifier);
        c.configureMultiplayer(
          gameId: 'game-timeout-local',
          localSeat: 1, // Client invité
          repository: fakeRepo,
          players: [
            {'seat': 0, 'name': 'Hôte', 'is_host': true, 'is_bot': false},
            {'seat': 1, 'name': 'Guest1', 'is_host': false, 'is_bot': false},
            {'seat': 2, 'name': 'Partner', 'is_host': false, 'is_bot': false},
            {'seat': 3, 'name': 'Guest3', 'is_host': false, 'is_bot': false},
          ],
        );

        // L'hôte distribue et commence en enchère Grand, c'est au tour du siège 1
        final stateInBidding = MusGameState.initial().copyWith(
          version: 5,
          phase: MusPhase.bidding,
          currentPlayer: 1,
          bidding: const BiddingState(
            phase: BidPhase.grand,
            participants: [1, 2, 3, 0],
            stage: BidStage.opening,
          ),
        );
        c.syncFromRemote(stateInBidding);

        expect(p.read(musGameControllerProvider).currentPlayer, 1);
        expect(p.read(musTableFeedbackProvider).clock!.seat, 1);

        // À 9999ms, aucune action auto-appliquée
        await tester.pump(const Duration(milliseconds: 9999));
        expect(p.read(musGameControllerProvider).currentPlayer, 1);
        expect(fakeRepo.pushedStates, isEmpty);

        // À 10s (9999ms + 1ms), le client local s'auto-applique Paso et pousse vers Supabase
        await tester.pump(const Duration(milliseconds: 1));
        expect(p.read(musGameControllerProvider).currentPlayer, 2);
        expect(p.read(musTableFeedbackProvider).clock!.seat, 2);
        expect(fakeRepo.pushedStates.isNotEmpty, isTrue);
        expect(fakeRepo.pushedStates.last['lastActionSeat'], 1);
        expect(
          fakeRepo.pushedStates.last['bidHistory']['grand'].last['type'],
          'paso',
        );
      } finally {
        p.dispose();
        await tester.pump();
      }
    },
  );

  testWidgets(
    'Multijoueur : Le client local s\'auto-applique Tira à 10s face à Embido et pousse sur Supabase',
    (tester) async {
      final fakeRepo = _FakeRepo();
      final p = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(const Duration(seconds: 10)),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      try {
        final c = p.read(musGameControllerProvider.notifier);
        c.configureMultiplayer(
          gameId: 'game-timeout-tira',
          localSeat: 2, // Client invité
          repository: fakeRepo,
          players: [
            {'seat': 0, 'name': 'Hôte', 'is_host': true, 'is_bot': false},
            {'seat': 1, 'name': 'Guest1', 'is_host': false, 'is_bot': false},
            {'seat': 2, 'name': 'Guest2', 'is_host': false, 'is_bot': false},
            {'seat': 3, 'name': 'Guest3', 'is_host': false, 'is_bot': false},
          ],
        );

        // Équipe B a misé Embido, c'est au joueur 2 de répondre
        final stateResponding = MusGameState.initial().copyWith(
          version: 7,
          phase: MusPhase.bidding,
          currentPlayer: 2,
          bidding: const BiddingState(
            phase: BidPhase.grand,
            participants: [1, 2, 3, 0],
            stage: BidStage.responding,
            currentBid: 2,
            bidderTeam: 1,
            responders: [2, 0],
          ),
        );
        c.syncFromRemote(stateResponding);

        expect(p.read(musGameControllerProvider).currentPlayer, 2);
        expect(p.read(musTableFeedbackProvider).clock!.seat, 2);

        await tester.pump(const Duration(seconds: 10));
        // À expiration, auto-tira exécuté et poussé
        expect(fakeRepo.pushedStates.isNotEmpty, isTrue);
        expect(fakeRepo.pushedStates.last['lastActionSeat'], 2);
        expect(
          fakeRepo.pushedStates.last['bidHistory']['grand'].last['type'],
          'nereGatikTira',
        );
      } finally {
        p.dispose();
        await tester.pump();
      }
    },
  );

  testWidgets(
    'Multijoueur : Fallback de l\'hôte à 13s pour un joueur distant inactif',
    (tester) async {
      final fakeRepo = _FakeRepo();
      final p = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(const Duration(seconds: 10)),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      try {
        final c = p.read(musGameControllerProvider.notifier);
        c.configureMultiplayer(
          gameId: 'game-fallback-host',
          localSeat: 0, // Hôte
          repository: fakeRepo,
          players: [
            {'seat': 0, 'name': 'Hôte', 'is_host': true, 'is_bot': false},
            {'seat': 1, 'name': 'Distant1', 'is_host': false, 'is_bot': false},
            {'seat': 2, 'name': 'Distant2', 'is_host': false, 'is_bot': false},
            {'seat': 3, 'name': 'Distant3', 'is_host': false, 'is_bot': false},
          ],
        );

        c.startGame();
        c.chooseMus(0, MusChoice.mintza);
        c.act(0, BidActionType.embido, amount: 2);
        fakeRepo.pushedStates.clear();

        expect(p.read(musGameControllerProvider).currentPlayer, 3);
        expect(p.read(musTableFeedbackProvider).clock!.seat, 3);

        // À 10s : l'hôte n'a rien forcé (grâce réseau 3s)
        await tester.pump(const Duration(seconds: 10));
        expect(p.read(musGameControllerProvider).currentPlayer, 3);
        expect(fakeRepo.pushedStates.isEmpty, isTrue);

        // À 12s : toujours en grâce réseau
        await tester.pump(const Duration(seconds: 2));
        expect(p.read(musGameControllerProvider).currentPlayer, 3);
        expect(fakeRepo.pushedStates.isEmpty, isTrue);

        // À 13s (10s + 3s de grâce réseau) : l'hôte déclenche le fallback, force Tira et pousse sur Supabase
        await tester.pump(const Duration(seconds: 1));
        expect(fakeRepo.pushedStates.isNotEmpty, isTrue);
        expect(fakeRepo.pushedStates.first['lastActionSeat'], 3);
        expect(
          fakeRepo.pushedStates.first['bidHistory']['grand'].last['type'],
          'nereGatikTira',
        );
        expect(p.read(musGameControllerProvider).currentPlayer, 1);
        expect(p.read(musGameControllerProvider).outcomes, isEmpty);
        await tester.pump(const Duration(seconds: 13));
        expect(
          p.read(musGameControllerProvider).outcomes[BidPhase.grand]!.kind,
          OutcomeKind.refused,
        );
        expect(p.read(musGameControllerProvider).tantto[0], 1);
      } finally {
        p.dispose();
        await tester.pump();
      }
    },
  );

  testWidgets(
    'Multijoueur : Une action du joueur distant avant 13s annule le timer de secours de l\'hôte',
    (tester) async {
      final fakeRepo = _FakeRepo();
      final p = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(const Duration(seconds: 10)),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      try {
        final c = p.read(musGameControllerProvider.notifier);
        c.configureMultiplayer(
          gameId: 'game-cancel-fallback',
          localSeat: 0, // Hôte
          repository: fakeRepo,
          players: [
            {'seat': 0, 'name': 'Hôte', 'is_host': true, 'is_bot': false},
            {'seat': 1, 'name': 'Distant1', 'is_host': false, 'is_bot': false},
            {'seat': 2, 'name': 'Distant2', 'is_host': false, 'is_bot': false},
            {'seat': 3, 'name': 'Distant3', 'is_host': false, 'is_bot': false},
          ],
        );

        c.startGame();
        c.chooseMus(0, MusChoice.mintza);
        c.act(0, BidActionType.embido, amount: 2);
        fakeRepo.pushedStates.clear();

        expect(p.read(musGameControllerProvider).currentPlayer, 3);

        // Le joueur distant joue à 5 secondes (Tira)
        await tester.pump(const Duration(seconds: 5));
        final remoteActionState = p
            .read(musGameControllerProvider)
            .copyWith(
              version: p.read(musGameControllerProvider).version + 1,
              currentPlayer: -1,
              bidHistory: {
                BidPhase.grand: [
                  ...p
                      .read(musGameControllerProvider)
                      .bidHistory[BidPhase.grand]!,
                  const BidAction(3, BidActionType.tira),
                ],
              },
            );
        c.syncFromRemote(remoteActionState);

        // Attente au-delà des 13s : le fallback a bien été annulé, aucune action parasite
        await tester.pump(const Duration(seconds: 10));
        expect(
          p
              .read(musGameControllerProvider)
              .bidHistory[BidPhase.grand]!
              .last
              .type,
          BidActionType.tira,
        );
      } finally {
        p.dispose();
        await tester.pump();
      }
    },
  );
}
