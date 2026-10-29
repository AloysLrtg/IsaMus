import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/audio/audio_haptic_service.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/main.dart';

import 'helpers/audio_haptic_fakes.dart';

void main() {
  for (final seat in [0, 1, 2, 3]) {
    testWidgets('Bordure intérieure et timer extérieur séparés, siège $seat', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          musBotsEnabledProvider.overrideWithValue(false),
          audioHapticServiceProvider.overrideWithValue(
            FakeAudioHapticService(),
          ),
          playerProfileProvider.overrideWith(
            (ref) async => {'sound_enabled': false},
          ),
        ],
      );
      final controller = container.read(musGameControllerProvider.notifier);
      controller.configureMultiplayer(
        players: [
          for (var i = 0; i < 4; i++)
            {
              'id': 'bot_$i',
              'seat': i,
              'is_bot': false,
              'is_host': i == 0,
              'avatar_config': const AvatarConfig(
                border: AvatarBorder.gold,
                exclusiveHat: ExclusiveHat.txapela,
              ).toJson(),
            },
        ],
      );
      controller.startGame(eskuIndex: seat);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(home: GameScreen()),
        ),
      );
      await tester.pump();
      final portrait = find.byKey(ValueKey('player-avatar-$seat'));
      final border = find.descendant(
        of: portrait,
        matching: find.byKey(const ValueKey('avatar-border-gold')),
      );
      final outer = find.byKey(ValueKey('turn-progress-$seat'));
      expect(border, findsOneWidget);
      expect(outer, findsOneWidget);
      expect(find.byKey(ValueKey('turn-linear-$seat')), findsNothing);
      final inside = tester.getRect(border), outside = tester.getRect(outer);
      expect(inside.center.dx, closeTo(outside.center.dx, .1));
      expect(inside.center.dy, closeTo(outside.center.dy, .1));
      // Lateral seats may be scaled to fit: compare spacing in logical units.
      final scale = outside.width / tester.getSize(outer).width;
      expect(inside.left - outside.left, greaterThanOrEqualTo(4.99 * scale));
      expect(outside.right - inside.right, greaterThanOrEqualTo(4.99 * scale));
      final before = tester.widget<CircularProgressIndicator>(outer).value!;
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester.widget<CircularProgressIndicator>(outer).value,
        lessThan(before),
      );
      expect(border, findsOneWidget);
      expect(
        container.read(musGameControllerProvider).phase,
        MusPhase.musDecision,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump();
    });
  }
}
