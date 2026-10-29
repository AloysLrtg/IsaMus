import 'package:isamus/core/audio/audio_haptic_service.dart';

import 'helpers/audio_haptic_fakes.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/models/card.dart' as mus;
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/features/settings/settings_screen.dart';
import 'package:isamus/main.dart';

class ScoringController extends MusGameController {
  @override
  MusGameState build() {
    super.build();
    final cards = mus.Card.fullDeck();
    return MusGameState.initial().copyWith(
      phase: MusPhase.roundScoring,
      hands: [for (var i = 0; i < 4; i++) cards.sublist(i * 4, i * 4 + 4)],
      tantto: const [4, 4],
      scoreLog: const [
        ScoreEvent(BidPhase.grand, 0, 1, 'allPaso'),
        ScoreEvent(BidPhase.petit, 1, 1, 'allPaso'),
        ScoreEvent(BidPhase.paires, 0, 3, 'allPaso'),
        ScoreEvent(BidPhase.jeu, 1, 2, 'allPaso'),
        ScoreEvent(BidPhase.grand, 1, 1, 'tira'),
      ],
    );
  }
}

class ScoringPlayer extends PlayerRepository {
  bool enabled = true;
  @override
  Future<Map<String, dynamic>> profile() async => {
    'username': 'Ane',
    'elo': 1200,
    'sound_enabled': enabled,
  };
  @override
  Future<void> sound(bool value) async {
    enabled = value;
  }
}

class ScoringNetwork implements SupabaseRepository {
  final events = StreamController<Map<String, dynamic>>.broadcast();
  bool closed = false;
  @override
  Stream<Map<String, dynamic>> streamGame(String id) => events.stream;
  @override
  Future<void> closeGame(String id) async {
    closed = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<ProviderContainer> mount(
    WidgetTester tester, {
    int seat = 0,
    ScoringPlayer? player,
    ScoringNetwork? network,
  }) async {
    final container = ProviderContainer(
      overrides: [
        audioHapticServiceProvider.overrideWithValue(FakeAudioHapticService()),
        if (network != null)
          supabaseRepositoryProvider.overrideWithValue(network),
        musGameControllerProvider.overrideWith(ScoringController.new),
        playerRepositoryProvider.overrideWithValue(player ?? ScoringPlayer()),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
        musRoundScoringDelayProvider.overrideWithValue(
          const Duration(hours: 1),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MyApp(
          home: GameScreen(
            localSeat: seat,
            gameId: network == null ? null : 'settings-match',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  for (final size in [
    const Size(320, 568),
    const Size(568, 320),
    const Size(390, 844),
  ]) {
    for (final seat in [0, 2]) {
      testWidgets(
        'décompte : sièges ancrés, toutes les cartes visibles à $size / siège $seat',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final container = await mount(tester, seat: seat);
          try {
            final table = tester.getRect(
              find.byKey(const ValueKey('reveal-layout')),
            );
            final summary = tester.getRect(
              find.byKey(const ValueKey('round-scoring-summary')),
            );
            final left = tester.getRect(
              find.byKey(ValueKey('player-avatar-${(seat + 1) % 4}')),
            );
            final right = tester.getRect(
              find.byKey(ValueKey('player-avatar-${(seat + 3) % 4}')),
            );
            expect(left.center.dx, lessThan(table.left + table.width * .3));
            expect(
              right.center.dx,
              greaterThan(table.right - table.width * .3),
            );
            expect(left.overlaps(right), isFalse);
            expect((left.top - right.top).abs(), lessThan(1));
            expect(table.height, greaterThan(80));
            expect(summary.height, lessThanOrEqualTo(150));
            expect(table.bottom, lessThan(summary.top));
            final viewport = Rect.fromLTWH(
              0,
              0,
              size.width,
              size.height,
            ).inflate(.1);
            for (var offset = 1; offset < 4; offset++) {
              final hand = find.byKey(
                ValueKey('reveal-hand-${(seat + offset) % 4}'),
              );
              final images = find.descendant(
                of: hand,
                matching: find.byType(Image),
              );
              expect(images, findsNWidgets(4));
              for (final image in images.evaluate()) {
                final rect = tester.getRect(find.byWidget(image.widget));
                expect(table.inflate(.1).contains(rect.topLeft), isTrue);
                expect(table.inflate(.1).contains(rect.bottomRight), isTrue);
                expect(
                  viewport.contains(rect.topLeft) &&
                      viewport.contains(rect.bottomRight),
                  isTrue,
                );
                expect(rect.overlaps(summary), isFalse);
              }
            }
            final localImages = find.descendant(
              of: find.byKey(const ValueKey('local-hand')),
              matching: find.byType(Image),
            );
            expect(localImages, findsNWidgets(4));
            for (final image in localImages.evaluate()) {
              final rect = tester.getRect(find.byWidget(image.widget));
              expect(
                viewport.contains(rect.topLeft) &&
                    viewport.contains(rect.bottomRight),
                isTrue,
              );
              expect(rect.overlaps(summary), isFalse);
            }
            if (size.height < 480) {
              final scroll = find.descendant(
                of: find.byKey(const ValueKey('round-scoring-scroll')),
                matching: find.byType(Scrollable),
              );
              final state = tester.state<ScrollableState>(scroll);
              expect(state.position.maxScrollExtent, greaterThan(0));
              await tester.drag(
                find.byKey(const ValueKey('round-scoring-scroll')),
                const Offset(0, -200),
              );
              await tester.pumpAndSettle();
              expect(state.position.pixels, greaterThan(0));
              expect(
                summary.contains(tester.getCenter(find.text('Total donne'))),
                isTrue,
              );
            }
            expect(tester.takeException(), isNull);
          } finally {
            await tester.pumpWidget(const SizedBox.shrink());
            container.dispose();
          }
        },
      );
    }
  }
  testWidgets('Réglages en jeu coupe le son puis revient sur la même partie', (
    tester,
  ) async {
    final player = ScoringPlayer();
    final network = ScoringNetwork();
    final container = await mount(tester, player: player, network: network);
    try {
      final controller = container.read(musGameControllerProvider.notifier);
      final snapshot = container.read(musGameControllerProvider);
      await tester.tap(find.byKey(const ValueKey('game-menu-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Réglages'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('settings-sound-toggle')));
      await tester.pumpAndSettle();
      expect(player.enabled, isFalse);
      expect(network.events.hasListener, isTrue);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);
      expect(
        container.read(musGameControllerProvider.notifier),
        same(controller),
      );
      expect(container.read(musGameControllerProvider), same(snapshot));
      expect(controller.gameId, 'settings-match');
      expect(network.closed, isFalse);
      expect(network.events.hasListener, isTrue);
      expect(
        container.read(playerProfileProvider).asData?.value['sound_enabled'],
        isFalse,
      );
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await network.events.close();
    }
  });
}
