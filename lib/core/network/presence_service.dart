import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceIds extends StateNotifier<Set<String>> {
  PresenceIds() : super(const {});
  void replace(Set<String> ids) {
    if (!setEquals(state, ids)) state = Set.unmodifiable(ids);
  }
}

final onlineUsersProvider = StateNotifierProvider<PresenceIds, Set<String>>(
  (ref) => PresenceIds(),
);
final inGameUsersProvider = StateNotifierProvider<PresenceIds, Set<String>>(
  (ref) => PresenceIds(),
);
final presenceClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
final presenceServiceProvider = Provider((ref) {
  var alive = true;
  final service = PresenceService(
    clientFactory: () => ref.read(presenceClientProvider),
    onChanged: (online, inGame) {
      // Socket callbacks may run during subscription setup, never mutate a
      // Riverpod state while the session's widget/provider is being built.
      scheduleMicrotask(() {
        if (!alive) return;
        ref.read(onlineUsersProvider.notifier).replace(online);
        ref.read(inGameUsersProvider.notifier).replace(inGame);
      });
    },
  );
  ref.onDispose(() {
    alive = false;
    service.dispose();
  });
  return service;
});

class _PresenceChannel {
  _PresenceChannel(this.id, this.channel);
  final String id;
  final RealtimeChannel channel;
  bool connected = false, online = false, inGame = false, selfTracked = false;
  int failures = 0;
  Timer? retry;
  Future<void> writes = Future.value();
}

/// Private per-user topics bind identity to RLS. Only accepted friends observe
/// another user's topic; an observer never tracks itself in that friend's room.
class PresenceService with WidgetsBindingObserver {
  PresenceService({this.clientInstance, this.clientFactory, this.onChanged}) {
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _active =
        lifecycle == null ||
        lifecycle == AppLifecycleState.resumed ||
        lifecycle == AppLifecycleState.inactive;
  }
  final SupabaseClient? clientInstance;
  final SupabaseClient Function()? clientFactory;
  SupabaseClient? _resolvedClient;
  final void Function(Set<String> online, Set<String> inGame)? onChanged;
  SupabaseClient get _client => _resolvedClient ??=
      clientInstance ?? clientFactory?.call() ?? Supabase.instance.client;
  final _channels = <String, _PresenceChannel>{};
  Set<String> _friends = {};
  String? _id;
  bool _inGame = false, _active = true, _disposed = false;
  int _generation = 0;

  bool _current(_PresenceChannel entry) =>
      !_disposed && identical(_channels[entry.id], entry);
  Future<void> connect(String id) async {
    if (_disposed || id.isEmpty) return;
    if (_id == id && _channels.containsKey(id)) return;
    final client =
        _client; // Fail before taking ownership if Supabase isn't initialized.
    if (_id != null && _id != id) {
      _friends = {};
      _inGame = false;
    }
    final generation = ++_generation;
    final old = _channels.values.toList();
    _channels.clear();
    _id = id;
    _publish();
    await Future.wait(old.map((entry) => _close(entry, client)));
    if (_disposed || generation != _generation) return;
    _open(id);
    _watchFriends();
  }

  void setFriends(Set<String> ids) {
    _friends = {...ids}..remove(_id);
    _watchFriends();
  }

  void _watchFriends() {
    final own = _id;
    if (_disposed || own == null) return;
    final obsolete = _channels.keys
        .where((id) => id != own && !_friends.contains(id))
        .toList();
    for (final id in obsolete) {
      final entry = _channels.remove(id)!;
      unawaited(_close(entry, _client));
    }
    for (final id in _friends) {
      if (id != own && !_channels.containsKey(id)) _open(id);
    }
    _publish();
  }

  void _open(String id) {
    if (_disposed || _channels.containsKey(id)) return;
    final channel = _client.channel(
      'presence:$id',
      opts: const RealtimeChannelConfig(private: true, enabled: true),
    );
    final entry = _PresenceChannel(id, channel);
    _channels[id] = entry;
    channel
        .onPresenceSync((_) => _sync(entry))
        .onPresenceJoin((_) => _sync(entry))
        .onPresenceLeave((_) => _sync(entry))
        .subscribe((status, _) {
          if (!_current(entry)) return;
          entry.retry?.cancel();
          entry.retry = null;
          entry.connected = status == RealtimeSubscribeStatus.subscribed;
          if (entry.connected) {
            // Wait for a fresh snapshot after a reconnect.
            if (id == _id) unawaited(_write(entry));
          } else {
            entry.online = false;
            entry.inGame = false;
            entry.selfTracked = false;
            _publish();
            // The SDK rejoins on errors/timeouts with backoff. A closed channel,
            // however, is terminal and must be replaced (unless we disposed it).
            if (status == RealtimeSubscribeStatus.closed) _reopenLater(entry);
          }
        });
  }

