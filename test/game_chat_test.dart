import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/network/game_sign_repository.dart';
import 'package:isamus/core/network/table_chat_event.dart';

import 'helpers/game_sign_fakes.dart';
import 'game_sign_transport_test.dart' show RecordingClient, host, guest;

void main() {
  test(
    'Chat privé sur le canal existant : identité du topic et payload borné',
    () async {
      final client = RecordingClient();
      final session = SupabaseGameSignSession(
        client,
        'room',
        authenticatedUserId: host,
      );
      session.updateRoster([
        {'id': host},
        {'id': guest},
      ]);
      final remote = session.chatEvents.first;
      client.channels['game-signs:room:$guest']!.callbacks['table_chat']!({
        'seat': 1,
        'id': 'message-1',
        'body': 'Bonjour !',
        'kind': 'text',
        'senderId': host,
      });
      expect((await remote).senderId, guest);
      const event = TableChatEvent(
        senderId: host,
        seat: 0,
        id: 'out-1',
        body: 'Salut',
      );
      await session.sendChat(event);
      expect(
        client.channels['game-signs:room:$host']!.sentNames.last,
        'table_chat',
      );
      expect(
        client.channels['game-signs:room:$host']!.payloads.single,
        event.toJson(),
      );
      expect(event.toJson().containsKey('senderId'), isFalse);
      await session.close();
      expect(client.removed.length, 2);
      await expectLater(session.sendChat(event), throwsStateError);
      await client.dispose();
    },
  );
  test('Messages vides, surdimensionnés ou mal formés rejetés', () {
    for (final body in ['', 'a' * 161, '\nBonjour']) {
      expect(
        TableChatEvent.parse(guest, {
          'seat': 1,
          'id': 'm',
          'body': body,
          'kind': 'text',
        }),
        isNull,
      );
    }
    expect(
      TableChatEvent.parse(guest, {
        'seat': 4,
        'id': 'm',
        'body': 'Salut',
        'kind': 'text',
      }),
      isNull,
    );
    expect(
      TableChatEvent.parse(guest, {
        'seat': 1,
        'id': '',
        'body': 'Salut',
        'kind': 'text',
      }),
      isNull,
    );
    expect(TableChatEvent.normalize('  Salut\n à\t tous  '), 'Salut à tous');
  });
  test(
    'Canal non prêt : aucun envoi HTTP ni message affiché comme reçu',
    () async {
      final client = RecordingClient(ready: false);
      final session = SupabaseGameSignSession(
        client,
        'room',
        authenticatedUserId: host,
      );
      await expectLater(
        session.sendChat(
          const TableChatEvent(senderId: host, seat: 0, id: 'm', body: 'Salut'),
        ),
        throwsStateError,
      );
      expect(client.channels.values.single.payloads, isEmpty);
      await session.close();
      await client.dispose();
    },
  );
  test(
    'Contrôleur : chat éphémère, sans changement de version ni écriture games',
    () async {
      final session = FakeSignSession();
      final repo = SignGameRepository();
      final container = ProviderContainer(
        overrides: [
          gameSignRepositoryProvider.overrideWithValue(
            FakeSignRepository(session),
          ),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
        ],
      );
      final controller = container.read(musGameControllerProvider.notifier);
      controller.configureMultiplayer(
        gameId: 'room',
        localSeat: 0,
        repository: repo,
        players: [
          {'id': host, 'seat': 0},
          {'id': guest, 'seat': 1},
          {'id': 'bot_2', 'seat': 2, 'is_bot': true},
          {'id': 'bot_3', 'seat': 3, 'is_bot': true},
        ],
      );
      final before = container.read(musGameControllerProvider);
      await controller.sendTextChat('  Bonjour à tous !  ');
      await controller.sendQuickChat(0, QuickChat.aupa);
      expect(session.sentChats.length, 2);
      expect(session.sentChats.first.body, 'Bonjour à tous !');
      expect(session.sentChats.last.quick, isTrue);
      expect(
        identical(container.read(musGameControllerProvider), before),
        isTrue,
      );
      expect(repo.pushed, isEmpty);
      final remote = TableChatEvent(
        senderId: guest,
        seat: 1,
        id: 'in-1',
        body: 'Salut !',
      );
      session.incomingChat.add(remote);
      session.incomingChat.add(remote);
      session.incomingChat.add(
        const TableChatEvent(
          senderId: guest,
          seat: 0,
          id: 'spoof',
          body: 'Faux hôte',
        ),
      );
      session.incomingChat.add(
        const TableChatEvent(
          senderId: guest,
          seat: 2,
          id: 'bot',
          body: 'Faux bot',
        ),
      );
      session.incomingChat.add(
        const TableChatEvent(
          senderId: guest,
          seat: 1,
          id: 'bad-quick',
          body: 'unknown',
          quick: true,
        ),
      );
      expect(container.read(musTableFeedbackProvider).chatHistory.length, 3);
      expect(
        container.read(musTableFeedbackProvider).speeches[1]!.text,
        'Salut !',
      );
      await expectLater(
        controller.sendQuickChat(1, QuickChat.aupa),
        throwsStateError,
      );
      session.failChat = true;
      await expectLater(
        controller.sendTextChat('Non transmis'),
        throwsStateError,
      );
      expect(container.read(musTableFeedbackProvider).chatHistory.length, 3);
      controller.disconnectSignChannel();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(musTableFeedbackProvider).chatHistory, isEmpty);
      expect(session.closed, isTrue);
      container.dispose();
    },
  );
  test('Historique limité à 40 messages, conservé entre les donnes', () async {
    final c = ProviderContainer();
    final feedback = c.read(musTableFeedbackProvider.notifier);
    for (var i = 0; i < 60; i++) {
      feedback.say(0, TableSpeech(SpeechKind.freeChat, text: 'Message $i'));
    }
    expect(c.read(musTableFeedbackProvider).chatHistory.length, 40);
    expect(
      c.read(musTableFeedbackProvider).chatHistory.first.speech.text,
      'Message 20',
    );
    feedback.clearSpeeches();
    expect(c.read(musTableFeedbackProvider).chatHistory.length, 40);
    c.dispose();
  });
  test('Onze phrases gratuites réparties entre les trois catégories', () {
    expect(QuickChat.values.where((q) => q.shopItemId == null).length, 11);
    for (final cat in QuickChatCategory.values) {
      expect(
        QuickChat.values
            .where((q) => q.category == cat && q.shopItemId == null)
            .length,
        greaterThanOrEqualTo(3),
      );
    }
  });
}
