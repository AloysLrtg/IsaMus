import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/audio/audio_haptic_service.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/localization/app_locale.dart';
import 'package:isamus/features/game/game_over_overlay.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/l10n/app_localizations.dart';
import 'package:isamus/main.dart';

import 'game_scoring_layout_test.dart' show ScoringController, ScoringPlayer;
import 'helpers/audio_haptic_fakes.dart';

import 'package:isamus/core/network/player_repository.dart';

class AnnouncementController extends MusGameController {
  @override
  MusGameState build() {
    super.build();
    return MusGameState.initial();
  }
}

void main() {
  for (final language in ['fr', 'eu', 'es', 'en']) {
    final locale = Locale(language);
    final l = lookupAppLocalizations(locale);

    Future<ProviderContainer> mount(
      WidgetTester tester,
      Widget child, {
      bool scoring = true,
    }) async {
      final container = ProviderContainer(
        overrides: [
          audioHapticServiceProvider.overrideWithValue(
            FakeAudioHapticService(),
          ),
          playerRepositoryProvider.overrideWithValue(ScoringPlayer()),
          musGameControllerProvider.overrideWith(
            scoring ? ScoringController.new : AnnouncementController.new,
          ),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
          musRoundScoringDelayProvider.overrideWithValue(
            const Duration(hours: 1),
          ),
        ],
      );
      container.read(appLocaleProvider.notifier).select(locale);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MyApp(home: child),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('$language: HUD scoring labels and unchanged Mus phases', (
      tester,
    ) async {
      await mount(tester, const GameScreen(localSeat: 0));
      for (final text in [
        l.endOfDeal,
        l.scoringPhase,
        l.team('A'),
        l.team('B'),
        l.dealTotal,
        'Handia',
        'Ttipia',
        'Pareak',
        'Jokoa',
        'Tira',
      ]) {
        expect(find.text(text), findsWidgets, reason: '$language: $text');
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('$language: contextual announcements', (tester) async {
      final container = await mount(
        tester,
        const GameScreen(localSeat: 0),
        scoring: false,
      );
      final feedback = container.read(musTableFeedbackProvider.notifier);
      for (final entry in {
        TableAnnouncement.onlyOneTeamHasPairs: l.onlyOneTeamHasPairs,
        TableAnnouncement.noPairs: l.noTeamHasPairs,
        TableAnnouncement.onlyOneTeamHasGame: l.onlyOneTeamHasGame,
        TableAnnouncement.noGame: l.noTeamHasGame,
      }.entries) {
        feedback.setAnnouncement(entry.key);
        await tester.pump();
        expect(find.text(entry.value), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    for (final winner in [0, 1]) {
      for (final seat in [0, 1]) {
        testWidgets('$language: winner $winner, local seat $seat', (
          tester,
        ) async {
          var returnedHome = false;
          await mount(
            tester,
            Scaffold(
              body: Stack(
                children: [
                  GameOverOverlay(
                    state: MusGameState.initial().copyWith(
                      phase: MusPhase.gameOver,
                      tantto: winner == 0 ? const [40, 20] : const [20, 40],
                    ),
                    localSeat: seat,
                    onHomePressed: () => returnedHome = true,
                  ),
                ],
              ),
            ),
          );
          final team = winner == 0 ? 'A' : 'B';
          expect(
            find.text(seat == winner ? l.victoryTitle : l.defeatTitle),
            findsOneWidget,
          );
          expect(
            find.text(
              seat == winner ? l.congratulationsTeam(team) : l.defeatTeam(team),
            ),
            findsOneWidget,
          );
          expect(find.text(l.finalScores), findsOneWidget);
          expect(find.text(l.team('A')), findsOneWidget);
          expect(find.text(l.team('B')), findsOneWidget);
          await tester.ensureVisible(find.text(l.returnHome));
          await tester.tap(find.text(l.returnHome));
          expect(returnedHome, isTrue);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}
