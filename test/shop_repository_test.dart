import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/shop_item.dart';
import 'package:isamus/core/network/shop_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Le catalogue masque bordures et lunettes opaques même avec une ancienne base', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode([
          {
            'item_id': 'retired_opaque',
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
            'item_id': 'shop_hair_mullet',
            'cost': 300,
            'description': 'Une coupe',
            'cosmetics': {'label': 'Coupe Mulet', 'kind': 'avatar_hair'},
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
    expect(items.map((i) => i.id), ['shop_hair_mullet']);
    expect(items.single.category, ShopCategory.avatar);
  });

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
                  : {'coins_remaining': 700, 'item_id': 'shop_hair_mullet'},
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
            .buy('shop_hair_mullet', 300);
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
          'body': {'p_item_id': 'shop_hair_mullet', 'p_cost': 300},
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
