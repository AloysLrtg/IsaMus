import 'package:isamus/l10n/app_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/network/auth_repository.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/features/home/main_dashboard_screen.dart';
import 'package:isamus/main.dart';
import 'package:isamus/core/localization/app_locale.dart';
import 'package:isamus/features/settings/settings_screen.dart';

class ExitRepository implements SupabaseRepository {
  final events = StreamController<Map<String, dynamic>>.broadcast();
  final closed = <String>[];
  bool fail = false;
  @override
  Stream<Map<String, dynamic>> streamGame(String gameId) => events.stream;
  @override
  Future<void> updateGameState(
    String gameId,
    Map<String, dynamic> state,
  ) async {}
  @override
  Future<void> closeGame(String gameId) async {
    if (fail) throw Exception('offline');
    closed.add(gameId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ExitAuth implements AuthRepository {
  @override
  Future<String> signInAnonymously() async => 'test';
  @override
  Future<Map<String, dynamic>?> getProfile(String id) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ExitRepository repo;
  late ProviderContainer container;
  tearDown(() async {
    container.dispose();
    await repo.events.close();
  });
  Future<void> mount(
    WidgetTester tester, {
    int seat = 0,
    Locale locale = const Locale('fr'),
  }) async {
    repo = ExitRepository();
    container = ProviderContainer(
      overrides: [
        supabaseRepositoryProvider.overrideWithValue(repo),
        authRepositoryProvider.overrideWithValue(ExitAuth()),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
      ],
    );
    container.read(appLocaleProvider.notifier).select(locale);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MyApp(
          home: GameScreen(gameId: 'game', localSeat: seat),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> confirm(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('game-menu-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(testL10n.gameQuitTitle));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(testL10n.gameQuitConfirm), findsOneWidget);
    await tester.tap(
      find.widgetWithText(FilledButton, testL10n.gameQuitAction),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('annuler conserve la partie sans fermeture', (tester) async {
    await mount(tester);
    final state = container.read(musGameControllerProvider);
    await tester.tap(find.byKey(const ValueKey('game-menu-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(testL10n.gameQuitTitle));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(testL10n.menuCancel));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);
    expect(repo.closed, isEmpty);
    expect(container.read(musGameControllerProvider), same(state));
  });
  testWidgets('hôte ferme le salon, purge le contrôleur et la navigation', (
    tester,
  ) async {
    await mount(tester);
    await confirm(tester);
    expect(repo.closed, ['game']);
    expect(repo.events.hasListener, isFalse);
    expect(find.byType(MainDashboardScreen), findsOneWidget);
    expect(find.byType(GameScreen), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(MainDashboardScreen))).canPop(),
      isFalse,
    );
    expect(container.read(musGameControllerProvider).phase, MusPhase.dealing);
    expect(container.read(musGameControllerProvider.notifier).gameId, isNull);
  });
  testWidgets('invité quitte sans fermer le salon de l’hôte', (tester) async {
    await mount(tester, seat: 1);
    await confirm(tester);
    expect(repo.closed, isEmpty);
    expect(find.byType(MainDashboardScreen), findsOneWidget);
    expect(repo.events.hasListener, isFalse);
  });
  testWidgets('échec réseau conserve la table et permet de réessayer', (
    tester,
  ) async {
    await mount(tester);
    repo.fail = true;
    await confirm(tester);
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text(testL10n.gameQuitFailed), findsOneWidget);
    repo.fail = false;
    await confirm(tester);
    expect(repo.closed, ['game']);
    expect(find.byType(MainDashboardScreen), findsOneWidget);
  });
  for (final language in ['fr', 'eu', 'es', 'en']) {
    testWidgets('menu en jeu et confirmation localisés en $language', (
      tester,
    ) async {
      final locale = Locale(language);
      final l10n = lookupAppLocalizations(locale);
      await mount(tester, locale: locale);
      final state = container.read(musGameControllerProvider);
      Future<void> openMenu() async {
        await tester.tap(find.byTooltip(l10n.gameMenuTitle));
        await tester.pumpAndSettle();
        expect(find.text(l10n.settingsTitle), findsOneWidget);
        expect(find.text(l10n.gameQuitTitle), findsOneWidget);
      }

      await openMenu();
      await tester.tap(find.text(l10n.settingsTitle));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text(l10n.settingsTitle), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await openMenu();
      await tester.tap(find.text(l10n.gameQuitTitle));
      await tester.pumpAndSettle();
      expect(find.text(l10n.gameQuitConfirm), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, l10n.gameQuitAction),
        findsOneWidget,
      );
      await tester.tap(find.text(l10n.menuCancel));
      await tester.pumpAndSettle();
      expect(container.read(musGameControllerProvider), same(state));
      expect(repo.closed, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('fermeture distante ramène les invités à l’accueil', (
    tester,
  ) async {
    await mount(tester, seat: 1);
    repo.events.add({'status': 'cancelled'});
    await tester.pumpAndSettle();
    expect(find.byType(MainDashboardScreen), findsOneWidget);
    expect(find.text('L’hôte a fermé le salon.'), findsOneWidget);
    expect(repo.closed, isEmpty);
    expect(container.read(musGameControllerProvider.notifier).gameId, isNull);
  });
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
