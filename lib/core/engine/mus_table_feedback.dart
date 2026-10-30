import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mus_game_state.dart';

enum QuickChat {
  goodLuck,
  nothing,
  aupa,
  wellPlayed,
  eskerrik,
  rematch,
  oneMoment,
  lastHand,
  niceTeam,
  keepGoing,
  yourMove,
  luckyToday,
  bluffing,
}

enum QuickChatCategory { information, encouragement, trashtalk }

extension QuickChatGrouping on QuickChat {
  QuickChatCategory get category => switch (this) {
    QuickChat.nothing ||
    QuickChat.rematch ||
    QuickChat.oneMoment ||
    QuickChat.lastHand => QuickChatCategory.information,
    QuickChat.yourMove ||
    QuickChat.luckyToday ||
    QuickChat.bluffing => QuickChatCategory.trashtalk,
    _ => QuickChatCategory.encouragement,
  };
}

extension QuickChatInventory on QuickChat {
  String? get shopItemId => switch (this) {
    QuickChat.eskerrik => 'shop_chat_eskerrik',
    QuickChat.rematch => 'shop_chat_rematch',
    _ => null,
  };
}

enum TableAnnouncement {
  noPairs,
  onlyOneTeamHasPairs,
  noGame,
  onlyOneTeamHasGame,
}

enum SpeechKind { mus, mintza, bid, discard, chat, custom, freeChat }

class TableSpeech {
  const TableSpeech(
    this.kind, {
    this.action,
    this.amount = 0,
    this.chat,
    this.text,
  });

  /// Derived from the message type: player text cannot impersonate an action.
  bool get isSystemMessage => switch (kind) {
    SpeechKind.chat || SpeechKind.freeChat => false,
    SpeechKind.mus ||
    SpeechKind.mintza ||
    SpeechKind.bid ||
    SpeechKind.discard ||
    SpeechKind.custom => true,
  };

  final SpeechKind kind;
  final BidActionType? action;
  final int amount;
  final QuickChat? chat;
  final String? text;
}

/// Une échéance par tour ; aucun tick n'est publié dans Riverpod.
class TurnClock {
  TurnClock({required this.seat, required this.duration})
    : deadline = DateTime.now().add(duration);
  final int seat;
  final Duration duration;
  final DateTime deadline;
}

class TableChatEntry {
  const TableChatEntry(this.seat, this.speech);
  final int seat;
  final TableSpeech speech;
}

class TableFeedback {
  const TableFeedback({
    this.speeches = const {},
    this.clock,
    this.announcement,
    this.chatHistory = const [],
  });
  final List<TableChatEntry> chatHistory;
  final Map<int, TableSpeech> speeches;
  final TurnClock? clock;
  final TableAnnouncement? announcement;
}

final musTableFeedbackProvider =
    NotifierProvider<MusTableFeedback, TableFeedback>(MusTableFeedback.new);

/// État visuel séparé du moteur. Chaque avatar observe uniquement sa bulle.
class MusTableFeedback extends Notifier<TableFeedback> {
  final _timers = <int, Timer>{};

  @override
  TableFeedback build() {
    ref.onDispose(_cancelTimers);
    return const TableFeedback();
  }

  void setAnnouncement(TableAnnouncement? text) {
    state = TableFeedback(
      chatHistory: state.chatHistory,
      speeches: state.speeches,
      clock: state.clock,
      announcement: text,
    );
  }

  void setClock(TurnClock? clock) {
    state = TableFeedback(
      chatHistory: state.chatHistory,
      speeches: state.speeches,
      clock: clock,
      announcement: state.announcement,
    );
  }

  void say(int seat, TableSpeech speech) {
    _timers.remove(seat)?.cancel();
    state = TableFeedback(
      chatHistory:
          speech.kind == SpeechKind.chat || speech.kind == SpeechKind.freeChat
          ? List.unmodifiable(
              [
                ...state.chatHistory,
                TableChatEntry(seat, speech),
              ].reversed.take(40).toList().reversed,
            )
          : state.chatHistory,
      speeches: Map.unmodifiable({...state.speeches, seat: speech}),
      clock: state.clock,
      announcement: state.announcement,
    );
    _timers[seat] = Timer(
      Duration(milliseconds: speech.kind == SpeechKind.freeChat ? 6000 : 2500),
      () {
        _timers.remove(seat);
        if (!ref.mounted) return;
        state = TableFeedback(
          chatHistory: state.chatHistory,
          speeches: Map.unmodifiable({...state.speeches}..remove(seat)),
          clock: state.clock,
          announcement: state.announcement,
        );
      },
    );
  }

  void _cancelTimers() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  void clearChatHistory({Set<TableChatEntry>? entries}) {
    final oldSpeeches = entries?.map((e) => e.speech).toSet();
    final speeches = {...state.speeches};
    for (final seat in speeches.keys.toList()) {
      if ((speeches[seat]!.kind == SpeechKind.chat ||
              speeches[seat]!.kind == SpeechKind.freeChat) &&
          (oldSpeeches == null || oldSpeeches.contains(speeches[seat]))) {
        speeches.remove(seat);
        _timers.remove(seat)?.cancel();
      }
    }
    state = TableFeedback(
      chatHistory: entries == null
          ? const []
          : List.unmodifiable(
              state.chatHistory.where((e) => !entries.contains(e)),
            ),
      speeches: Map.unmodifiable(speeches),
      clock: state.clock,
      announcement: state.announcement,
    );
  }

  void clearSpeeches() {
    _cancelTimers();
    state = TableFeedback(
      clock: state.clock,
      announcement: state.announcement,
      chatHistory: state.chatHistory,
    );
  }
}
