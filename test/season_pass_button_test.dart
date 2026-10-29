import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/season_repository.dart';
import 'package:isamus/features/home/season_pass_button.dart';

Widget _button({
  bool enabled = true,
  bool reducedMotion = false,
  VoidCallback? onPressed,
  DateTime Function()? clock,
}) => ProviderScope(
  overrides: [if (clock != null) seasonClockProvider.overrideWithValue(clock)],
  child: MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: TickerMode(
        enabled: enabled,
        child: Scaffold(body: SeasonPassButton(onPressed: onPressed ?? () {})),
      ),
    ),
  ),
);

void main() {
  testWidgets('Le balayage se répète, le bouton reste utilisable et se libère', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(_button(onPressed: () => taps++));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.tap(find.byKey(const ValueKey('open-battle-pass')));
    expect(taps, 1);
    // Leave during the sweep: neither the controller nor its timer may survive.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Animations suspendues hors écran et avec mouvement réduit', (
    tester,
  ) async {
    await tester.pumpWidget(_button());
    await tester.pumpWidget(_button(enabled: false));
    await tester.pump(const Duration(seconds: 6));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(_button());
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(_button(reducedMotion: true));
    await tester.pump(const Duration(seconds: 6));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Le badge suit la fin du mois puis la nouvelle saison', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 10, 20, 12);
    await tester.pumpWidget(_button(clock: () => now, reducedMotion: true));
    expect(find.text('Saison en cours'), findsOneWidget);
    now = DateTime.utc(2026, 10, 31, 12);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Dernier jour'), findsOneWidget);
    now = DateTime.utc(2026, 11, 1, 12);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Saison en cours'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
