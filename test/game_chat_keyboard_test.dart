import 'package:isamus/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/audio/audio_haptic_service.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/features/game/table_chat_sheets.dart';
import 'package:isamus/main.dart';

import 'helpers/audio_haptic_fakes.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(568, 320),
    ]) {
      testWidgets(
        'Clavier ${platform.name} à $size : table stable et saisie visible',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          final bottom = platform == TargetPlatform.iOS ? 34.0 : 0.0;
          tester.view.viewPadding = FakeViewPadding(top: 24, bottom: bottom);
          tester.view.padding = FakeViewPadding(top: 24, bottom: bottom);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetViewPadding);
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.view.resetViewInsets);
          final c = ProviderContainer(
            overrides: [
              musBotsEnabledProvider.overrideWithValue(false),
              musTurnTimeoutProvider.overrideWithValue(null),
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              playerProfileProvider.overrideWith(
                (ref) async => {'sound_enabled': false},
              ),
              inventoryProvider.overrideWith((ref) async => <String>{}),
            ],
          );
          final controller = c.read(musGameControllerProvider.notifier);
          controller.startGame();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: c,
              child: const MyApp(home: GameScreen()),
            ),
          );
          await tester.pumpAndSettle();
          final hand = find.byKey(const ValueKey('local-hand'));
          final baseline = tester.getRect(hand);
          final before = c.read(musGameControllerProvider);
          await tester.tap(find.byKey(const ValueKey('text-chat')));
          await tester.pumpAndSettle();
          final keyboard = size.height < 400 ? 150.0 : 300.0;
          tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
          tester.view.padding = const FakeViewPadding(top: 24);
          await tester.pumpAndSettle();
          expect(tester.getRect(hand), baseline);
          expect(
            tester
                .getRect(find.byKey(const ValueKey('table-chat-send')))
                .bottom,
            lessThanOrEqualTo(size.height - keyboard),
          );
          await tester.enterText(
            find.byKey(const ValueKey('table-chat-input')),
            'Bonjour à tous 👋',
          );
          await tester.tap(find.byKey(const ValueKey('table-chat-send')));
          await tester.pumpAndSettle();
          expect(
            c.read(musTableFeedbackProvider).speeches[0]!.text,
            'Bonjour à tous 👋',
          );
          expect(identical(c.read(musGameControllerProvider), before), isTrue);
          expect(
            tester
                .widget<TextField>(
                  find.byKey(const ValueKey('table-chat-input')),
                )
                .controller!
                .text,
            isEmpty,
          );
          await tester.tap(find.byTooltip('Fermer le chat'));
          await tester.pumpAndSettle();
          expect(find.byType(TextChatSheet), findsNothing);
          expect(tester.getRect(hand), baseline);
          c
              .read(musTableFeedbackProvider.notifier)
              .say(1, const TableSpeech(SpeechKind.freeChat, text: 'Salut !'));
          await tester.pump();
          final text = tester.widget<Text>(
            find.descendant(
              of: find.byKey(const ValueKey('speech-1')),
              matching: find.byType(Text),
            ),
          );
          expect(text.style!.fontStyle, FontStyle.italic);
          expect(text.style!.fontWeight, FontWeight.normal);
          c
              .read(musTableFeedbackProvider.notifier)
              .say(1, const TableSpeech(SpeechKind.mus));
          await tester.pump();
          final official = tester.widget<Text>(
            find.descendant(
              of: find.byKey(const ValueKey('speech-1')),
              matching: find.byType(Text),
            ),
          );
          expect(official.style!.fontWeight, FontWeight.bold);
          expect(official.style!.fontStyle, FontStyle.normal);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          c.dispose();
          await tester.pump();
          debugDefaultTargetPlatformOverride = null;
        },
      );
    }
  }
  testWidgets(
    'Erreur réseau : le brouillon reste éditable et peut être réenvoyé',
    (tester) async {
      var fail = true;
      final sent = <String>[];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => TextChatSheet(
                      names: const ['Moi', 'A', 'B', 'C'],
                      quickLabel: (q) => q.name,
                      onSend: (text) async {
                        if (fail) throw StateError('offline');
                        sent.add(text);
                      },
                    ),
                  ),
                  child: const Text('Ouvrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('table-chat-input')),
        'À bientôt !',
      );
      await tester.tap(find.byKey(const ValueKey('table-chat-send')));
      await tester.pumpAndSettle();
      expect(
        find.text('Message non transmis. Votre texte est conservé.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('table-chat-input')))
            .controller!
            .text,
        'À bientôt !',
      );
      fail = false;
      await tester.tap(find.byKey(const ValueKey('table-chat-send')));
      await tester.pumpAndSettle();
      expect(sent, ['À bientôt !']);
      expect(tester.takeException(), isNull);
    },
  );
}
