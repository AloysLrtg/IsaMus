import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/leaderboard_repository.dart';
import 'package:isamus/features/home/leaderboard_tab.dart';

const entries = [
  LeaderboardEntry(id: 'a', username: 'Ane', elo: 1500),
  LeaderboardEntry(id: 'b', username: 'Patxi', elo: 1400),
  LeaderboardEntry(id: 'c', username: 'Maddi', elo: 1300),
  // Same display name as another player: highlighting must use the UUID.
  LeaderboardEntry(id: 'local', username: 'Ane', elo: 1200),
];

void main() {
  Future<void> mount(
    WidgetTester tester,
    Future<List<LeaderboardEntry>> Function() fetch, {
    String? userId = 'local',
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [leaderboardProvider.overrideWith((ref) => fetch())],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: LeaderboardTab(currentUserId: userId)),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('loading, podium order and UUID-based local highlight', (
    tester,
  ) async {
    final pending = Completer<List<LeaderboardEntry>>();
    await mount(tester, () => pending.future);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(entries);
    await tester.pumpAndSettle();
    final first = find.byKey(const ValueKey('leaderboard-podium-1'));
    final second = find.byKey(const ValueKey('leaderboard-podium-2'));
    final third = find.byKey(const ValueKey('leaderboard-podium-3'));
    expect(tester.getCenter(second).dx, lessThan(tester.getCenter(first).dx));
    expect(tester.getCenter(first).dx, lessThan(tester.getCenter(third).dx));
    expect(find.text('Votre position : #4'), findsOneWidget);
    final local = find.byKey(const ValueKey('leaderboard-row-local'));
    await tester.ensureVisible(local);
    expect(
      find.descendant(of: local, matching: find.text('Vous')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('leaderboard-row-a')),
        matching: find.text('Vous'),
      ),
      findsNothing,
    );
  });

  for (final count in [0, 1, 2]) {
    testWidgets('handles $count players on a small screen with large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await mount(tester, () async => entries.take(count).toList());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (count == 0) {
        expect(
          find.text('Aucun joueur classé pour le moment.'),
          findsOneWidget,
        );
      } else {
        expect(
          find.byKey(const ValueKey('leaderboard-podium-1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('leaderboard-podium-3')),
          findsNothing,
        );
      }
    });
  }

  testWidgets('retry, refresh, and leaving the tab while loading', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<List<LeaderboardEntry>>();
    await mount(tester, () async {
      calls++;
      if (calls == 1) throw Exception('offline');
      if (calls == 3) return pending.future;
      return entries;
    });
    await tester.pumpAndSettle();
    expect(find.text('Réessayer'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Votre position : #4'), findsOneWidget);
    await tester.tap(find.byTooltip('Actualiser le classement'));
    await tester.pump();
    expect(calls, 3);
    await tester.pumpWidget(const SizedBox());
    pending.complete(entries);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('pull to refresh works on an empty leaderboard', (tester) async {
    var calls = 0;
    await mount(tester, () async => ++calls == 1 ? [] : entries);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byKey(const ValueKey('leaderboard-podium-1')), findsOneWidget);
  });
}