  void _sync(_PresenceChannel entry) {
    if (!_current(entry) || !entry.connected) return;
    final peers = entry.channel
        .presenceState()
        .expand((state) => state.presences)
        .where(
          (p) =>
              p.payload['user_id'] == null || p.payload['user_id'] == entry.id,
        )
        .toList();
    entry.online = peers.isNotEmpty || entry.selfTracked;
    entry.inGame =
        peers.any((p) => p.payload['in_game'] == true) ||
        entry.selfTracked && _inGame;
    _publish();
  }

  void _publish() {
    if (_disposed) return;
    final visible = _channels.values.where(
      (entry) => entry.connected && entry.online,
    );
    onChanged?.call(
      Set.unmodifiable(visible.map((e) => e.id)),
      Set.unmodifiable(visible.where((e) => e.inGame).map((e) => e.id)),
    );
  }

  Future<void> _write(_PresenceChannel entry) {
    entry.writes = entry.writes.then((_) async {
      if (!_current(entry) || !entry.connected || entry.id != _id) return;
      final active = _active;
      final inGame = _inGame;
      try {
        final response = active
            ? await entry.channel
                  .track({'user_id': entry.id, 'in_game': inGame})
                  .timeout(const Duration(seconds: 3))
            : await entry.channel.untrack().timeout(const Duration(seconds: 3));
        if (response != ChannelResponse.ok) {
          throw StateError('Presence not acknowledged');
        }
        if (!_current(entry) || !entry.connected) return;
        entry.failures = 0;
        entry.selfTracked = active && _active;
        entry.online = entry.selfTracked;
        entry.inGame = entry.selfTracked && inGame;
        _publish();
      } catch (_) {
        if (!_current(entry) || !entry.connected) return;
        entry.retry?.cancel();
        final seconds = 1 << entry.failures.clamp(0, 4);
        entry.failures++;
        entry.retry = Timer(Duration(seconds: seconds), () {
          entry.retry = null;
          if (_current(entry) && entry.connected) unawaited(_write(entry));
        });
      }
    });
    return entry.writes;
  }

  void _reopenLater(_PresenceChannel entry) {
    entry.retry = Timer(const Duration(seconds: 1), () async {
      entry.retry = null;
      if (!_current(entry)) return;
      _channels.remove(entry.id);
      await _close(entry, _client);
      if (!_disposed &&
          _id != null &&
          (entry.id == _id || _friends.contains(entry.id)) &&
          !_channels.containsKey(entry.id)) {
        _open(entry.id);
      }
    });
  }

  Future<void> setInGame(bool value) async {
    if (_disposed) return;
    _inGame = value;
    final entry = _channels[_id];
    if (entry != null) await _write(entry);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed || state == AppLifecycleState.inactive) return;
    _active = state == AppLifecycleState.resumed;
    final entry = _channels[_id];
    if (entry != null) unawaited(_write(entry));
  }

  Future<void> _close(_PresenceChannel entry, SupabaseClient client) async {
    entry.retry?.cancel();
    if (entry.selfTracked) {
      try {
        await entry.channel.untrack().timeout(const Duration(seconds: 1));
      } catch (_) {}
    }
    try {
      await client
          .removeChannel(entry.channel)
          .timeout(const Duration(seconds: 2));
    } catch (_) {}
  }

  Future<void> disconnect() async {
    ++_generation;
    final old = _channels.values.toList();
    _channels.clear();
    _id = null;
    _inGame = false;
    _publish();
    if (old.isNotEmpty) {
      await Future.wait(old.map((entry) => _close(entry, _client)));
    }
  }

  void dispose() {
    if (_disposed) return;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(disconnect());
    _disposed = true;
  }
}
