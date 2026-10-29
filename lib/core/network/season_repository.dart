import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_season.dart';

final seasonRepositoryProvider = Provider((ref) => SeasonRepository());
final activeSeasonProvider = FutureProvider.autoDispose<GameSeason?>(
  (ref) => ref.watch(seasonRepositoryProvider).active(),
);
final seasonClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);
final seasonNowProvider = NotifierProvider.autoDispose<SeasonTicker, DateTime>(
  SeasonTicker.new,
);

/// One local ticker shared by the pass and ranked card; it never reads Supabase.
class SeasonTicker extends Notifier<DateTime> {
  @override
  DateTime build() {
    final clock = ref.watch(seasonClockProvider);
    final timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (ref.mounted) state = clock();
    });
    ref.onDispose(timer.cancel);
    return clock();
  }
}

class SeasonRepository {
  Future<GameSeason?> active() async {
    final data = await Supabase.instance.client.rpc('active_season');
    return data == null
        ? null
        : GameSeason.fromJson(Map<String, dynamic>.from(data));
  }
}
