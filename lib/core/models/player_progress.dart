/// XP is the remainder within the current level, not lifetime accumulated XP.
class PlayerProgress {
  static const xpPerLevel = 500;
  const PlayerProgress({this.level = 1, this.xp = 0});
  final int level;
  final int xp;
  int get xpRemaining => xpPerLevel - xp;
  double get fraction => xp / xpPerLevel;
  factory PlayerProgress.fromJson(Map? json) {
    final level = json?['level'];
    final rawXp = json?['xp'];
    final xp = rawXp is int && rawXp >= 0 ? rawXp : 0;
    return PlayerProgress(
      level: level is int && level >= 1 ? level : 1 + xp ~/ xpPerLevel,
      xp: xp % xpPerLevel,
    );
  }
}
