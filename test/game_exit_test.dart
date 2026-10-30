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
  Future<void> mount(WidgetTester tester, {int seat = 0}) async {
    repo = ExitRepository();
    container = ProviderContainer(
      overrides: [
        supabaseRepositoryProvider.overrideWithValue(repo),
        authRepositoryProvider.overrideWithValue(ExitAuth()),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
      ],
    );
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
    await tester.tap(find.text('Quitter la partie'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Voulez-vous vraiment quitter la partie ?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Quitter'));
    await tester.pumpAndSettle();
  }

  testWidgets('annuler conserve la partie sans fermeture', (tester) async {
    await mount(tester);
    final state = container.read(musGameControllerProvider);
    await tester.tap(find.byKey(const ValueKey('game-menu-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Quitter la partie'));
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
    expect(
      find.textContaining('Impossible de fermer le salon'),
      findsOneWidget,
    );
    repo.fail = false;
    await confirm(tester);
    expect(repo.closed, ['game']);
    expect(find.byType(MainDashboardScreen), findsOneWidget);
  });
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
