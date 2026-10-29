import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/retention_repository.dart';
import 'package:isamus/features/game/game_over_overlay.dart';
import 'package:isamus/features/retention/quests_screen.dart';
import 'package:isamus/main.dart';

class XpResultRepository extends PlayerRepository {
  @override
  Future<Map<String, dynamic>?> finish(String id) async => {
    'elo_before': 1200,
    'elo_after': 1216,
    'xp_earned': 350,
    'coins_earned': 999,
  };
}

void main() {
  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets(
      'Fin de partie $size : XP et Elo, scores stylisés sans doublon ni pièces',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final state = MusGameState.initial().copyWith(
          phase: MusPhase.gameOver,
          tantto: const [40, 20],
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              playerRepositoryProvider.overrideWithValue(XpResultRepository()),
            ],
            child: MyApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    GameOverOverlay(
                      state: state,
                      localSeat: 0,
                      mode: 'ranked',
                      gameId: 'result-test',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('+350 XP'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('game-over-elo-badge')),
          findsOneWidget,
        );
        expect(find.text('Partie Classée • Elo : +16'), findsOneWidget);
        expect(find.byKey(const ValueKey('match-earned-coins')), findsNothing);
        expect(find.textContaining('pièces'), findsNothing);
        expect(find.textContaining('Équipe A :'), findsNothing);
        expect(find.text('Équipe A'), findsOneWidget);
        expect(find.text('Équipe B'), findsOneWidget);
        expect(find.text('40'), findsOneWidget);
        expect(find.text('20'), findsOneWidget);
        expect(find.byIcon(Icons.star_rounded), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final vip in [false, true]) {
    testWidgets(
      'Quête ${vip ? 'VIP' : 'normale'} : récompense affichée en XP uniquement',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              retentionStatusProvider.overrideWith(
                (ref) async => {
                  'vip': vip,
                  'quests': [
                    {
                      'title': 'Terminer 5 parties',
                      'target': 5,
                      'progress': 1,
                      'reward': 50,
                      'reward_xp': 250,
                      'rewarded': false,
                    },
                  ],
                },
              ),
            ],
            child: MyApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => showWeeklyQuests(context),
                    child: const Text('Ouvrir'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Ouvrir'));
        await tester.pumpAndSettle();
        expect(find.text('1/5 · +${vip ? 500 : 250} XP'), findsOneWidget);
        expect(find.textContaining('pièces'), findsNothing);
        expect(find.byIcon(Icons.monetization_on_rounded), findsNothing);
        expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Quête déjà reçue : le reçu réel reste exact après expiration VIP',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            retentionStatusProvider.overrideWith(
              (ref) async => {
                'vip': false,
                'quests': [
                  {
                    'title': 'Terminer 5 parties',
                    'target': 5,
                    'progress': 5,
                    'reward_xp': 250,
                    'rewarded': true,
                    'earned_xp': 500,
                  },
                ],
              },
            ),
          ],
          child: MyApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showWeeklyQuests(context),
                  child: const Text('Ouvrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      expect(find.text('5/5 · +500 XP · Récompense reçue'), findsOneWidget);
      expect(find.textContaining('+250 XP'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Ancien serveur : ne pas renommer une récompense en pièces comme XP',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            retentionStatusProvider.overrideWith(
              (ref) async => {
                'quests': [
                  {
                    'title': 'Ancienne quête',
                    'target': 5,
                    'progress': 1,
                    'reward': 50,
                    'rewarded': false,
                  },
                ],
              },
            ),
          ],
          child: MyApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showWeeklyQuests(context),
                  child: const Text('Ouvrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Récompense XP indisponible'), findsOneWidget);
      expect(find.textContaining('+50 XP'), findsNothing);
      expect(find.textContaining('pièces'), findsNothing);
    },
  );
}
