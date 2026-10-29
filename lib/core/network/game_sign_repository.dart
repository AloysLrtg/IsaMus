import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';
import 'table_chat_event.dart';

final gameSignRepositoryProvider = Provider((ref) => GameSignRepository());

class SignBroadcast {
  const SignBroadcast({
    required this.senderId,
    required this.seat,
    required this.sign,
    required this.handId,
    required this.id,
  });

  /// Sender identity is taken from the RLS-protected topic, never the payload.
  final String senderId;
  final int seat;
  final String sign;
  final String handId;
  final String id;
  Map<String, dynamic> toJson() => {
    'seat': seat,
    'sign': sign,
    'hand_id': handId,
    'id': id,
  };
}

abstract class GameSignSession {
  Stream<SignBroadcast> get events;
  void updateRoster(List<dynamic> players);
  Future<void> send(SignBroadcast sign);
  Future<void> close();
}

class GameSignRepository {
  GameSignRepository({this.clientInstance});
  final SupabaseClient? clientInstance;
  GameSignSession open(String gameId) => SupabaseGameSignSession(
    clientInstance ?? Supabase.instance.client,
    gameId,
  );
}

class SupabaseGameSignSession implements GameSignSession, GameChatSession {
  SupabaseGameSignSession(
    this.client,
    this.gameId, {
    String? authenticatedUserId,
  }) {
    userId =
        authenticatedUserId ??
        client.auth.currentUser?.id ??
        (throw StateError('Session requise'));
    _subscribe(userId);
  }
  final SupabaseClient client;
  final String gameId;
  late final String userId;
  final _events = StreamController<SignBroadcast>.broadcast();
  final _chatEvents = StreamController<TableChatEvent>.broadcast();
  @override
  Stream<TableChatEvent> get chatEvents => _chatEvents.stream;
  final _channels = <String, RealtimeChannel>{};
  final _ready = <String>{};
  bool _closed = false;
  @override
  Stream<SignBroadcast> get events => _events.stream;

  void _subscribe(String owner) {
    if (_closed || _channels.containsKey(owner)) return;
    final channel = client.channel(
      'game-signs:$gameId:$owner',
      opts: const RealtimeChannelConfig(private: true, ack: true, self: false),
    );
    _channels[owner] = channel;
    channel
        .onBroadcast(
          event: 'table_chat',
          callback: (payload) {
            if (_closed) return;
            final event = TableChatEvent.parse(owner, payload);
            if (event != null) _chatEvents.add(event);
          },
        )
        .onBroadcast(
          event: 'keinu',
          callback: (payload) {
            if (_closed) return;
            final seat = payload['seat'];
            final sign = payload['sign'];
            final hand = payload['hand_id'];
            final id = payload['id'];
            if (seat is! int ||
                seat < 0 ||
                seat > 3 ||
                sign is! String ||
                sign.length > 32 ||
                hand is! String ||
                hand.length > 64 ||
                id is! String ||
                id.length > 100) {
              return;
            }
            _events.add(
              SignBroadcast(
                senderId: owner,
                seat: seat,
                sign: sign,
                handId: hand,
                id: id,
              ),
            );
          },
        )
        .subscribe((status, _) {
          if (_closed) return;
          if (status == RealtimeSubscribeStatus.subscribed) {
            _ready.add(owner);
          } else {
            _ready.remove(owner);
          }
        });
  }

  @override
  void updateRoster(List<dynamic> players) {
    final owners = {
      userId,
      for (final player in players)
        if (player is Map &&
            AuthRepository.isValidUuid(player['id']?.toString()))
          player['id'].toString(),
    };
    for (final owner in owners) {
      _subscribe(owner);
    }
    for (final owner
        in _channels.keys.where((id) => !owners.contains(id)).toList()) {
      final channel = _channels.remove(owner)!;
      _ready.remove(owner);
      unawaited(client.removeChannel(channel));
    }
  }

  @override
  Future<void> send(SignBroadcast sign) async {
    // Never use HTTP fallback or enqueue a gesture for a later hand.
    if (_closed || !_ready.contains(userId)) {
      throw StateError('Canal de signes indisponible');
    }
    final response = await _channels[userId]!.sendBroadcastMessage(
      event: 'keinu',
      payload: sign.toJson(),
    );
    if (response != ChannelResponse.ok) throw StateError('Signe non transmis');
  }

  @override
  Future<void> sendChat(TableChatEvent event) async {
    if (_closed || !_ready.contains(userId)) {
      throw StateError('Chat indisponible. Réessayez dans un instant.');
    }
    final result = await _channels[userId]!.sendBroadcastMessage(
      event: 'table_chat',
      payload: event.toJson(),
    );
    if (result != ChannelResponse.ok) throw StateError('Message non transmis');
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final channels = _channels.values.toList();
    _channels.clear();
    _ready.clear();
    try {
      await Future.wait(
        channels.map((channel) => client.removeChannel(channel)),
      );
    } finally {
      await _events.close();
      await _chatEvents.close();
    }
  }
}
