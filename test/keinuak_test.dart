import 'package:isamus/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_sign.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/models/card.dart' as mus;
import 'package:isamus/core/network/game_sign_repository.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:isamus/features/avatar/player_avatar_view.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/main.dart';

import 'helpers/game_sign_fakes.dart';

List<List<mus.Card>> hands() => [
  [
    mus.Card(12, mus.Suit.oros),
    mus.Card(12, mus.Suit.copas),
    mus.Card(1, mus.Suit.oros),
    mus.Card(1, mus.Suit.copas),
  ],
  [
    mus.Card(12, mus.Suit.espadas),
    mus.Card(12, mus.Suit.bastos),
    mus.Card(1, mus.Suit.espadas),
    mus.Card(1, mus.Suit.bastos),
  ],
  [
    mus.Card(4, mus.Suit.oros),
    mus.Card(5, mus.Suit.copas),
    mus.Card(6, mus.Suit.espadas),
    mus.Card(7, mus.Suit.bastos),
  ],
  [
    mus.Card(4, mus.Suit.copas),
    mus.Card(5, mus.Suit.espadas),
    mus.Card(6, mus.Suit.bastos),
    mus.Card(7, mus.Suit.oros),
  ],
];
final roster = [
  for (var i = 0; i < 4; i++)
    {
      'id': ['host', 'guest', 'bot2', 'bot3'][i],
      'seat': i,
      'name': 'Player $i',
      'is_bot': i >= 2,
      'is_host': i == 0,
    },
];

