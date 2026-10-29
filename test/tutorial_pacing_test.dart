import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/features/tutorial/tutorial_game_controller.dart';

void main() {
  ProviderContainer tutorial() => ProviderContainer(
    overrides: [
      musGameControllerProvider.overrideWith(TutorialGameController.new),
      musBotsEnabledProvider.overrideWithValue(false),
      musTurnTimeoutProvider.overrideWithValue(null),
      musBidResolutionDelayProvider.overrideWithValue(
        const Duration(seconds: 2),
      ),
    ],
  );

  testWidgets(
    'Le bot attend 2 secondes et Iduki reste visible avant le Petit',
    (tester) async {
      final container = tutorial();
      final controller = container.read(
        musGameControllerProvider.notifier,
      ) as TutorialGameController;
      controller.startTutorial();
      controller.chooseMus(0, MusChoice.mintza);
      controller.act(0, BidActionType.embido, amount: 2);
      final before = container.read(musGameControllerProvider);
      unawaited(controller.playBotStep());
      unawaited(
        controller.playBotStep(),
      ); // Duplicate scheduling must be ignored.
      await tester.pump(const Duration(milliseconds: 1999));
      expect(container.read(musGameControllerProvider), same(before));
      await tester.pump(const Duration(milliseconds: 1));
      final reply = container.read(musGameControllerProvider);
      expect(reply.bidding!.phase, BidPhase.grand);
      expect(reply.currentPlayer, -1);
      expect(reply.bidHistory[BidPhase.grand]!.length, 2);
      expect(
        container
            .read(musTableFeedbackProvider)
            .speeches
            .values
            .any((speech) => speech.action == BidActionType.iduki),
        isTrue,
      );
      await tester.pump(const Duration(milliseconds: 1999));
      expect(
        container.read(musGameControllerProvider).bidding!.phase,
        BidPhase.grand,
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        container.read(musGameControllerProvider).bidding!.phase,
        BidPhase.petit,
      );
      container.dispose();
    },
  );

  testWidgets('Quitter la table annule les effets des actions différées', (
    tester,
  ) async {
    final container = tutorial();
    final controller = container.read(
      musGameControllerProvider.notifier,
    ) as TutorialGameController;
    controller.startTutorial();
    controller.chooseMus(0, MusChoice.mintza);
    controller.act(0, BidActionType.embido, amount: 2);
    final pending = controller.playBotStep();
    container.dispose();
    await tester.pump(const Duration(seconds: 3));
    await pending;
    expect(tester.takeException(), isNull);
  });
}
