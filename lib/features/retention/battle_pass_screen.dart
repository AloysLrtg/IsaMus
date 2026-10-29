import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/network/retention_repository.dart';
import '../../core/models/player_progress.dart';
import '../../core/models/season_reward.dart';
import 'season_path_step.dart';
import '../seasons/season_countdown.dart';
import '../../core/network/player_repository.dart';
import '../../core/monetization/store_service.dart';

final vipPackageProvider = FutureProvider.autoDispose<Package?>(
  (ref) => ref.watch(storeServiceProvider).vipPackage(),
);

class BattlePassScreen extends ConsumerStatefulWidget {
  const BattlePassScreen({super.key});
  @override
  ConsumerState<BattlePassScreen> createState() => _BattlePassScreenState();
}

class _BattlePassScreenState extends ConsumerState<BattlePassScreen> {
  bool _busy = false;
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
    });
    try {
      await action();
      if (mounted) {
        ref.invalidate(retentionStatusProvider);
        ref.invalidate(playerProfileProvider);
        ref.invalidate(inventoryProvider);
      }
    } catch (_) {
      if (mounted) {
        const message =
            'Action indisponible. Réessayez dans quelques instants.';
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pass de Saison')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: SeasonCountdown(),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(retentionStatusProvider);
              await ref.read(retentionStatusProvider.future);
            },
            child: ref
                .watch(retentionStatusProvider)
                .when(
                  loading: () => ListView(
                    children: const [
                      SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                  error: (_, _) => ListView(
                    children: [
                      const ListTile(title: Text('Pass indisponible.')),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(retentionStatusProvider),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                  data: _pass,
                ),
          ),
        ),
      ],
    ),
  );

  Widget _pass(Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final season = data['season'] as Map?;
    final rewards =
        (data['rewards'] as List? ?? [])
            .whereType<Map>()
            .map(SeasonReward.fromJson)
            .toList()
          ..sort((a, b) => a.tier.compareTo(b.tier));
    final claims = (data['claims'] as List? ?? []).whereType<Map>().toList();
    final progress = PlayerProgress.fromJson(data);
    final vip = data['vip'] == true;
    final expiry = DateTime.tryParse(
      (season?['end_date'] ?? season?['ends_at'])?.toString() ?? '',
    );
    final active = expiry != null && expiry.isAfter(DateTime.now());
    final nextTier = rewards
        .where(
          (reward) =>
              reward.tier > progress.level &&
              (vip ? reward.hasVipReward : reward.hasFreeReward),
        )
        .firstOrNull
        ?.tier;
    final unlockedTiers = rewards
        .where((reward) => reward.tier <= progress.level)
        .length;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _vipControls(vip),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF263D53), Color(0xFF142035)],
                    ),
                    border: Border.all(
                      color: const Color(0xFF7CD5FF).withValues(alpha: .3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (season?['name'] ?? season?['title'])?.toString() ??
                              'Aucune saison en cours',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (season?['preview'] == true)
                          Text(
                            'Calendrier de démonstration',
                            style: theme.textTheme.labelSmall,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Niveau ${progress.level} · ${progress.xp} / 500 XP',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: nextTier == null && rewards.isNotEmpty
                              ? 1
                              : progress.fraction,
                          minHeight: 8,
                          color: const Color(0xFF7CD5FF),
                          backgroundColor: Colors.white.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$unlockedTiers / ${rewards.length} paliers débloqués',
                          key: const ValueKey('season-tier-progress'),
                        ),
                        Text(
                          '${data['coins'] ?? 0} pièces',
                          key: const ValueKey('coins-balance'),
                        ),
                        const SizedBox(height: 8),
                        if (rewards.isNotEmpty) ...[
                          Text(
                            nextTier == null
                                ? 'Tous les paliers sont débloqués !'
                                : 'Prochain objectif : palier $nextTier',
                            key: const ValueKey('season-next-objective'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF7CD5FF),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (nextTier != null && active)
                            Text(
                              'Encore ${(nextTier - progress.level) * PlayerProgress.xpPerLevel - progress.xp} XP pour l’atteindre.',
                              style: theme.textTheme.bodySmall,
                            ),
                          const SizedBox(height: 12),
                        ],
                        const Text(
                          'Touchez une récompense débloquée pour la récupérer. Une récompense gratuite tous les 5 paliers ; une récompense VIP à chaque palier.',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                  child: _busy ? const LinearProgressIndicator() : null,
                ),
                const SizedBox(height: 20),
                Text(
                  'Route des récompenses',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    _RouteLegend(
                      icon: Icons.check_circle_rounded,
                      color: Color(0xFF79E7AE),
                      label: 'Atteint',
                    ),
                    _RouteLegend(
                      icon: Icons.flag_rounded,
                      color: Color(0xFF7CD5FF),
                      label: 'Objectif',
                    ),
                    _RouteLegend(
                      icon: Icons.lock_outline_rounded,
                      color: Color(0xFF9CAABE),
                      label: 'À venir',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return SeasonPathStep(
                key: ValueKey('season-tier-${reward.tier}'),
                reward: reward,
                level: progress.level,
                nextTier: nextTier,
                vip: vip,
                active: active,
                busy: _busy,
                freeClaimed: claims.any(
                  (c) => c['tier'] == reward.tier && c['vip_track'] == false,
                ),
                vipClaimed: claims.any(
                  (c) => c['tier'] == reward.tier && c['vip_track'] == true,
                ),
                first: index == 0,
                last: index == rewards.length - 1,
                onClaim: (premium) => _run(() async {
                  final earned = await ref
                      .read(retentionRepositoryProvider)
                      .claim(
                        reward.tier,
                        vip: premium,
                        seasonId: season!['id'].toString(),
                      );
                  if (!mounted) return;
                  final message = earned['already_claimed'] == true
                      ? 'Récompense déjà reçue'
                      : '${earned['coins']} pièces reçues${earned['cosmetic'] != null ? ' · Cosmétique débloqué' : ''}';
                  ScaffoldMessenger.of(this.context)
                      .showSnackBar(SnackBar(content: Text(message)));
                }),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _vipControls(bool vip) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      key: const ValueKey('vip-premium-offer'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(colors.surface, colors.primary, .28)!,
            colors.surfaceContainerLow,
          ],
        ),
        border: Border.all(
          color: colors.primary.withValues(alpha: .65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 42,
                color: colors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREMIUM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      vip
                          ? 'Votre Pass VIP est actif'
                          : 'Débloquez le Pass VIP',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final perk in [
                (Icons.block_rounded, 'Sans publicités'),
                (Icons.card_giftcard_rounded, 'Voie VIP du Pass'),
                (Icons.bolt_rounded, 'XP ×2'),
              ])
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(perk.$1, size: 18, color: colors.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          perk.$2,
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Les pièces se gagnent uniquement dans le Pass de Saison. XP ×2 sur les parties et les quêtes.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          ref
              .watch(vipPackageProvider)
              .when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) =>
                    const Text('Le VIP est momentanément indisponible.'),
                data: (package) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      key: const ValueKey('purchase-vip'),
                      onPressed: _busy || package == null || vip
                          ? null
                          : () => _run(
                              () => ref
                                  .read(storeServiceProvider)
                                  .purchase(package),
                            ),
                      icon: const Icon(Icons.workspace_premium),
                      label: Text(
                        vip
                            ? 'VIP actif'
                            : package == null
                            ? 'VIP bientôt disponible'
                            : 'Devenir VIP · ${package.storeProduct.priceString}/mois',
                      ),
                    ),
                    if (package != null)
                      const Text(
                        'Abonnement mensuel renouvelé automatiquement. Annulable depuis votre store.',
                        style: TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
          TextButton(
            onPressed: _busy || !ref.read(storeServiceProvider).configured
                ? null
                : () => _run(() => ref.read(storeServiceProvider).restore()),
            child: const Text('Restaurer mes achats'),
          ),
        ],
      ),
    );
  }
}

class _RouteLegend extends StatelessWidget {
  const _RouteLegend({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}
