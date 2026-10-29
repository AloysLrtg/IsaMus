enum ShopCategory { avatar, cardBack, quickChat }

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.category,
  });
  final String id, name, description;
  final int cost;
  final ShopCategory category;
  factory ShopItem.fromJson(Map<String, dynamic> json) {
    final cosmetic = json['cosmetics'] as Map;
    final cost = json['cost'];
    if (cost is! int || cost <= 0) throw const FormatException('Prix invalide');
    return ShopItem(
      id: json['item_id'] as String,
      name: cosmetic['label'] as String,
      description: json['description'] as String,
      cost: cost,
      category: switch (cosmetic['kind']) {
        'avatar' ||
        'avatar_hair' ||
        'avatar_top' ||
        'exclusive_hat' => ShopCategory.avatar,
        'card_back' => ShopCategory.cardBack,
        'quick_chat' => ShopCategory.quickChat,
        _ => throw const FormatException('Catégorie inconnue'),
      },
    );
  }
}
