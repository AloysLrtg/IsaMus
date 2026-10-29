import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isamus/core/network/auth_repository.dart';

const uid = '123e4567-e89b-12d3-a456-426614174000';
Map<String, dynamic> user() => {
  'id': uid,
  'aud': 'authenticated',
  'role': 'authenticated',
  'email': 'ane@example.com',
  'app_metadata': {'provider': 'email'},
  'user_metadata': {},
  'created_at': '2026-10-28T00:00:00Z',
};
Map<String, dynamic> session() {
  final payload = base64Url
      .encode(
        utf8.encode(
          jsonEncode({
            'sub': uid,
            'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
          }),
        ),
      )
      .replaceAll('=', '');
  return {
    'access_token': 'e30.$payload.signature',
    'refresh_token': 'test-refresh',
    'token_type': 'bearer',
    'expires_in': 3600,
    'user': user(),
  };
}

class MemoryAuthStorage extends GotrueAsyncStorage {
  final data = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => data[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    data[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    data.remove(key);
  }
}

void main() {
  late SupabaseClient client;
  late AuthRepository repo;
  final requests = <http.Request>[];
  var confirmation = false;
  var failedDeletion = false;
  var offlineLogout = false;
  setUp(() {
    requests.clear();
    confirmation = false;
    failedDeletion = false;
    offlineLogout = false;
    client = SupabaseClient(
      'https://example.test',
      'public-test-key',
      authOptions: AuthClientOptions(
        autoRefreshToken: false,
        pkceAsyncStorage: MemoryAuthStorage(),
      ),
      httpClient: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/logout')) {
          if (offlineLogout) throw http.ClientException('offline');
          return http.Response('', 204);
        }
        if (request.url.path.endsWith('/delete-account')) {
          return http.Response(
            jsonEncode({'ok': !failedDeletion}),
            failedDeletion ? 500 : 200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode(confirmation ? {'user': user()} : session()),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    repo = AuthRepository(clientInstance: client);
  });
  tearDown(() async {
    await client.dispose();
  });

  test(
    'email/mot de passe : échange Supabase et session authentifiée',
    () async {
      await repo.signIn(' ane@example.com ', 'password');
      expect(requests.single.url.queryParameters['grant_type'], 'password');
      expect(
        jsonDecode(requests.single.body),
        containsPair('email', 'ane@example.com'),
      );
      expect(repo.currentUserId, uid);
    },
  );
  test(
    'création avec confirmation : aucune session prématurée, callback mobile',
    () async {
      confirmation = true;
      expect(
        await repo.signUp(
          ' ane@example.com ',
          'longpassword',
          username: ' Ane ',
        ),
        isFalse,
      );
      expect(repo.currentUser, isNull);
      expect(requests.single.url.path, '/auth/v1/signup');
      expect(jsonDecode(requests.single.body)['data'], {'username': 'Ane'});
      expect(
        requests.single.url.queryParameters['redirect_to'],
        'isamus://auth/callback',
      );
    },
  );
  test('pseudo manquant ou trop long : aucune requête de création', () async {
    for (final name in ['', '   ', 'x' * 25]) {
      await expectLater(
        repo.signUp('ane@example.com', 'longpassword', username: name),
        throwsA(isA<AuthException>()),
      );
    }
    expect(requests, isEmpty);
  });
  test('création sans confirmation : session reconnue', () async {
    expect(
      await repo.signUp('ane@example.com', 'longpassword', username: 'Ane'),
      isTrue,
    );
    expect(repo.currentUserId, uid);
  });
  test('déconnexion retire la session même hors ligne', () async {
    await repo.signIn('ane@example.com', 'password');
    offlineLogout = true;
    try {
      await repo.signOut();
    } catch (_) {
      /* Local removal still takes precedence. */
    }
    expect(repo.currentUser, isNull);
  });
  test(
    'suppression refuse une réponse serveur en échec et préserve la session',
    () async {
      await repo.signIn('ane@example.com', 'password');
      failedDeletion = true;
      await expectLater(repo.deleteAccount(), throwsA(isA<Exception>()));
      expect(repo.currentUserId, uid);
      failedDeletion = false;
      await repo.deleteAccount();
      expect(repo.currentUser, isNull);
    },
  );
}
