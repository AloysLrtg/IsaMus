import 'package:flutter/material.dart';

import '../../core/models/game_invitation_mode.dart';

Future<GameInvitationMode?> showInviteModeSheet(
  BuildContext context,
  String name,
) {
  FocusManager.instance.primaryFocus?.unfocus();
  var selected = false;
  return showModalBottomSheet<GameInvitationMode>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (context) {
      final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Inviter $name',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choisissez comment jouer ensemble.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              for (final mode in GameInvitationMode.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: ValueKey('invite-mode-${mode.value}'),
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        if (selected) return;
                        selected = true;
                        Navigator.of(context).pop(mode);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: .35),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              colors.primary.withValues(alpha: .16),
                              colors.surfaceContainerHigh,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Icon(mode.icon, size: 30, color: colors.primary),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mode.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mode.isPublic
                                        ? 'Même équipe, face à deux autres joueurs'
                                        : 'Salon avec code et choix des équipes',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
