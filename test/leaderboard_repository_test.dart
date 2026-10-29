import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/leaderboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'fetchTop100 uses the public projection, stable order and server limit',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final requestReceived = Completer<Uri>();
      server.listen((request) async {
        requestReceived.complete(request.uri);
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode([
            {'id': 'a', 'username': 'Ane', 'elo': 1500},
          ]),
        );
        await request.response.close();
      });
      final client = SupabaseClient(
        'http://127.0.0.1:${server.port}',
        'test-key',
      );
      addTearDown(() async {
        await client.dispose();
        await server.close(force: true);
      });
      final result = await LeaderboardRepository(client: client).fetchTop100();
      final uri = await requestReceived.future;
      expect(uri.path, '/rest/v1/profiles');
      expect(uri.queryParameters['select'], 'id,username,elo');
      expect(uri.queryParameters['limit'], '100');
      expect(
        uri.queryParameters['order'],
        'elo.desc.nullslast,id.asc.nullslast',
      );
      expect(uri.queryParameters['elo'], 'not.is.null');
      expect(result.single.username, 'Ane');
      expect(result.single.elo, 1500);
    },
  );

  test('fetchTop100 propagates permission failures rather than returning an empty list', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.statusCode = 403;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'code': '42501', 'message': 'denied'}),
      );
      await request.response.close();
    });
    final client = SupabaseClient(
      'http://127.0.0.1:${server.port}',
      'test-key',
    );
    addTearDown(() async {
      await client.dispose();
      await server.close(force: true);
    });
    await expectLater(
      LeaderboardRepository(client: client).fetchTop100(),
      throwsA(isA<PostgrestException>()),
    );
  });
}
