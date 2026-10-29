import 'package:isamus/core/audio/audio_haptic_service.dart';

import 'helpers/audio_haptic_fakes.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/bot_ai.dart';
import 'package:isamus/core/engine/bot_profile.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_sign.dart';
import 'package:isamus/core/models/card.dart' as mus;
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/social_repository.dart';
import 'package:isamus/features/profile/profile_tab.dart';
import 'package:isamus/features/social/friends_tab.dart';

class FakeSocial extends SocialRepository {
  String? requested;
  String? accepted;
  @override
  String get userId => 'me';
  @override
  Future<List<Map<String, dynamic>>> search(String query) async => [
    {'id': 'friend', 'username': 'Ane', 'elo': 1200},
  ];
  @override
  Future<void> request(String id) async {
    requested = id;
  }

  @override
  Future<void> accept(String id) async {
    accepted = id;
  }
}

class FakePlayer extends PlayerRepository {
  String? equipped;
  final data = <String, dynamic>{
    'username': 'Patxi',
    'elo': 1250,
    'peak_elo': 1450,
    'casual_played': 4,
    'casual_won': 3,
    'ranked_played': 3,
    'ranked_won': 1,
    'solo_played': 3,
    'solo_won': 2,
    'games_played': 10,
    'games_won': 6,
    'avatar': 'mus',
    'card_back': 'classic',
    'table_theme': 'green',
    'sound_enabled': true,
  };
  @override
  Future<Map<String, dynamic>> profile() async => Map.of(data);
  @override
  Future<List<Map<String, dynamic>>> history() async => [];
  @override
  Future<List<Map<String, dynamic>>> cosmetics() async => [
    {'id': 'green', 'kind': 'table_theme', 'label': 'Vert', 'free': true},
    {'id': 'ocean', 'kind': 'table_theme', 'label': 'Océan', 'free': true},
    {'id': 'gold', 'kind': 'card_back', 'label': 'Or', 'free': false},
  ];
  @override
  Future<Set<String>> inventory() async => {};
  @override
  Future<void> equip(String id) async {
    equipped = id;
    data['table_theme'] = id;
  }

  @override
  Future<void> sound(bool enabled) async {
    data['sound_enabled'] = enabled;
  }
}

MusGameState botState({
  List<int> values = const [2, 4, 6, 7],
  BiddingState? bidding,
}) => MusGameState.initial().copyWith(
  phase: MusPhase.bidding,
  currentPlayer: 1,
  players: [
    for (final p in MusGameState.defaultPlayers())
      p.isBot
          ? p.withBotProfile(BotProfile.forPersonality(BotPersonality.balanced))
          : p,
  ],
  hands: [
    [],
    [for (var i = 0; i < 4; i++) mus.Card(values[i], mus.Suit.values[i])],
    [],
    [],
  ],
  bidding:
      bidding ??
      const BiddingState(phase: BidPhase.grand, participants: [1, 2, 3, 0]),
);
void main() {
  test('le bluff peut engager gros mais ne surenchérit jamais un Hordago', () {
    final ai = MusBotAI(random: Random(1), bluffProbability: 1);
    expect(
      (ai.decide(
        botState(),
        1,
        personality: BotPersonality.bluffer,
      ) as BotBidDecision).action,
      anyOf(BidActionType.embido, BidActionType.hordago),
    );
    final decision = ai.decide(
      botState(
        bidding: const BiddingState(
          phase: BidPhase.grand,
          participants: [0, 1, 2, 3],
          stage: BidStage.responding,
          currentBid: 40,
          isHordago: true,
          bidderTeam: 0,
          responders: [1],
        ),
      ),
      1,
    ) as BotBidDecision;
    expect(decision.action, BidActionType.tira);
  });
  test('partner sign informs a bot, opponent sign does not', () {
    const ai = MusBotAI();
    expect(
      (ai.decide(
        botState().copyWith(signs: {3: MusSign.twoKings}),
        1,
      ) as BotBidDecision).action,
      BidActionType.embido,
    );
    expect(
      (ai.decide(
        botState().copyWith(signs: {0: MusSign.twoKings}),
        1,
      ) as BotBidDecision).action,
      BidActionType.paso,
    );
  });
  testWidgets('search and friend request use the selected identity', (
    tester,
  ) async {
    final repo = FakeSocial();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioHapticServiceProvider.overrideWithValue(
            FakeAudioHapticService(),
          ),
          socialRepositoryProvider.overrideWithValue(repo),
          friendshipsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: FriendsTab(userId: 'me', username: 'Patxi'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ane');
    await tester.tap(find.byTooltip('Rechercher'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('Ane')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Demander en ami'));
    await tester.pumpAndSettle();
    expect(repo.requested, 'friend');
  });
  testWidgets('incoming requests have an accept action', (tester) async {
    final repo = FakeSocial();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioHapticServiceProvider.overrideWithValue(
            FakeAudioHapticService(),
          ),
          socialRepositoryProvider.overrideWithValue(repo),
          friendshipsProvider.overrideWith(
            (ref) => Stream.value([
              {
                'id': 'request',
                'user_id_1': 'friend',
                'user_id_2': 'me',
                'status': 'pending',
              },
            ]),
          ),
          personProvider.overrideWith((ref, id) async => {'username': 'Ane'}),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: FriendsTab(userId: 'me', username: 'Patxi'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demandes'));
    await tester.pumpAndSettle();
    expect(find.text('Demande reçue'), findsOneWidget);
    await tester.tap(find.text('Accepter'));
    await tester.pumpAndSettle();
    expect(repo.accepted, 'request');
  });
  testWidgets('profile contains only identity, statistics and history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = FakePlayer();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioHapticServiceProvider.overrideWithValue(
            FakeAudioHapticService(),
          ),
          playerRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: Scaffold(body: ProfileTab(onChanged: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('60 % de victoires'), findsOneWidget);
    expect(find.text('Modifier mon Avatar'), findsOneWidget);
    expect(find.text('Détails par mode'), findsOneWidget);
    expect(find.text('Effets sonores'), findsNothing);
    expect(find.text('Compte & sécurité'), findsNothing);
    expect(find.text('Conditions d’utilisation'), findsNothing);
    expect(find.text('Politique de confidentialité'), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Personnalisation'), findsOneWidget);
    expect(find.text('Boutique de cosmétiques'), findsNothing);
    await tester.scrollUntilVisible(find.text('Dernières parties'), 150);
    expect(find.text('Dernières parties'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('expired invitation is not offered', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioHapticServiceProvider.overrideWithValue(
            FakeAudioHapticService(),
          ),
          invitationsProvider.overrideWith(
            (ref) => Stream.value([
              {
                'id': 'old',
                'status': 'pending',
                'expires_at': '2000-01-01T00:00:00Z',
                'sender_id': 'friend',
              },
            ]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: InvitationInbox(username: 'Patxi')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rejoindre'), findsNothing);
  });
}
