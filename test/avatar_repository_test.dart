import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarRepository extends PlayerRepository {
  AvatarRepository(SupabaseClient client) : super(clientInstance: client);
  @override
  String get userId => '00000000-0000-4000-8000-000000000001';
}

void main() {
  test(
    'sauvegarde uniquement le JSON avatar pour le joueur authentifié',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = Completer<({String method, Uri uri, Object? body})>();
      server.listen((request) async {
        final body = jsonDecode(await utf8.decoder.bind(request).join());
        received.complete((
          method: request.method,
          uri: request.uri,
          body: body,
        ));
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({'id': '00000000-0000-4000-8000-000000000001'}),
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
      final repo = AvatarRepository(client);
      await repo.saveAvatar(const AvatarConfig(skin: 2, hair: 1));
      final request = await received.future;
      expect(request.method, 'PATCH');
      expect(request.uri.path, '/rest/v1/profiles');
      expect(request.uri.queryParameters['id'], 'eq.${repo.userId}');
      expect(request.body, {
        'avatar_config': {
          'skin': 2,
          'glasses': 0,
          'top': 0,
          'hair': 1,
          'background_color': 0,
          'hair_color': 0,
          'border': 'none',
          'exclusive_hat': 'none',
        },
      });
    },
  );
}
