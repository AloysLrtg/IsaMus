import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/presence_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/presence_fakes.dart';

void main() {
  late PresenceTestClient client;
  late PresenceService service;
  Set<String> online = {}, inGame = {};
  setUp(() {
    client = PresenceTestClient();
    online = {};
    inGame = {};
    service = PresenceService(
      clientInstance: client,
      onChanged: (o, g) {
        online = o;
        inGame = g;
      },
    );
  });
  tearDown(() async {
    service.dispose();
    await Future<void>.delayed(Duration.zero);
    await client.dispose();
  });
  testWidgets(
    'Présence explicitement activée et track authentifié après abonnement',
    (tester) async {
      await service.connect('me');
      await tester.pump();
      final self = client.rooms['presence:me']!;
      expect(self.options.enabled, isTrue);
      expect(self.options.private, isTrue);
      expect(self.sync, isNotNull);
      expect(self.join, isNotNull);
      expect(self.leave, isNotNull);
      expect(self.tracked.single, {'user_id': 'me', 'in_game': false});
      expect(online, {'me'});
      await service.setInGame(true);
      expect(self.tracked.last['in_game'], isTrue);
      expect(inGame, {'me'});
    },
  );
  testWidgets(
    'Sync/join/leave et plusieurs appareils maintiennent les amis en ligne',
    (tester) async {
      await service.connect('me');
      service.setFriends({'friend'});
      await tester.pump();
      final peer = client.rooms['presence:friend']!;
      expect(peer.tracked, isEmpty);
      peer.snapshot('friend', [false, true], event: 'join');
      expect(online, contains('friend'));
      expect(inGame, contains('friend'));
      peer.snapshot('friend', [false], event: 'leave');
      expect(online, contains('friend'));
      expect(inGame, isNot(contains('friend')));
      peer.snapshot('friend', [], event: 'leave');
      expect(online, isNot(contains('friend')));
      peer.snapshot('friend', [true]);
      expect(inGame, contains('friend'));
      peer.snapshot('forged', [true]);
      expect(online, isNot(contains('forged')));
      expect(online, isNot(contains('friend')));
    },
  );
  testWidgets(
    'Micro-coupure : état nettoyé et nouveau track après rejoin SDK',
    (tester) async {
      await service.connect('me');
      service.setFriends({'friend'});
      await tester.pump();
      final self = client.rooms['presence:me']!,
          peer = client.rooms['presence:friend']!;
      peer.snapshot('friend', [false]);
      await service.setInGame(true);
      self.state(RealtimeSubscribeStatus.channelError);
      peer.state(RealtimeSubscribeStatus.timedOut);
      expect(online, isEmpty);
      final count = self.tracked.length;
      self.state(RealtimeSubscribeStatus.subscribed);
      peer.state(RealtimeSubscribeStatus.subscribed);
      await tester.pump();
      expect(self.tracked.length, count + 1);
      expect(self.tracked.last, {'user_id': 'me', 'in_game': true});
      expect(online, isNot(contains('friend')));
      peer.snapshot('friend', [false]);
      expect(online, {'me', 'friend'});
      expect(client.created, hasLength(2));
    },
  );
  testWidgets('Fermeture terminale du canal : remplacement puis track', (
    tester,
  ) async {
    await service.connect('me');
    await tester.pump();
    final first = client.rooms['presence:me']!;
    first.state(RealtimeSubscribeStatus.closed);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    final second = client.rooms['presence:me']!;
    expect(second, same(client.created.last));
    expect(second, isNot(same(first)));
    expect(second.tracked.single['user_id'], 'me');
  });
  testWidgets('Track refusé : nouvelle tentative bornée sans boucle active', (
    tester,
  ) async {
    await service.connect('me');
    await tester.pump();
    final self = client.rooms['presence:me']!;
    self.response = ChannelResponse.error;
    await service.setInGame(true);
    final count = self.tracked.length;
    await tester.pump(const Duration(milliseconds: 999));
    expect(self.tracked.length, count);
    self.response = ChannelResponse.ok;
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(self.tracked.length, count + 1);
    expect(inGame, {'me'});
  });
  testWidgets(
    'Arrière-plan untrack, reprise track, déconnexion nettoie tous les canaux',
    (tester) async {
      await service.connect('me');
      service.setFriends({'friend'});
      await tester.pump();
      final self = client.rooms['presence:me']!,
          peer = client.rooms['presence:friend']!;
      service.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump();
      expect(self.untracked, 0);
      service.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();
      expect(self.untracked, 1);
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();
      expect(self.tracked, hasLength(2));
      await service.disconnect();
      expect(client.removed.toSet(), {self, peer});
      expect(online, isEmpty);
      final total = client.created.length;
      await tester.pump(const Duration(seconds: 20));
      expect(client.created.length, total);
    },
  );
  testWidgets(
    'Changement de compte et retrait d’amitié ignorent les anciens événements',
    (tester) async {
      await service.connect('me');
      service.setFriends({'friend'});
      await tester.pump();
      final old = client.rooms['presence:friend']!;
      service.setFriends({});
      old.snapshot('friend', [true]);
      expect(online, isNot(contains('friend')));
      await service.connect('new-user');
      await tester.pump();
      expect(online, {'new-user'});
      expect(inGame, isEmpty);
      old.state(RealtimeSubscribeStatus.subscribed);
      old.snapshot('friend', [true]);
      await tester.pump();
      expect(online, {'new-user'});
    },
  );
}
