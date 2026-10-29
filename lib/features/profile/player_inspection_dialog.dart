import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/player_repository.dart';
import '../../core/network/social_repository.dart';
import '../../core/network/auth_repository.dart';
import '../../core/models/avatar_config.dart';
import '../../core/models/profile_statistics.dart';
import '../avatar/player_avatar_view.dart';
import '../social/social_banners.dart';

class PlayerInspectionDialog extends ConsumerStatefulWidget {
  const PlayerInspectionDialog({super.key, required this.userId});
  final String userId;
  @override
  ConsumerState<PlayerInspectionDialog> createState() =>
      _PlayerInspectionDialogState();
}

class _PlayerInspectionDialogState
    extends ConsumerState<PlayerInspectionDialog> {
  bool _sending = false;
  String? _error;
  Future<void> _addFriend() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(socialRepositoryProvider).request(widget.userId);
      if (mounted) {
        ref.invalidate(friendshipsProvider);
        ref
            .read(socialNoticeProvider.notifier)
            .show('Demande d’amitié envoyée');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible d’envoyer la demande. Réessayez.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleBlock(bool blocked) async {
    if (_sending) return;
    if (!blocked) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          title: const Text('Bloquer ce joueur ?'),
          content: const Text(
            'Votre amitié sera supprimée et vos demandes et invitations en attente seront annulées. Ce joueur ne pourra plus vous contacter ainsi. Vous pourrez le débloquer depuis l’onglet Bloqués.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Bloquer'),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final repo = ref.read(socialRepositoryProvider);
      if (blocked) {
        await repo.unblock(widget.userId);
      } else {
        await repo.block(widget.userId);
      }
      if (mounted) {
        ref.invalidate(blockedUsersProvider);
        ref.invalidate(friendshipsProvider);
        ref
            .read(socialNoticeProvider.notifier)
            .show(
              blocked ? 'Joueur débloqué' : 'Joueur bloqué',
              kind: SocialNoticeKind.information,
            );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Impossible de modifier le blocage. Réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final me = ref.watch(authRepositoryProvider).currentUserId;
    final relations = me != null && me != widget.userId
        ? ref.watch(friendshipsProvider)
        : const AsyncValue<List<Map<String, dynamic>>>.data([]);
    final blocked =
        me != null &&
        (ref
                .watch(blockedUsersProvider)
                .asData
                ?.value
                .any((r) => r['blocked_id'] == widget.userId) ??
            false);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.primary.withValues(alpha: .26),
                              colors.tertiary.withValues(alpha: .12),
                              colors.surface,
                            ],
                          ),
                        ),
                        child: ref
                            .watch(publicPlayerProfileProvider(widget.userId))
                            .when(
                              loading: () => const SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (_, _) => Column(
                                children: [
                                  const Text('Profil indisponible.'),
                                  TextButton(
                                    onPressed: () => ref.invalidate(
                                      publicPlayerProfileProvider(
                                        widget.userId,
                                      ),
                                    ),
                                    child: const Text('Réessayer'),
                                  ),
                                ],
                              ),
                              data: (profile) => Column(
                                children: [
                                  PlayerAvatarView(
                                    config: AvatarConfig.fromJson(
                                      profile['avatar_config'],
                                    ),
                                    size: 96,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    profile['username']?.toString() ?? 'Joueur',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Profil du joueur',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ),
                    ],
                  ),
                  ref
                      .watch(publicPlayerProfileProvider(widget.userId))
                      .when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (profile) {
                          final stats = ProfileStatistics.fromProfile(profile);
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final width =
                                        (constraints.maxWidth - 12) / 2;
                                    return Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        _stat(
                                          width,
                                          Icons.emoji_events_rounded,
                                          '${stats.elo}',
                                          'Elo actuel',
                                        ),
                                        _stat(
                                          width,
                                          Icons.workspace_premium_rounded,
                                          '${stats.peakElo}',
                                          'Peak Elo',
                                        ),
                                        _stat(
                                          width,
                                          Icons.trending_up_rounded,
                                          '${stats.global.winPercent} %',
                                          'Taux de victoire',
                                        ),
                                        _stat(
                                          width,
                                          Icons.sports_esports_rounded,
                                          '${stats.global.played}',
                                          'Parties jouées',
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  '${stats.global.won} victoires · ${stats.global.lost} défaites',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (blocked)
                                  const FilledButton(
                                    onPressed: null,
                                    child: Text('Joueur bloqué'),
                                  )
                                else
                                  _friendButton(me, relations),
                                if (me != null && me != widget.userId)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: OutlinedButton.icon(
                                      key: const ValueKey(
                                        'block-player-button',
                                      ),
                                      onPressed: _sending
                                          ? null
                                          : () => _toggleBlock(blocked),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .error,
                                      ),
                                      icon: Icon(
                                        blocked
                                            ? Icons.lock_open_rounded
                                            : Icons.block_rounded,
                                      ),
                                      label: Text(
                                        blocked ? 'Débloquer' : 'Bloquer',
                                      ),
                                    ),
                                  ),
                                if (_error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      _error!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: colors.error),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                key: const ValueKey('close-player-card'),
                tooltip: 'Fermer',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(double width, IconData icon, String value, String label) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: .12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendButton(
    String? me,
    AsyncValue<List<Map<String, dynamic>>> relations,
  ) {
    String label = 'Ajouter en ami';
    IconData icon = Icons.person_add_rounded;
    VoidCallback? action;
    if (me == null) {
      label = 'Connexion requise';
    } else if (me == widget.userId) {
      label = 'Votre profil';
      icon = Icons.person_rounded;
    } else if (_sending) {
      label = 'Envoi en cours…';
    } else if (relations.isLoading) {
      label = 'Vérification de la relation…';
    } else {
      relations.when(
        data: (rows) {
          final relation = rows.where((row) {
            final sender = row['sender_id'] ?? row['user_id_1'],
                receiver = row['receiver_id'] ?? row['user_id_2'];
            return sender == me && receiver == widget.userId ||
                sender == widget.userId && receiver == me;
          }).firstOrNull;
          if (relation?['status'] == 'accepted') {
            label = 'Déjà amis';
            icon = Icons.check_circle_outline_rounded;
          } else if (relation?['status'] == 'pending') {
            label = (relation?['sender_id'] ?? relation?['user_id_1']) == me
                ? 'Demande envoyée'
                : 'Demande reçue';
            icon = Icons.mark_email_read_outlined;
          } else {
            action = _addFriend;
          }
        },
        error: (_, _) {
          label = 'Réessayer la relation';
          icon = Icons.refresh_rounded;
          action = () => ref.invalidate(friendshipsProvider);
        },
        loading: () {
          label = 'Vérification de la relation…';
        },
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        key: const ValueKey('add-player-friend'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onPressed: action,
        icon: Icon(icon),
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
