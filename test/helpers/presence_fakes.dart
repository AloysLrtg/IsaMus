import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceTestChannel implements RealtimeChannel {
  PresenceTestChannel(this.options);
  final RealtimeChannelConfig options;
  void Function(RealtimePresenceSyncPayload)? sync;
  void Function(RealtimePresenceJoinPayload)? join;
  void Function(RealtimePresenceLeavePayload)? leave;
  void Function(RealtimeSubscribeStatus, Object?)? status;
  final tracked = <Map<String, dynamic>>[];
  List<SinglePresenceState> peers = [];
  int untracked = 0;
  ChannelResponse response = ChannelResponse.ok;
  @override
  RealtimeChannel onPresenceSync(
    void Function(RealtimePresenceSyncPayload) callback,
  ) {
    sync = callback;
    return this;
  }

  @override
  RealtimeChannel onPresenceJoin(
    void Function(RealtimePresenceJoinPayload) callback,
  ) {
    join = callback;
    return this;
  }

  @override
  RealtimeChannel onPresenceLeave(
    void Function(RealtimePresenceLeavePayload) callback,
  ) {
    leave = callback;
    return this;
  }

  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus, Object?)? callback,
    Duration? timeout,
  ]) {
    status = callback;
    callback?.call(RealtimeSubscribeStatus.subscribed, null);
    return this;
  }

  @override
  List<SinglePresenceState> presenceState() => peers;
  @override
  Future<ChannelResponse> track(
    Map<String, dynamic> payload, [
    Map<String, dynamic> opts = const {},
  ]) async {
    tracked.add({...payload});
    return response;
  }

  @override
  Future<ChannelResponse> untrack([
    Map<String, dynamic> opts = const {},
  ]) async {
    untracked++;
    return ChannelResponse.ok;
  }

  void snapshot(String owner, List<bool> inGame, {String event = 'sync'}) {
    peers = [
      if (inGame.isNotEmpty)
        SinglePresenceState(
          key: 'device',
          presences: [
            for (var i = 0; i < inGame.length; i++)
              Presence(
                presenceRef: '$i',
                payload: {'user_id': owner, 'in_game': inGame[i]},
              ),
          ],
        ),
    ];
    if (event == 'join') {
      join?.call(
        RealtimePresenceJoinPayload.fromJson({
          'event': 'join',
          'key': 'device',
          'newPresences': [],
          'currentPresences': [],
        }),
      );
    } else if (event == 'leave') {
      leave?.call(
        RealtimePresenceLeavePayload.fromJson({
          'event': 'leave',
          'key': 'device',
          'leftPresences': [],
          'currentPresences': [],
        }),
      );
    } else {
      sync?.call(RealtimePresenceSyncPayload.fromJson({'event': 'sync'}));
    }
  }

  void state(RealtimeSubscribeStatus value) => status?.call(value, null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PresenceTestClient extends SupabaseClient {
  PresenceTestClient()
    : super(
        'http://127.0.0.1',
        'test-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
  final rooms = <String, PresenceTestChannel>{};
  final created = <PresenceTestChannel>[], removed = <RealtimeChannel>[];
  @override
  RealtimeChannel channel(
    String name, {
    RealtimeChannelConfig opts = const RealtimeChannelConfig(),
  }) {
    final channel = PresenceTestChannel(opts);
    created.add(channel);
    rooms[name] = channel;
    return channel;
  }

  @override
  Future<String> removeChannel(RealtimeChannel channel) async {
    removed.add(channel);
    (channel as PresenceTestChannel).state(RealtimeSubscribeStatus.closed);
    return 'ok';
  }
}
