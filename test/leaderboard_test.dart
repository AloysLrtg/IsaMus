import 'package:isamus/l10n/app_localizations.dart';

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
    Locale locale = const Locale('fr'),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [leaderboardProvider.overrideWith((ref) => fetch())],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

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
    expect(find.text(testL10n.menuYourPositionArg0('4')), findsOneWidget);
    final local = find.byKey(const ValueKey('leaderboard-row-local'));
    await tester.ensureVisible(local);
    expect(
      find.descendant(of: local, matching: find.text(testL10n.you)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('leaderboard-row-a')),
        matching: find.text(testL10n.you),
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
        expect(find.text(testL10n.menuNoRankedPlayersYet), findsOneWidget);
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
    expect(find.text(testL10n.menuTryAgain), findsOneWidget);
    await tester.tap(find.text(testL10n.menuTryAgain));
    await tester.pumpAndSettle();
    expect(find.text(testL10n.menuYourPositionArg0('4')), findsOneWidget);
    await tester.tap(find.byTooltip(testL10n.menuRefreshRankings));
    await tester.pump();
    expect(calls, 3);
    await tester.pumpWidget(const SizedBox());
    pending.complete(entries);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final language in ['fr', 'eu', 'es', 'en']) {
    testWidgets(
      'Top 100 localisé en $language avec pseudos courts et historiques',
      (tester) async {
        final locale = Locale(language);
        final l10n = lookupAppLocalizations(locale);
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const players = [
          LeaderboardEntry(id: 'local', username: 'Joueur abcd', elo: 1500),
          LeaderboardEntry(
            id: 'legacy',
            username: 'Joueur b78c3661234567890',
            elo: 1400,
          ),
          LeaderboardEntry(id: 'other', username: 'Ane', elo: 1300),
        ];
        final semantics = tester.ensureSemantics();
        try {
          await mount(tester, () async => players, locale: locale);
          await tester.pumpAndSettle();
          expect(find.text(l10n.menuTop100Players), findsOneWidget);
          expect(find.text(l10n.menuTheHighestEloRatings), findsOneWidget);
          expect(find.text(l10n.menuYourPositionArg0('1')), findsOneWidget);
          expect(find.text(l10n.menuRankedByDescendingElo), findsOneWidget);
          await tester.ensureVisible(
            find.byKey(const ValueKey('leaderboard-row-local')),
          );
          expect(find.text(l10n.you), findsOneWidget);
          expect(
            find.bySemanticsLabel(
              l10n.menuPositionArg0Arg1Arg2EloArg3(
                '1',
                'Joueur abcd',
                '1500',
                l10n.leaderboardYouSuffix,
              ),
            ),
            findsOneWidget,
          );
          for (final text in tester.widgetList<Text>(
            find.text(players[1].username),
          )) {
            expect(text.maxLines, 1);
            expect(text.overflow, TextOverflow.ellipsis);
          }
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }

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

final testL10n = lookupAppLocalizations(const Locale('fr'));
