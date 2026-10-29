import 'package:flutter/material.dart';

import '../../core/engine/mus_game_state.dart';
import 'tutorial_game_controller.dart';

/// Pause guided choices while leaving table navigation available.
class TutorialInteractionGate extends InheritedWidget {
  const TutorialInteractionGate({
    super.key,
    required this.enabled,
    required super.child,
  });

  final bool enabled;

  static bool enabledOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<TutorialInteractionGate>()
          ?.enabled ??
      true;

  @override
  bool updateShouldNotify(TutorialInteractionGate oldWidget) =>
      enabled != oldWidget.enabled;
}

class TutorialActionsView extends StatelessWidget {
  const TutorialActionsView({
    super.key,
    required this.controller,
    required this.compact,
    required this.perform,
  });
  final TutorialGameController controller;
  final bool compact;
  final void Function(VoidCallback) perform;

  @override
  Widget build(BuildContext context) {
    final expected = controller.expectedAction;
    final enabled = TutorialInteractionGate.enabledOf(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    if (expected == null) {
      return const Center(child: Text('Les autres joueurs jouent…'));
    }
    final choices = expected == TutorialAction.mintza
        ? [(null, 'Mus'), (TutorialAction.mintza, 'Mintza')]
        : expected == TutorialAction.iduki
        ? [
            (TutorialAction.iduki, 'Iduki (Suivre)'),
            (null, 'Tira'),
            (null, 'Relancer'),
          ]
        : [
            (TutorialAction.paso, 'Paso'),
            (TutorialAction.betTwo, 'Enchérir de 2'),
            (null, 'Hordago'),
          ];
    void act() => switch (expected) {
      TutorialAction.mintza => controller.chooseMus(0, MusChoice.mintza),
      TutorialAction.betTwo => controller.act(
        0,
        BidActionType.embido,
        amount: 2,
      ),
      TutorialAction.paso => controller.act(0, BidActionType.paso),
      TutorialAction.iduki => controller.act(0, BidActionType.iduki),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: controller.explanation,
            triggerMode: TooltipTriggerMode.tap,
            child: Text(
              controller.explanation,
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < choices.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AnimatedContainer(
                    key: choices[i].$1 == expected
                        ? const ValueKey('tutorial-expected-action')
                        : null,
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: choices[i].$1 == expected
                          ? [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: .5),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: FilledButton(
                      key: choices[i].$1 == null
                          ? null
                          : ValueKey('tutorial-action-${choices[i].$1!.name}'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size(0, compact ? 38 : 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: enabled && choices[i].$1 == expected
                          ? () => perform(act)
                          : null,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          choices[i].$2,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: choices[i].$1 == expected
                                ? colors.onPrimary
                                : colors.onSurface.withValues(alpha: .38),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
