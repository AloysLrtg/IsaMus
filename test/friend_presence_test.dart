import 'package:isamus/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/auth_repository.dart';
import 'package:isamus/core/network/presence_service.dart';
import 'package:isamus/core/network/presence_session.dart';
import 'package:isamus/core/network/social_repository.dart';
import 'package:isamus/features/social/friends_tab.dart';
import 'package:isamus/main.dart';

import 'helpers/presence_fakes.dart';
import 'social_tabs_test.dart'
    show TabSocial, SocialAuth, actor, friend, blocked;

void main() {
  late PresenceTestClient client;
  late TabSocial social;
  setUp(() {
    client = PresenceTestClient();
    social = TabSocial();
  });
  tearDown(() async {
    await social.events.close();
    await social.blockEvents.close();
    await social.inviteEvents.close();
    await client.dispose();
  });
  testWidgets(
    'Ami : Hors ligne gris puis En ligne vert et pastille, sans changer d’onglet',
    (tester) async {
      social.rows = [
        {
          'id': 'accepted',
          'sender_id': actor,
          'receiver_id': friend,
          'status': 'accepted',
        },
        {
          'id': 'pending',
          'sender_id': actor,
          'receiver_id': blocked,
          'status': 'pending',
        },
      ];
      final c = ProviderContainer(
        overrides: [
          presenceClientProvider.overrideWithValue(client),
          authRepositoryProvider.overrideWithValue(SocialAuth()),
          socialRepositoryProvider.overrideWithValue(social),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: PresenceSessionHost(
            userId: actor,
            child: const MyApp(
              home: Scaffold(
                body: FriendsTab(userId: actor, username: 'Patxi'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(client.rooms.keys.toSet(), {
        'presence:$actor',
        'presence:$friend',
      });
      expect(find.text(testL10n.menuOffline), findsOneWidget);
      expect(find.byKey(ValueKey('friend-online-$friend')), findsNothing);
      final offline = tester
          .widget<Text>(find.text(testL10n.menuOffline))
          .style!
          .color;
      final peer = client.rooms['presence:$friend']!;
      peer.snapshot(friend, [false], event: 'join');
      await tester.pumpAndSettle();
      expect(c.read(onlineUsersProvider), contains(friend));
      expect(find.text(testL10n.menuOnline), findsOneWidget);
      expect(find.byKey(ValueKey('friend-online-$friend')), findsOneWidget);
      expect(
        tester.widget<Text>(find.text(testL10n.menuOnline)).style!.color,
        const Color(0xFF4ADE80),
      );
      expect(offline, isNot(const Color(0xFF4ADE80)));
      peer.snapshot(friend, [true]);
      await tester.pumpAndSettle();
      expect(find.text(testL10n.menuInAGame), findsOneWidget);
      peer.snapshot(friend, [], event: 'leave');
      await tester.pumpAndSettle();
      expect(find.text(testL10n.menuOffline), findsOneWidget);
      expect(find.byKey(ValueKey('friend-online-$friend')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
      await tester.pump();
      expect(client.removed, hasLength(2));
    },
  );
  testWidgets(
    'Présence de session : survit à la navigation et retire les anciens amis',
    (tester) async {
      social.rows = [
        {
          'id': 'friendship',
          'user_id_1': actor,
          'user_id_2': friend,
          'status': 'accepted',
        },
      ];
      final c = ProviderContainer(
        overrides: [
          presenceClientProvider.overrideWithValue(client),
          authRepositoryProvider.overrideWithValue(SocialAuth()),
          socialRepositoryProvider.overrideWithValue(social),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: PresenceSessionHost(
            userId: actor,
            child: const MyApp(home: Scaffold(body: Text('Accueil'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final self = client.rooms['presence:$actor']!,
          peer = client.rooms['presence:$friend']!;
      expect(self.tracked.single['user_id'], actor);
      final nav = Navigator.of(tester.element(find.text('Accueil')));
      nav.push<void>(
        MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Table'))),
      );
      await tester.pumpAndSettle();
      peer.snapshot(friend, [false]);
      await tester.pump();
      expect(c.read(onlineUsersProvider), contains(friend));
      expect(client.created, hasLength(2));
      social.rows = [];
      social.events.add([]);
      await tester.pumpAndSettle();
      expect(client.removed, contains(peer));
      expect(c.read(onlineUsersProvider), isNot(contains(friend)));
      peer.snapshot(friend, [true]);
      await tester.pump();
      expect(c.read(onlineUsersProvider), isNot(contains(friend)));
      nav.pop();
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const PresenceSessionHost(
            userId: null,
            child: MyApp(home: Scaffold(body: Text('Connexion'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(c.read(onlineUsersProvider), isEmpty);
      expect(client.removed, contains(self));
      expect(self.untracked, greaterThan(0));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
      await tester.pump();
    },
  );
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
