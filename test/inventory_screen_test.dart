import 'package:isamus/l10n/app_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/models/inventory_item.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/features/inventory/inventory_screen.dart';
import 'package:isamus/features/profile/profile_tab.dart';
import 'package:isamus/features/avatar/player_avatar_view.dart';
import 'package:isamus/features/game/card_back_view.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/main.dart';

const catalog = [
  {
    'id': 'shop_hair_mohawk',
    'kind': 'avatar_hair',
    'label': 'Crête',
    'free': false,
  },
  {'id': 'classic', 'kind': 'card_back', 'label': 'Classique', 'free': true},
  {
    'id': 'shop_back_violet',
    'kind': 'card_back',
    'label': 'Dos Violet',
    'free': false,
  },
  {
    'id': 'shop_glasses_gold',
    'kind': 'avatar_glasses',
    'label': 'Lunettes dorées',
    'free': false,
  },
  {
    'id': 'shop_hat_cap',
    'kind': 'exclusive_hat',
    'label': 'Casquette',
    'free': false,
  },
  {
    'id': 'league_border_gold',
    'kind': 'avatar_border',
    'label': 'Bordure Or',
    'free': false,
  },
  {
    'id': 'shop_chat_eskerrik',
    'kind': 'quick_chat',
    'label': 'Eskerrik asko !',
    'free': false,
  },
  {
    'id': 'shop_top_striped',
    'kind': 'avatar_top',
    'label': 'Maillot non possédé',
    'free': false,
  },
];

class WardrobePlayer extends PlayerRepository {
  String back = 'shop_back_violet';
  AvatarConfig avatar = const AvatarConfig(
    skin: 2,
    hair: 1,
    top: 2,
    glasses: 1,
    exclusiveHat: ExclusiveHat.cap,
    border: AvatarBorder.gold,
    backgroundColor: 4,
    hairColor: 5,
  );
  final owned = {
    'shop_back_violet',
    'shop_hair_mohawk',
    'shop_glasses_gold',
    'shop_hat_cap',
    'league_border_gold',
    'shop_chat_eskerrik',
  };
  final equipped = <String>[], saved = <AvatarConfig>[];
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<Map<String, dynamic>> profile() async => {
    'id': 'local',
    'username': 'Patxi',
    'elo': 800,
    'coins': 500,
    'avatar_config': avatar.toJson(),
    'card_back': back,
  };
  @override
  Future<Set<String>> inventory() async => {...owned};
  @override
  Future<List<Map<String, dynamic>>> cosmetics() async => catalog;
  @override
  Future<List<Map<String, dynamic>>> history() async => [];
  @override
  Future<void> equip(String id) async {
    equipped.add(id);
    await gate?.future;
    if (fail) throw Exception('offline');
    if (id == 'classic' || id == 'shop_back_violet') {
      back = id;
    } else if (id == 'league_border_gold') {
      avatar = avatar.withOption(AvatarPart.border, AvatarBorder.gold.index);
    } else {
      throw StateError('unexpected');
    }
  }

  @override
  Future<void> saveAvatar(AvatarConfig value) async {
    if (fail) throw Exception('offline');
    saved.add(value);
    avatar = value;
  }
}

