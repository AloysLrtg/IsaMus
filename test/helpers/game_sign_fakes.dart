import 'package:isamus/core/network/table_chat_event.dart';

import 'dart:async';

import 'package:isamus/core/network/game_sign_repository.dart';
import 'package:isamus/core/network/supabase_repository.dart';

class FakeSignSession implements GameSignSession, GameChatSession {
  final incoming = StreamController<SignBroadcast>.broadcast(sync: true);
  final sent = <SignBroadcast>[];
  final incomingChat = StreamController<TableChatEvent>.broadcast(sync: true);
  final sentChats = <TableChatEvent>[];
  bool failChat = false;
  @override
  Stream<TableChatEvent> get chatEvents => incomingChat.stream;
  @override
  Future<void> sendChat(TableChatEvent event) async {
    if (failChat) throw StateError('offline');
    sentChats.add(event);
  }

  bool closed = false;
  @override
  Stream<SignBroadcast> get events => incoming.stream;
  @override
  void updateRoster(List<dynamic> players) {}
  @override
  Future<void> send(SignBroadcast event) async {
    sent.add(event);
  }

  @override
  Future<void> close() async {
    if (closed) return;
    closed = true;
    await incoming.close();
    await incomingChat.close();
  }
}

class FakeSignRepository extends GameSignRepository {
  FakeSignRepository(this.session);
  final FakeSignSession session;
  @override
  GameSignSession open(String gameId) => session;
}

class SignGameRepository implements SupabaseRepository {
  final pushed = <Map<String, dynamic>>[];
  @override
  Future<void> updateGameState(String id, Map<String, dynamic> state) async {
    pushed.add(state);
  }

  @override
  Stream<Map<String, dynamic>> streamGame(String id) => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
