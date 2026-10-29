import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_item.dart';
import 'player_repository.dart';
import 'social_repository.dart';

final playerInventoryProvider = FutureProvider.autoDispose<PlayerInventory>((
  ref,
) async {
  final result = await Future.wait<Object>([
    ref.watch(playerProfileProvider.future),
    ref.watch(inventoryProvider.future),
    ref.watch(cosmeticsProvider.future),
  ]);
  return PlayerInventory(
    profile: result[0] as Map<String, dynamic>,
    owned: result[1] as Set<String>,
    catalog: result[2] as List<Map<String, dynamic>>,
  );
});
// Safe even when an equipment request completes after its screen is closed.
final equipmentRefreshProvider = Provider<void Function()>((ref) {
  var active = true;
  ref.onDispose(() => active = false);
  return () {
    if (!active) return;
    ref.invalidate(playerProfileProvider);
    ref.invalidate(inventoryProvider);
    ref.invalidate(personProvider);
    ref.invalidate(publicPlayerProfileProvider);
  };
});
