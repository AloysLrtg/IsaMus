import 'package:flutter/material.dart';

import '../../core/models/player_progress.dart';

class ProfileProgressView extends StatelessWidget {
  const ProfileProgressView({super.key, required this.progress});
  final PlayerProgress progress;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      key: const ValueKey('profile-xp-card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: .45)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: .16),
            colors.surfaceContainerHigh,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primary.withValues(alpha: .18),
                foregroundColor: colors.primary,
                child: const Icon(Icons.auto_awesome_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Niveau ${progress.level}',
                  key: const ValueKey('profile-level'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${progress.xp} / ${PlayerProgress.xpPerLevel} XP',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            key: const ValueKey('profile-xp-progress'),
            value: progress.fraction,
            minHeight: 9,
            borderRadius: BorderRadius.circular(8),
            semanticsLabel:
                'Progression du niveau ${progress.level}, ${progress.xp} XP sur 500',
          ),
          const SizedBox(height: 10),
          Text(
            'Encore ${progress.xpRemaining} XP avant le niveau ${progress.level + 1}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
