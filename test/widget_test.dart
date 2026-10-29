import 'package:isamus/core/network/player_repository.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_sign.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/models/card.dart' as mus;
import 'package:isamus/features/game/game_over_overlay.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/features/avatar/player_avatar_view.dart';
import 'package:isamus/features/home/home_screen.dart';
import 'package:isamus/l10n/app_localizations.dart';
import 'package:isamus/main.dart';

List<List<mus.Card>> signHands() {
  final local = [
    mus.Card(12, mus.Suit.oros),
    mus.Card(12, mus.Suit.copas),
    mus.Card(12, mus.Suit.espadas),
    mus.Card(1, mus.Suit.bastos),
  ];
  final rest = mus.Card.fullDeck()
      .where((card) => !local.contains(card))
      .toList();
  return [local, for (var i = 0; i < 3; i++) rest.sublist(i * 4, i * 4 + 4)];
}

void main() {
  late ProviderContainer container;
  late MusGameController controller;
  MusGameState state() => container.read(musGameControllerProvider);
  Finder button(String text) => find.widgetWithText(FilledButton, text);
  void uiTest(
    String name,
    Future<void> Function(WidgetTester) run, {
    bool timed = false,
    Set<String> ownedChats = const {},
  }) {
    testWidgets(name, (tester) async {
      container = ProviderContainer(
        overrides: [
          inventoryProvider.overrideWith((ref) async => ownedChats),
          musRandomProvider.overrideWithValue(Random(42)),
          musBotsEnabledProvider.overrideWithValue(false),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          if (!timed) musTurnTimeoutProvider.overrideWithValue(null),
        ],
      );
      controller = container.read(musGameControllerProvider.notifier);
      try {
        await run(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump();
      }
    });
  }

  Future<void> mount(
    WidgetTester tester, {
    int seat = 0,
    String locale = 'fr',
    bool timed = false,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GameScreen(localSeat: seat),
        ),
      ),
    );
    if (timed) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  uiTest('Démarrage : avatars, score complet, aucun log ni scroll de la main', (
    tester,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(home: GameScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(button('Distribuer'));
    await tester.pumpAndSettle();
    expect(find.text('Zuetan ?'), findsOneWidget);
    expect(find.byType(PlayerAvatarView), findsNWidgets(4));
    for (var seat = 0; seat < 4; seat++) {
      expect(find.byKey(ValueKey('player-avatar-$seat')), findsOneWidget);
    }
    final botConfigs = [
      for (var seat = 1; seat < 4; seat++)
        tester
            .widget<PlayerAvatarView>(
              find.byKey(ValueKey('player-avatar-$seat')),
            )
            .config,
    ];
    expect(botConfigs.toSet(), hasLength(3));
    expect(find.byKey(const ValueKey('score-total-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('score-total-1')), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('0 H'), findsNWidgets(2));
    expect(find.text('0 T'), findsNWidgets(2));
    expect(find.textContaining('Manches'), findsNothing);
    expect(find.text('Dernières actions'), findsNothing);
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('local-hand')),
        matching: find.byType(Scrollable),
      ),
      findsNothing,
    );
    expect(
      tester.widget<InkWell>(find.byKey(const ValueKey('hand-card-0'))).onTap,
      isNull,
    );
    await tester.tap(button('Mus'));
    await tester.pumpAndSettle();
    expect(state().currentPlayer, 2);
    expect(button('Mus'), findsNothing);
    expect(find.byKey(const ValueKey('speech-0')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.byKey(const ValueKey('speech-0')), findsNothing);
  });

  for (final size in [
    const Size(320, 568),
    const Size(568, 320),
    const Size(390, 844),
  ]) {
    uiTest('Scores centrés avec le menu unique à $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(tester);
      final first = tester.getRect(find.byKey(const ValueKey('score-card-0')));
      final second = tester.getRect(find.byKey(const ValueKey('score-card-1')));
      final exit = tester.getRect(
        find.byKey(const ValueKey('game-menu-button')),
      );
      expect(
        (first.center.dx + second.center.dx) / 2,
        closeTo(size.width / 2, .01),
      );
      expect(
        tester.getCenter(find.byKey(const ValueKey('game-scores'))).dx,
        closeTo(size.width / 2, .01),
      );
      expect(exit.right, closeTo(size.width - 8, .01));
      expect(second.right, lessThanOrEqualTo(exit.left));
      expect(find.byKey(const ValueKey('game-exit-button')), findsNothing);
      expect(find.byKey(const ValueKey('game-settings-button')), findsNothing);
      expect(
        tester.widget(find.byKey(const ValueKey('game-menu-button'))),
        isA<PopupMenuButton>(),
      );
      expect(tester.takeException(), isNull);
    });
  }

  uiTest('Défausse : sélection et remise à zéro', (tester) async {
    controller.startGame();
    for (final seat in [0, 2, 3, 1]) {
      controller.chooseMus(seat, MusChoice.mus);
    }
    await mount(tester);
    await tester.tap(find.byKey(const ValueKey('hand-card-0')));
    await tester.pumpAndSettle();
    await tester.tap(button('Échanger 1 carte(s)'));
    await tester.pumpAndSettle();
    expect(state().discardSelections[0], [0]);
    for (final seat in [3, 2, 1]) {
      controller.discard(seat, []);
    }
    for (final seat in [0, 2, 3, 1]) {
      controller.chooseMus(seat, MusChoice.mus);
    }
    await tester.pumpAndSettle();
    await tester.tap(button('Garder mes cartes'));
    expect(state().discardSelections[0], isEmpty);
  });

  uiTest('Enchère sans clavier : minimum, sélecteur et absence de plafond 40', (
    tester,
  ) async {
    controller.startGame();
    controller.chooseMus(0, MusChoice.mintza);
    await mount(tester);
    await tester.tap(button('Gehiago'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('bid-minus')))
          .onPressed,
      isNull,
    );
    for (var i = 0; i < 48; i++) {
      await tester.tap(find.byKey(const ValueKey('bid-plus')));
      await tester.pump();
    }
    expect(find.text('50'), findsOneWidget);
    await tester.tap(button('Valider'));
    await tester.pumpAndSettle();
    expect(state().bidding!.currentBid, 50);
    expect(state().bidding!.isHordago, isFalse);
  });

  uiTest('Bouton Embido : mise directe de 2 points instantanément', (
    tester,
  ) async {
    controller.startGame();
    controller.chooseMus(0, MusChoice.mintza);
    await mount(tester);
    await tester.tap(button('Embido'));
    await tester.pumpAndSettle();
    expect(state().bidding!.currentBid, 2);
  });

  for (final amount in [3, 4, 5]) {
    uiTest('Raccourci de mise $amount', (tester) async {
      controller.startGame();
      controller.chooseMus(0, MusChoice.mintza);
      await mount(tester);
      await tester.tap(button('Gehiago'));
      await tester.pumpAndSettle();
      await tester.tap(button('+$amount'));
      await tester.pumpAndSettle();
      expect(state().bidding!.currentBid, amount);
    });
  }

  uiTest('Relance +3 incrémentale ; premier refus Nere gatik tira', (
    tester,
  ) async {
    controller.startGame();
    controller.chooseMus(0, MusChoice.mintza);
    controller.act(0, BidActionType.embido, amount: 2);
    await mount(tester, seat: 3);
    expect(button('Nere gatik tira'), findsOneWidget);
    await tester.tap(button('Gehiago'));
    await tester.pumpAndSettle();
    expect(find.text('Relancer de…'), findsOneWidget);
    await tester.tap(button('+3'));
    await tester.pumpAndSettle();
    expect(state().bidding!.currentBid, 5);
  });

  uiTest(
    'Le premier refus affiche Nere gatik tira puis le partenaire voit Tira',
    (tester) async {
      controller.startGame();
      controller.chooseMus(0, MusChoice.mintza);
      controller.act(0, BidActionType.embido, amount: 2);
      await mount(tester, seat: 3);
      expect(button('Nere gatik tira'), findsOneWidget);
      expect(button('Tira'), findsNothing);
      await tester.tap(button('Nere gatik tira'));
      await tester.pumpAndSettle();
      expect(state().currentPlayer, 1);
      expect(state().outcomes.containsKey(BidPhase.grand), isFalse);
      await mount(tester, seat: 1);
      expect(button('Tira'), findsOneWidget);
      expect(button('Nere gatik tira'), findsNothing);
      await tester.tap(button('Tira'));
      await tester.pumpAndSettle();
      expect(state().outcomes[BidPhase.grand]!.kind, OutcomeKind.refused);
    },
  );

  uiTest('Hordago dans le panneau puis Iduki ou Nere gatik tira', (
    tester,
  ) async {
    controller.startGame();
    controller.chooseMus(0, MusChoice.mintza);
    await mount(tester);
    await tester.tap(button('Gehiago'));
    await tester.pumpAndSettle();
    await tester.tap(button('Hordago'));
    await tester.pumpAndSettle();
    await mount(tester, seat: 3);
    expect(button('Gehiago'), findsNothing);
    expect(button('Nere gatik tira'), findsOneWidget);
    await tester.tap(button('Iduki'));
    await tester.pumpAndSettle();
    expect(state().phase, MusPhase.roundScoring);
    expect(find.text('Donne suivante'), findsNothing);
    expect(find.byKey(const Key('game-over-overlay')), findsNothing);
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
    // En fin de partie (Hordago = 40 tantto), à l'expiration des 8s : transition en gameOver et affichage de l'overlay.
    expect(state().phase, MusPhase.gameOver);
    expect(state().teamAScore >= 40 || state().teamBScore >= 40, isTrue);
    expect(state().eskuIndex, 0);
    expect(find.byKey(const Key('game-over-overlay')), findsOneWidget);
    expect(find.text('DÉFAITE'), findsOneWidget);
    expect(find.text('Retour à l\'accueil'), findsOneWidget);
  });

  uiTest('Le panneau se ferme si le tour change', (tester) async {
    controller.startGame();
    controller.chooseMus(0, MusChoice.mintza);
    await mount(tester);
    await tester.tap(button('Gehiago'));
    await tester.pumpAndSettle();
    controller.act(0, BidActionType.paso);
    await tester.pumpAndSettle();
    expect(button('Valider'), findsNothing);
    expect(state().bidding!.currentBid, 0);
  });

  uiTest('Menu des signes sincères et expiration', (tester) async {
    // 1. Avec des signes valides (signHands : 2 Rois, Mediak, 31)
    controller.startGame(hands: signHands());
    await mount(tester);
    final signMenuFinder = find.byKey(const ValueKey('sign-menu'));
    expect(tester.widget<IconButton>(signMenuFinder).onPressed != null, isTrue);
    await tester.tap(signMenuFinder);
    await tester.pumpAndSettle();

    for (final label in [
      '2 Rois',
      '2 As',
      'Mediak',
      'Dobliak / 29',
      '30 / 31',
      'Jeu',
    ]) {
      expect(find.widgetWithText(FilledButton, label), findsOneWidget);
    }
    expect(find.text('Aveugle'), findsNothing);
    // 'Jeu' est désactivé avec 31 ; le menu contient six choix officiels.
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Jeu'))
          .onPressed,
      isNull,
    );
    // '31' est autorisé et présent
    expect(find.widgetWithText(FilledButton, '30 / 31'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '30 / 31'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('sign-0')), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const ValueKey('sign-0')), findsNothing);

    // 2. Sans aucun signe valide (ex: 4, 5, 6, 7 sans paires, total 22 != 31)
    controller.startGame(
      hands: [
        [
          mus.Card(4, mus.Suit.oros),
          mus.Card(5, mus.Suit.copas),
          mus.Card(6, mus.Suit.espadas),
          mus.Card(7, mus.Suit.bastos),
        ],
        ...signHands().sublist(1),
      ],
    );
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(signMenuFinder).onPressed, isNull);
    expect(find.text('Aveugle'), findsNothing);
  });

  uiTest('Les signes ne ferment pas le panneau de mise', (tester) async {
    controller.startGame(hands: signHands());
    controller.chooseMus(0, MusChoice.mintza);
    await mount(tester);
    await tester.tap(button('Gehiago'));
    await tester.pumpAndSettle();
    controller.sendSignForSeat(0, MusSign.twoKings);
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(button('Valider'));
    await tester.pumpAndSettle();
    expect(state().bidding!.currentBid, 2);
  });

  uiTest('Les Quick Chats achetés sont disponibles à la table', (tester) async {
    controller.startGame();
    await mount(tester);
    await tester.tap(find.byKey(const ValueKey('quick-chat')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encouragement'));
    await tester.pumpAndSettle();
    expect(find.text('Eskerrik asko !'), findsOneWidget);
    expect(find.text('La revanche ?'), findsNothing);
    await tester.tap(button('Eskerrik asko !'));
    await tester.pumpAndSettle();
    expect(
      container.read(musTableFeedbackProvider).speeches[0]!.chat,
      QuickChat.eskerrik,
    );
  }, ownedChats: {'shop_chat_eskerrik'});

  uiTest(
    'Quick Chats : Information et Trashtalk fonctionnent sur petit écran',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      controller.startGame();
      await mount(tester);
      final before = state();
      await tester.tap(find.byKey(const ValueKey('quick-chat')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('quick-option-oneMoment')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('quick-option-oneMoment')));
      await tester.pumpAndSettle();
      expect(
        container.read(musTableFeedbackProvider).speeches[0]!.chat,
        QuickChat.oneMoment,
      );
      await tester.tap(find.byKey(const ValueKey('quick-chat')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Trashtalk'));
      await tester.tap(find.text('Trashtalk'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quick-option-bluffing')));
      await tester.pumpAndSettle();
      expect(
        container.read(musTableFeedbackProvider).speeches[0]!.chat,
        QuickChat.bluffing,
      );
      expect(identical(state(), before), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  uiTest('Chat rapide : une bulle, sans changement de tour', (tester) async {
    controller.startGame();
    await mount(tester);
    final before = state();
    await tester.tap(find.byKey(const ValueKey('quick-chat')));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Information'), findsOneWidget);
    expect(find.text('Trashtalk'), findsOneWidget);
    await tester.tap(find.text('Encouragement'));
    await tester.pumpAndSettle();
    expect(find.text('Eskerrik asko !'), findsNothing);
    expect(find.text('La revanche ?'), findsNothing);
    await tester.tap(button('Bonne chance'));
    await tester.pumpAndSettle();
    expect(find.text('Bonne chance'), findsOneWidget);
    expect(identical(state(), before), isTrue);
    expect(
      container.read(musTableFeedbackProvider).speeches[0]!.chat,
      QuickChat.goodLuck,
    );
  });

  uiTest('Expiration à 10 s pendant le panneau : Paso et fermeture', (
    tester,
  ) async {
    controller.startGame();
    controller.chooseMus(0, MusChoice.mintza);
    await mount(tester, timed: true);
    expect(find.byKey(const ValueKey('turn-progress-0')), findsOneWidget);
    await tester.tap(button('Gehiago'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(button('Valider'), findsNothing);
    expect(state().currentPlayer, 3);
    expect(state().bidHistory[BidPhase.grand]!.last.type, BidActionType.paso);
  }, timed: true);

  for (final size in [
    const Size(320, 568),
    const Size(568, 320),
    const Size(390, 844),
  ]) {
    uiTest('Table fixe et paquet près de chaque Esku à $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (var esku = 0; esku < 4; esku++) {
        controller.startGame(eskuIndex: esku);
        await mount(tester, locale: 'eu');
        final deck = find.byKey(ValueKey('deck-$esku'));
        expect(deck, findsOneWidget);
        final deckRect = tester.getRect(deck);
        switch (esku) {
          case 0: // bottomLeft
            expect(deckRect.left, lessThan(size.width * 0.45));
            expect(deckRect.bottom, greaterThan(size.height * 0.25));
          case 1: // topLeft
            expect(deckRect.left, lessThan(size.width * 0.45));
            expect(deckRect.top, lessThan(size.height * 0.45));
          case 2: // topRight
            expect(deckRect.right, greaterThan(size.width * 0.55));
            expect(deckRect.top, lessThan(size.height * 0.45));
          case 3: // bottomRight
            expect(deckRect.right, greaterThan(size.width * 0.55));
            expect(deckRect.bottom, greaterThan(size.height * 0.25));
        }
        expect(
          tester.getRect(find.byKey(const ValueKey('local-hand'))).bottom,
          lessThan(size.height),
        );
        for (var i = 0; i < 4; i++) {
          final rect = tester.getRect(find.byKey(ValueKey('hand-card-$i')));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
        }
        expect(tester.takeException(), isNull);
      }
      controller.chooseMus(3, MusChoice.mintza);
      controller.act(3, BidActionType.embido, amount: 2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  uiTest('Badge natif des cartes et masquage du talon en roundScoring', (
    tester,
  ) async {
    controller.startGame(
      hands: [
        [
          mus.Card(1, mus.Suit.oros),
          mus.Card(7, mus.Suit.copas),
          mus.Card(10, mus.Suit.espadas),
          mus.Card(12, mus.Suit.bastos),
        ],
        [
          mus.Card(2, mus.Suit.oros),
          mus.Card(3, mus.Suit.copas),
          mus.Card(11, mus.Suit.espadas),
          mus.Card(4, mus.Suit.bastos),
        ],
        [
          mus.Card(5, mus.Suit.oros),
          mus.Card(6, mus.Suit.copas),
          mus.Card(7, mus.Suit.espadas),
          mus.Card(1, mus.Suit.bastos),
        ],
        [
          mus.Card(10, mus.Suit.oros),
          mus.Card(11, mus.Suit.copas),
          mus.Card(12, mus.Suit.espadas),
          mus.Card(2, mus.Suit.bastos),
        ],
      ],
    );
    await mount(tester);
    // Nettoyage UI : le bandeau des signes est complètement supprimé
    expect(find.text('Signes désactivés'), findsNothing);
    expect(find.text('Signes autorisés'), findsNothing);

    // Vérification des badges sur la main locale (1, 7, 10, 12)
    expect(find.text('1'), findsWidgets);
    expect(find.text('7'), findsWidgets);
    expect(find.text('10'), findsWidgets);
    expect(find.text('12'), findsWidgets);

    // Talon présent en cours de jeu
    expect(find.byKey(const ValueKey('deck-0')), findsOneWidget);

    // Passer en roundScoring via Hordago accepté
    controller.chooseMus(0, MusChoice.mintza);
    controller.act(0, BidActionType.hordago);
    controller.act(3, BidActionType.iduki);
    await tester.pumpAndSettle();
    expect(state().phase, MusPhase.roundScoring);

    // Le talon est masqué au décompte
    expect(find.byKey(const ValueKey('deck-0')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  uiTest('Filtrage dynamique des lignes du score de fin de donne', (
    tester,
  ) async {
    controller.startGame(
      hands: [
        [
          mus.Card(1, mus.Suit.oros),
          mus.Card(1, mus.Suit.copas),
          mus.Card(7, mus.Suit.espadas),
          mus.Card(7, mus.Suit.bastos),
        ],
        [
          mus.Card(2, mus.Suit.oros),
          mus.Card(3, mus.Suit.copas),
          mus.Card(4, mus.Suit.espadas),
          mus.Card(5, mus.Suit.bastos),
        ],
        [
          mus.Card(10, mus.Suit.oros),
          mus.Card(10, mus.Suit.copas),
          mus.Card(11, mus.Suit.espadas),
          mus.Card(12, mus.Suit.bastos),
        ],
        [
          mus.Card(2, mus.Suit.oros),
          mus.Card(3, mus.Suit.copas),
          mus.Card(4, mus.Suit.espadas),
          mus.Card(6, mus.Suit.bastos),
        ],
      ],
    );
    await mount(tester);
    controller.chooseMus(0, MusChoice.mintza);
    // Joueur 0 mise Embido 2 en Grand, Joueur 3 dit Tira (Équipe A marque 1 pt Tira)
    controller.act(0, BidActionType.embido, amount: 2);
    controller.act(3, BidActionType.tira);
    controller.act(1, BidActionType.tira);

    // Passer Petit
    for (final seat in [0, 3, 2, 1]) {
      controller.act(seat, BidActionType.paso);
    }
    await tester.pumpAndSettle();
    expect(state().phase, MusPhase.roundScoring);

    // Vérification du filtrage dynamique :
    // Total donne doit toujours être présent
    expect(find.text('Total donne'), findsOneWidget);
    // Tira a rapporté 1 pt -> présent
    expect(find.text('Tira'), findsOneWidget);
    // Pareak a rapporté des points de paires -> présent
    expect(find.text('Pareak'), findsOneWidget);
    // Handia a été remporté via Tira (1 pt sous la ligne Tira), donc Handia a 0 pt et doit être absent
    expect(find.text('Handia'), findsNothing);
  });

  uiTest('Code couleur et indicateur visuel selon la phase en cours', (
    tester,
  ) async {
    controller.startGame();
    await mount(tester);

    // Phase Zuetan : Violet
    expect(find.text('ZUETAN ?'), findsOneWidget);

    // Passage en Handia
    controller.chooseMus(0, MusChoice.mintza);
    await tester.pumpAndSettle();
    expect(find.text('HANDIA'), findsOneWidget);

    // Passage en Ttipia
    for (final seat in [0, 3, 2, 1]) {
      controller.act(seat, BidActionType.paso);
    }
    await tester.pumpAndSettle();
    expect(find.text('TTIPIA'), findsOneWidget);
  });

  for (final size in [
    const Size(320.0, 568.0),
    const Size(568.0, 320.0),
    const Size(390.0, 844.0),
  ]) {
    uiTest('Mains latérales au décompte et label Adv 2 à $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      controller.startGame();
      await mount(tester);

      // Passer en roundScoring
      controller.chooseMus(0, MusChoice.mintza);
      controller.act(0, BidActionType.hordago);
      controller.act(3, BidActionType.iduki);
      await tester.pumpAndSettle();
      expect(state().phase, MusPhase.roundScoring);

      // Labels Adv 1 et Adv 2
      final adv1 = find.text(
        state().players.singleWhere((p) => p.seat == 1).name,
      );
      final adv2 = find.text(
        state().players.singleWhere((p) => p.seat == 3).name,
      );
      expect(adv1, findsOneWidget);
      expect(adv2, findsOneWidget);

      final adv1Rect = tester.getRect(adv1);
      final adv2Rect = tester.getRect(adv2);

      // Le label Adv 2 doit être strictement à l'intérieur du bord droit de l'écran
      expect(adv2Rect.right, lessThan(size.width - 10));
      // Le label Adv 1 doit être strictement à l'intérieur du bord gauche de l'écran
      expect(adv1Rect.left, greaterThan(10));

      // Les labels sont descendus vers le bas (dans la moitié inférieure de la table)
      expect(adv1Rect.top, greaterThan(size.height * 0.10));
      expect(adv2Rect.top, greaterThan(size.height * 0.10));

      // Symétrie verticale parfaite entre Adv 1 et Adv 2
      expect((adv1Rect.top - adv2Rect.top).abs(), lessThan(5.0));

      // Aucun overflow RenderFlex
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [
    const Size(320.0, 568.0),
    const Size(568.0, 320.0),
    const Size(390.0, 844.0),
  ]) {
    uiTest('Stabilité stricte de la table (aucun effet accordéon) à $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Phase de distribution / Démarrage
      await mount(tester);
      final tableFinder = find.byKey(const ValueKey('mus-table'));
      expect(tableFinder, findsOneWidget);
      final rectDealing = tester.getRect(tableFinder);

      // 2. Lancement de la partie -> Tour du joueur (Mus/Mintza)
      controller.startGame();
      await tester.pumpAndSettle();
      expect(state().phase, MusPhase.musDecision);
      expect(state().currentPlayer, 0);
      expect(find.text('MUS'), findsOneWidget);
      final rectPlayerMus = tester.getRect(tableFinder);
      expect(rectPlayerMus.height, closeTo(rectDealing.height, 0.001));
      expect(rectPlayerMus.top, closeTo(rectDealing.top, 0.001));

      // 3. Choix du joueur -> Au tour d'un autre joueur (espace vide sous le statut)
      controller.chooseMus(0, MusChoice.mus);
      await tester.pumpAndSettle();
      expect(state().phase, MusPhase.musDecision);
      expect(state().currentPlayer, isNot(0));
      expect(find.text('MUS'), findsNothing);
      final rectBotMus = tester.getRect(tableFinder);
      expect(rectBotMus.height, closeTo(rectDealing.height, 0.001));
      expect(rectBotMus.top, closeTo(rectDealing.top, 0.001));

      // 4. Défausse
      for (final seat in [2, 3, 1]) {
        controller.chooseMus(seat, MusChoice.mus);
      }
      await tester.pumpAndSettle();
      expect(state().phase, MusPhase.discarding);
      expect(state().currentPlayer, 0);
      final rectDiscard = tester.getRect(tableFinder);
      expect(rectDiscard.height, closeTo(rectDealing.height, 0.001));
      expect(rectDiscard.top, closeTo(rectDealing.top, 0.001));

      // 5. Enchères -> Tour du joueur (3 boutons : Paso, Embido, Gehiago)
      for (final seat in [0, 3, 2, 1]) {
        controller.discard(seat, []);
      }
      await tester.pumpAndSettle();
      expect(state().phase, MusPhase.musDecision);
      controller.chooseMus(0, MusChoice.mintza);
      await tester.pumpAndSettle();
      expect(state().phase, MusPhase.bidding);
      expect(state().currentPlayer, 0);
      expect(find.text('Paso'), findsOneWidget);
      expect(find.text('Embido'), findsOneWidget);
      expect(find.text('Gehiago'), findsOneWidget);
      final rectBiddingPlayer = tester.getRect(tableFinder);
      expect(rectBiddingPlayer.height, closeTo(rectDealing.height, 0.001));
      expect(rectBiddingPlayer.top, closeTo(rectDealing.top, 0.001));

      // 6. Enchères -> Tour d'un adversaire
      controller.act(0, BidActionType.paso);
      await tester.pumpAndSettle();
      expect(state().phase, MusPhase.bidding);
      expect(state().currentPlayer, isNot(0));
      expect(button('Paso'), findsNothing);
      final rectBiddingBot = tester.getRect(tableFinder);
      expect(rectBiddingBot.height, closeTo(rectDealing.height, 0.001));
      expect(rectBiddingBot.top, closeTo(rectDealing.top, 0.001));

      // Aucun overflow RenderFlex
      expect(tester.takeException(), isNull);
    });
  }

  uiTest('Mise en temps réel au-dessus de la pilule et Mise : HORDAGO doré', (
    tester,
  ) async {
    controller.startGame();
    controller.chooseMus(0, MusChoice.mintza);
    await mount(tester);

    // Initialement aucune mise sur Handia
    expect(find.byKey(const ValueKey('bidding-current-amount')), findsNothing);

    // Joueur mise Embido (2)
    await tester.tap(button('Embido'));
    await tester.pumpAndSettle();
    expect(state().bidding!.amount, 2);

    final bidTextFinder = find.byKey(const ValueKey('bidding-current-amount'));
    expect(bidTextFinder, findsOneWidget);
    expect(find.text('Mise : 2 Tantto'), findsOneWidget);

    // Vérification géométrique : la mise est STRICTEMENT AU-DESSUS de la pilule
    final bidRect = tester.getRect(bidTextFinder);
    final pillRect = tester.getRect(find.text('HANDIA'));
    expect(bidRect.bottom, lessThanOrEqualTo(pillRect.top));

    // Relance (+3) -> Mise totale = 5
    await mount(tester, seat: 3);
    await tester.tap(button('Gehiago'));
    await tester.pumpAndSettle();
    await tester.tap(button('+3'));
    await tester.pumpAndSettle();
    expect(state().bidding!.amount, 5);
    expect(find.text('Mise : 5 Tantto'), findsOneWidget);

    // Hordago -> Texte Mise : HORDAGO
    await mount(tester, seat: 0);
    await tester.tap(button('Gehiago'));
    await tester.pumpAndSettle();
    await tester.tap(button('Hordago'));
    await tester.pumpAndSettle();
    expect(state().bidding!.isHordago, isTrue);

    final hordagoFinder = find.text('Mise : HORDAGO');
    expect(hordagoFinder, findsOneWidget);
    final hordagoRect = tester.getRect(hordagoFinder);
    expect(hordagoRect.bottom, lessThanOrEqualTo(pillRect.top));

    // Typographie dorée
    final textWidget = tester.widget<Text>(
      find.byKey(const ValueKey('bidding-current-amount')),
    );
    expect(textWidget.style?.color, Colors.amber);
    expect(textWidget.style?.fontWeight, FontWeight.w900);
  });

  uiTest(
    'Overlay de fin de partie : célébration de la VICTOIRE, affichage des scores et retour accueil',
    (tester) async {
      controller.startGame();
      controller.chooseMus(0, MusChoice.mintza);
      controller.act(0, BidActionType.hordago);
      controller.act(3, BidActionType.iduki);
      // Monter avec seat 0 (Équipe A gagnante)
      await mount(tester, seat: 0);

      expect(state().teamAScore, 40);
      expect(state().phase, MusPhase.roundScoring);

      // Vérification du timer visuel (LinearProgressIndicator) de fin de donne
      final progressFinder = find.byKey(
        const Key('round-scoring-progress-indicator'),
      );
      expect(progressFinder, findsOneWidget);
      expect(find.text('Fin de donne'), findsOneWidget);
      expect(find.text('8s'), findsOneWidget);

      // Pendant les 8 secondes, le récapitulatif reste visible et GameOverOverlay n'est pas affiché
      expect(find.byType(GameOverOverlay), findsNothing);
      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(GameOverOverlay), findsNothing);

      // Le timer visuel a diminué de moitié
      expect(find.text('4s'), findsOneWidget);
      final indicator = tester.widget<LinearProgressIndicator>(progressFinder);
      expect(indicator.value, closeTo(0.5, 0.05));

      // À l'expiration des 8 secondes : transition en gameOver et apparition de l'overlay
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(state().phase, MusPhase.gameOver);
      expect(find.byType(GameOverOverlay), findsOneWidget);
      expect(find.byKey(const Key('game-over-overlay')), findsOneWidget);
      expect(find.text('VICTOIRE'), findsOneWidget);
      expect(find.text('Équipe A : 40  -  Équipe B : 0'), findsNothing);

      final homeBtn = find.byKey(const Key('return-home-button'));
      expect(homeBtn, findsOneWidget);
      expect(find.text('Retour à l\'accueil'), findsOneWidget);

      // Clic sur "Retour à l'accueil" -> ramène vers HomeScreen et purge l'état de jeu
      await tester.tap(homeBtn);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Vérification de la purge d'état : nouvelle partie prête avec scores à 0
      expect(state().teamAScore, 0);
      expect(state().teamBScore, 0);
      expect(state().phase, MusPhase.dealing);
    },
  );

  uiTest(
    'Overlay de fin de partie : affichage DÉFAITE pour l\'équipe perdante',
    (tester) async {
      controller.startGame();
      controller.chooseMus(0, MusChoice.mintza);
      controller.act(0, BidActionType.hordago);
      controller.act(3, BidActionType.iduki);
      // Monter avec seat 1 (Équipe B perdante)
      await mount(tester, seat: 1);

      expect(state().phase, MusPhase.roundScoring);
      // Timer visuel présent en roundScoring
      expect(
        find.byKey(const Key('round-scoring-progress-indicator')),
        findsOneWidget,
      );
      // Pas d'overlay pendant le récapitulatif
      expect(find.byType(GameOverOverlay), findsNothing);
      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(GameOverOverlay), findsNothing);

      // Expiration du délai de 8 secondes -> GameOverOverlay s'affiche
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(state().phase, MusPhase.gameOver);
      expect(find.byType(GameOverOverlay), findsOneWidget);
      expect(find.byKey(const Key('game-over-overlay')), findsOneWidget);
      expect(find.text('DÉFAITE'), findsOneWidget);
      expect(find.text('Équipe A : 40  -  Équipe B : 0'), findsNothing);
      expect(find.byKey(const Key('return-home-button')), findsOneWidget);
    },
  );
}
