import 'package:isamus/l10n/app_localizations.dart';

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/bot_profile.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:isamus/features/avatar/player_avatar_view.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/main.dart';

class PortraitNetwork implements SupabaseRepository {
  final events = StreamController<Map<String, dynamic>>.broadcast();
  final pushed = <Map<String, dynamic>>[];
  @override
  Stream<Map<String, dynamic>> streamGame(String id) => events.stream;
  @override
  Future<void> updateGameState(String id, Map<String, dynamic> state) async {
    pushed.add(state);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('ancienne config convertie et pool sans doublons', () {
    expect(
      AvatarConfig.fromJson({'skin': 2, 'head': 1, 'eyes': 2, 'mouth': 1}),
      const AvatarConfig(skin: 2, hair: 1, glasses: 2, top: 1, hairColor: 1),
    );
    final pool = AvatarConfig.shuffledOptions(Random(7));
    expect(pool.toSet(), hasLength(81));
    expect(
      pool.every(
        (avatar) =>
            avatar.hair < 3 &&
            avatar.glasses < 3 &&
            avatar.top < 3 &&
            avatar.exclusiveHat == ExclusiveHat.none,
      ),
      isTrue,
    );
    expect(pool, AvatarConfig.shuffledOptions(Random(7)));
  });
  test('avatars locaux conservés après donne et sérialisation', () {
    final container = ProviderContainer(
      overrides: [
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(musGameControllerProvider.notifier);
    final before = container.read(musGameControllerProvider).players;
    expect(before.map((p) => p.avatarConfig).toSet(), hasLength(4));
    controller.startGame();
    controller.startGame();
    final state = container.read(musGameControllerProvider);
    expect(state.players.first, before.first);
    expect(
      state.players.map((p) => p.avatarConfig).toSet(),
      before.map((p) => p.avatarConfig).toSet(),
    );
    expect(MusGameState.fromJson(state.toJson()).players, state.players);
  });
  testWidgets('les six assets par portrait ont un remplacement sans erreur', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,

        home: Scaffold(
          body: PlayerAvatarView(
            config: AvatarConfig(skin: 2, hair: 1, glasses: 2, top: 1),
            size: 180,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(PlayerAvatarView),
        matching: find.byType(ClipOval),
      ),
      findsOneWidget,
    );
    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images.map((i) => (i.image as AssetImage).assetName), [
      'assets/avatars/skin_2.png',
      'assets/avatars/top_1.png',
      'assets/avatars/eyes_normal.png',
      'assets/avatars/mouth_normal.png',
      'assets/avatars/brows_normal.png',
      'assets/avatars/hair_1.png',
      'assets/avatars/glasses_2.png',
    ]);
    for (var i = 0; i < 6; i++) {
      if (i != 0 && i != 3) {
        expect(find.byKey(ValueKey('avatar-fallback-$i')), findsOneWidget);
      }
    }
    expect(tester.takeException(), isNull);
  });
  for (final seat in [0, 1]) {
    testWidgets(
      'siège local $seat lit les avatars canoniques des quatre sièges',
      (tester) async {
        final repo = PortraitNetwork();
        final container = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(repo),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
          ],
        );
        final configs = [
          AvatarConfig.shuffledOptions(Random(14)).first,
          ...BotProfile.profiles.map((p) => p.avatar),
        ];
        final roster = [
          for (var i = 0; i < 4; i++)
            {
              'id': i == 0 ? 'host' : 'bot_$i',
              'seat': i,
              'name': 'Player $i',
              'is_bot': i != 0,
              'is_host': i == 0,
              'avatar_config': configs[i].toJson(),
            },
        ];
        try {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MyApp(
                home: GameScreen(gameId: 'portraits', localSeat: seat),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(repo.pushed, isEmpty);
          repo.events.add({'status': 'ready', 'players': roster});
          await tester.pumpAndSettle();
          expect(find.byType(PlayerAvatarView), findsNWidgets(4));
          for (var i = 0; i < 4; i++) {
            expect(
              tester
                  .widget<PlayerAvatarView>(
                    find.byKey(ValueKey('player-avatar-$i')),
                  )
                  .config,
              configs[i],
            );
          }
          if (seat == 0) {
            expect(
              container.read(musGameControllerProvider).phase,
              MusPhase.musDecision,
            );
            expect(repo.pushed, isNotEmpty);
            final serialized = MusGameState.fromJson(repo.pushed.first).players;
            expect(serialized.map((p) => p.avatarConfig).toList(), configs);
          } else {
            expect(repo.pushed, isEmpty);
          }
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          container.dispose();
          await repo.events.close();
        }
      },
    );
  }
}
