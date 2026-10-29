import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/shop_item.dart';
import 'package:isamus/core/network/shop_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'Le catalogue expose les lunettes et masque les anciens cadres',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode([
            {
              'item_id': 'shop_glasses_round',
              'cost': 250,
              'description': 'Verres opaques',
              'cosmetics': {
                'label': 'Lunettes de soleil',
                'kind': 'avatar_glasses',
              },
            },
            {
              'item_id': 'shop_border_emerald',
              'cost': 300,
              'description': 'Ancien cadre',
              'cosmetics': {'label': 'Cadre Émeraude', 'kind': 'avatar_border'},
            },
            {
              'item_id': 'shop_top_striped',
              'cost': 300,
              'description': 'Une coupe',
              'cosmetics': {'label': 'Maillot Rayé', 'kind': 'avatar_hair'},
            },
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
      final items = await ShopRepository(clientInstance: client).catalog();
      expect(items.map((i) => i.id), [
        'shop_glasses_round',
        'shop_top_striped',
      ]);
      expect(items.first.category, ShopCategory.glasses);
    },
  );

  for (final insufficient in [false, true]) {
    test(
      'Achat via RPC uniquement : ${insufficient ? 'erreur propagée' : 'reçu serveur'}',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final received = Completer<Map<String, dynamic>>();
        server.listen((request) async {
          received.complete({
            'path': request.uri.path,
            'method': request.method,
            'body': jsonDecode(await utf8.decoder.bind(request).join()),
          });
          request.response.headers.contentType = ContentType.json;
          if (insufficient) request.response.statusCode = 400;
          request.response.write(
            jsonEncode(
              insufficient
                  ? {'code': 'P0001', 'message': 'Fonds insuffisants'}
                  : {'coins_remaining': 700, 'item_id': 'shop_top_striped'},
            ),
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
        final purchase = ShopRepository(clientInstance: client)
            .buy('shop_top_striped', 300);
        if (insufficient) {
          await expectLater(
            purchase,
            throwsA(
              isA<PostgrestException>().having(
                (e) => e.message,
                'message',
                'Fonds insuffisants',
              ),
            ),
          );
        } else {
          expect((await purchase)['coins_remaining'], 700);
        }
        expect(await received.future, {
          'path': '/rest/v1/rpc/buy_shop_item',
          'method': 'POST',
          'body': {'p_item_id': 'shop_top_striped', 'p_cost': 300},
        });
      },
    );
  }
  test('Le catalogue conserve prix et catégorie serveur', () {
    final item = ShopItem.fromJson({
      'item_id': 'shop_chat_eskerrik',
      'cost': 150,
      'description': 'Un message',
      'cosmetics': {'kind': 'quick_chat', 'label': 'Eskerrik asko !'},
    });
    expect(item.category, ShopCategory.quickChat);
    expect(item.cost, 150);
    for (final invalid in [0, -1, null]) {
      expect(
        () => ShopItem.fromJson({
          'item_id': 'x',
          'cost': invalid,
          'description': '',
          'cosmetics': {'kind': 'quick_chat', 'label': 'x'},
        }),
        throwsFormatException,
      );
    }
  });
}
