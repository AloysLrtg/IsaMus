import 'package:flutter/material.dart';

/// The shared season ticker owns the periodic timer and cancels it on disposal.
class CountdownWidget extends StatelessWidget {
  const CountdownWidget({super.key, required this.remaining});
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final value = remaining.isNegative ? Duration.zero : remaining;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final blocks = [
      ('days', value.inDays, 'Jours'),
      ('hours', value.inHours % 24, 'Heures'),
      ('minutes', value.inMinutes % 60, 'Minutes'),
      ('seconds', value.inSeconds % 60, 'Secondes'),
    ];
    return Semantics(
      label:
          'Fin de saison dans ${value.inDays} jours, ${value.inHours % 24} heures, ${value.inMinutes % 60} minutes et ${value.inSeconds % 60} secondes',
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < blocks.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  key: ValueKey('countdown-${blocks[i].$1}'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: .25),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 32,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            key: ValueKey(
                              'countdown-${blocks[i].$1}-${blocks[i].$2}',
                            ),
                            child: Text(
                              blocks[i].$2.toString().padLeft(2, '0'),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w900,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          blocks[i].$3,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
