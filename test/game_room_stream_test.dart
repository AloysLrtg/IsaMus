import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomChannel implements RealtimeChannel {
  void Function(RealtimeSubscribeStatus, Object?)? status;
  void Function(PostgresChangePayload)? changed;
  PostgresChangeFilter? recordedFilter;
  String? recordedTable;
  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus, Object?)? callback,
    Duration? timeout,
  ]) {
    status = callback;
    return this;
  }

  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    PostgresChangeFilter? filter,
    List<PostgresChangeFilter>? filters,
    List<String>? select,
    required void Function(PostgresChangePayload) callback,
  }) {
    expect(event, PostgresChangeEvent.update);
    expect(schema, 'public');
    recordedTable = table;
    recordedFilter = filter;
    changed = callback;
    return this;
  }

  void emit(Map<String, dynamic> row) => changed!(
    PostgresChangePayload(
      schema: 'public',
      table: 'games',
      commitTimestamp: DateTime.now(),
      eventType: PostgresChangeEvent.update,
      newRecord: row,
      oldRecord: {},
      errors: null,
    ),
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class RoomClient extends SupabaseClient {
  RoomClient(super.url, super.key);
  final room = RoomChannel();
  int removed = 0;
  @override
  RealtimeChannel channel(
    String name, {
    RealtimeChannelConfig opts = const RealtimeChannelConfig(),
  }) => room;
  @override
  Future<String> removeChannel(RealtimeChannel channel) async {
    expect(channel, same(room));
    removed++;
    return 'ok';
  }
}

Map<String, dynamic> row(int count) => {
  'id': 'room',
  'status': count == 4 ? 'ready' : 'waiting',
  'players': List.generate(count, (i) => {'id': 'user-$i', 'seat': i}),
  'game_state': null,
};
Future<void> until(bool Function() predicate) async {
  final limit = DateTime.now().add(const Duration(seconds: 3));
  while (!predicate()) {
    if (DateTime.now().isAfter(limit)) fail('Le flux attendu n’est pas arrivé');
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

void main() {
  test('Flux : lecture après abonnement, arrivées en direct et rattrapage à la reconnexion', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var current = row(2);
    var reads = 0;
    server.listen((request) async {
      reads++;
      expect(request.uri.queryParameters['id'], 'eq.room');
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(current));
      await request.response.close();
    });
    final client = RoomClient('http://127.0.0.1:${server.port}', 'key');
    final received = <Map<String, dynamic>>[];
    final subscription = SupabaseRepository(client: client)
        .streamGame('room')
        .listen(received.add);
    addTearDown(() async {
      await subscription.cancel();
      await client.dispose();
      await server.close(force: true);
    });
    await Future<void>.delayed(Duration.zero);
    expect(reads, 0); // A second player arrived before Realtime was ready.
    expect(client.room.recordedTable, 'games');
    expect(client.room.recordedFilter?.column, 'id');
    expect(client.room.recordedFilter?.value, 'room');
    client.room.status!(RealtimeSubscribeStatus.subscribed, null);
    await until(() => received.isNotEmpty);
    expect((received.last['players'] as List).length, 2);
    client.room.emit(row(3));
    await until(() => received.length == 2);
    expect((received.last['players'] as List).length, 3);
    current = row(4);
    client.room.status!(RealtimeSubscribeStatus.subscribed, null);
    await until(() => received.length == 3);
    expect(received.last['status'], 'ready');
    expect(reads, 2);
    await subscription.cancel();
    expect(client.removed, 1);
    client.room.emit(row(1));
    client.room.status!(RealtimeSubscribeStatus.subscribed, null);
    await Future<void>.delayed(Duration.zero);
    expect(received.length, 3);
    expect(reads, 2);
  });
  for (final cancel in [false, true]) {
    test(
      'Flux : lecture HTTP tardive ignorée après ${cancel ? 'annulation' : 'événement Realtime'}',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final started = Completer<void>(),
            release = Completer<void>(),
            completed = Completer<void>();
        server.listen((request) async {
          started.complete();
          await release.future;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(row(1)));
          await request.response.close();
          completed.complete();
        });
        final client = RoomClient('http://127.0.0.1:${server.port}', 'key');
        final received = <Map<String, dynamic>>[];
        final subscription = SupabaseRepository(client: client)
            .streamGame('room')
            .listen(received.add);
        addTearDown(() async {
          await subscription.cancel();
          await client.dispose();
          await server.close(force: true);
        });
        client.room.status!(RealtimeSubscribeStatus.subscribed, null);
        await started.future;
        if (cancel) {
          await subscription.cancel();
        } else {
          client.room.emit(row(2));
          await until(() => received.isNotEmpty);
        }
        release.complete();
        await completed.future;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(
          received.map((r) => (r['players'] as List).length).toList(),
          cancel ? [] : [2],
        );
      },
    );
  }
}
