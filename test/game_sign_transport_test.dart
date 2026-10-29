import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isamus/core/network/game_sign_repository.dart';

class RecordingChannel implements RealtimeChannel {
  RecordingChannel(this.options, this.ready);
  final RealtimeChannelConfig options;
  final bool ready;
  void Function(Map<String, dynamic>)? receive;
  void Function(RealtimeSubscribeStatus, Object?)? status;
  String? eventName;
  final callbacks = <String, void Function(Map<String, dynamic>)>{};
  final sentNames = <String>[];
  final payloads = <Map<String, dynamic>>[];
  ChannelResponse response = ChannelResponse.ok;
  @override
  RealtimeChannel onBroadcast({
    required String event,
    required void Function(Map<String, dynamic>) callback,
  }) {
    callbacks[event] = callback;
    eventName = event;
    receive = callback;
    return this;
  }

  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus, Object?)? callback,
    Duration? timeout,
  ]) {
    status = callback;
    if (ready) callback?.call(RealtimeSubscribeStatus.subscribed, null);
    return this;
  }

  @override
  Future<ChannelResponse> sendBroadcastMessage({
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    sentNames.add(event);
    payloads.add(payload);
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class RecordingClient extends SupabaseClient {
  RecordingClient({this.ready = true}) : super('http://127.0.0.1', 'test-key');
  final bool ready;
  final channels = <String, RecordingChannel>{};
  final removed = <RealtimeChannel>[];
  @override
  RealtimeChannel channel(
    String name, {
    RealtimeChannelConfig opts = const RealtimeChannelConfig(),
  }) => channels.putIfAbsent(name, () => RecordingChannel(opts, ready));
  @override
  Future<String> removeChannel(RealtimeChannel channel) async {
    removed.add(channel);
    return 'ok';
  }
}

const host = '00000000-0000-4000-8000-000000000001';
const guest = '00000000-0000-4000-8000-000000000002';
void main() {
  test(
    'canaux privés par émetteur, payload éphémère et identité liée au topic',
    () async {
      final client = RecordingClient();
      final session = SupabaseGameSignSession(
        client,
        'room',
        authenticatedUserId: host,
      );
      try {
        session.updateRoster([
          {'id': host},
          {'id': guest},
          {'id': 'bot_1'},
        ]);
        session.updateRoster([
          {'id': host},
          {'id': guest},
          {'id': 'bot_1'},
        ]);
        expect(client.channels.length, 2);
        for (final channel in client.channels.values) {
          expect(channel.options.private, isTrue);
          expect(channel.options.ack, isTrue);
          expect(channel.options.self, isFalse);
          expect(channel.eventName, 'keinu');
        }
        const sign = SignBroadcast(
          senderId: host,
          seat: 0,
          sign: 'twoKings',
          handId: 'deal',
          id: 'gesture-1',
        );
        await session.send(sign);
        expect(client.channels['game-signs:room:$host']!.payloads.single, {
          'seat': 0,
          'sign': 'twoKings',
          'hand_id': 'deal',
          'id': 'gesture-1',
        });
        final next = session.events.first;
        client.channels['game-signs:room:$guest']!.receive!({
          'senderId': host,
          'seat': 1,
          'sign': 'blind',
          'hand_id': 'deal',
          'id': 'gesture-2',
        });
        expect((await next).senderId, guest);
      } finally {
        await session.close();
        await client.dispose();
      }
      expect(client.removed.length, 2);
    },
  );
  test(
    'absence de connexion ou d’ack : échec sans file d’attente différée',
    () async {
      final client = RecordingClient(ready: false);
      final session = SupabaseGameSignSession(
        client,
        'room',
        authenticatedUserId: host,
      );
      const sign = SignBroadcast(
        senderId: host,
        seat: 0,
        sign: 'twoKings',
        handId: 'deal',
        id: '1',
      );
      try {
        await expectLater(session.send(sign), throwsStateError);
        final channel = client.channels.values.single;
        expect(channel.payloads, isEmpty);
        channel.status?.call(RealtimeSubscribeStatus.subscribed, null);
        channel.response = ChannelResponse.error;
        await expectLater(session.send(sign), throwsStateError);
        expect(channel.payloads, hasLength(1));
      } finally {
        await session.close();
        await client.dispose();
      }
    },
  );
}
