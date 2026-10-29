/// Ephemeral table messages use the authenticated channel owner as sender.
class TableChatEvent {
  const TableChatEvent({
    required this.senderId,
    required this.seat,
    required this.id,
    required this.body,
    this.quick = false,
  });
  final String senderId, id, body;
  final int seat;
  final bool quick;
  static const maxLength = 160;
  static String normalize(String value) => value
      .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  static bool validText(String value) =>
      value.isNotEmpty &&
      value.length <= maxLength &&
      normalize(value) == value;
  Map<String, dynamic> toJson() => {
    'seat': seat,
    'id': id,
    'body': body,
    'kind': quick ? 'quick' : 'text',
  };
  static TableChatEvent? parse(String owner, Map<String, dynamic> payload) {
    final seat = payload['seat'],
        id = payload['id'],
        body = payload['body'],
        kind = payload['kind'];
    if (seat is! int ||
        seat < 0 ||
        seat > 3 ||
        id is! String ||
        id.isEmpty ||
        id.length > 100 ||
        body is! String ||
        (kind != 'text' && kind != 'quick')) {
      return null;
    }
    if (kind == 'text' ? !validText(body) : body.isEmpty || body.length > 40) {
      return null;
    }
    return TableChatEvent(
      senderId: owner,
      seat: seat,
      id: id,
      body: body,
      quick: kind == 'quick',
    );
  }
}

abstract class GameChatSession {
  Stream<TableChatEvent> get chatEvents;
  Future<void> sendChat(TableChatEvent event);
}
