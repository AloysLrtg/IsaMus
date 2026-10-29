import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/audio/audio_haptic_service.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/models/card.dart' as mus;
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/game_sign_repository.dart';
import 'package:isamus/core/network/table_chat_event.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/main.dart';

import 'helpers/audio_haptic_fakes.dart';
import 'helpers/game_sign_fakes.dart';
import 'game_sign_transport_test.dart' show host, guest;

class DebriefController extends MusGameController {
  DebriefController(this.phase);
  final MusPhase phase;
  @override
  MusGameState build() {
    final initial = super.build();
    final deck = mus.Card.fullDeck();
    return initial.copyWith(
      phase: phase,
      hands: [
        for (var seat = 0; seat < 4; seat++)
          deck.sublist(seat * 4, seat * 4 + 4),
      ],
    );
  }
}

void main() {
  for (final phase in MusPhase.values) {
    test(
      'Realtime ${phase.name} : envoi et réception sans changer la partie',
      () async {
        final session = FakeSignSession();
        final c = ProviderContainer(
          overrides: [
            musGameControllerProvider.overrideWith(
              () => DebriefController(phase),
            ),
            gameSignRepositoryProvider.overrideWithValue(
              FakeSignRepository(session),
            ),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
          ],
        );
        final controller = c.read(musGameControllerProvider.notifier);
        controller.configureMultiplayer(
          gameId: 'room',
          localSeat: 0,
          players: [
            {'id': host, 'seat': 0},
            {'id': guest, 'seat': 1},
          ],
        );
        final before = c.read(musGameControllerProvider);
        if (phase == MusPhase.gameOver) {
          await expectLater(controller.sendTextChat('Fin'), throwsStateError);
          await expectLater(
            controller.sendQuickChat(0, QuickChat.aupa),
            throwsStateError,
          );
          expect(session.sentChats, isEmpty);
          expect(c.read(musGameControllerProvider), same(before));
          c.dispose();
          return;
        }
        await controller.sendTextChat('Belle partie !');
        await controller.sendQuickChat(0, QuickChat.aupa);
        session.incomingChat.add(
          const TableChatEvent(
            senderId: guest,
            seat: 1,
            id: 'debrief',
            body: 'À bientôt !',
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(session.sentChats, hasLength(2));
        expect(
          c.read(musTableFeedbackProvider).speeches[1]!.text,
          'À bientôt !',
        );
        expect(c.read(musGameControllerProvider), same(before));
        c.dispose();
      },
    );
    if (phase != MusPhase.roundScoring) continue;
    for (final size in [const Size(320, 568), const Size(568, 320)]) {
      testWidgets('Chats utilisables en ${phase.name} à $size avec clavier', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final c = ProviderContainer(
          overrides: [
            musGameControllerProvider.overrideWith(
              () => DebriefController(phase),
            ),
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
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: const MyApp(home: GameScreen()),
          ),
        );
        await tester.pumpAndSettle();
        final before = c.read(musGameControllerProvider);
        final keyboard = find.byKey(const ValueKey('text-chat'));
        expect(keyboard, findsOneWidget);
        await tester.ensureVisible(keyboard);
        await tester.pumpAndSettle();
        await tester.tap(keyboard);
        await tester.pumpAndSettle();
        tester.view.viewInsets = FakeViewPadding(
          bottom: size.height < 400 ? 150 : 250,
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('table-chat-input')),
          'Belle partie !',
        );
        await tester.tap(find.byKey(const ValueKey('table-chat-send')));
        await tester.pumpAndSettle();
        expect(
          c.read(musTableFeedbackProvider).speeches[0]!.text,
          'Belle partie !',
        );
        await tester.tap(find.byTooltip('Fermer le chat'));
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        final quick = find.byKey(const ValueKey('quick-chat'));
        expect(quick, findsOneWidget);
        await tester.ensureVisible(quick);
        await tester.pumpAndSettle();
        await tester.tap(quick);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Encouragement'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Aupa !'));
        await tester.pumpAndSettle();
        expect(
          c.read(musTableFeedbackProvider).speeches[0]!.chat,
          QuickChat.aupa,
        );
        expect(c.read(musGameControllerProvider), same(before));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        c.dispose();
        await tester.pump();
      });
    }
  }
}
