import 'package:isamus/l10n/app_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/models/shop_item.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/shop_repository.dart';
import 'package:isamus/features/shop/shop_screen.dart';
import 'package:isamus/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const shopTestItems = [
  ShopItem(
    id: 'shop_top_striped',
    name: 'Maillot Rayé',
    description: 'Un maillot.',
    cost: 300,
    category: ShopCategory.avatar,
  ),
  ShopItem(
    id: 'shop_back_violet',
    name: 'Dos Violet',
    description: 'Un dos violet.',
    cost: 250,
    category: ShopCategory.cardBack,
  ),
  ShopItem(
    id: 'shop_chat_eskerrik',
    name: 'Eskerrik asko !',
    description: 'Remerciez vos partenaires.',
    cost: 150,
    category: ShopCategory.quickChat,
  ),
];

class ShopTestPlayer extends PlayerRepository {
  ShopTestPlayer({this.coins = 1000, Set<String>? owned}) : owned = owned ?? {};
  int coins;
  final Set<String> owned;
  AvatarConfig avatar = const AvatarConfig();
  String? back;
  @override
  Future<Map<String, dynamic>> profile() async => {
    'coins': coins,
    'avatar_config': avatar.toJson(),
    'card_back': back,
  };
  @override
  Future<Set<String>> inventory() async => {...owned};
  @override
  Future<void> equip(String id) async {
    if (!owned.contains(id)) throw StateError('not owned');
    if (id.startsWith('shop_back_')) {
      back = id;
    } else {
      avatar = avatar.withCosmetic(id);
    }
  }
}

class ShopTestRepository extends ShopRepository {
  ShopTestRepository(this.player);
  final ShopTestPlayer player;
  int calls = 0;
  Completer<void>? pending;
  bool unavailable = false;
  @override
  Future<List<ShopItem>> catalog() async {
    if (unavailable) throw StateError('offline');
    return shopTestItems;
  }

  @override
  Future<Map<String, dynamic>> buy(String itemId, int cost) async {
    calls++;
    if (pending != null) await pending!.future;
    if (player.owned.contains(itemId)) {
      throw const PostgrestException(
        message: 'Article déjà possédé',
        code: 'P0001',
      );
    }
    if (player.coins < cost) {
      throw const PostgrestException(
        message: 'Fonds insuffisants',
        code: 'P0001',
      );
    }
    player.coins -= cost;
    player.owned.add(itemId);
    return {'coins_remaining': player.coins, 'item_id': itemId};
  }
}

Future<void> openShop(
  WidgetTester tester,
  ShopTestPlayer player,
  ShopTestRepository repository,
) async {
  tester.view.physicalSize = const Size(320, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playerRepositoryProvider.overrideWithValue(player),
        shopRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MyApp(home: ShopScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Boutique lisible avec texte agrandi sur écran étroit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final player = ShopTestPlayer();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerRepositoryProvider.overrideWithValue(player),
          shopRepositoryProvider.overrideWithValue(ShopTestRepository(player)),
        ],
        child: MyApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: const ShopScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final buy = find.byKey(const ValueKey('shop-buy-shop_top_striped'));
    await tester.ensureVisible(buy);
    await tester.pumpAndSettle();
    await tester.tap(buy);
    await tester.pumpAndSettle();
    expect(player.coins, 700);
    expect(
      find.byKey(const ValueKey('shop-owned-shop_top_striped')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Le solde est actualisé même si le joueur change d’onglet pendant l’achat',
    (tester) async {
      final player = ShopTestPlayer();
      final repository = ShopTestRepository(player)
        ..pending = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWithValue(player),
          shopRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(home: ShopScreen(embedded: true)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('shop-buy-shop_top_striped')));
      await tester.pump();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            home: Consumer(
              builder: (context, ref, _) => Text(
                '${ref.watch(playerProfileProvider).asData?.value['coins']}',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1000'), findsOneWidget);
      repository.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.text('700'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Achat serveur : solde rafraîchi, badge Possédé sans équipement',
    (tester) async {
      final player = ShopTestPlayer();
      final repository = ShopTestRepository(player);
      await openShop(tester, player, repository);
      expect(find.text('1000 pièces'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('shop-buy-shop_top_striped')));
      await tester.pumpAndSettle();
      expect(repository.calls, 1);
      expect(player.coins, 700);
      expect(find.text('700 pièces'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('shop-buy-shop_top_striped')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('shop-owned-shop_top_striped')),
        findsOneWidget,
      );
      expect(find.text(testL10n.menuEquip), findsNothing);
      expect(player.avatar.hair, 0);
      expect(player.coins, 700);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Solde insuffisant : refus serveur visible, aucun débit ni déblocage',
    (tester) async {
      final player = ShopTestPlayer(coins: 10);
      final repository = ShopTestRepository(player);
      await openShop(tester, player, repository);
      await tester.tap(find.byKey(const ValueKey('shop-buy-shop_top_striped')));
      await tester.pumpAndSettle();
      expect(repository.calls, 1);
      expect(player.coins, 10);
      expect(player.owned, isEmpty);
      expect(find.text(testL10n.menuNotEnoughCoinsForThisItem), findsOneWidget);
      expect(find.text('10 pièces'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('shop-buy-shop_top_striped')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('shop-owned-shop_top_striped')),
        findsNothing,
      );
    },
  );
  testWidgets('Une transaction en cours bloque les doubles clics', (
    tester,
  ) async {
    final player = ShopTestPlayer();
    final repository = ShopTestRepository(player)..pending = Completer<void>();
    await openShop(tester, player, repository);
    final buy = find.byKey(const ValueKey('shop-buy-shop_top_striped'));
    await tester.tap(buy);
    await tester.pump();
    await tester.tap(buy);
    await tester.pump();
    expect(repository.calls, 1);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(player.coins, 700);
    expect(player.owned.length, 1);
  });
  testWidgets('Trois catégories, articles possédés sans bouton d’achat', (
    tester,
  ) async {
    final player = ShopTestPlayer(
      owned: {'shop_back_violet', 'shop_chat_eskerrik'},
    );
    await openShop(tester, player, ShopTestRepository(player));
    await tester.ensureVisible(find.text(testL10n.menuCardBacks));
    await tester.tap(find.text(testL10n.menuCardBacks));
    await tester.pumpAndSettle();
    expect(find.text('Dos Violet'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('shop-owned-shop_back_violet')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('shop-buy-shop_back_violet')),
      findsNothing,
    );
    await tester.ensureVisible(find.text(testL10n.menuQuickChats));
    await tester.tap(find.text(testL10n.menuQuickChats));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('shop-owned-shop_chat_eskerrik')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('shop-buy-shop_chat_eskerrik')),
      findsNothing,
    );
    expect(find.text(testL10n.menuEquip), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Le catalogue indisponible propose une nouvelle tentative', (
    tester,
  ) async {
    final player = ShopTestPlayer();
    final repository = ShopTestRepository(player)..unavailable = true;
    await openShop(tester, player, repository);
    expect(find.text(testL10n.menuShopUnavailable), findsOneWidget);
    repository.unavailable = false;
    await tester.tap(find.text(testL10n.menuTryAgain));
    await tester.pumpAndSettle();
    expect(find.text('1000 pièces'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
