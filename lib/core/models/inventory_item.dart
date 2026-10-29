import 'avatar_config.dart';

enum InventoryCategory { avatar, cardBack }

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.kind,
  });
  final String id, name, kind;
  static const classic = InventoryItem(
    id: 'classic',
    name: 'Dos Classique',
    kind: 'card_back',
  );
  InventoryCategory get category => switch (kind) {
    'card_back' => InventoryCategory.cardBack,
    _ => InventoryCategory.avatar,
  };
  static bool supports(String kind) => [
    'avatar',
    'avatar_border',
    'avatar_hair',
    'avatar_top',
    'exclusive_hat',
    'card_back',
  ].contains(kind);
  AvatarPart? get part => switch (kind) {
    'avatar_border' => AvatarPart.border,
    'avatar_hair' => AvatarPart.hair,
    'avatar_top' => AvatarPart.top,
    'exclusive_hat' => AvatarPart.exclusiveHat,
    _ => null,
  };
  AvatarConfig preview(AvatarConfig current) => switch (kind) {
    'avatar_border' => current.withOption(
      AvatarPart.border,
      AvatarBorder.values
              .where((b) => id == 'league_border_${b.name}')
              .firstOrNull
              ?.index ??
          0,
    ),
    'exclusive_hat' => current.withOption(
      AvatarPart.exclusiveHat,
      ExclusiveHat.values
              .where(
                (h) =>
                    id == 'league_hat_${h.name}' || id == 'shop_hat_${h.name}',
              )
              .firstOrNull
              ?.index ??
          0,
    ),
    'avatar_hair' => current.withOption(AvatarPart.hair, 3),
    'avatar_top' => current.withOption(AvatarPart.top, 3),
    _ => current,
  };
  bool isEquipped(Map<String, dynamic> profile) {
    if (kind == 'card_back') return (profile['card_back'] ?? 'classic') == id;
    if (kind == 'avatar') return profile['avatar'] == id;
    final current = AvatarConfig.fromJson(profile['avatar_config']);
    return part != null &&
        current.valueFor(part!) == preview(current).valueFor(part!);
  }
}

class PlayerInventory {
  PlayerInventory({
    required this.profile,
    required Set<String> owned,
    required List<Map<String, dynamic>> catalog,
  }) {
    final byId = <String, InventoryItem>{'classic': InventoryItem.classic};
    for (final json in catalog) {
      final id = json['id'], kind = json['kind'];
      if (id is! String ||
          kind is! String ||
          !InventoryItem.supports(kind) ||
          id == 'classic') {
        continue;
      }
      if (!owned.contains(id) &&
          !(kind == 'card_back' && json['free'] == true)) {
        continue;
      }
      byId[id] = InventoryItem(
        id: id,
        name: json['label']?.toString() ?? id,
        kind: kind,
      );
    }
    items = List.unmodifiable(byId.values);
  }
  final Map<String, dynamic> profile;
  late final List<InventoryItem> items;
  List<InventoryItem> forCategory(InventoryCategory category) {
    final result = items.where((i) => i.category == category).toList();
    result.sort(
      (a, b) => a.id == 'classic'
          ? -1
          : b.id == 'classic'
          ? 1
          : a.name.compareTo(b.name),
    );
    return result;
  }
}