void main() {
  late WardrobePlayer repo;
  late ProviderContainer container;
  Future<void> mount(
    WidgetTester tester, {
    Widget screen = const InventoryScreen(),
  }) async {
    repo = WardrobePlayer();
    container = ProviderContainer(
      overrides: [
        playerRepositoryProvider.overrideWithValue(repo),
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MyApp(home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('Inventaire vide : Dos Classique présent et premier sans achat', () {
    final state = PlayerInventory(profile: {}, owned: {}, catalog: []);
    expect(state.forCategory(InventoryCategory.cardBack).single.id, 'classic');
    expect(state.items.single.isEquipped({}), isTrue);
  });
  test('L’inventaire couvre aussi les récompenses de ligue hors boutique', () {
    final state = PlayerInventory(
      profile: {},
      owned: {'league_border_gold', 'shop_chat_eskerrik'},
      catalog: catalog,
    );
    expect(
      state.forCategory(InventoryCategory.avatar).single.id,
      'league_border_gold',
    );
    expect(
      state.forCategory(InventoryCategory.cardBack).first.name,
      'Dos Classique',
    );
    expect(state.items.any((i) => i.id == 'shop_top_striped'), isFalse);
  });
  testWidgets('Dos classique rééquipable gratuitement depuis l’inventaire', (
    tester,
  ) async {
    await mount(tester);
    final classic = find.byKey(const ValueKey('inventory-item-classic'));
    expect(find.text('Dos Classique'), findsOneWidget);
    await tester.tap(
      find.descendant(of: classic, matching: find.text(testL10n.menuEquip)),
    );
    await tester.pumpAndSettle();
    expect(repo.equipped, ['classic']);
    expect(repo.back, 'classic');
    expect(
      container.read(playerProfileProvider).asData?.value['card_back'],
      'classic',
    );
    expect(
      find.descendant(of: classic, matching: find.text(testL10n.menuEquipped)),
      findsOneWidget,
    );
    expect(repo.owned.contains('classic'), isFalse);
    expect((await repo.profile())['coins'], 500);
  });
  testWidgets('Personnalisation propose les onglets dos et cheveux', (
    tester,
  ) async {
    await mount(tester);
    expect(find.byType(DefaultTabController), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.text('Dos Classique'), findsOneWidget);
    expect(find.text('Dos Violet'), findsOneWidget);
    for (final label in [
      'Avatar',
      'Chats',
      'Casquette',
      'Bordure Or',
      'Lunettes dorées',
      'Aucun accessoire',
    ]) {
      expect(find.text(label), findsNothing);
    }
    await tester.tap(find.widgetWithText(Tab, 'Cheveux'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('inventory-item-shop_hair_mohawk')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('avatar-mohawk')), findsOneWidget);
    expect(repo.saved, isEmpty);
  });
  testWidgets('Profil : Personnalisation ouvre l’inventaire', (tester) async {
    await mount(
      tester,
      screen: Scaffold(body: ProfileTab(onChanged: () {})),
    );
    final entry = find.byKey(const ValueKey('open-inventory-button'));
    expect(
      find.descendant(of: entry, matching: find.byType(Icon)),
      findsNothing,
    );
    expect(
      tester
          .getCenter(
            find.descendant(
              of: entry,
              matching: find.text(testL10n.menuCustomisation),
            ),
          )
          .dx,
      closeTo(tester.getCenter(entry).dx, .1),
    );
    await tester.tap(find.byKey(const ValueKey('open-inventory-button')));
    await tester.pumpAndSettle();
    expect(find.byType(InventoryScreen), findsOneWidget);
  });
  testWidgets(
    'Erreur d’équipement : pas de badge mensonger et nouvelle tentative possible',
    (tester) async {
      await mount(tester);
      repo.fail = true;
      final classic = find.byKey(const ValueKey('inventory-item-classic'));
      await tester.tap(
        find.descendant(of: classic, matching: find.text(testL10n.menuEquip)),
      );
      await tester.pumpAndSettle();
      expect(repo.back, 'shop_back_violet');
      expect(find.textContaining('Équipement impossible'), findsOneWidget);
      expect(
        find.descendant(
          of: classic,
          matching: find.text(testL10n.menuEquipped),
        ),
        findsNothing,
      );
    },
  );
  testWidgets(
    'Table : le dos suit le profil global sans changer l’avatar ni réinitialiser la partie',
    (tester) async {
      await mount(tester);
      final controller = container.read(musGameControllerProvider.notifier);
      final roster = [
        for (var seat = 0; seat < 4; seat++)
          {
            'seat': seat,
            'name': 'P$seat',
            'is_host': seat == 0,
            'is_bot': seat != 0,
            'avatar_config': const AvatarConfig(glasses: 1).toJson(),
          },
      ];
      controller.configureMultiplayer(players: roster);
      controller.startGame();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MyApp(home: GameScreen(players: roster)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PlayerAvatarView>(
              find.byKey(const ValueKey('player-avatar-0')),
            )
            .config
            .glasses,
        1,
      );
      expect(
        tester
            .widgetList<CardBackView>(find.byType(CardBackView))
            .any((view) => view.id == 'shop_back_violet'),
        isTrue,
      );
      final before = container.read(musGameControllerProvider);
      Navigator.of(
        tester.element(find.byType(GameScreen)),
      ).push<void>(MaterialPageRoute(builder: (_) => const InventoryScreen()));
      await tester.pumpAndSettle();
      final classic = find.byKey(const ValueKey('inventory-item-classic'));
      await tester.tap(
        find.descendant(of: classic, matching: find.text(testL10n.menuEquip)),
      );
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(InventoryScreen))).pop();
      await tester.pumpAndSettle();
      final local = tester
          .widget<PlayerAvatarView>(
            find.byKey(const ValueKey('player-avatar-0')),
          )
          .config;
      expect(local, repo.avatar);
      expect(repo.saved, isEmpty);
      expect(local.border, AvatarBorder.gold);
      expect(
        tester
            .widget<PlayerAvatarView>(
              find.byKey(const ValueKey('player-avatar-1')),
            )
            .config
            .glasses,
        1,
      );
      expect(
        tester
            .widgetList<CardBackView>(find.byType(CardBackView))
            .every((view) => view.id == 'classic'),
        isTrue,
      );
      expect(container.read(musGameControllerProvider), same(before));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Une requête finie après fermeture rafraîchit le profil sans double équipement',
    (tester) async {
      await mount(tester, screen: const Scaffold(body: Text('Accueil')));
      final keep = container.listen(playerProfileProvider, (_, _) {});
      addTearDown(keep.close);
      await container.read(playerProfileProvider.future);
      Navigator.of(
        tester.element(find.text('Accueil')),
      ).push<void>(MaterialPageRoute(builder: (_) => const InventoryScreen()));
      await tester.pumpAndSettle();
      repo.gate = Completer<void>();
      final button = find.descendant(
        of: find.byKey(const ValueKey('inventory-item-classic')),
        matching: find.text(testL10n.menuEquip),
      );
      await tester.tap(button);
      await tester.pump();
      await tester.tap(button);
      await tester.pump();
      expect(repo.equipped.length, 1);
      Navigator.of(tester.element(find.byType(InventoryScreen))).pop();
      await tester.pumpAndSettle();
      repo.gate!.complete();
      await tester.pumpAndSettle();
      expect(
        (await container.read(playerProfileProvider.future))['card_back'],
        'classic',
      );
      expect(tester.takeException(), isNull);
    },
  );
  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('Inventaire à $size sans débordement', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(tester);
      expect(find.text('Dos Classique'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
