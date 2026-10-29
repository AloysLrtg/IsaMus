import 'package:isamus/features/seasons/countdown_widget.dart';
import 'package:isamus/core/models/season_reward.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/monetization/ads_banner.dart';
import 'package:isamus/core/monetization/store_service.dart';
import 'package:isamus/core/monetization/vip_access.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/retention_repository.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/features/profile/player_inspection_dialog.dart';
import 'package:isamus/features/retention/quests_screen.dart';
import 'package:isamus/features/retention/battle_pass_screen.dart';
import 'package:isamus/features/retention/season_path_step.dart';
import 'package:isamus/features/tutorial/tutorial_game_controller.dart';
import 'package:isamus/features/tutorial/tutorial_actions_view.dart';
import 'package:isamus/features/tutorial/tutorial_screen.dart';
import 'package:isamus/main.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class TestPlayer extends PlayerRepository {
  int finished = 0;
  final inspected = <String>[];
  @override
  Future<Map<String, dynamic>> profile() async => {'sound_enabled': false};
  @override
  Future<Map<String, dynamic>?> finish(String id) async {
    finished++;
    return null;
  }

  @override
  Future<Map<String, dynamic>> publicProfile(String id) async {
    inspected.add(id);
    return {
      'username': 'Amaia',
      'elo': 1450,
      'peak_elo': 1600,
      'games_played': 10,
      'games_won': 6,
    };
  }
}

class TestRetention extends RetentionRepository {
  TestRetention({this.level = 7, this.vip = false});
  final int level;
  final bool vip;
  int balance = 20;
  final claims = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> status() async => {
    'coins': balance,
    'vip': vip,
    'level': level,
    'xp': 250,
    'season': {
      'id': 'season_1',
      'title': 'Saison 1',
      'preview': true,
      'ends_at': DateTime.now().add(const Duration(days: 20)).toIso8601String(),
    },
    'rewards': [
      for (var tier = 1; tier <= 30; tier++)
        {
          'tier': tier,
          'free_coins': tier % 5 == 0 ? 50 : null,
          'vip_coins': 100,
          'vip_cosmetic': null,
          'vip_cosmetic_placeholder': [10, 20, 30].contains(tier)
              ? 'season_1_cosmetic_$tier'
              : null,
        },
    ],
    'claims': claims,
    'quests': [
      {
        'id': 'play_week',
        'title': 'Terminer 5 parties',
        'progress': 1,
        'target': 5,
        'reward_xp': 250,
        'rewarded': false,
      },
    ],
  };
  @override
  Future<Map<String, dynamic>> claim(
    int tier, {
    required bool vip,
    required String seasonId,
  }) async {
    if ((!vip && tier % 5 != 0) || tier > level || (vip && !this.vip)) {
      throw StateError('Récompense indisponible');
    }
    if (claims.any((c) => c['tier'] == tier && c['vip_track'] == vip)) {
      return {'coins': 0, 'already_claimed': true};
    }
    final coins = (vip ? 100 : 50);
    balance += coins;
    claims.add({'tier': tier, 'vip_track': vip});
    return {'coins': coins, 'cosmetic': null, 'already_claimed': false};
  }
}

class TestStore extends StoreService {
  @override
  bool get configured => false;
  @override
  Future<Package?> vipPackage() async => null;
}

