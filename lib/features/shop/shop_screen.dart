import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/shop_item.dart';
import '../../core/models/avatar_config.dart';
import '../../core/network/shop_repository.dart';
import '../../core/network/player_repository.dart';
import '../avatar/player_avatar_view.dart';
import '../game/card_back_view.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String? _busy;
  String _error(Object error) {
    if (error is PostgrestException) {
      if (error.message.contains('insuffisants')) {
        return 'Fonds insuffisants pour cet article.';
      }
      if (error.message.contains('déjà possédé')) {
        return 'Cet article est déjà dans votre inventaire.';
      }
      if (error.message.contains('Prix modifié')) {
        return 'Le prix a changé. La boutique a été actualisée.';
      }
      if (error.message.contains('indisponible')) {
        return 'Cet article n’est plus disponible.';
      }
    }
    return 'Achat impossible. Réessayez dans quelques instants.';
  }

  Future<void> _act(ShopItem item) async {
    if (_busy != null) return;
    final refresh = ref.read(shopRefreshProvider);
    setState(() => _busy = item.id);
    var message = '';
    try {
      await ref.read(shopRepositoryProvider).buy(item.id, item.cost);
      message = '${item.name} ajouté à votre inventaire';
    } catch (error) {
      message = _error(error);
    }
    refresh();
    if (!mounted) return;
    try {
      await ref.read(shopStateProvider.future);
    } catch (_) {
      /* Retry UI owns read errors. */
    }
    if (!mounted) return;
    setState(() => _busy = null);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: widget.embedded || _busy == null,
    child: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: widget.embedded ? null : const Text('Boutique'),
          toolbarHeight: widget.embedded ? 0 : kToolbarHeight,
          automaticallyImplyLeading: !widget.embedded,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Cosmétiques d’Avatar'),
              Tab(text: 'Dos de cartes'),
              Tab(text: 'Quick Chats'),
            ],
          ),
        ),
        body: ref
            .watch(shopStateProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Boutique indisponible.'),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(playerProfileProvider);
                        ref.invalidate(inventoryProvider);
                        ref.invalidate(shopCatalogProvider);
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
              data: (state) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer
                            .withValues(alpha: .35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary
                              .withValues(alpha: .4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${state.coins} pièces',
                              key: const ValueKey('shop-coins-balance'),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                    child: _busy != null
                        ? const LinearProgressIndicator()
                        : null,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        for (final category in ShopCategory.values)
                          RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(playerProfileProvider);
                              ref.invalidate(inventoryProvider);
                              ref.invalidate(shopCatalogProvider);
                              try {
                                await ref.read(shopStateProvider.future);
                              } catch (_) {
                                /* The page displays read errors. */
                              }
                            },
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                if (state.items
                                    .where((i) => i.category == category)
                                    .isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'De nouveaux articles arrivent bientôt.',
                                    ),
                                  ),
                                for (final item in state.items.where(
                                  (i) => i.category == category,
                                ))
                                  _item(item, state),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    ),
  );

  AvatarConfig _avatarPreview(ShopItem item, ShopState state) {
    final current = AvatarConfig.fromJson(state.profile['avatar_config']);
    return current.withCosmetic(item.id);
  }

  Widget _item(ShopItem item, ShopState state) {
    final owned = state.owned.contains(item.id);
    final theme = Theme.of(context);
    return Card(
      key: ValueKey('shop-item-${item.id}'),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              height: 80,
              child: switch (item.category) {
                ShopCategory.avatar => PlayerAvatarView(
                  size: 72,
                  config: _avatarPreview(item, state),
                ),
                ShopCategory.cardBack => Center(
                  child: SizedBox(
                    width: 48,
                    height: 68,
                    child: CardBackView(id: item.id),
                  ),
                ),
                ShopCategory.quickChat => Icon(
                  Icons.forum_rounded,
                  size: 42,
                  color: theme.colorScheme.primary,
                ),
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(item.description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  if (owned) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Possédé',
                          key: ValueKey('shop-owned-${item.id}'),
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ] else
                    FilledButton.icon(
                      key: ValueKey('shop-buy-${item.id}'),
                      onPressed: _busy != null ? null : () => _act(item),
                      icon: const Icon(Icons.monetization_on_rounded, size: 18),
                      label: Text(
                        _busy == item.id
                            ? 'Achat…'
                            : 'Acheter · ${item.cost} pièces',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
