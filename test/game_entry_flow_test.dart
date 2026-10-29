import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/network/auth_repository.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/features/home/lobby_screen.dart';
import 'package:isamus/features/home/main_dashboard_screen.dart';
import 'package:isamus/main.dart';

class EntryRepository implements SupabaseRepository {
  final events = StreamController<Map<String, dynamic>>.broadcast();
  final pushed = <Map<String, dynamic>>[];
  final cancelled = <String>[];
  final teams = <int>[];
  int starts = 0;
  bool failCancel = false;
  @override
  Stream<Map<String, dynamic>> streamGame(String id) => events.stream;
  @override
  Future<void> updateGameState(String id, Map<String, dynamic> state) async {
    pushed.add(state);
  }

  @override
  Future<void> leavePublicQueue(String id) async {
    if (failCancel) throw Exception('already ready');
    cancelled.add(id);
  }

  @override
  Future<void> choosePrivateTeam(String id, int team) async {
    teams.add(team);
  }

  @override
  Future<void> startPrivateGame(String id) async {
    starts++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class EntryAuth implements AuthRepository {
  EntryAuth(this.uid);
  final String uid;
  @override
  String? get currentUserId => uid;
  @override
  Future<String> signInAnonymously() async => uid;
  @override
  Future<Map<String, dynamic>?> getProfile(String id) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<Map<String, dynamic>> roster(int count) => List.generate(
  count,
  (seat) => {
    'id': 'user-$seat',
    'name': 'Joueur $seat',
    'seat': seat,
    'team': seat % 2,
    'is_host': seat == 0,
    'is_bot': false,
  },
);
Map<String, dynamic> snapshot(
  List<dynamic> players, {
  bool public = true,
  String status = 'waiting',
}) => {
  'id': 'room',
  'join_code': 'ABCDE',
  'is_public': public,
  'mode': public ? 'casual' : 'private',
  'status': status,
  'players': players,
};
void main() {
  late EntryRepository repo;
  late ProviderContainer container;
  Future<void> mount(
    WidgetTester tester,
    Widget screen, {
    String uid = 'user-0',
  }) async {
    repo = EntryRepository();
    container = ProviderContainer(
      overrides: [
        supabaseRepositoryProvider.overrideWithValue(repo),
        authRepositoryProvider.overrideWithValue(EntryAuth(uid)),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await repo.events.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MyApp(home: screen),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets(
    'Public : attente sur la table puis disparition à quatre humains',
    (tester) async {
      final two = roster(2);
      await mount(
        tester,
        GameScreen(
          gameId: 'room',
          localSeat: 1,
          userId: 'user-1',
          players: two,
          publicMatchmaking: true,
          initialGame: snapshot(two),
        ),
        uid: 'user-1',
      );
      expect(find.text('En attente des joueurs (2/4)'), findsOneWidget);
      expect(find.text('Temps écoulé : 0:00'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(LobbyScreen), findsNothing);
      repo.events.add(snapshot(roster(3)));
      await tester.pump();
      expect(find.text('En attente des joueurs (3/4)'), findsOneWidget);
      repo.events.add(snapshot(roster(4), status: 'ready'));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('public-queue-overlay')), findsNothing);
      expect(repo.pushed, isEmpty); // Seat 1 is a guest, not the dealer.
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Public : Annuler quitte la file et purge le contrôleur', (
    tester,
  ) async {
    final two = roster(2);
    await mount(
      tester,
      GameScreen(
        gameId: 'room',
        localSeat: 1,
        userId: 'user-1',
        players: two,
        publicMatchmaking: true,
        initialGame: snapshot(two),
      ),
      uid: 'user-1',
    );
    final previous = container.read(musGameControllerProvider);
    await tester.tap(find.byKey(const ValueKey('cancel-public-queue')));
    await tester.pumpAndSettle();
    expect(repo.cancelled, ['room']);
    expect(find.byType(MainDashboardScreen), findsOneWidget);
    expect(find.byType(GameScreen), findsNothing);
    expect(
      identical(previous, container.read(musGameControllerProvider)),
      isFalse,
    );
  });
  testWidgets(
    'Public : une annulation refusée ne quitte pas une partie devenue prête',
    (tester) async {
      final two = roster(2);
      await mount(
        tester,
        GameScreen(
          gameId: 'room',
          localSeat: 1,
          players: two,
          publicMatchmaking: true,
          initialGame: snapshot(two),
        ),
        uid: 'user-1',
      );
      await tester.pump(const Duration(seconds: 2));
      repo.failCancel = true;
      await tester.tap(find.byKey(const ValueKey('cancel-public-queue')));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('Annulation impossible'), findsOneWidget);
      expect(find.byType(GameScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Temps écoulé : 0:03'), findsOneWidget);
      repo.events.add(snapshot(roster(4), status: 'ready'));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('public-queue-overlay')), findsNothing);
      expect(repo.cancelled, isEmpty);
    },
  );
  testWidgets(
    'Privé : quatre joueurs attendent le lancement et peuvent encore choisir leur équipe',
    (tester) async {
      await mount(
        tester,
        const LobbyScreen(gameId: 'room', playerName: 'Joueur 0'),
      );
      final players = roster(4);
      repo.events.add(snapshot(players, public: false));
      await tester.pumpAndSettle();
      expect(find.byType(LobbyScreen), findsOneWidget);
      final start = find.byKey(const ValueKey('private-start-game'));
      await tester.ensureVisible(start);
      expect(tester.widget<FilledButton>(start).onPressed, isNotNull);
      final join = find.byKey(const ValueKey('join-private-team-1'));
      await tester.ensureVisible(join);
      await tester.tap(join);
      await tester.pumpAndSettle();
      expect(repo.teams, [1]);
      players[0] = {...players[0], 'team': 1};
      repo.events.add(snapshot(players, public: false));
      await tester.pumpAndSettle();
      final teamB = find.byKey(const ValueKey('lobby-team-1'));
      expect(
        find.descendant(of: teamB, matching: find.text('Joueur 0')),
        findsOneWidget,
      );
      expect(find.text('Équipe B · 3/2'), findsOneWidget);
      expect(tester.widget<FilledButton>(start).onPressed, isNull);
      // Another human moves to A: the server will seat the host in B when starting.
      players[1] = {...players[1], 'team': 0};
      repo.events.add(snapshot(players, public: false));
      await tester.pumpAndSettle();
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(repo.starts, 1);
      expect(
        find.byType(LobbyScreen),
        findsOneWidget,
      ); // Await authoritative ready status.
      final seated = players
          .map(
            (p) => {
              ...p,
              'seat': switch (p['id']) {
                'user-0' => 1,
                'user-1' => 0,
                'user-2' => 2,
                _ => 3,
              },
            },
          )
          .toList();
      repo.events.add(snapshot(seated, public: false, status: 'ready'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(find.byType(GameScreen), findsOneWidget);
      expect(tester.widget<GameScreen>(find.byType(GameScreen)).localSeat, 1);
      expect(container.read(musGameControllerProvider.notifier).isHost, isTrue);
      expect(repo.pushed, isNotEmpty);
      expect(repo.pushed.first['lastActionSeat'], 1);
    },
  );
  testWidgets('Public : transfert de l’hôte au siège 1 pendant l’attente', (
    tester,
  ) async {
    final initial = roster(3);
    await mount(
      tester,
      GameScreen(
        gameId: 'room',
        localSeat: 1,
        players: initial,
        publicMatchmaking: true,
        initialGame: snapshot(initial),
      ),
      uid: 'user-1',
    );
    final remaining = [
      {...initial[1], 'is_host': true},
      initial[2],
    ];
    repo.events.add(snapshot(remaining));
    await tester.pump();
    await tester.pump();
    final controller = container.read(musGameControllerProvider.notifier);
    expect(controller.hostSeat, 1);
    expect(controller.isHost, isTrue);
    expect(find.text('En attente des joueurs (2/4)'), findsOneWidget);
    repo.events.add(
      snapshot([
        remaining[0],
        remaining[1],
        {...initial[0], 'is_host': false},
        roster(4)[3],
      ], status: 'ready'),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('public-queue-overlay')), findsNothing);
    expect(repo.pushed, isNotEmpty);
    expect(repo.pushed.first['lastActionSeat'], 1);
  });
  testWidgets(
    'Créateur : compteur 1→2 sans état de jeu et chronomètre non réinitialisé',
    (tester) async {
      final one = roster(1);
      await mount(
        tester,
        GameScreen(
          gameId: 'room',
          localSeat: 0,
          players: one,
          publicMatchmaking: true,
          initialGame: snapshot(one),
        ),
      );
      expect(find.text('En attente des joueurs (1/4)'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Temps écoulé : 0:03'), findsOneWidget);
      repo.events.add(snapshot(roster(2)));
      await tester.pump();
      await tester.pump();
      expect(find.text('En attente des joueurs (2/4)'), findsOneWidget);
      expect(find.text('Temps écoulé : 0:03'), findsOneWidget);
      await tester.pump(const Duration(seconds: 60));
      expect(find.text('Temps écoulé : 1:03'), findsOneWidget);
      repo.events.add(snapshot(roster(4), status: 'ready'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('queue-elapsed-time')), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(repo.events.hasListener, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Recherche : retrait de l’écran libère flux et timer', (
    tester,
  ) async {
    final one = roster(1);
    await mount(
      tester,
      GameScreen(
        gameId: 'room',
        players: one,
        publicMatchmaking: true,
        initialGame: snapshot(one),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Temps écoulé : 0:02'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(repo.events.hasListener, isFalse);
    repo.events.add(snapshot(roster(2)));
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });
  test('Autorité : le siège zéro invité ne devient pas hôte', () {
    repo = EntryRepository();
    container = ProviderContainer(
      overrides: [
        supabaseRepositoryProvider.overrideWithValue(repo),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await repo.events.close();
    });
    final players = roster(4);
    players[0] = {...players[0], 'seat': 1};
    players[1] = {...players[1], 'seat': 0};
    final controller = container.read(musGameControllerProvider.notifier);
    controller.configureMultiplayer(
      gameId: 'room',
      localSeat: 0,
      players: players,
    );
    expect(controller.hostSeat, 1);
    expect(controller.isHost, isFalse);
    controller.startGame();
    expect(repo.pushed, isEmpty);
  });
}
