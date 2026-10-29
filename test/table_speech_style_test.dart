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

void main() {
  test('La nature du message détermine son origine, pas le texte', () {
    for (final kind in SpeechKind.values) {
      expect(
        TableSpeech(kind).isSystemMessage,
        kind != SpeechKind.chat && kind != SpeechKind.freeChat,
      );
    }
    expect(
      const TableSpeech(SpeechKind.freeChat, text: 'Hordago').isSystemMessage,
      isFalse,
    );
    expect(
      const TableSpeech(SpeechKind.custom, text: '31 points').isSystemMessage,
      isTrue,
    );
  });

  Future<ProviderContainer> mount(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
        audioHapticServiceProvider.overrideWithValue(FakeAudioHapticService()),
        playerProfileProvider.overrideWith(
          (ref) async => {'sound_enabled': false},
        ),
      ],
    );
    container.read(musGameControllerProvider.notifier).startGame();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(home: GameScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Finder bubble(int seat) => find.byKey(ValueKey('speech-$seat'));
  BoxDecoration decoration(WidgetTester tester, int seat) =>
      tester.widget<Container>(bubble(seat)).decoration! as BoxDecoration;
  TextStyle style(WidgetTester tester, int seat) => tester
      .widget<Text>(
        find.descendant(of: bubble(seat), matching: find.byType(Text)),
      )
      .style!;
  Finder icon(int seat) => find.descendant(
    of: bubble(seat),
    matching: find.byIcon(Icons.chat_bubble_outline_rounded),
  );

  testWidgets(
    'Quick Chat et texte libre : même jaune, texte, icône et décoration',
    (tester) async {
      final container = await mount(tester);
      try {
        final feedback = container.read(musTableFeedbackProvider.notifier);
        feedback.say(
          1,
          const TableSpeech(SpeechKind.chat, chat: QuickChat.aupa),
        );
        feedback.say(
          3,
          const TableSpeech(SpeechKind.freeChat, text: 'Bonjour !'),
        );
        await tester.pump();
        expect(decoration(tester, 1), decoration(tester, 3));
        expect(decoration(tester, 1).color, const Color(0xFFFFE082));
        expect(style(tester, 1), style(tester, 3));
        expect(style(tester, 1).color, const Color(0xFF1E293B));
        expect(style(tester, 1).fontStyle, FontStyle.italic);
        expect(style(tester, 1).fontWeight, FontWeight.normal);
        expect(icon(1), findsOneWidget);
        expect(icon(3), findsOneWidget);
        expect(
          tester.widget<Icon>(icon(1)).color,
          tester.widget<Icon>(icon(3)).color,
        );
        expect(
          tester.widget<Container>(bubble(1)).padding,
          tester.widget<Container>(bubble(3)).padding,
        );
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump();
      }
    },
  );
  testWidgets(
    'Mus, Mintza, Hordago, défausse et points restent blancs et gras',
    (tester) async {
      final container = await mount(tester);
      try {
        final feedback = container.read(musTableFeedbackProvider.notifier);
        feedback.say(
          3,
          const TableSpeech(SpeechKind.freeChat, text: 'Hordago'),
        );
        for (final message in [
          const TableSpeech(SpeechKind.mus),
          const TableSpeech(SpeechKind.mintza),
          const TableSpeech(SpeechKind.bid, action: BidActionType.hordago),
          const TableSpeech(SpeechKind.bid, action: BidActionType.paso),
          const TableSpeech(SpeechKind.discard, amount: 2),
          const TableSpeech(SpeechKind.custom, text: '31 points'),
        ]) {
          feedback.say(1, message);
          await tester.pump();
          expect(
            decoration(tester, 1).color,
            Colors.white,
            reason: message.kind.name,
          );
          expect(style(tester, 1).color, const Color(0xFF1E293B));
          expect(style(tester, 1).fontWeight, FontWeight.bold);
          expect(style(tester, 1).fontStyle, FontStyle.normal);
          expect(icon(1), findsNothing);
          expect(decoration(tester, 3).color, const Color(0xFFFFE082));
        }
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump();
      }
    },
  );
}
