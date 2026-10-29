import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/inventory_item.dart';
import '../../core/network/player_repository.dart';
import '../../core/network/inventory_repository.dart';
import '../game/card_back_view.dart';
import '../avatar/player_avatar_view.dart';
import '../../core/models/avatar_config.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});
  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String? _busy;
  Future<void> _act(
    String id,
    Future<void> Function() action,
    String message,
  ) async {
    if (_busy != null) return;
    final refresh = ref.read(equipmentRefreshProvider);
    setState(() => _busy = id);
    try {
      await action();
      refresh();
      if (mounted) {
        try {
          await ref.read(playerInventoryProvider.future);
        } catch (_) {
          message =
              'Équipement enregistré. Réessayez le chargement de l’inventaire.';
        }
      }
    } catch (_) {
      message = 'Équipement impossible. Vérifiez votre connexion et réessayez.';
    }
    if (!mounted) return;
    setState(() => _busy = null);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _reload() {
    ref.invalidate(playerProfileProvider);
    ref.invalidate(inventoryProvider);
    ref.invalidate(cosmeticsProvider);
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Personnalisation'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Dos de cartes'),
            Tab(text: 'Cheveux'),
          ],
        ),
      ),
      body: ref
          .watch(playerInventoryProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Inventaire indisponible.'),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            data: (state) => Column(
              children: [
                SizedBox(
                  height: 4,
                  child: _busy == null ? null : const LinearProgressIndicator(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _reload();
                      try {
                        await ref.read(playerInventoryProvider.future);
                      } catch (_) {}
                    },
                    child: TabBarView(
                      children: [
                        for (final hair in [false, true])
                          ListView(
                            key: ValueKey(
                              hair
                                  ? 'inventory-list-hair'
                                  : 'inventory-list-cardBack',
                            ),
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            children: [
                              Text(
                                hair ? 'Cheveux' : 'Dos de cartes',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              for (final item
                                  in state
                                      .forCategory(
                                        hair
                                            ? InventoryCategory.avatar
                                            : InventoryCategory.cardBack,
                                      )
                                      .where(
                                        (item) =>
                                            !hair || item.kind == 'avatar_hair',
                                      ))
                                _item(item, state),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    ),
  );

  Widget _item(InventoryItem item, PlayerInventory state) {
    final selected = item.isEquipped(state.profile);
    final theme = Theme.of(context);
    return Card(
      key: ValueKey('inventory-item-${item.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 68,
              height: 76,
              child: item.kind == 'avatar_hair'
                  ? PlayerAvatarView(
                      size: 68,
                      config: item.preview(
                        AvatarConfig.fromJson(state.profile['avatar_config']),
                      ),
                    )
                  : Center(
                      child: SizedBox(
                        width: 42,
                        height: 62,
                        child: CardBackView(id: item.id),
                      ),
                    ),
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
                  if (item.id == 'classic')
                    Text(
                      'Le dos bleu d’origine, toujours disponible.',
                      style: theme.textTheme.bodySmall,
                    ),
                  const SizedBox(height: 10),
                  if (selected)
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        const Text('Équipé'),
                      ],
                    )
                  else
                    FilledButton.tonal(
                      onPressed: _busy != null
                          ? null
                          : () => _act(
                              item.id,
                              () => ref
                                  .read(playerRepositoryProvider)
                                  .equip(item.id),
                              '${item.name} équipé',
                            ),
                      child: const Text('Équiper'),
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
