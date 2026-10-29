import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/social_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const recipient = '00000000-0000-4000-8000-000000000001';

class NotificationChannel implements RealtimeChannel {
  void Function(RealtimeSubscribeStatus, Object?)? status;
  void Function(PostgresChangePayload)? changed;
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
    expect(event, PostgresChangeEvent.all);
    expect(schema, 'public');
    expect(table, 'game_invitations');
    expect(filter?.column, 'recipient_id');
    expect(filter?.value, recipient);
    changed = callback;
    return this;
  }

  void emit() => changed!(
    PostgresChangePayload(
      schema: 'public',
      table: 'game_invitations',
      commitTimestamp: DateTime.now(),
      eventType: PostgresChangeEvent.insert,
      newRecord: {'id': 'invite', 'recipient_id': recipient},
      oldRecord: {},
      errors: null,
    ),
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class NotificationClient extends SupabaseClient {
  NotificationClient(super.url, super.key);
  final notices = NotificationChannel();
  int removed = 0;
  @override
  RealtimeChannel channel(
    String name, {
    RealtimeChannelConfig opts = const RealtimeChannelConfig(),
  }) {
    expect(name, startsWith('invitation-notifications:$recipient:'));
    return notices;
  }

  @override
  Future<String> removeChannel(RealtimeChannel channel) async {
    removed++;
    return 'ok';
  }
}

class NotificationSocial extends SocialRepository {
  NotificationSocial(SupabaseClient client) : super(clientInstance: client);
  @override
  String get userId => recipient;
}

Future<void> until(bool Function() test) async {
  final end = DateTime.now().add(const Duration(seconds: 3));
  while (!test()) {
    if (DateTime.now().isAfter(end)) fail('Notification non reçue');
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

void main() {
  test('Notifications : snapshot après connexion, mises à jour et reconnexion sans perte', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var reads = 0;
    var rows = <Map<String, dynamic>>[];
    server.listen((request) async {
      reads++;
      expect(request.uri.queryParameters['recipient_id'], 'eq.$recipient');
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(rows));
      await request.response.close();
    });
    final client = NotificationClient('http://127.0.0.1:${server.port}', 'key');
    final received = <List<Map<String, dynamic>>>[];
    final subscription = NotificationSocial(client)
        .invitations()
        .listen(received.add);
    addTearDown(() async {
      await subscription.cancel();
      await client.dispose();
      await server.close(force: true);
    });
    expect(reads, 0);
    rows = [
      {
        'id': 'invite',
        'recipient_id': recipient,
        'mode': 'ranked',
        'status': 'pending',
      },
    ];
    client.notices.status!(RealtimeSubscribeStatus.subscribed, null);
    await until(() => received.length == 1);
    expect(received.single.single['mode'], 'ranked');
    rows = [
      {...rows.single, 'status': 'declined'},
    ];
    client.notices.emit();
    await until(() => received.length == 2);
    expect(received.last.single['status'], 'declined');
    rows = [];
    client.notices.status!(RealtimeSubscribeStatus.subscribed, null);
    await until(() => received.length == 3);
    expect(received.last, isEmpty);
    await subscription.cancel();
    expect(client.removed, 1);
    client.notices.emit();
    await Future<void>.delayed(Duration.zero);
    expect(reads, 3);
  });
}
