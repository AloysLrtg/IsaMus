import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.username,
    required this.elo,
  });

  final String id;
  final String username;
  final int elo;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      username: json['username'] as String,
      elo: (json['elo'] as num).toInt(),
    );
  }
}

class LeaderboardRepository {
  LeaderboardRepository({this.client});

  final SupabaseClient? client;

  Future<List<LeaderboardEntry>> fetchTop100() async {
    final rows = await (client ?? Supabase.instance.client)
        .from('profiles')
        .select('id, username, elo')
        .not('elo', 'is', null)
        .order('elo', ascending: false)
        // Stable positions when several players have the same Elo.
        .order('id', ascending: true)
        .limit(100)
        .timeout(const Duration(seconds: 15));
    return rows.map(LeaderboardEntry.fromJson).toList(growable: false);
  }
}

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>(
  (ref) => ref.watch(leaderboardRepositoryProvider).fetchTop100(),
  // Let the player explicitly retry, rather than silently retrying errors.
  retry: (retryCount, error) => null,
);
