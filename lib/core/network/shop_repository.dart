import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/shop_item.dart';
import 'player_repository.dart';
import 'retention_repository.dart';

// Keep the invalidation callback alive for the session if a purchase finishes
// after the player switches tabs; never reuse it across a disposed session.
final shopRefreshProvider = Provider<void Function()>((ref) {
  var active = true;
  ref.onDispose(() => active = false);
  return () {
    if (!active) return;
    ref.invalidate(playerProfileProvider);
    ref.invalidate(inventoryProvider);
    ref.invalidate(shopCatalogProvider);
    ref.invalidate(retentionStatusProvider);
  };
});

final shopRepositoryProvider = Provider((ref) => ShopRepository());
final shopCatalogProvider = FutureProvider.autoDispose<List<ShopItem>>(
  (ref) => ref.watch(shopRepositoryProvider).catalog(),
);
final shopStateProvider = FutureProvider.autoDispose<ShopState>((ref) async {
  final result = await Future.wait<Object>([
    ref.watch(shopCatalogProvider.future),
    ref.watch(playerProfileProvider.future),
    ref.watch(inventoryProvider.future),
  ]);
  return ShopState(
    items: result[0] as List<ShopItem>,
    profile: result[1] as Map<String, dynamic>,
    owned: result[2] as Set<String>,
  );
});

class ShopState {
  const ShopState({
    required this.items,
    required this.profile,
    required this.owned,
  });
  final List<ShopItem> items;
  final Map<String, dynamic> profile;
  final Set<String> owned;
  int get coins => (profile['coins'] as num? ?? 0).toInt();
}

class ShopRepository {
  ShopRepository({this.clientInstance});
  final SupabaseClient? clientInstance;
  SupabaseClient get client => clientInstance ?? Supabase.instance.client;
  Future<List<ShopItem>> catalog() async =>
      (await client
              .from('shop_items')
              .select('item_id,cost,description,cosmetics!inner(label,kind)')
              .order('cost')
              .order('item_id'))
          // Also hide retired frames while a server migration is pending.
          .where(
            (json) =>
                json['item_id'] != 'shop_hair_mullet' &&
                !{'avatar_border'}.contains((json['cosmetics'] as Map)['kind']),
          )
          .map((json) => ShopItem.fromJson(json))
          .toList();
  Future<Map<String, dynamic>> buy(String itemId, int cost) async =>
      Map<String, dynamic>.from(
        await client.rpc(
          'buy_shop_item',
          params: {'p_item_id': itemId, 'p_cost': cost},
        ),
      );
}
