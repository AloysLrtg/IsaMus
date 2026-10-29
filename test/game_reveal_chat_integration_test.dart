import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/audio/audio_haptic_service.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/models/card.dart' as mus;
import 'package:isamus/core/network/game_sign_repository.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:isamus/core/network/table_chat_event.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/main.dart';

import 'helpers/audio_haptic_fakes.dart';
import 'helpers/game_sign_fakes.dart';
import 'game_sign_transport_test.dart' show host, guest;

void main() {
  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets(
      'Table réseau $size : soumettre pendant la révélation puis après sa fin automatique',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 34);
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        addTearDown(tester.view.resetViewPadding);
        addTearDown(tester.view.resetPadding);
        final session = FakeSignSession();
        final network = SignGameRepository();
        final c = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(network),
            gameSignRepositoryProvider.overrideWithValue(
              FakeSignRepository(session),
            ),
            audioHapticServiceProvider.overrideWithValue(
              FakeAudioHapticService(),
            ),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            playerProfileProvider.overrideWith(
              (ref) async => {'sound_enabled': false, 'card_back': 'classic'},
            ),
            inventoryProvider.overrideWith((ref) async => <String>{}),
          ],
        );
        final roster = [
          {'id': host, 'seat': 0, 'is_host': true, 'name': 'Ane'},
          {'id': guest, 'seat': 1, 'name': 'Amaia'},
          {
            'id': '00000000-0000-4000-8000-000000000003',
            'seat': 2,
            'name': 'Jon',
          },
          {
            'id': '00000000-0000-4000-8000-000000000004',
            'seat': 3,
            'name': 'Leire',
          },
        ];
        final deck = mus.Card.fullDeck();
        final snapshot =
            MusGameState.initial(
              players: roster.map(MusPlayer.fromJson).toList(),
            ).copyWith(
              version: 40,
              phase: MusPhase.roundScoring,
              currentPlayer: -1,
              hands: [
                for (var seat = 0; seat < 4; seat++)
                  deck.sublist(seat * 4, seat * 4 + 4),
              ],
              talon: deck.sublist(16),
              scoreLog: const [
                ScoreEvent(BidPhase.grand, 0, 1, 'allPaso'),
                ScoreEvent(BidPhase.petit, 1, 1, 'allPaso'),
                ScoreEvent(BidPhase.paires, 0, 3, 'allPaso'),
                ScoreEvent(BidPhase.jeu, 1, 2, 'allPaso'),
                ScoreEvent(BidPhase.grand, 1, 1, 'tira'),
              ],
            );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: MyApp(
              home: GameScreen(
                gameId: 'room',
                players: roster,
                initialGame: {
                  'id': 'room',
                  'status': 'playing',
                  'mode': 'casual',
                  'players': roster,
                  'game_state': snapshot.toJson(),
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(c.read(musGameControllerProvider).phase, MusPhase.roundScoring);
        final board = find.byKey(const ValueKey('game-board-stack'));
        final dock = find.byKey(const ValueKey('debrief-chat-bar'));
        expect(find.descendant(of: board, matching: dock), findsNothing);
        expect(
          tester.getRect(board).bottom,
          lessThanOrEqualTo(tester.getRect(dock).top),
        );
        for (final key in ['text-chat', 'quick-chat']) {
          final button = find.byKey(ValueKey(key));
          expect(button.hitTestable(), findsOneWidget);
          expect(tester.getRect(button).width, greaterThanOrEqualTo(44));
          expect(tester.getRect(button).height, greaterThanOrEqualTo(44));
        }
        final scoreRect = tester.getRect(
          find.byKey(const ValueKey('round-scoring-hitbox')),
        );
        final chatRect = tester.getRect(
          find.byKey(const ValueKey('reveal-chat-hitbox')),
        );
        expect(scoreRect.overlaps(chatRect), isFalse);
        final footer = find.byKey(const ValueKey('reveal-footer-row'));
        expect(tester.widget(footer), isA<Row>());
        expect(
          find.descendant(of: footer, matching: find.byType(Positioned)),
          findsNothing,
        );
        for (final key in ['text-chat', 'quick-chat']) {
          expect(
            tester
                .getRect(find.byKey(const ValueKey('round-scoring-summary')))
                .overlaps(tester.getRect(find.byKey(ValueKey(key)))),
            isFalse,
          );
        }
        final boardBeforeKeyboard = tester.getRect(board);
        final before = c.read(musGameControllerProvider);
        await tester.tap(find.byKey(const ValueKey('text-chat')));
        await tester.pumpAndSettle();
        tester.view.viewInsets = FakeViewPadding(
          bottom: size.height < 400 ? 150 : 250,
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(board), boardBeforeKeyboard);
        await tester.enterText(
          find.byKey(const ValueKey('table-chat-input')),
          'Bien joué pendant la révélation !',
        );
        await tester.tap(find.byKey(const ValueKey('table-chat-send')));
        await tester.pumpAndSettle();
        expect(
          session.sentChats.single.body,
          'Bien joué pendant la révélation !',
        );
        expect(session.sentChats.single.seat, 0);
        expect(c.read(musGameControllerProvider), same(before));
        expect(network.pushed, isEmpty);
        session.incomingChat.add(
          const TableChatEvent(
            senderId: guest,
            seat: 1,
            id: 'reveal-reply',
            body: 'Merci !',
          ),
        );
        await tester.pump();
        expect(c.read(musTableFeedbackProvider).speeches[1]!.text, 'Merci !');
        await tester.enterText(
          find.byKey(const ValueKey('table-chat-input')),
          'On continue !',
        );
        await tester.pump(const Duration(seconds: 8));
        await tester.pumpAndSettle();
        expect(c.read(musGameControllerProvider).phase, MusPhase.musDecision);
        expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('table-chat-input')))
              .controller!
              .text,
          'On continue !',
        );
        final next = c.read(musGameControllerProvider);
        final writes = network.pushed.length;
        await tester.tap(find.byKey(const ValueKey('table-chat-send')));
        await tester.pumpAndSettle();
        expect(session.sentChats, hasLength(2));
        expect(session.sentChats.last.body, 'On continue !');
        expect(c.read(musGameControllerProvider), same(next));
        expect(network.pushed.length, writes);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        c.dispose();
        await tester.pump();
      },
    );
  }
}
