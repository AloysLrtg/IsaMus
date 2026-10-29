import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/social_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const actor = '00000000-0000-4000-8000-000000000001';
const target = '00000000-0000-4000-8000-000000000002';

class RequestSocial extends SocialRepository {
  RequestSocial(SupabaseClient client) : super(clientInstance: client);
  @override
  String get userId => actor;
}

void main() {
  test(
    'Déduplication : les échos INSERT ne rétablissent pas une demande traitée',
    () {
      for (final status in ['accepted', 'declined']) {
        final rows = deduplicateSocialRows([
          {'id': 'same', 'status': status},
          {'id': 'same', 'status': 'pending'},
        ]);
        expect(rows.length, 1);
        expect(rows.single['status'], status);
      }
      final renewed = deduplicateSocialRows([
        {
          'id': 'same',
          'status': 'declined',
          'created_at': '2026-10-29T10:00:00Z',
        },
        {
          'id': 'same',
          'status': 'pending',
          'created_at': '2026-10-29T11:00:00Z',
        },
      ]);
      expect(renewed.single['status'], 'pending');
    },
  );
  for (final method in [
    'create_mode_invitation',
    'accept_game_invitation',
    'decline_game_invitation',
  ]) {
    test(
      'Invitation $method : mode et identité contrôlés par le serveur',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final requests = <Map<String, dynamic>>[];
        server.listen((request) async {
          requests.add({
            'path': request.uri.path,
            'method': request.method,
            'body': jsonDecode(await utf8.decoder.bind(request).join()),
          });
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            method == 'decline_game_invitation'
                ? 'null'
                : jsonEncode({
                    'id': 'room',
                    'mode': 'ranked',
                    'local_seat': 2,
                    'players': [],
                  }),
          );
          await request.response.close();
        });
        final client = SupabaseClient('http://127.0.0.1:${server.port}', 'key');
        addTearDown(() async {
          await client.dispose();
          await server.close(force: true);
        });
        final repo = RequestSocial(client);
        switch (method) {
          case 'create_mode_invitation':
            expect(
              (await repo.createModeInvitation(target, 'ranked'))['mode'],
              'ranked',
            );
          case 'accept_game_invitation':
            expect(
              (await repo.acceptGameInvitation('invite'))['local_seat'],
              2,
            );
          case 'decline_game_invitation':
            await repo.decline('invite');
        }
        expect(requests, [
          {
            'path': '/rest/v1/rpc/$method',
            'method': 'POST',
            'body': method == 'create_mode_invitation'
                ? {'p_friend': target, 'p_mode': 'ranked'}
                : {'invitation': 'invite'},
          },
        ]);
      },
    );
  }
  for (final method in [
    'search_social_players',
    'block_user',
    'unblock_user',
    'decline_request',
  ]) {
    test(
      'Appel social $method : paramètres minimaux et identité serveur',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final requests = <Map<String, dynamic>>[];
        server.listen((request) async {
          requests.add({
            'path': request.uri.path,
            'method': request.method,
            'body': jsonDecode(await utf8.decoder.bind(request).join()),
          });
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            method == 'search_social_players' ? '[]' : 'null',
          );
          await request.response.close();
        });
        final client = SupabaseClient('http://127.0.0.1:${server.port}', 'key');
        addTearDown(() async {
          await client.dispose();
          await server.close(force: true);
        });
        final repo = RequestSocial(client);
        switch (method) {
          case 'search_social_players':
            expect(await repo.search('A'), isEmpty);
            expect(requests, isEmpty);
            await repo.search('  Ane  ');
          case 'block_user':
            await repo.block(target);
          case 'unblock_user':
            await repo.unblock(target);
          case 'decline_request':
            await repo.declineRequest('relation');
        }
        expect(requests, [
          {
            'path': method == 'decline_request'
                ? '/rest/v1/friendships'
                : '/rest/v1/rpc/$method',
            'method': method == 'decline_request' ? 'PATCH' : 'POST',
            'body': method == 'decline_request'
                ? {'status': 'declined'}
                : method == 'search_social_players'
                ? {'p_query': 'Ane'}
                : {'p_user_id': target},
          },
        ]);
      },
    );
  }
  for (final scenario in [
    'new',
    'pending',
    'accepted',
    'declined',
    'race',
    'offline',
  ]) {
    test(
      'Demande d’ami : $scenario, identité authentifiée et doublons maîtrisés',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final calls = <String>[], bodies = <dynamic>[];
        var reads = 0;
        server.listen((request) async {
          calls.add(request.method);
          request.response.headers.contentType = ContentType.json;
          if (request.method == 'GET') {
            reads++;
            expect(request.uri.queryParameters['or'], contains(actor));
            expect(request.uri.queryParameters['or'], contains(target));
            final exists =
                ['pending', 'accepted', 'declined'].contains(scenario) ||
                (scenario == 'race' && reads > 1);
            request.response.write(
              jsonEncode(
                exists
                    ? {
                        'id': 'relation',
                        'user_id_1': actor,
                        'user_id_2': target,
                        'status': scenario == 'race' ? 'pending' : scenario,
                      }
                    : null,
              ),
            );
          } else if (request.method == 'DELETE') {
            expect(request.uri.queryParameters['id'], 'eq.relation');
            expect(request.uri.queryParameters['status'], 'eq.declined');
            request.response.statusCode = 204;
          } else {
            bodies.add(jsonDecode(await utf8.decoder.bind(request).join()));
            if (scenario == 'race' || scenario == 'offline') {
              request.response.statusCode = scenario == 'race' ? 409 : 403;
              request.response.write(
                jsonEncode({
                  'code': scenario == 'race' ? '23505' : '42501',
                  'message': 'rejected',
                }),
              );
            } else {
              request.response.write('null');
            }
          }
          await request.response.close();
        });
        final client = SupabaseClient('http://127.0.0.1:${server.port}', 'key');
        addTearDown(() async {
          await client.dispose();
          await server.close(force: true);
        });
        final repo = RequestSocial(client);
        if (scenario == 'offline') {
          await expectLater(
            repo.request(target),
            throwsA(isA<PostgrestException>()),
          );
        } else {
          await repo.request(target);
        }
        expect(calls, switch (scenario) {
          'pending' || 'accepted' => ['GET'],
          'declined' => ['GET', 'DELETE', 'POST'],
          'race' => ['GET', 'POST', 'GET'],
          _ => ['GET', 'POST'],
        });
        if (bodies.isNotEmpty) {
          expect(bodies.single, {'user_id_1': actor, 'user_id_2': target});
        }
        final before = calls.length;
        await expectLater(repo.request(actor), throwsFormatException);
        await expectLater(
          repo.request('bad-id),status.eq.accepted'),
          throwsFormatException,
        );
        expect(calls.length, before);
      },
    );
  }
}