Future<void> completeScriptedTutorial(WidgetTester tester) async {
  final context = tester.element(find.byType(GameScreen));
  final container = ProviderScope.containerOf(context);
  final controller = container.read(
    musGameControllerProvider.notifier,
  ) as TutorialGameController;
  Future<void> lesson(String name) async {
    expect(find.byKey(ValueKey('tutorial-lesson-$name')), findsOneWidget);
    await tester.tap(find.text('J’ai compris'));
    await tester.pumpAndSettle();
  }

  Future<void> action(TutorialAction action) async {
    expect(controller.expectedAction, action);
    final buttons = tester.widgetList<FilledButton>(
      find.descendant(
        of: find.byType(TutorialActionsView),
        matching: find.byType(FilledButton),
      ),
    );
    expect(buttons.where((b) => b.onPressed != null), hasLength(1));
    expect(
      find.byKey(const ValueKey('tutorial-expected-action')),
      findsOneWidget,
    );
    expect(container.read(musTableFeedbackProvider).clock, isNull);
    await tester.tap(find.byKey(ValueKey('tutorial-action-${action.name}')));
    await tester.pumpAndSettle();
    // Timers do not keep pumpAndSettle running: advance the reading pauses
    // until the next lesson, without dismissing it.
    for (
      var i = 0;
      i < 60 && find.byType(AlertDialog).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle();
  }

  for (final step in ['mus', 'mise', 'reply', 'hordago']) {
    await lesson(step);
  }
  expect(() => controller.chooseMus(0, MusChoice.mus), throwsStateError);
  await action(TutorialAction.mintza);
  await lesson('grand');
  expect(() => controller.act(0, BidActionType.paso), throwsStateError);
  expect(
    () => controller.act(0, BidActionType.embido, amount: 4),
    throwsStateError,
  );
  await action(TutorialAction.betTwo);
  await lesson('petit');
  await action(TutorialAction.paso);
  await lesson('paires');
  expect(() => controller.act(0, BidActionType.paso), throwsStateError);
  await action(TutorialAction.betTwo);
  await lesson('jeu');
  await action(TutorialAction.betTwo);
  await lesson('jeu-call');
  expect(container.read(musGameControllerProvider).bidding!.currentBid, 10);
  expect(() => controller.act(0, BidActionType.tira), throwsStateError);
  await action(TutorialAction.iduki);
  await lesson('roundScoring');
  final history = container.read(musGameControllerProvider).bidHistory;
  expect(history[BidPhase.grand]!.first.type, BidActionType.embido);
  expect(history[BidPhase.paires]!.first.type, BidActionType.embido);
  expect(
    history[BidPhase.jeu]!.map((a) => a.type),
    containsAllInOrder([
      BidActionType.embido,
      BidActionType.gehiago,
      BidActionType.iduki,
    ]),
  );
}

void main() {
  testWidgets(
    'Tutoriel scripté sur petit écran : actions imposées, sans timer ni résultat réseau',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = TestPlayer();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [playerRepositoryProvider.overrideWithValue(repo)],
          child: const MyApp(home: TutorialScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(GameScreen));
      final container = ProviderScope.containerOf(context);
      expect(
        container.read(musGameControllerProvider.notifier),
        isA<TutorialGameController>(),
      );
      await completeScriptedTutorial(tester);
      expect(
        container.read(musGameControllerProvider).phase,
        MusPhase.roundScoring,
      );
      await tester.pump(const Duration(seconds: 30));
      expect(
        container.read(musGameControllerProvider).phase,
        MusPhase.roundScoring,
      );
      expect(repo.finished, 0);
      expect(find.byKey(const ValueKey('tutorial-complete')), findsOneWidget);
      final before = container.read(musGameControllerProvider);
      await tester.tap(find.text('Terminer la partie en cours (Libre)'));
      await tester.pumpAndSettle();
      final controller = container.read(
        musGameControllerProvider.notifier,
      ) as TutorialGameController;
      expect(controller.guided, isFalse);
      expect(controller.autoAdvanceRounds, isTrue);
      expect(controller.botsEnabled, isTrue);
      expect(
        container.read(musGameControllerProvider).teamAScore,
        before.teamAScore,
      );
      expect(container.read(musTableFeedbackProvider).clock, isNull);
      final freeStart = container.read(musGameControllerProvider);
      await tester.pump(const Duration(seconds: 2));
      expect(
        container.read(musGameControllerProvider).hasSameTurnAs(freeStart),
        isFalse,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(repo.finished, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('Fin du tutoriel : retour au menu et libération de la table', (
    tester,
  ) async {
    final repo = TestPlayer();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [playerRepositoryProvider.overrideWithValue(repo)],
        child: MyApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TutorialScreen(),
                  ),
                ),
                child: const Text('Menu de test'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Menu de test'));
    await tester.pumpAndSettle();
    await completeScriptedTutorial(tester);
    await tester.tap(find.text('Retourner au menu'));
    await tester.pumpAndSettle();
    expect(find.text('Menu de test'), findsOneWidget);
    expect(find.byType(TutorialScreen), findsNothing);
    expect(repo.finished, 0);
    await tester.pump(const Duration(seconds: 30));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'avatar humain ouvre le profil ; bot et joueur local ne sont pas inspectables',
    (tester) async {
      final repo = TestPlayer();
      const id = '00000000-0000-4000-8000-000000000002';
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWithValue(repo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
        ],
      );
      final roster = [
        for (var seat = 0; seat < 4; seat++)
          {
            'seat': seat,
            'id': seat == 1
                ? id
                : seat == 3
                ? 'bot_3'
                : '00000000-0000-4000-8000-00000000000${seat + 3}',
            'name': 'Player $seat',
            'is_bot': seat == 3,
            'is_host': seat == 0,
          },
      ];
      container
          .read(musGameControllerProvider.notifier)
          .configureMultiplayer(players: roster);
      container.read(musGameControllerProvider.notifier).startGame();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MyApp(home: GameScreen(players: roster)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<GestureDetector>(
              find.byKey(const ValueKey('inspect-player-3')),
            )
            .onTap,
        isNull,
      );
      expect(
        tester
            .widget<GestureDetector>(
              find.byKey(const ValueKey('inspect-player-0')),
            )
            .onTap,
        isNull,
      );
      await tester.tap(find.byKey(const ValueKey('inspect-player-1')));
      await tester.pumpAndSettle();
      expect(find.byType(PlayerInspectionDialog), findsOneWidget);
      expect(repo.inspected, [id]);
      expect(find.text('Amaia'), findsOneWidget);
      expect(find.text('Peak Elo'), findsOneWidget);
      expect(find.text('1600'), findsOneWidget);
      expect(find.text('6 victoires · 4 défaites'), findsOneWidget);
      expect(find.text('60 %'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump();
    },
  );
  testWidgets(
    'Pass de Saison : 30 paliers selon le niveau, récompenses uniques',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = TestRetention();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            retentionRepositoryProvider.overrideWithValue(repo),
            playerRepositoryProvider.overrideWithValue(TestPlayer()),
            storeServiceProvider.overrideWithValue(TestStore()),
          ],
          child: const MyApp(home: BattlePassScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Prochain objectif : palier 10'), findsOneWidget);
      expect(find.text('Encore 1250 XP pour l’atteindre.'), findsOneWidget);
      expect(find.text('Défis de la semaine'), findsNothing);
      expect(find.text('Terminer 5 parties'), findsNothing);
      expect(find.text('Débloquez le Pass VIP'), findsOneWidget);
      expect(find.text('Sans publicités'), findsOneWidget);
      expect(find.text('Voie VIP du Pass'), findsOneWidget);
      expect(find.text('Pièces ×3'), findsNothing);
      expect(find.text('XP ×2'), findsOneWidget);
      final premium = find.byKey(const ValueKey('vip-premium-offer'));
      expect(
        tester.getRect(premium).top,
        greaterThan(tester.getRect(find.byType(CountdownWidget)).bottom),
      );
      expect(
        tester.getRect(premium).top,
        lessThan(
          tester
              .getRect(find.byKey(const ValueKey('season-tier-progress')))
              .top,
        ),
      );
      expect(find.text('Saison 1'), findsOneWidget);
      expect(find.text('Niveau 7 · 250 / 500 XP'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('season-tier-progress')),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('season-tier-1')),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      final vip = find.byKey(const ValueKey('claim-pass-true-1'));
      expect(tester.widget<InkWell>(vip).onTap, isNull);
      final empty = find.byKey(const ValueKey('claim-pass-false-1'));
      expect(tester.widget<InkWell>(empty).onTap, isNull);
      expect(find.byKey(const ValueKey('season-node-1')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('claim-pass-false-5')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final free = find.byKey(const ValueKey('claim-pass-false-5'));
      await tester.ensureVisible(free);
      await tester.pumpAndSettle();
      final left = tester.getCenter(free).dx;
      final node = tester
          .getCenter(find.byKey(const ValueKey('season-node-5')))
          .dx;
      final right = tester
          .getCenter(find.byKey(const ValueKey('claim-pass-true-5')))
          .dx;
      expect(left, lessThan(node));
      expect(right, greaterThan(node));
      expect(node, 160);
      await tester.tap(free);
      await tester.pumpAndSettle();
      expect(repo.claims, hasLength(1));
      expect(repo.balance, 70);
      expect(tester.widget<InkWell>(free).onTap, isNull);
      expect(
        find.byKey(const ValueKey('season-claimed-false-5')),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('season-node-7')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const ValueKey('season-node-7')),
            )
            .constraints!
            .maxWidth,
        42,
      );
      expect(find.byKey(const ValueKey('season-reached-7')), findsOneWidget);
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const ValueKey('season-node-8')),
            )
            .constraints!
            .maxWidth,
        42,
      );
      final step8 = find.byKey(const ValueKey('season-tier-8'));
      final step7 = find.byKey(const ValueKey('season-tier-7'));
      expect(
        tester.getRect(step7).bottom,
        closeTo(tester.getRect(step8).top, .01),
      );
      final painter =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: step7,
                      matching: find.byWidgetPredicate(
                        (w) =>
                            w is CustomPaint && w.painter is SeasonRoutePainter,
                      ),
                    ),
                  )
                  .painter
              as SeasonRoutePainter;
      expect(painter.first, isFalse);
      expect(painter.last, isFalse);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('season-tier-30')),
        700,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 40,
      );
      expect(find.byKey(const ValueKey('season-node-30')), findsOneWidget);
      expect(find.text('Cosmétique à venir'), findsWidgets);
      expect(
        tester
            .widget<InkWell>(find.byKey(const ValueKey('claim-pass-false-30')))
            .onTap,
        isNull,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Route VIP : récupérer un palier, aperçu cosmétique et coche verte',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = TestRetention(level: 30, vip: true);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            retentionRepositoryProvider.overrideWithValue(repo),
            playerRepositoryProvider.overrideWithValue(TestPlayer()),
            storeServiceProvider.overrideWithValue(TestStore()),
          ],
          child: const MyApp(home: BattlePassScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tous les paliers sont débloqués !'), findsOneWidget);
      final reward = find.byKey(const ValueKey('claim-pass-true-10'));
      await tester.scrollUntilVisible(
        reward,
        400,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 30,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(reward);
      await tester.pumpAndSettle();
      expect(find.text('Cosmétique à venir'), findsWidgets);
      await tester.tap(reward);
      await tester.pumpAndSettle();
      expect(repo.claims, [
        {'tier': 10, 'vip_track': true},
      ]);
      expect(repo.balance, 120);
      expect(
        find.byKey(const ValueKey('season-claimed-true-10')),
        findsOneWidget,
      );
      expect(tester.widget<InkWell>(reward).onTap, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  for (final vip in [false, true]) {
    testWidgets('Objectif niveau 4 : voie VIP=$vip', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            retentionRepositoryProvider.overrideWithValue(
              TestRetention(level: 3, vip: vip),
            ),
            playerRepositoryProvider.overrideWithValue(TestPlayer()),
            storeServiceProvider.overrideWithValue(TestStore()),
          ],
          child: const MyApp(home: BattlePassScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final target = vip ? 4 : 5;
      expect(find.text('Prochain objectif : palier $target'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(ValueKey('season-tier-$target')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final targetTile = find.byKey(
        ValueKey('claim-pass-${vip ? 'true' : 'false'}-$target'),
      );
      expect(
        find.descendant(
          of: targetTile,
          matching: find.text('Prochain objectif'),
        ),
        findsOneWidget,
      );
      if (!vip) {
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('claim-pass-true-5')),
            matching: find.text('Prochain objectif'),
          ),
          findsNothing,
        );
      }
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(ValueKey('season-node-$target')),
            )
            .constraints!
            .maxWidth,
        54,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets('Route : texte agrandi sans débordement sur téléphone étroit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MyApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SeasonPathStep(
                    reward: const SeasonReward(
                      tier: 10,
                      freeCoins: 50,
                      vipCoins: 100,
                      vipCosmeticPlaceholder: 'season_1_cosmetic_10',
                    ),
                    level: 10,
                    vip: true,
                    active: true,
                    busy: false,
                    freeClaimed: false,
                    vipClaimed: false,
                    first: false,
                    last: false,
                    onClaim: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('season-node-10')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Quêtes dans une modale, sans pass ni abonnement', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          retentionRepositoryProvider.overrideWithValue(TestRetention()),
        ],
        child: MyApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showWeeklyQuests(context),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Quêtes hebdomadaires'), findsOneWidget);
    expect(find.text('Terminer 5 parties'), findsOneWidget);
    expect(find.byKey(const ValueKey('pass-track-free')), findsNothing);
    expect(find.byKey(const ValueKey('purchase-vip')), findsNothing);
    await tester.tap(find.byTooltip('Fermer'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });
  testWidgets(
    'VIP coupe les publicités, même avec AdMob activé ; expiration réactive la possibilité',
    (tester) async {
      var now = DateTime.utc(2026, 10, 28);
      final container = ProviderContainer(
        overrides: [
          adsConfiguredProvider.overrideWithValue(true),
          vipClockProvider.overrideWithValue(() => now),
          playerProfileProvider.overrideWith(
            (ref) async => {
              'vip_expires_at': DateTime.utc(
                2026,
                10,
                28,
                0,
                0,
                1,
              ).toIso8601String(),
            },
          ),
        ],
      );
      expect(container.read(canShowAdsProvider), isFalse);
      final subscription = container.listen(canShowAdsProvider, (_, _) {});
      await tester.pump();
      expect(container.read(vipAccessProvider), isTrue);
      expect(container.read(canShowAdsProvider), isFalse);
      now = now.add(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      expect(container.read(vipAccessProvider), isFalse);
      expect(container.read(canShowAdsProvider), isTrue);
      subscription.close();
      container.dispose();
      await tester.pump();
    },
  );
}
