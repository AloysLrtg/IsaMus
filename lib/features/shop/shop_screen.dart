import '../../core/localization/catalog_localizations.dart';
import '../../l10n/app_localizations.dart';

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
  String _error(Object error, AppLocalizations l10n) {
    if (error is PostgrestException) {
      if (error.message.contains('insuffisants')) {
        return l10n.menuNotEnoughCoinsForThisItem;
      }
      if (error.message.contains('déjà possédé')) {
        return l10n.menuThisItemIsAlreadyInYourInventory;
      }
      if (error.message.contains('Prix modifié')) {
        return l10n.menuThePriceHasChangedTheShopHasBeenRefreshed;
      }
      if (error.message.contains('indisponible')) {
        return l10n.menuThisItemIsNoLongerAvailable;
      }
    }
    return l10n.menuPurchaseFailedTryAgainShortly;
  }

  Future<void> _act(ShopItem item) async {
    if (_busy != null) return;
    final refresh = ref.read(shopRefreshProvider);
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = item.id);
    var message = '';
    try {
      await ref.read(shopRepositoryProvider).buy(item.id, item.cost);
      message = l10n.menuArg0AddedToYourInventory(
        (catalogName(l10n, item.id, item.name)).toString(),
      );
    } catch (error) {
      message = _error(error, l10n);
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
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: widget.embedded
              ? null
              : Text(AppLocalizations.of(context)!.shopTitle),
          toolbarHeight: widget.embedded ? 0 : kToolbarHeight,
          automaticallyImplyLeading: !widget.embedded,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.menuOutfits),
              Tab(text: AppLocalizations.of(context)!.menuCardBacks),
              Tab(text: AppLocalizations.of(context)!.menuHeadwear),
              Tab(text: AppLocalizations.of(context)!.menuGlasses),
              Tab(text: AppLocalizations.of(context)!.menuHair),
              Tab(text: AppLocalizations.of(context)!.menuQuickChats),
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
                    Text(AppLocalizations.of(context)!.menuShopUnavailable),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(playerProfileProvider);
                        ref.invalidate(inventoryProvider);
                        ref.invalidate(shopCatalogProvider);
                      },
                      child: Text(AppLocalizations.of(context)!.menuTryAgain),
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
                              AppLocalizations.of(context)!
                                  .menuArg0Coins((state.coins).toString()),
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
                                  Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .menuNewItemsComingSoon,
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
    final l10n = AppLocalizations.of(context)!;
    final owned = state.owned.contains(item.id);
    final theme = Theme.of(context);
    const gold = Color(0xFFFFD76B);
    const success = Color(0xFF79E7AE);
    return Container(
      key: ValueKey('shop-item-${item.id}'),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF29313E), Color(0xFF14243D), Color(0xFF101B30)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked =
                    constraints.maxWidth < 230 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20;
                final preview = _preview(item, state);
                final details = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catalogName(
                        AppLocalizations.of(context)!,
                        item.id,
                        item.name,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      catalogDescription(
                        AppLocalizations.of(context)!,
                        item.id,
                        item.description,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFBFCDDF),
                        height: 1.4,
                      ),
                    ),
                  ],
                );
                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: preview),
                      const SizedBox(height: 16),
                      details,
                    ],
                  );
                }
                return Row(
                  children: [
                    preview,
                    const SizedBox(width: 18),
                    Expanded(child: details),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            if (owned)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: success.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: success.withValues(alpha: .3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: success,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.menuOwned,
                        key: ValueKey('shop-owned-${item.id}'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Semantics(
                label: AppLocalizations.of(context)!.menuBuyArg0Arg1Coins(
                  (catalogName(l10n, item.id, item.name)).toString(),
                  (item.cost).toString(),
                ),
                child: FilledButton(
                  key: ValueKey('shop-buy-${item.id}'),
                  onPressed: _busy != null ? null : () => _act(item),
                  style: FilledButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: const Color(0xFF281D08),
                    disabledBackgroundColor: gold.withValues(alpha: .25),
                    disabledForegroundColor: const Color(0xFFFFE8AD),
                    minimumSize: const Size(0, 50),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        _busy == item.id
                            ? AppLocalizations.of(context)!.menuBuying
                            : AppLocalizations.of(context)!.menuBuy,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on_rounded, size: 21),
                          const SizedBox(width: 5),
                          Text('${item.cost}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _preview(ShopItem item, ShopState state) => Container(
    width: 112,
    height: 138,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: RadialGradient(
        radius: .85,
        colors: [
          const Color(0xFF729BCD).withValues(alpha: .22),
          const Color(0xFF0C1729).withValues(alpha: .15),
        ],
      ),
    ),
    child: switch (item.category) {
      ShopCategory.avatar ||
      ShopCategory.hat ||
      ShopCategory.glasses ||
      ShopCategory.hair => PlayerAvatarView(
        size: 104,
        config: _avatarPreview(item, state),
      ),
      ShopCategory.cardBack => Transform.rotate(
        angle: -.06,
        child: Container(
          width: 76,
          height: 108,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CardBackView(id: item.id),
        ),
      ),
      ShopCategory.quickChat => const Icon(
        Icons.forum_rounded,
        size: 58,
        color: Color(0xFFA3D8FF),
      ),
    },
  );
}
