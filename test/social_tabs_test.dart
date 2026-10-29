import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/auth_repository.dart';
import 'package:isamus/core/network/social_repository.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/features/social/friends_tab.dart';
import 'package:isamus/features/profile/player_inspection_dialog.dart';
import 'package:isamus/main.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:isamus/core/models/game_invitation_mode.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/features/home/lobby_screen.dart';

const actor = '00000000-0000-4000-8000-000000000001';
const friend = '00000000-0000-4000-8000-000000000002';
const blocked = '00000000-0000-4000-8000-000000000003';

class SocialAuth implements AuthRepository {
  @override
  String? get currentUserId => actor;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class InviteGames implements SupabaseRepository {
  InviteGames(this.social);
  final TabSocial social;
  @override
  Stream<Map<String, dynamic>> streamGame(String id) =>
      Stream.value(social.game!);
  @override
  Future<void> updateGameState(String id, Map<String, dynamic> state) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TabSocial extends SocialRepository {
  List<Map<String, dynamic>> rows = [], blocks = [];
  final events = StreamController<List<Map<String, dynamic>>>.broadcast(),
      blockEvents = StreamController<List<Map<String, dynamic>>>.broadcast();
  String? accepted, refused, unblocked, blockedTarget, removed;
  List<Map<String, dynamic>> invites = [];
  final inviteEvents = StreamController<List<Map<String, dynamic>>>.broadcast();
  Map<String, dynamic>? game;
  final createdModes = <String>[],
      acceptedInvites = <String>[],
      declinedInvites = <String>[];
  @override
  Stream<List<Map<String, dynamic>>> invitations() async* {
    yield invites;
    yield* inviteEvents.stream;
  }

  @override
  Future<Map<String, dynamic>> createModeInvitation(
    String id,
    String mode,
  ) async {
    createdModes.add(mode);
    return game = {
      'id': 'duo-room',
      'mode': mode,
      'status': 'waiting',
      'is_public': mode != 'private',
      'local_seat': 0,
      'join_code': 'DUO12',
      'players': [
        {
          'id': actor,
          'name': 'Patxi',
          'seat': 0,
          'is_host': true,
          'is_bot': false,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> acceptGameInvitation(String id) async {
    acceptedInvites.add(id);
    invites = [];
    inviteEvents.add(invites);
    return game!;
  }

  @override
  Future<void> decline(String id) async {
    declinedInvites.add(id);
    invites = [];
    inviteEvents.add(invites);
  }

  @override
  String get userId => actor;
  @override
  Stream<List<Map<String, dynamic>>> friendships() async* {
    yield rows;
    yield* events.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> blockedUsers() async* {
    yield blocks;
    yield* blockEvents.stream;
  }

  @override
  Future<List<Map<String, dynamic>>> search(String query) async => [
    {'id': friend, 'username': 'Ane', 'elo': 1200},
  ];
  @override
  Future<Map<String, dynamic>> person(String id) async => {
    'id': id,
    'username': id == friend ? 'Ane' : 'Mikel',
  };
  @override
  Stream<String> presence(String id) => Stream.value('En ligne');
  @override
  Future<void> request(String id) async {
    rows = [
      {'id': 'out', 'user_id_1': actor, 'user_id_2': id, 'status': 'pending'},
    ];
    events.add(rows);
  }

  @override
  Future<void> accept(String id) async {
    accepted = id;
    rows = rows.where((r) => r['id'] != id).toList();
    events.add(rows);
  }

  @override
  Future<void> declineRequest(String id) async {
    refused = id;
    rows = rows.where((r) => r['id'] != id).toList();
    events.add(rows);
  }

  @override
  Future<void> remove(String id) async {
    removed = id;
    rows = rows.where((r) => r['id'] != id).toList();
    events.add(rows);
  }

  @override
  Future<void> unblock(String id) async {
    unblocked = id;
    blocks = blocks.where((b) => b['blocked_id'] != id).toList();
    blockEvents.add(blocks);
  }

  @override
  Future<void> block(String id) async {
    blockedTarget = id;
    blocks = [
      {'blocker_id': actor, 'blocked_id': id},
    ];
    rows = [];
    blockEvents.add(blocks);
    events.add(rows);
  }
}

void main() {
  late TabSocial repo;
  Future<void> mount(
    WidgetTester tester, {
    bool modal = false,
    DateTime Function()? now,
  }) async {
    addTearDown(() async {
      await repo.events.close();
      await repo.blockEvents.close();
      await repo.inviteEvents.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(SocialAuth()),
          if (now != null) invitationClockProvider.overrideWithValue(now),
          socialRepositoryProvider.overrideWithValue(repo),
          supabaseRepositoryProvider.overrideWithValue(InviteGames(repo)),
          publicPlayerProfileProvider(friend)
              .overrideWith((ref) async => {'username': 'Ane', 'elo': 1200}),
        ],
        child: MyApp(
          home: Scaffold(
            body: modal
                ? Builder(
                    builder: (context) => TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) =>
                            const PlayerInspectionDialog(userId: friend),
                      ),
                      child: const Text('Profil'),
                    ),
                  )
                : const FriendsTab(userId: actor, username: 'Patxi'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Demandes : un ID répété dans Realtime ne produit qu’une carte', (
    tester,
  ) async {
    repo = TabSocial();
    final request = {
      'id': 'duplicate',
      'user_id_1': friend,
      'user_id_2': actor,
      'status': 'pending',
    };
    repo.rows = [request, Map.of(request), Map.of(request)];
    await mount(tester);
    await tester.tap(find.text('Demandes'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('friend-request-duplicate')),
      findsOneWidget,
    );
    expect(find.text('Demande reçue'), findsOneWidget);
    repo.rows = [
      request,
      {...request, 'status': 'accepted'},
    ];
    repo.events.add(repo.rows);
    await tester.pump();
    await tester.pump();
    expect(
      find.byKey(const ValueKey('friend-request-duplicate')),
      findsNothing,
    );
  });
  for (final mode in GameInvitationMode.values) {
    testWidgets('Choix ${mode.value} : invitation spécifique et bon écran', (
      tester,
    ) async {
      repo = TabSocial();
      repo.rows = [
        {
          'id': 'accepted',
          'user_id_1': actor,
          'user_id_2': friend,
          'status': 'accepted',
        },
      ];
      await mount(tester);
      await tester.tap(find.byTooltip('Inviter à jouer'));
      await tester.pumpAndSettle();
      for (final option in GameInvitationMode.values) {
        expect(find.text(option.title), findsOneWidget);
      }
      final selected = find.byKey(ValueKey('invite-mode-${mode.value}'));
      await tester.ensureVisible(selected);
      await tester.tap(selected);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(repo.createdModes, [mode.value]);
      expect(
        find.byType(mode.isPublic ? GameScreen : LobbyScreen),
        findsOneWidget,
      );
      if (mode.isPublic) {
        expect(
          tester.widget<GameScreen>(find.byType(GameScreen)).publicMatchmaking,
          isTrue,
        );
        expect(
          find.byKey(const ValueKey('public-queue-overlay')),
          findsOneWidget,
        );
      }
    });
    testWidgets('Invitation reçue ${mode.value} : rejoindre le bon flux', (
      tester,
    ) async {
      repo = TabSocial();
      repo.invites = [
        {
          'id': 'incoming',
          'sender_id': friend,
          'recipient_id': actor,
          'game_id': 'duo-room',
          'mode': mode.value,
          'status': 'pending',
          'expires_at': DateTime.now()
              .add(const Duration(minutes: 5))
              .toIso8601String(),
        },
      ];
      repo.game = {
        'id': 'duo-room',
        'mode': mode.value,
        'is_public': mode.isPublic,
        'status': 'waiting',
        'join_code': 'DUO12',
        'local_seat': mode.isPublic ? 2 : 1,
        'players': [
          {
            'id': friend,
            'name': 'Ane',
            'seat': 0,
            'is_host': true,
            'is_bot': false,
          },
          {
            'id': actor,
            'name': 'Patxi',
            'seat': mode.isPublic ? 2 : 1,
            'is_host': false,
            'is_bot': false,
          },
        ],
      };
      await mount(tester);
      expect(
        find.text('Ane vous invite à jouer en ${mode.label}'),
        findsOneWidget,
      );
      await tester.tap(find.text('Rejoindre'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(repo.acceptedInvites, ['incoming']);
      expect(
        find.byType(mode.isPublic ? GameScreen : LobbyScreen),
        findsOneWidget,
      );
      if (mode.isPublic) {
        expect(tester.widget<GameScreen>(find.byType(GameScreen)).localSeat, 2);
      }
    });
  }
  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('Choix du mode à $size sans débordement', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      repo = TabSocial();
      repo.rows = [
        {
          'id': 'accepted',
          'user_id_1': actor,
          'user_id_2': friend,
          'status': 'accepted',
        },
      ];
      await mount(tester);
      await tester.tap(find.byTooltip('Inviter à jouer'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('invite-mode-ranked')),
      );
      await tester.pumpAndSettle();
      expect(find.text('En Ligne (Classé) en Duo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Une invitation persistante disparaît à son expiration', (
    tester,
  ) async {
    var clock = DateTime.utc(2026, 10, 29, 12);
    repo = TabSocial();
    repo.invites = [
      {
        'id': 'expire',
        'sender_id': friend,
        'recipient_id': actor,
        'game_id': 'duo-room',
        'mode': 'casual',
        'status': 'pending',
        'expires_at': clock.add(const Duration(seconds: 2)).toIso8601String(),
      },
    ];
    await mount(tester, now: () => clock);
    expect(find.text('Rejoindre'), findsOneWidget);
    clock = clock.add(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Rejoindre'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Rejoindre ne réinitialise pas la table déjà ouverte', (
    tester,
  ) async {
    repo = TabSocial();
    repo.invites = [
      {
        'id': 'already',
        'sender_id': friend,
        'recipient_id': actor,
        'game_id': 'duo-room',
        'mode': 'casual',
        'status': 'pending',
        'expires_at': DateTime.now()
            .add(const Duration(minutes: 5))
            .toIso8601String(),
      },
    ];
    await mount(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FriendsTab)),
    );
    container
        .read(musGameControllerProvider.notifier)
        .configureMultiplayer(gameId: 'duo-room', localSeat: 0);
    await tester.tap(find.text('Rejoindre'));
    await tester.pumpAndSettle();
    expect(repo.acceptedInvites, isEmpty);
    expect(
      find.textContaining('Quittez votre partie actuelle'),
      findsOneWidget,
    );
  });
  testWidgets('Décliner ferme la bannière et ne rejoint aucun salon', (
    tester,
  ) async {
    repo = TabSocial();
    repo.invites = [
      {
        'id': 'incoming',
        'sender_id': friend,
        'recipient_id': actor,
        'game_id': 'duo-room',
        'mode': 'ranked',
        'status': 'pending',
        'expires_at': DateTime.now()
            .add(const Duration(minutes: 5))
            .toIso8601String(),
      },
    ];
    await mount(tester);
    await tester.tap(find.text('Décliner'));
    await tester.pumpAndSettle();
    expect(repo.declinedInvites, ['incoming']);
    expect(find.text('Rejoindre'), findsNothing);
    expect(find.byType(GameScreen), findsNothing);
  });
  testWidgets('Fermer le choix de mode ne crée aucune invitation', (
    tester,
  ) async {
    repo = TabSocial();
    repo.rows = [
      {
        'id': 'accepted',
        'user_id_1': actor,
        'user_id_2': friend,
        'status': 'accepted',
      },
    ];
    await mount(tester);
    await tester.tap(find.byTooltip('Inviter à jouer'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(repo.createdModes, isEmpty);
    await tester.tap(find.byTooltip('Inviter à jouer'));
    await tester.pumpAndSettle();
    expect(find.text('Créer un Salon Privé'), findsOneWidget);
  });

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('Onglets sociaux et demandes pleine largeur à $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      repo = TabSocial();
      repo.rows = [
        {
          'id': 'in',
          'user_id_1': friend,
          'user_id_2': actor,
          'status': 'pending',
        },
      ];
      repo.blocks = [
        {'blocker_id': actor, 'blocked_id': blocked},
      ];
      await mount(tester);
      expect(find.byType(DefaultTabController), findsOneWidget);
      expect(find.text('Rechercher un pseudo'), findsOneWidget);
      await tester.tap(find.text('Demandes'));
      await tester.pumpAndSettle();
      final card = find.byKey(const ValueKey('friend-request-in'));
      expect(tester.getSize(card).width, closeTo(size.width - 32, .1));
      expect(find.text('Accepter'), findsOneWidget);
      expect(find.text('Refuser'), findsOneWidget);
      expect(
        tester.getRect(find.text('Accepter')).right,
        lessThanOrEqualTo(tester.getRect(card).right),
      );
      await tester.tap(find.text('Bloqués'));
      await tester.pumpAndSettle();
      expect(find.text('Mikel'), findsOneWidget);
      final unblock = find.widgetWithText(TextButton, 'Débloquer');
      await tester.ensureVisible(unblock);
      await tester.tap(unblock);
      await tester.pumpAndSettle();
      expect(repo.unblocked, blocked);
      expect(find.text('Aucun joueur bloqué.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Un ami confirmé garde les actions inviter et retirer', (
    tester,
  ) async {
    repo = TabSocial();
    repo.rows = [
      {
        'id': 'accepted',
        'user_id_1': actor,
        'user_id_2': friend,
        'status': 'accepted',
      },
    ];
    await mount(tester);
    expect(find.byTooltip('Inviter à jouer'), findsOneWidget);
    await tester.tap(find.byTooltip('Options de l’ami'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retirer de mes amis'));
    await tester.pumpAndSettle();
    expect(repo.removed, 'accepted');
  });
  testWidgets('Accepter puis refuser les demandes reçues', (tester) async {
    repo = TabSocial();
    repo.rows = [
      for (final id in ['one', 'two'])
        {
          'id': id,
          'user_id_1': friend,
          'user_id_2': actor,
          'status': 'pending',
        },
    ];
    await mount(tester);
    await tester.tap(find.text('Demandes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accepter').first);
    await tester.pumpAndSettle();
    expect(repo.accepted, 'one');
    await tester.tap(find.text('Refuser'));
    await tester.pumpAndSettle();
    expect(repo.refused, 'two');
    expect(find.text('Aucune demande en attente.'), findsOneWidget);
  });
  testWidgets('Bannière verte après envoi et disparition automatique', (
    tester,
  ) async {
    repo = TabSocial();
    await mount(tester);
    await tester.enterText(find.byType(TextField), 'Ane');
    await tester.tap(find.byTooltip('Rechercher'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Demander en ami'));
    await tester.pumpAndSettle();
    expect(find.text('Demande d’amitié envoyée'), findsOneWidget);
    expect(
      tester
          .widget<Material>(find.byKey(const ValueKey('social-banner')))
          .color,
      Colors.green.shade700,
    );
    await tester.pump(const Duration(seconds: 4));
    expect(find.byKey(const ValueKey('social-banner')), findsNothing);
  });
  testWidgets('Bannière bleue uniquement pour une nouvelle demande reçue', (
    tester,
  ) async {
    repo = TabSocial();
    repo.rows = [
      {
        'id': 'old',
        'user_id_1': friend,
        'user_id_2': actor,
        'status': 'pending',
      },
    ];
    await mount(tester);
    expect(find.byKey(const ValueKey('social-banner')), findsNothing);
    repo.rows = [
      ...repo.rows,
      {
        'id': 'new',
        'user_id_1': blocked,
        'user_id_2': actor,
        'status': 'pending',
      },
    ];
    repo.events.add(repo.rows);
    await tester.pump();
    await tester.pump();
    expect(find.text('Nouvelle demande d’amitié reçue'), findsOneWidget);
    expect(
      tester
          .widget<Material>(find.byKey(const ValueKey('social-banner')))
          .color,
      Colors.blue.shade700,
    );
    await tester.pump(const Duration(seconds: 3));
    repo.events.add(repo.rows);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const ValueKey('social-banner')), findsNothing);
  });
  testWidgets('La carte joueur confirme le blocage et permet de le révoquer', (
    tester,
  ) async {
    repo = TabSocial();
    await mount(tester, modal: true);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('block-player-button'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Bloquer'));
    await tester.pumpAndSettle();
    expect(repo.blockedTarget, friend);
    expect(find.widgetWithText(FilledButton, 'Joueur bloqué'), findsOneWidget);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(repo.unblocked, friend);
    expect(find.text('Ajouter en ami'), findsOneWidget);
  });
}
