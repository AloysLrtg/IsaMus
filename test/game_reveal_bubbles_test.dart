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
import 'game_debrief_chat_test.dart' show DebriefController;

class FinishableController extends DebriefController {
  FinishableController() : super(MusPhase.roundScoring);
  void finish() => state = state.copyWith(phase: MusPhase.gameOver);
  void finalCount() => state = state.copyWith(tantto: const [40, 0]);
}

void main() {
  Future<ProviderContainer> mount(WidgetTester tester, {int seat = 0}) async {
    final c = ProviderContainer(
      overrides: [
        musGameControllerProvider.overrideWith(FinishableController.new),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
        audioHapticServiceProvider.overrideWithValue(FakeAudioHapticService()),
        playerProfileProvider.overrideWith(
          (ref) async => {'sound_enabled': false},
        ),
        inventoryProvider.overrideWith((ref) async => <String>{}),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MyApp(home: GameScreen(localSeat: seat)),
      ),
    );
    await tester.pumpAndSettle();
    return c;
  }

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    for (final localSeat in [0, 2]) {
      testWidgets(
        'Bulles visibles sur les quatre sièges à la révélation $size / $localSeat',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final c = await mount(tester, seat: localSeat);
          final feedback = c.read(musTableFeedbackProvider.notifier);
          feedback.say(
            0,
            const TableSpeech(SpeechKind.chat, chat: QuickChat.aupa),
          );
          feedback.say(
            1,
            const TableSpeech(SpeechKind.freeChat, text: 'Bien joué !'),
          );
          feedback.say(2, const TableSpeech(SpeechKind.mus));
          feedback.say(
            3,
            const TableSpeech(
              SpeechKind.freeChat,
              text: 'Quelle belle donne !',
            ),
          );
          await tester.pump();
          await tester.pump();
          final scaffold = tester.widget<Scaffold>(
            find
                .descendant(
                  of: find.byType(GameScreen),
                  matching: find.byType(Scaffold),
                )
                .first,
          );
          final root = scaffold.body! as Stack;
          expect(
            find.descendant(
              of: find.byWidget(root.children.last),
              matching: find.byKey(const ValueKey('reveal-speech-overlay')),
            ),
            findsOneWidget,
          );
          final viewport = Rect.fromLTWH(
            0,
            0,
            size.width,
            size.height,
          ).inflate(.1);
          for (var seat = 0; seat < 4; seat++) {
            final bubble = find.byKey(ValueKey('speech-$seat'));
            expect(bubble, findsOneWidget);
            final rect = tester.getRect(bubble);
            expect(rect.width, greaterThan(20));
            expect(rect.height, greaterThan(10));
            expect(
              viewport.contains(rect.topLeft),
              isTrue,
              reason: 'bulle $seat hors écran',
            );
            expect(viewport.contains(rect.bottomRight), isTrue);
            final avatar = tester.getRect(
              find.byKey(ValueKey('player-avatar-$seat')),
            );
            expect(rect.bottom, lessThanOrEqualTo(avatar.top + 1));
            expect(avatar.top - rect.bottom, lessThan(24));
            expect(rect.left, lessThanOrEqualTo(avatar.center.dx));
            expect(rect.right, greaterThanOrEqualTo(avatar.center.dx));
            final decoration =
                tester.widget<Container>(bubble).decoration! as BoxDecoration;
            expect(
              decoration.color,
              seat == 2 ? Colors.white : const Color(0xFFFFE082),
            );
          }
          expect(
            find.byKey(const ValueKey('text-chat')).hitTestable(),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('quick-chat')).hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          c.dispose();
          await tester.pump();
        },
      );
    }
    testWidgets('Victoire finale $size : aucun accès au chat ni bulle', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = await mount(tester);
      c
          .read(musTableFeedbackProvider.notifier)
          .say(1, const TableSpeech(SpeechKind.freeChat, text: 'Bravo !'));
      (c.read(musGameControllerProvider.notifier) as FinishableController)
          .finish();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('game-over-overlay')), findsOneWidget);
      for (final key in [
        'text-chat',
        'quick-chat',
        'debrief-chat-bar',
        'reveal-speech-overlay',
      ]) {
        expect(find.byKey(ValueKey(key)), findsNothing);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
      await tester.pump();
    });
  }
  testWidgets(
    'Le dernier décompte à 40 conserve les chats jusqu’à l’écran final',
    (tester) async {
      final c = await mount(tester);
      (c.read(musGameControllerProvider.notifier) as FinishableController)
          .finalCount();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('round-scoring-progress-indicator')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('text-chat')).hitTestable(),
        findsOneWidget,
      );
      await c
          .read(musGameControllerProvider.notifier)
          .sendTextChat('Bien joué !');
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('speech-0')), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
      await tester.pump();
    },
  );
  for (final quick in [false, true]) {
    testWidgets(
      'Une feuille ${quick ? 'rapide' : 'textuelle'} ouverte se désactive à la victoire',
      (tester) async {
        final c = await mount(tester);
        await tester.tap(
          find.byKey(ValueKey(quick ? 'quick-chat' : 'text-chat')),
        );
        await tester.pumpAndSettle();
        (c.read(musGameControllerProvider.notifier) as FinishableController)
            .finish();
        await tester.pumpAndSettle();
        if (quick) {
          await tester.tap(find.text('Encouragement'));
          await tester.pumpAndSettle();
          final button = find.ancestor(
            of: find.text('Aupa !'),
            matching: find.byType(FilledButton),
          );
          expect(tester.widget<FilledButton>(button).onPressed, isNull);
        } else {
          expect(
            tester
                .widget<TextField>(
                  find.byKey(const ValueKey('table-chat-input')),
                )
                .enabled,
            isFalse,
          );
          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const ValueKey('table-chat-send')),
                )
                .onPressed,
            isNull,
          );
        }
        expect(c.read(musTableFeedbackProvider).chatHistory, isEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
        c.dispose();
        await tester.pump();
      },
    );
  }
}
