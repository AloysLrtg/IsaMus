import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/models/profile_statistics.dart';
import 'package:isamus/features/avatar/player_avatar_view.dart';
import 'package:isamus/features/avatar/avatar_palette.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/features/profile/profile_tab.dart';
import 'package:isamus/features/profile/profile_progress_view.dart';
import 'package:isamus/core/models/player_progress.dart';

class StatsPlayer extends PlayerRepository {
  StatsPlayer({this.empty = false});
  final bool empty;
  @override
  Future<Map<String, dynamic>> profile() async => {
    'username': 'Ane',
    'elo': 1250,
    'peak_elo': 1450,
    'level': 3,
    'xp': 1200,
    'games_played': empty ? 0 : 10,
    'games_won': empty ? 0 : 6,
    'casual_played': empty ? 0 : 4,
    'casual_won': empty ? 0 : 3,
    'ranked_played': empty ? 0 : 3,
    'ranked_won': empty ? 0 : 1,
    'solo_played': empty ? 0 : 3,
    'solo_won': empty ? 0 : 2,
  };
  @override
  Future<List<Map<String, dynamic>>> history() async => [];
}

void main() {
  test(
    'statistiques anciennes ou incohérentes gérées sans division par zéro',
    () {
      final old = ProfileStatistics.fromProfile({
        'elo': 1300,
        'games_played': 3,
        'games_won': 1,
      });
      expect(ProfileStatistics.fromProfile({}).elo, 800);
      expect(ProfileStatistics.fromProfile({}).peakElo, 800);
      expect(old.peakElo, 1300);
      expect(old.unclassified, 3);
      final invalid = GameStatistics.fromValues(-4, 10);
      expect(invalid.played, 0);
      expect(invalid.won, 0);
      expect(invalid.winPercent, 0);
      expect(GameStatistics.fromValues(5, 9).lost, 0);
    },
  );
  test('coupe et couleur indépendantes, anciennes teintes conservées', () {
    final old = AvatarConfig.fromJson({
      'skin': 1,
      'hair': 2,
      'glasses': 0,
      'top': 1,
    });
    expect(old.hairColor, 2);
    expect(old.backgroundColor, 0);
    final changed = old
        .withOption(AvatarPart.hairColor, 5)
        .withOption(AvatarPart.backgroundColor, 4);
    expect(changed.hair, 2);
    expect(changed.hairColor, 5);
    expect(changed.backgroundColor, 4);
    expect(AvatarConfig.fromJson(changed.toJson()), changed);
  });
  testWidgets('palette du fond et teinte des assets cheveux dans un cercle', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlayerAvatarView(
            config: AvatarConfig(hair: 1, hairColor: 5, backgroundColor: 3),
            size: 120,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ClipOval), findsOneWidget);
    final background = tester.widget<Image>(
      find.byKey(const ValueKey('avatar-layer-0')),
    );
    expect(
      (background.image as AssetImage).assetName,
      'assets/avatars/background_3.png',
    );
    final hair = tester.widget<Image>(
      find.byKey(const ValueKey('avatar-layer-4')),
    );
    expect(hair.color, AvatarPalette.hairColors[5]);
    expect((hair.image as AssetImage).assetName, 'assets/avatars/hair_1.png');
    expect(tester.takeException(), isNull);
  });
  Future<void> mount(WidgetTester tester, {bool empty = false}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerRepositoryProvider.overrideWithValue(StatsPlayer(empty: empty)),
        ],
        child: MaterialApp(
          home: Scaffold(body: ProfileTab(onChanged: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'camembert global, Elo et modale des trois modes sur écran étroit',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(tester);
      final global = tester.widget<PieChart>(
        find.byKey(const ValueKey('stats-global-pie')),
      );
      expect(global.data.sections.map((s) => s.value), [6.0, 4.0]);
      expect(find.text('Elo actuel'), findsOneWidget);
      expect(find.text('Peak Elo'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('peak-elo'))).data,
        '1450',
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('mode-statistics-button')),
        150,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('mode-statistics-button')));
      await tester.pumpAndSettle();
      for (final entry in {
        'casual': [3.0, 1.0],
        'ranked': [1.0, 2.0],
        'solo': [2.0, 1.0],
      }.entries) {
        await tester.ensureVisible(
          find.byKey(ValueKey('stats-mode-${entry.key}')),
        );
        await tester.pumpAndSettle();
        final chart = tester.widget<PieChart>(
          find.byKey(ValueKey('stats-${entry.key}-pie')),
        );
        expect(chart.data.sections.map((s) => s.value), entry.value);
      }
      expect(find.text('Classique'), findsOneWidget);
      expect(find.text('Classé'), findsOneWidget);
      expect(find.text('Solo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('Progression XP à $size avec texte agrandi', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: const TextScaler.linear(1.5),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: ProfileProgressView(
                  progress: PlayerProgress.fromJson({'level': 3, 'xp': 200}),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('200 / 500 XP'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Profil : niveau 3, XP du palier et XP restante', (tester) async {
    await mount(tester);
    expect(find.text('Niveau 3'), findsOneWidget);
    expect(find.text('200 / 500 XP'), findsOneWidget);
    expect(find.text('Encore 300 XP avant le niveau 4'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const ValueKey('profile-xp-progress')),
          )
          .value,
      .4,
    );
  });
  testWidgets('profil sans partie affiche un anneau neutre', (tester) async {
    await mount(tester, empty: true);
    expect(find.text('Aucune partie terminée'), findsOneWidget);
    final chart = tester.widget<PieChart>(
      find.byKey(const ValueKey('stats-global-pie')),
    );
    expect(chart.data.sections.length, 1);
    expect(chart.data.sections.single.value.isFinite, true);
    expect(find.text('Victoires : 0'), findsOneWidget);
    expect(find.text('Défaites : 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
