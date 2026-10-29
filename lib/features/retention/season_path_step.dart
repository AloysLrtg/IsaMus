import 'package:flutter/material.dart';

import '../../core/models/season_reward.dart';

/// Adjacent steps have no vertical margin, so their painted segments join.
class SeasonPathStep extends StatelessWidget {
  const SeasonPathStep({
    super.key,
    required this.reward,
    required this.level,
    required this.vip,
    required this.active,
    required this.busy,
    required this.freeClaimed,
    required this.vipClaimed,
    required this.first,
    required this.last,
    required this.onClaim,
    this.nextTier,
  });
  final SeasonReward reward;
  final int level;
  final int? nextTier;
  final bool vip, active, busy, freeClaimed, vipClaimed, first, last;
  final ValueChanged<bool> onClaim;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unlocked = reward.tier <= level;
    final current =
        active &&
        reward.tier == (nextTier ?? level + 1) &&
        (vip ? reward.hasVipReward : reward.hasFreeReward);
    const success = Color(0xFF79E7AE);
    const focus = Color(0xFF7CD5FF);
    final nodeColor = current
        ? focus
        : unlocked
        ? success
        : colors.outlineVariant;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 190),
      child: IntrinsicHeight(
        child: CustomPaint(
          painter: SeasonRoutePainter(
            first: first,
            last: last,
            upperColor: unlocked ? success : colors.outlineVariant,
            lowerColor: reward.tier < level ? success : colors.outlineVariant,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _RewardTile(
                        reward: reward,
                        premium: false,
                        vip: vip,
                        unlocked: unlocked,
                        current: current,
                        active: active,
                        busy: busy,
                        claimed: freeClaimed,
                        onTap: () => onClaim(false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 72),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _RewardTile(
                        reward: reward,
                        premium: true,
                        vip: vip,
                        unlocked: unlocked,
                        current: current && vip,
                        active: active,
                        busy: busy,
                        claimed: vipClaimed,
                        onTap: () => onClaim(true),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: Center(
                  child: Semantics(
                    label:
                        'Palier ${reward.tier}, ${current
                            ? 'prochain objectif'
                            : unlocked
                            ? 'atteint'
                            : 'verrouillé'}',
                    child: AnimatedContainer(
                      key: ValueKey('season-node-${reward.tier}'),
                      duration: const Duration(milliseconds: 250),
                      width: current ? 54 : 42,
                      height: current ? 54 : 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: current
                            ? const Color(0xFF16394D)
                            : colors.surface,
                        border: Border.all(
                          color: nodeColor,
                          width: current ? 3 : 2,
                        ),
                        boxShadow: current
                            ? [
                                BoxShadow(
                                  color: focus.withValues(alpha: .22),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${reward.tier}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: nodeColor,
                                ),
                              ),
                            ),
                          ),
                          if (unlocked)
                            Positioned(
                              top: -6,
                              right: -6,
                              child: Icon(
                                Icons.check_circle_rounded,
                                key: ValueKey('season-reached-${reward.tier}'),
                                color: success,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SeasonRoutePainter extends CustomPainter {
  const SeasonRoutePainter({
    required this.first,
    required this.last,
    required this.upperColor,
    required this.lowerColor,
  });
  final bool first, last;
  final Color upperColor, lowerColor;
  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final y = size.height / 2;
    final paint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    if (!first) {
      canvas.drawLine(Offset(x, 0), Offset(x, y), paint..color = upperColor);
    }
    if (!last) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, size.height),
        paint..color = lowerColor,
      );
    }
    canvas.drawLine(
      Offset(x - 36, y),
      Offset(x + 36, y),
      paint
        ..strokeWidth = 1.5
        ..color = upperColor,
    );
  }

  @override
  bool shouldRepaint(SeasonRoutePainter oldDelegate) =>
      first != oldDelegate.first ||
      last != oldDelegate.last ||
      upperColor != oldDelegate.upperColor ||
      lowerColor != oldDelegate.lowerColor;
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.reward,
    required this.premium,
    required this.vip,
    required this.unlocked,
    required this.current,
    required this.active,
    required this.busy,
    required this.claimed,
    required this.onTap,
  });
  final SeasonReward reward;
  final bool premium, vip, unlocked, current, active, busy, claimed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasReward = premium ? reward.hasVipReward : reward.hasFreeReward;
    final available =
        hasReward &&
        unlocked &&
        active &&
        (!premium || vip) &&
        !claimed &&
        !busy;
    final coins = (premium ? reward.vipCoins : reward.freeCoins ?? 0);
    const success = Color(0xFF79E7AE);
    const focus = Color(0xFF7CD5FF);
    final muted = colors.onSurfaceVariant.withValues(alpha: .72);
    final accent = claimed && hasReward
        ? success
        : current && hasReward
        ? focus
        : available
        ? colors.primary
        : colors.outlineVariant;
    final label = premium ? 'VIP' : 'Gratuite';
    final status = !hasReward
        ? 'Aucune récompense'
        : claimed
        ? 'Acquis'
        : !unlocked
        ? current
              ? 'Prochain objectif'
              : 'Niveau ${reward.tier}'
        : premium && !vip
        ? 'VIP requis'
        : !active
        ? 'Saison terminée'
        : busy
        ? 'Patientez…'
        : 'Récupérer';
    return Semantics(
      button: hasReward,
      enabled: available,
      label:
          '$label, palier ${reward.tier}, $status${hasReward ? ', $coins pièces' : ''}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('claim-pass-$premium-${reward.tier}'),
          borderRadius: BorderRadius.circular(18),
          onTap: available ? onTap : null,
          child: Ink(
            decoration: BoxDecoration(
              gradient: hasReward
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: claimed
                          ? [colors.surfaceContainerLow, colors.surface]
                          : current
                          ? [
                              const Color(0xFF1B354A),
                              colors.surfaceContainerLow,
                            ]
                          : [
                              colors.surfaceContainerHigh,
                              colors.surfaceContainerLow,
                            ],
                    )
                  : null,
              color: hasReward ? null : colors.surface.withValues(alpha: .4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: accent,
                width: current && hasReward ? 2 : 1,
              ),
              boxShadow: current && hasReward || available
                  ? [
                      BoxShadow(
                        color: (current ? focus : colors.primary).withValues(
                          alpha: .12,
                        ),
                        blurRadius: 14,
                      ),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: current && hasReward
                        ? focus
                        : hasReward && unlocked
                        ? colors.primary
                        : muted,
                  ),
                ),
                const SizedBox(height: 8),
                if (claimed && hasReward)
                  Icon(
                    Icons.check_circle,
                    key: ValueKey('season-claimed-$premium-${reward.tier}'),
                    color: success,
                    size: 26,
                  )
                else
                  Icon(
                    !hasReward
                        ? Icons.block
                        : !unlocked || premium && !vip
                        ? current && (!premium || vip)
                              ? Icons.flag_rounded
                              : Icons.lock_outline
                        : Icons.monetization_on_rounded,
                    color: current && hasReward
                        ? focus
                        : available
                        ? colors.primary
                        : muted,
                    size: 32,
                  ),
                if (hasReward) ...[
                  const SizedBox(height: 6),
                  Text(
                    '$coins pièces',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: claimed
                          ? colors.onSurfaceVariant
                          : unlocked || current
                          ? colors.onSurface
                          : muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (premium && reward.hasCosmeticPreview)
                    Tooltip(
                      message: 'Aperçu uniquement : cosmétique à définir, non distribué actuellement.',
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Cosmétique à venir',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                    ),
                  if (premium && reward.vipCosmetic != null)
                    Text(
                      reward.vipCosmetic == 'gold' ? 'Dos Or' : 'Tapis Rubis',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall,
                    ),
                ],
                const SizedBox(height: 8),
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: claimed && hasReward
                        ? success
                        : current && hasReward
                        ? focus
                        : available
                        ? colors.primary
                        : muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
