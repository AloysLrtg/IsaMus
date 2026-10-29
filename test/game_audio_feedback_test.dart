import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/audio/audio_haptic_service.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/main.dart';

import 'helpers/audio_haptic_fakes.dart';

class FeedbackController extends MusGameController {
  void show(MusGameState value) {
    state = value;
  }
}

void main() {
  late ProviderContainer container;
  late FeedbackController controller;
  late FakeAudioHapticService effects;
  Future<void> mount(
    WidgetTester tester, {
    bool enabled = true,
    bool timed = false,
  }) async {
    effects = FakeAudioHapticService(enabled: enabled);
    container = ProviderContainer(
      overrides: [
        audioHapticServiceProvider.overrideWithValue(effects),
        musGameControllerProvider.overrideWith(FeedbackController.new),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(
          timed ? const Duration(seconds: 1) : null,
        ),
        playerProfileProvider.overrideWith(
          (ref) async => {'sound_enabled': enabled},
        ),
      ],
    );
    controller = container.read(
      musGameControllerProvider.notifier,
    ) as FeedbackController;
    controller.startGame();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(home: GameScreen()),
      ),
    );
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    effects.dispose();
    await tester.pump();
  }

  testWidgets(
    'début, Mus, sélection de carte : sons centralisés et impacts légers',
    (tester) async {
      await mount(tester);
      try {
        expect(effects.output.played, [GameSounds.deal]);
        controller.chooseMus(0, MusChoice.mus);
        await tester.pump();
        expect(effects.output.played.last, GameSounds.tap);
        expect(effects.impacts, [HapticImpact.light]);
        while (container.read(musGameControllerProvider).phase ==
            MusPhase.musDecision) {
          controller.chooseMus(
            container.read(musGameControllerProvider).currentPlayer,
            MusChoice.mus,
          );
        }
        await tester.pump();
        effects.output.played.clear();
        effects.impacts.clear();
        await tester.tap(find.byKey(const ValueKey('hand-card-0')));
        await tester.pump();
        expect(effects.output.played, [GameSounds.cardSlide]);
        expect(effects.impacts, [HapticImpact.light]);
      } finally {
        await close(tester);
      }
    },
  );

  testWidgets(
    'un écho réseau avec les mêmes cartes ne rejoue pas la distribution',
    (tester) async {
      await mount(tester);
      try {
        effects.output.played.clear();
        effects.impacts.clear();
        final before = container.read(musGameControllerProvider);
        controller.syncFromRemote(
          MusGameState.fromJson({
            ...before.toJson(),
            'version': before.version + 1,
          }),
        );
        await tester.pump();
        expect(effects.output.played, isEmpty);
        expect(effects.impacts, isEmpty);
      } finally {
        await close(tester);
      }
    },
  );

  testWidgets('Tira et Nere gatik tira jouent exactement le même fichier', (
    tester,
  ) async {
    await mount(tester);
    try {
      effects.output.played.clear();
      for (final action in [BidActionType.tira, BidActionType.nereGatikTira]) {
        container
            .read(musTableFeedbackProvider.notifier)
            .say(0, TableSpeech(SpeechKind.bid, action: action));
        await tester.pump();
      }
      expect(effects.output.played, [GameSounds.tap, GameSounds.tap]);
      expect(effects.output.played, isNot(contains(GameSounds.chips)));
    } finally {
      await close(tester);
    }
  });

  for (final enabled in [true, false]) {
    testWidgets('Mintza/Paso/Hordago/victoire respectent le mute=$enabled', (
      tester,
    ) async {
      await mount(tester, enabled: enabled);
      try {
        expect(effects.output.played, enabled ? [GameSounds.deal] : isEmpty);
        effects.output.played.clear();
        controller.chooseMus(0, MusChoice.mintza);
        await tester.pump();
        controller.act(0, BidActionType.paso);
        await tester.pump();
        if (enabled) {
          expect(effects.output.played, [GameSounds.tap, GameSounds.tap]);
          expect(effects.impacts, [HapticImpact.light, HapticImpact.light]);
        }
        controller.act(
          container.read(musGameControllerProvider).currentPlayer,
          BidActionType.hordago,
        );
        await tester.pump();
        controller.show(
          container.read(musGameControllerProvider).copyWith(mancheWinner: 0),
        );
        await tester.pump();
        if (enabled) {
          expect(
            effects.output.played,
            containsAllInOrder([GameSounds.hordago, GameSounds.victory]),
          );
          expect(
            effects.impacts.where((i) => i == HapticImpact.heavy),
            hasLength(2),
          );
        } else {
          expect(effects.output.played, isEmpty);
          expect(effects.impacts, isEmpty);
        }
      } finally {
        await close(tester);
      }
    });

    testWidgets(
      'expiration du timer : impact fort, silencieux si désactivé=$enabled',
      (tester) async {
        await mount(tester, enabled: enabled, timed: true);
        try {
          effects.output.played.clear();
          await tester.pump(const Duration(seconds: 1));
          await tester.pump();
          expect(effects.output.played.contains(GameSounds.timeout), enabled);
          expect(effects.impacts.contains(HapticImpact.heavy), enabled);
          if (!enabled) {
            expect(effects.output.played, isEmpty);
            expect(effects.impacts, isEmpty);
          }
        } finally {
          await close(tester);
        }
      },
    );
  }
}
