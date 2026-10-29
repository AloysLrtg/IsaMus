import 'dart:math' as math;

enum StatisticsMode { casual, ranked, solo }

class GameStatistics {
  const GameStatistics({required this.played, required this.won});
  final int played;
  final int won;
  int get lost => played - won;
  int get winPercent => played == 0 ? 0 : (won * 100 / played).round();
  static int number(Object? value) =>
      value is num ? math.max(0, value.toInt()) : 0;
  factory GameStatistics.fromValues(Object? played, Object? won) {
    final total = number(played);
    return GameStatistics(played: total, won: number(won).clamp(0, total));
  }
}

class ProfileStatistics {
  const ProfileStatistics({
    required this.elo,
    required this.peakElo,
    required this.global,
    required this.byMode,
  });
  final int elo;
  final int peakElo;
  final GameStatistics global;
  final Map<StatisticsMode, GameStatistics> byMode;
  int get unclassified => math.max(
    0,
    global.played -
        byMode.values.fold<int>(0, (total, stats) => total + stats.played),
  );
  factory ProfileStatistics.fromProfile(Map<String, dynamic> profile) {
    final elo = GameStatistics.number(profile['elo'] ?? 800);
    return ProfileStatistics(
      elo: elo,
      peakElo: math.max(elo, GameStatistics.number(profile['peak_elo'] ?? 800)),
      global: GameStatistics.fromValues(
        profile['games_played'],
        profile['games_won'],
      ),
      byMode: {
        for (final mode in StatisticsMode.values)
          mode: GameStatistics.fromValues(
            profile['${mode.name}_played'],
            profile['${mode.name}_won'],
          ),
      },
    );
  }
}
