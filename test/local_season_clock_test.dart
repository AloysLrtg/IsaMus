import 'package:isamus/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/paris_season_clock.dart';
import 'package:isamus/core/network/season_repository.dart';
import 'package:isamus/core/network/retention_repository.dart';
import 'package:isamus/features/seasons/season_countdown.dart';
import 'package:isamus/features/seasons/countdown_widget.dart';
import 'package:isamus/features/retention/battle_pass_screen.dart';
import 'package:isamus/main.dart';

class OfflineSeasonRepository extends SeasonRepository {
  int calls = 0;
  @override
  Future<Never> active() async {
    calls++;
    throw StateError('offline');
  }
}

void main() {
  test('Paris : dernière seconde du mois, fuseau du téléphone ignoré', () {
    final now = DateTime.parse('2026-10-28T12:00:00Z');
    expect(
      ParisSeasonClock.endOfMonth(now).toUtc(),
      DateTime.utc(2026, 10, 31, 22, 59, 59),
    );
    expect(ParisSeasonClock.countdown(now), 'Fin de saison dans 3j 10h 59m');
    expect(
      ParisSeasonClock.countdown(DateTime.parse('2026-10-28T07:00:00-05:00')),
      ParisSeasonClock.countdown(now),
    );
  });
  test(
    'Paris : passage à l’heure d’été, hiver, année bissextile et décembre',
    () {
      expect(
        ParisSeasonClock.endOfMonth(DateTime.utc(2026, 3, 1)).toUtc(),
        DateTime.utc(2026, 3, 31, 21, 59, 59),
      );
      expect(
        ParisSeasonClock.endOfMonth(DateTime.utc(2028, 2, 1)).toUtc(),
        DateTime.utc(2028, 2, 29, 22, 59, 59),
      );
      expect(
        ParisSeasonClock.endOfMonth(DateTime.utc(2026, 12, 1)).toUtc(),
        DateTime.utc(2026, 12, 31, 22, 59, 59),
      );
      expect(
        ParisSeasonClock.countdown(DateTime.utc(2026, 10, 31, 22, 59, 59, 500)),
        'Fin de saison dans 0j 0h 0m',
      );
    },
  );
  testWidgets(
    'Deux compteurs synchronisés avancent périodiquement sans requête Supabase',
    (tester) async {
      final repo = OfflineSeasonRepository();
      var now = DateTime.utc(2026, 10, 28, 12);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            seasonRepositoryProvider.overrideWithValue(repo),
            seasonClockProvider.overrideWithValue(() => now),
          ],
          child: const MyApp(
            home: Scaffold(
              body: Column(
                children: [SeasonCountdown(showName: true), SeasonCountdown()],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CountdownWidget), findsNWidgets(2));
      expect(
        find.byKey(const ValueKey('countdown-seconds-59')),
        findsNWidgets(2),
      );
      now = now.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byKey(const ValueKey('countdown-seconds-58')),
        findsNWidgets(2),
      );
      now = now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byKey(const ValueKey('countdown-minutes-58')),
        findsNWidgets(2),
      );
      now = DateTime.utc(2026, 10, 31, 23);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Saison 11/2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('countdown-days-29')), findsNWidgets(2));
      expect(repo.calls, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(minutes: 1));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Le Pass affiche le compteur même si ses données sont indisponibles',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            retentionStatusProvider.overrideWith(
              (ref) => Future.error(StateError('offline')),
            ),
            seasonClockProvider.overrideWithValue(
              () => DateTime.utc(2026, 10, 28, 12),
            ),
          ],
          child: const MyApp(home: BattlePassScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(testL10n.menuPassUnavailable), findsOneWidget);
      expect(find.byType(CountdownWidget), findsOneWidget);
      expect(find.byKey(const ValueKey('countdown-hours-10')), findsOneWidget);
      expect(
        find.textContaining('Calendrier de saison indisponible'),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
