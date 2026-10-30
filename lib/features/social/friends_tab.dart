import '../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/social_repository.dart';
import '../../core/network/presence_service.dart';
import '../../core/engine/mus_game_controller.dart';
import '../game/game_screen.dart';
import 'invite_mode_sheet.dart';
import '../../core/models/game_invitation_mode.dart';
export 'game_invitation_banner.dart';
import '../home/lobby_screen.dart';
import '../profile/player_inspection_dialog.dart';
import '../avatar/player_avatar_view.dart';
import '../../core/models/avatar_config.dart';
import 'social_banners.dart';

class FriendsTab extends ConsumerStatefulWidget {
  const FriendsTab({super.key, required this.userId, required this.username});
  final String userId, username;
  @override
  ConsumerState<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends ConsumerState<FriendsTab> {
  final _search = TextEditingController();
  List<Map<String, dynamic>>? _results;
  bool _busy = false;
  bool _choosingInvite = false;
  String? _error;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<void> Function() action, {
    String? success,
    bool refresh = false,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) {
        if (refresh) {
          ref.invalidate(friendshipsProvider);
          ref.invalidate(blockedUsersProvider);
        }
        if (success != null) {
          ref.read(socialNoticeProvider.notifier).show(success);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = AppLocalizations.of(context)!
                  .menuUnableToCompleteThisActionCheckYourConnectionOr,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invite(String friend) async {
    if (_busy || _choosingInvite) return;
    _choosingInvite = true;
    final name =
        ref
            .read(personProvider(friend))
            .asData
            ?.value['username']
            ?.toString() ??
        AppLocalizations.of(context)!.menuYourFriend;
    GameInvitationMode? mode;
    try {
      mode = await showInviteModeSheet(context, name);
    } finally {
      _choosingInvite = false;
    }
    if (mode == null || !mounted) return;
    final selection = mode;
    await _run(() async {
      final game = await ref
          .read(socialRepositoryProvider)
          .createModeInvitation(friend, selection.value);
      if (!mounted) return;
      ref
          .read(socialNoticeProvider.notifier)
          .show(
            AppLocalizations.of(context)!.menuInvitationSentArg0(
              (selection.label(AppLocalizations.of(context)!)).toString(),
            ),
          );
      if (selection.isPublic) {
        ref.invalidate(musGameControllerProvider);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GameScreen(
              gameId: game['id'] as String,
              localSeat: game['local_seat'] as int,
              players: List<dynamic>.from(game['players'] as List),
              mode: selection.value,
              userId: widget.userId,
              publicMatchmaking: true,
              initialGame: game,
            ),
          ),
        );
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LobbyScreen(
              gameId: game['id'] as String,
              playerName: widget.username,
              initialMode: 'private',
            ),
          ),
        );
      }
    });
  }

  Future<void> _find() async {
    final results = await ref
        .read(socialRepositoryProvider)
        .search(_search.text);
    if (mounted) setState(() => _results = results);
  }

  String _other(Map row) =>
      (row['receiver_id'] ?? row['user_id_2']) == widget.userId
      ? (row['sender_id'] ?? row['user_id_1']) as String
      : (row['receiver_id'] ?? row['user_id_2']) as String;
  Widget _person(
    String id, {
    String? subtitle,
    Widget? trailing,
    bool showPresence = false,
  }) {
    final online =
        showPresence &&
        ref.watch(onlineUsersProvider.select((ids) => ids.contains(id)));
    final inGame =
        showPresence &&
        ref.watch(inGameUsersProvider.select((ids) => ids.contains(id)));
    final person = ref.watch(personProvider(id));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 42,
        height: 42,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            PlayerAvatarView(
              config: AvatarConfig.fromJson(
                person.asData?.value['avatar_config'],
              ),
              size: 42,
            ),
            if (online)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  key: ValueKey('friend-online-$id'),
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4ADE80),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      title: Text(
        person.asData?.value['username']?.toString() ??
            AppLocalizations.of(context)!.menuPlayer,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showPresence
          ? Text(
              online
                  ? (inGame
                        ? AppLocalizations.of(context)!.menuInAGame
                        : AppLocalizations.of(context)!.menuOnline)
                  : AppLocalizations.of(context)!.menuOffline,
              style: TextStyle(
                color: online
                    ? const Color(0xFF4ADE80)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : subtitle == null
          ? null
          : Text(subtitle),
      trailing: trailing,
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => PlayerInspectionDialog(userId: id),
      ),
    );
  }

  Widget _friendActions(Map<String, dynamic> row) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: AppLocalizations.of(context)!.menuInviteToPlay,
        onPressed: _busy ? null : () => _invite(_other(row)),
        icon: const Icon(Icons.videogame_asset_outlined),
      ),
      PopupMenuButton<String>(
        tooltip: AppLocalizations.of(context)!.menuFriendOptions,
        enabled: !_busy,
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'remove',
            child: Text(AppLocalizations.of(context)!.menuRemoveFriend),
          ),
        ],
        onSelected: (_) => _run(
          () => ref.read(socialRepositoryProvider).remove(row['id'] as String),
          refresh: true,
        ),
      ),
    ],
  );
  Widget _card(Widget child, {Key? key}) => Card(
    key: key,
    margin: const EdgeInsets.only(bottom: 12),
    child: SizedBox(
      width: double.infinity,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    ),
  );
  Widget _failure(VoidCallback retry, String label) => Center(
    child: TextButton(onPressed: retry, child: Text(label)),
  );
  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendshipsProvider),
        blocks = ref.watch(blockedUsersProvider);
    final repository = ref.read(socialRepositoryProvider);
    final excluded = (blocks.asData?.value ?? [])
        .map((r) => r['blocked_id'])
        .toSet();
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppLocalizations.of(context)!.menuFriendsPrivateRooms,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TabBar(
            labelPadding: EdgeInsets.symmetric(horizontal: 8),
            tabs: [
              Tab(text: AppLocalizations.of(context)!.friendsTitle),
              Tab(text: AppLocalizations.of(context)!.menuRequests),
              Tab(text: AppLocalizations.of(context)!.menuBlocked),
            ],
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  key: const ValueKey('friends-list'),
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _search,
                      maxLength: 24,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .menuSearchForANickname,
                        suffixIcon: IconButton(
                          tooltip: AppLocalizations.of(context)!.menuSearch,
                          onPressed: _busy ? null : () => _run(_find),
                          icon: const Icon(Icons.search),
                        ),
                      ),
                      onSubmitted: (_) => _run(_find),
                    ),
                    if (_results != null) ...[
                      if (_results!
                          .where((p) => !excluded.contains(p['id']))
                          .isEmpty)
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            AppLocalizations.of(context)!
                                .menuNoResultsEnterAtLeast2Characters,
                          ),
                        ),
                      for (final person in _results!.where(
                        (p) => !excluded.contains(p['id']),
                      ))
                        ListTile(
                          title: Text(person['username'] as String),
                          subtitle: Text('${person['elo']} Elo'),
                          trailing: IconButton(
                            tooltip: AppLocalizations.of(context)!
                                .menuSendFriendRequest,
                            icon: const Icon(Icons.person_add_alt_1),
                            onPressed:
                                _busy ||
                                    (friends.asData?.value.any(
                                          (f) =>
                                              f['status'] != 'declined' &&
                                              _other(f) == person['id'],
                                        ) ??
                                        false)
                                ? null
                                : () => _run(
                                    () => repository.request(
                                      person['id'] as String,
                                    ),
                                    success: AppLocalizations.of(context)!
                                        .menuFriendRequestSent,
                                    refresh: true,
                                  ),
                          ),
                        ),
                      const Divider(),
                    ],
                    friends.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => _failure(
                        () => ref.invalidate(friendshipsProvider),
                        AppLocalizations.of(context)!
                            .menuUnableToLoadFriendsTryAgain,
                      ),
                      data: (rows) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (rows.every((r) => r['status'] != 'accepted'))
                            Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .menuYourListIsEmptySearchForAPlayerTo,
                              ),
                            ),
                          for (final row in rows.where(
                            (r) =>
                                r['status'] == 'accepted' &&
                                !excluded.contains(_other(r)),
                          ))
                            _card(
                              _person(
                                _other(row),
                                showPresence: true,
                                trailing: _friendActions(row),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                friends.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _failure(
                    () => ref.invalidate(friendshipsProvider),
                    AppLocalizations.of(context)!
                        .menuUnableToLoadRequestsTryAgain,
                  ),
                  data: (rows) => ListView(
                    key: const ValueKey('requests-list'),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (rows.every((r) => r['status'] != 'pending'))
                        Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            AppLocalizations.of(context)!.menuNoPendingRequests,
                          ),
                        ),
                      for (final incoming in [true, false]) ...[
                        if (rows.any(
                          (r) =>
                              r['status'] == 'pending' &&
                              ((r['receiver_id'] ?? r['user_id_2']) ==
                                      widget.userId) ==
                                  incoming,
                        ))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              incoming
                                  ? AppLocalizations.of(context)!.menuReceived
                                  : AppLocalizations.of(context)!.menuSent,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        for (final row in rows.where(
                          (r) =>
                              r['status'] == 'pending' &&
                              ((r['receiver_id'] ?? r['user_id_2']) ==
                                      widget.userId) ==
                                  incoming &&
                              !excluded.contains(_other(r)),
                        ))
                          _card(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _person(
                                  _other(row),
                                  subtitle: incoming
                                      ? AppLocalizations.of(context)!
                                            .menuRequestReceived
                                      : AppLocalizations.of(context)!
                                            .menuRequestSent,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 8,
                                    children: [
                                      if (incoming)
                                        TextButton(
                                          onPressed: _busy
                                              ? null
                                              : () => _run(
                                                  () => repository.accept(
                                                    row['id'] as String,
                                                  ),
                                                  refresh: true,
                                                ),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .menuAccept,
                                          ),
                                        ),
                                      TextButton(
                                        onPressed: _busy
                                            ? null
                                            : () => _run(
                                                () => incoming
                                                    ? repository.declineRequest(
                                                        row['id'] as String,
                                                      )
                                                    : repository.remove(
                                                        row['id'] as String,
                                                      ),
                                                refresh: true,
                                              ),
                                        child: Text(
                                          incoming
                                              ? AppLocalizations.of(context)!
                                                    .menuDecline
                                              : AppLocalizations.of(context)!
                                                    .menuCancel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            key: ValueKey('friend-request-${row['id']}'),
                          ),
                      ],
                    ],
                  ),
                ),
                blocks.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _failure(
                    () => ref.invalidate(blockedUsersProvider),
                    AppLocalizations.of(context)!
                        .menuUnableToLoadBlockedPlayersTryAgain,
                  ),
                  data: (rows) => ListView(
                    key: const ValueKey('blocked-list'),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (rows.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            AppLocalizations.of(context)!.menuNoBlockedPlayers,
                          ),
                        ),
                      for (final row in rows)
                        _card(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _person(
                                row['blocked_id'] as String,
                                subtitle: AppLocalizations.of(context)!
                                    .menuBlockedPlayer,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _busy
                                      ? null
                                      : () => _run(
                                          () => repository.unblock(
                                            row['blocked_id'] as String,
                                          ),
                                          success: AppLocalizations.of(context)!
                                              .menuPlayerUnblocked,
                                          refresh: true,
                                        ),
                                  icon: const Icon(Icons.lock_open_rounded),
                                  label: Text(
                                    AppLocalizations.of(context)!.menuUnblock,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
