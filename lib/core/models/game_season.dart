class GameSeason {
  const GameSeason({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });
  final String id, name;
  final DateTime startDate, endDate;
  factory GameSeason.fromJson(Map json) => GameSeason(
    id: json['id'] as String,
    name: (json['name'] ?? json['title']) as String,
    startDate: DateTime.parse(
      (json['start_date'] ?? json['starts_at']) as String,
    ),
    endDate: DateTime.parse((json['end_date'] ?? json['ends_at']) as String),
  );
  int daysRemaining(DateTime now) =>
      (endDate.difference(now).inSeconds / 86400).ceil().clamp(0, 9999);
}
