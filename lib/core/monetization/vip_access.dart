import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/player_repository.dart';

final vipClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final vipAccessProvider = Provider<bool>((ref) {
  final now = ref.watch(vipClockProvider)();
  final profile = ref.watch(playerProfileProvider);
  final expiry = DateTime.tryParse(
    profile.asData?.value['vip_expires_at']?.toString() ?? '',
  );
  final active = expiry != null && expiry.isAfter(now);
  if (active) {
    final timer = Timer(
      expiry.difference(now) + const Duration(milliseconds: 10),
      ref.invalidateSelf,
    );
    ref.onDispose(timer.cancel);
  }
  return active;
});
