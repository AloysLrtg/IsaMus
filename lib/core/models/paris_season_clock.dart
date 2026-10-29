import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

/// Calendar calculations remain correct regardless of the device's time zone.
abstract final class ParisSeasonClock {
  static final tz.Location _paris = () {
    data.initializeTimeZones();
    return tz.getLocation('Europe/Paris');
  }();

  static tz.TZDateTime parisTime(DateTime now) =>
      tz.TZDateTime.from(now, _paris);

  static DateTime endOfMonth(DateTime now) {
    final local = parisTime(now);
    return tz.TZDateTime(
      _paris,
      local.year,
      local.month + 1,
      1,
    ).subtract(const Duration(seconds: 1));
  }

  static Duration remaining(DateTime now) {
    final duration = endOfMonth(now).difference(now);
    return duration.isNegative ? Duration.zero : duration;
  }

  static String countdown(DateTime now) {
    final left = remaining(now);
    return 'Fin de saison dans ${left.inDays}j '
        '${left.inHours % 24}h ${left.inMinutes % 60}m';
  }
}
