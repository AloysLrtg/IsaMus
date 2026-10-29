import 'package:flutter/material.dart';

import '../../core/models/avatar_config.dart';
import '../../core/models/player_progress.dart';
import '../avatar/player_avatar_view.dart';

class ProfileXpAvatar extends StatelessWidget {
  const ProfileXpAvatar({super.key, required this.profile});
  final Map<String, dynamic> profile;
  @override
  Widget build(BuildContext context) {
    final progress = PlayerProgress.fromJson(profile);
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Niveau ${progress.level} · ${progress.xp} / 500 XP',
      child: Semantics(
        label: 'Niveau ${progress.level}, ${progress.xp} XP sur 500',
        child: SizedBox(
          width: 40,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 1,
                child: SizedBox.square(
                  dimension: 38,
                  child: CircularProgressIndicator(
                    key: const ValueKey('home-xp-progress'),
                    value: progress.fraction,
                    strokeWidth: 2.5,
                    backgroundColor: colors.onSurface.withValues(alpha: .15),
                    color: colors.primary,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 5,
                child: PlayerAvatarView(
                  config: AvatarConfig.fromJson(profile['avatar_config']),
                  size: 30,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  key: const ValueKey('home-level-badge'),
                  constraints: const BoxConstraints(minWidth: 19),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.surface, width: 1.5),
                  ),
                  child: Text(
                    '${progress.level}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
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
