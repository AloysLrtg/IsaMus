import '../../l10n/app_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/game_invitation_mode.dart';
import '../../core/network/social_repository.dart';
import '../../core/network/auth_repository.dart';
import '../../core/engine/mus_game_controller.dart';
import '../game/game_screen.dart';
import '../home/lobby_screen.dart';

final invitationClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

class InvitationInbox extends ConsumerStatefulWidget {
  const InvitationInbox({super.key, required this.username, this.navigatorKey});
  final String username;
  final GlobalKey<NavigatorState>? navigatorKey;
  @override
  ConsumerState<InvitationInbox> createState() => _InvitationInboxState();
}

class _InvitationInboxState extends ConsumerState<InvitationInbox> {
  bool _busy = false;
  String? _error;
  Timer? _expiryTimer;
  DateTime? _expiry;
  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _armExpiry(DateTime? expiry, DateTime now) {
    if (expiry == _expiry) return;
    _expiryTimer?.cancel();
    _expiry = expiry;
    if (expiry != null) {
      _expiryTimer = Timer(expiry.difference(now), () {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _respond(Map<String, dynamic> invitation, bool accept) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(socialRepositoryProvider);
      if (accept) {
        final currentGame = ref.read(musGameControllerProvider.notifier).gameId;
        if (currentGame != null) {
          throw StateError(
            AppLocalizations.of(context)!.menuLeaveYourCurrentGame,
          );
        }
        final game = await repo.acceptGameInvitation(
          invitation['id'] as String,
        );
        if (!mounted) return;
        final navigator =
            widget.navigatorKey?.currentState ?? Navigator.maybeOf(context);
        if (navigator == null) {
          throw StateError(
            AppLocalizations.of(context)!.menuNavigationUnavailable,
          );
        }
        final mode = GameInvitationMode.parse(game['mode']);
        ref.invalidate(invitationsProvider);
        if (mode.isPublic) {
          ref.invalidate(musGameControllerProvider);
          navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => GameScreen(
                gameId: game['id'] as String,
                localSeat: game['local_seat'] as int,
                players: List<dynamic>.from(game['players'] as List),
                mode: mode.value,
                userId: ref.read(authRepositoryProvider).currentUserId,
                publicMatchmaking: true,
                initialGame: game,
              ),
            ),
          );
        } else {
          navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => LobbyScreen(
                gameId: game['id'] as String,
                playerName: widget.username,
                initialMode: 'private',
              ),
            ),
          );
        }
      } else {
        await repo.decline(invitation['id'] as String);
        if (mounted) ref.invalidate(invitationsProvider);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = AppLocalizations.of(context)!
                  .menuInvitationUnavailableLeaveYourCurrentGameOrTryAgain,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(invitationsProvider).asData?.value ?? [];
    final now = ref.read(invitationClockProvider)();
    final pending = rows
        .where(
          (r) =>
              r['status'] == 'pending' &&
              (DateTime.tryParse(r['expires_at']?.toString() ?? '')
                      ?.isAfter(now) ??
                  false),
        )
        .toList();
    final deadlines =
        pending.map((r) => DateTime.parse(r['expires_at'] as String)).toList()
          ..sort();
    _armExpiry(deadlines.firstOrNull, now);
    if (pending.isEmpty) return const SizedBox.shrink();
    final invite = pending.first,
        mode = GameInvitationMode.parse(pending.first['mode']);
    final sender =
        ref
            .watch(personProvider(invite['sender_id'] as String))
            .asData
            ?.value['username']
            ?.toString() ??
        AppLocalizations.of(context)!.menuAFriend;
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    return Material(
      key: ValueKey('game-invitation-${invite['id']}'),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary.withValues(alpha: .4)),
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: .18),
              colors.surfaceContainerHigh,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(mode.icon, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.menuArg0InvitesYouToPlayArg1(
                      (sender).toString(),
                      (mode.label(AppLocalizations.of(context)!)).toString(),
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mode.isPublic
                  ? AppLocalizations.of(context)!.menuYouWillPlayOnTheSameTeam
                  : AppLocalizations.of(context)!.menuChooseYourTeamsInTheRoom,
              style: theme.textTheme.bodySmall,
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: colors.error)),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: _busy ? null : () => _respond(invite, false),
                  child: Text(AppLocalizations.of(context)!.menuDecline296),
                ),
                FilledButton(
                  onPressed: _busy ? null : () => _respond(invite, true),
                  child: Text(AppLocalizations.of(context)!.menuJoin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
