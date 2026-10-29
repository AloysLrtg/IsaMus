import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presence_service.dart';
import 'social_repository.dart';

final presenceSessionProvider = Provider.autoDispose.family<void, String>((
  ref,
  id,
) {
  final service = ref.watch(presenceServiceProvider);
  var alive = true;
  ref.onDispose(() {
    alive = false;
    unawaited(service.disconnect());
  });
  unawaited(
    Future<void>.microtask(() async {
      if (alive) {
        try {
          await service.connect(id);
        } catch (_) {}
      }
    }),
  );
  ref.listen(friendshipsProvider, (_, next) {
    final rows = next.asData?.value;
    if (rows == null) return;
    final ids = <String>{};
    for (final row in rows.where((r) => r['status'] == 'accepted')) {
      final sender = row['sender_id'] ?? row['user_id_1'];
      final receiver = row['receiver_id'] ?? row['user_id_2'];
      if (sender == id && receiver is String) ids.add(receiver);
      if (receiver == id && sender is String) ids.add(sender);
    }
    service.setFriends(ids);
  }, fireImmediately: true);
});

/// Above the navigator: presence survives while the dashboard is behind a game.
class PresenceSessionHost extends ConsumerWidget {
  const PresenceSessionHost({
    super.key,
    required this.userId,
    required this.child,
  });
  final String? userId;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId != null) ref.watch(presenceSessionProvider(userId!));
    return child;
  }
}