void main() {
  late ProviderContainer container;
  late FakeSignSession session;
  late SignGameRepository game;
  MusGameController setup({int localSeat = 1, List<List<mus.Card>>? dealt}) {
    session = FakeSignSession();
    game = SignGameRepository();
    container = ProviderContainer(
      overrides: [
        gameSignRepositoryProvider.overrideWithValue(
          FakeSignRepository(session),
        ),
        supabaseRepositoryProvider.overrideWithValue(game),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
        playerProfileProvider.overrideWith(
          (ref) async => {'sound_enabled': false},
        ),
      ],
    );
    final c = container.read(musGameControllerProvider.notifier);
    c.configureMultiplayer(
      gameId: 'sign-room',
      localSeat: localSeat,
      players: roster,
    );
    c.startGame(hands: dealt ?? hands());
    game.pushed.clear();
    return c;
  }

  SignBroadcast message(
    MusGameController c, {
    String sender = 'host',
    int seat = 0,
    String sign = 'twoKings',
    String id = '1',
    String? handId,
  }) => SignBroadcast(
    senderId: sender,
    seat: seat,
    sign: sign,
    handId: handId ?? c.signHandId,
    id: id,
  );

  testWidgets(
    'sendSign broadcast seul, version/tour/cartes inchangés et expiration',
    (tester) async {
      final c = setup();
      try {
        final before = container.read(musGameControllerProvider).toJson();
        await c.sendSign('twoKings');
        expect(session.sent.single.sign, 'twoKings');
        expect(session.sent.single.seat, 1);
        expect(game.pushed, isEmpty);
        expect(container.read(musGameControllerProvider).toJson(), before);
        expect(
          container.read(musGameControllerProvider).signs[1],
          MusSign.twoKings,
        );
        expect(before.containsKey('signs'), isFalse);
        await tester.pump(const Duration(seconds: 2));
        expect(container.read(musGameControllerProvider).signs, isEmpty);
        expect(game.pushed, isEmpty);
      } finally {
        container.dispose();
        await tester.pump();
      }
    },
  );
  testWidgets(
    'réception authentifiée, rejet des usurpations, doublons et anciennes mains',
    (tester) async {
      final c = setup();
      try {
        session.incoming.add(message(c, sender: 'guest'));
        session.incoming.add(message(c, handId: 'ancienne-main'));
        session.incoming.add(message(c, sign: 'inconnu'));
        session.incoming.add(message(c, sign: 'thirtyOne'));
        expect(container.read(musGameControllerProvider).signs, isEmpty);
        session.incoming.add(message(c));
        expect(
          container.read(musGameControllerProvider).signs[0],
          MusSign.twoKings,
        );
        await tester.pump(const Duration(seconds: 1));
        session.incoming.add(message(c)); // replay must not renew the timer
        await tester.pump(const Duration(seconds: 1));
        expect(container.read(musGameControllerProvider).signs, isEmpty);
        expect(game.pushed, isEmpty);
      } finally {
        container.dispose();
        await tester.pump();
      }
    },
  );
  testWidgets(
    'un état réseau normal conserve le geste, puis une nouvelle donne le purge',
    (tester) async {
      final c = setup();
      try {
        session.incoming.add(message(c));
        final state = container.read(musGameControllerProvider);
        c.syncFromRemote(
          MusGameState.fromJson({
            ...state.toJson(),
            'version': state.version + 1,
          }),
        );
        expect(
          container.read(musGameControllerProvider).signs[0],
          MusSign.twoKings,
        );
        c.startGame();
        expect(container.read(musGameControllerProvider).signs, isEmpty);
        session.incoming.add(message(c, handId: 'ancienne-main', id: '2'));
        expect(container.read(musGameControllerProvider).signs, isEmpty);
      } finally {
        container.dispose();
        await tester.pump();
      }
    },
  );
  testWidgets(
    '29 refusé avant et pendant Paires, accepté ensuite par émission et réception',
    (tester) async {
      final values = [12, 11, 7, 2];
      final c = setup(
        dealt: [
          for (var seat = 0; seat < 4; seat++)
            [
              for (var i = 0; i < 4; i++)
                mus.Card(values[i], mus.Suit.values[(i + seat) % 4]),
            ],
        ],
      );
      try {
        expect(() => c.sendSign('29'), throwsStateError);
        session.incoming.add(message(c, sign: 'twentyNine', id: 'early'));
        expect(container.read(musGameControllerProvider).signs, isEmpty);
        void phase(BidPhase next) {
          final old = container.read(musGameControllerProvider);
          c.syncFromRemote(
            old.copyWith(
              version: old.version + 1,
              phase: MusPhase.bidding,
              bidding: BiddingState(
                phase: next,
                participants: const [0, 1, 2, 3],
              ),
            ),
          );
        }

        phase(BidPhase.paires);
        expect(() => c.sendSign('29'), throwsStateError);
        phase(BidPhase.point);
        await c.sendSign('29');
        expect(session.sent.single.sign, 'twentyNine');
        session.incoming.add(message(c, sign: 'twentyNine', id: 'late'));
        expect(
          container.read(musGameControllerProvider).signs[0],
          MusSign.twentyNine,
        );
        expect(
          container.read(musGameControllerProvider).signs[1],
          MusSign.twentyNine,
        );
        expect(game.pushed, isEmpty);
      } finally {
        container.dispose();
        await tester.pump();
      }
    },
  );

  testWidgets('invité : bouton de signes et animation de l’avatar distant', (
    tester,
  ) async {
    final c = setup();
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MyApp(
            home: GameScreen(
              gameId: 'sign-room',
              localSeat: 1,
              players: roster,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<IconButton>(find.byKey(const ValueKey('sign-menu')))
            .onPressed,
        isNotNull,
      );
      session.incoming.add(message(c));
      await tester.pump();
      final avatar = find.byKey(const ValueKey('player-avatar-0'));
      expect(tester.widget<PlayerAvatarView>(avatar).currentSign, 'twoKings');
      expect(
        find.descendant(
          of: avatar,
          matching: find.byKey(const ValueKey('avatar-current-sign')),
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
      expect(tester.widget<PlayerAvatarView>(avatar).currentSign, isNull);
      expect(
        find.descendant(
          of: avatar,
          matching: find.byKey(const ValueKey('avatar-current-sign')),
        ),
        findsNothing,
      );
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump();
    }
    expect(session.closed, isTrue);
  });
  testWidgets(
    'Keinuak défile sans débordement en paysage et envoie le geste choisi',
    (tester) async {
      tester.view.physicalSize = const Size(568, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      setup();
      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MyApp(
              home: GameScreen(
                gameId: 'sign-room',
                localSeat: 1,
                players: roster,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('sign-menu')));
        await tester.pumpAndSettle();
        final choice = find.byKey(const ValueKey('send-sign-dobliak'));
        await tester.ensureVisible(choice);
        await tester.pumpAndSettle();
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(session.sent.single.sign, 'dobliak');
        expect(game.pushed, isEmpty);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump();
      }
    },
  );

  testWidgets(
    'PlayerAvatarView revient au neutre et renouvelle deux gestes identiques',
    (tester) async {
      Future<void> show(int revision) => tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          home: PlayerAvatarView(
            config: const AvatarConfig(),
            currentSign: 'thirtyOne',
            signRevision: revision,
          ),
        ),
      );
      await show(1);
      await tester.pump(const Duration(milliseconds: 1200));
      await show(2);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.byKey(const ValueKey('avatar-current-sign')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.byKey(const ValueKey('avatar-current-sign')), findsNothing);
    },
  );
}
