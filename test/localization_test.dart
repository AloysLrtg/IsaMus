import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/audio/audio_haptic_service.dart';
import 'package:isamus/core/localization/app_locale.dart';
import 'package:isamus/core/localization/catalog_localizations.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/models/game_invitation_mode.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/social_repository.dart';
import 'package:isamus/core/network/retention_repository.dart';
import 'package:isamus/core/network/shop_repository.dart';
import 'package:isamus/features/auth/login_screen.dart';
import 'package:isamus/features/auth/register_screen.dart';
import 'package:isamus/features/avatar/avatar_editor_screen.dart';
import 'package:isamus/features/profile/profile_tab.dart';
import 'package:isamus/features/retention/battle_pass_screen.dart';
import 'package:isamus/features/rules/rules_screen.dart';
import 'package:isamus/features/settings/settings_screen.dart';
import 'package:isamus/features/inventory/inventory_screen.dart';
import 'package:isamus/features/social/friends_tab.dart';
import 'package:isamus/features/retention/quests_screen.dart';
import 'package:isamus/features/shop/shop_screen.dart';
import 'package:isamus/features/tutorial/tutorial_screen.dart';
import 'package:isamus/l10n/app_localizations.dart';
import 'package:isamus/main.dart';

import 'helpers/audio_haptic_fakes.dart';
import 'shop_screen_test.dart' show shopTestItems;

const protectedMusTerms = [
  'TIRA',
  'PASO',
  'Nere gatik tira',
  'Tira nere gatik',
  'Hordago Kanta',
  'Biak Embido',
  'Biak Hordago',
  'Haundi Pasa',
  'Bigehiago',
  'Bortz gehiago',
  'Lau gehiago',
  'Hiru Embido',
  'Zuetan',
  'Mus',
  'Tira',
  'Nere gatik',
  'Ordago',
  'Imido',
  'Envido',
  'Mintza',
  'Iduki',
  'Embido',
  'Gehiago',
  'Hordago',
  'Esku',
  'ESKU',
  'Bai',
  'Paso',
  'Mediak',
  'Dobliak',
  'Handia',
  'Ttipia',
  'Pareak',
  'Joko',
  'Pontua',
  'tantto',
  'hamarreko',
  'Hamarreko',
  'Tantto',
  'Txapela',
  'Eskerrik asko',
];

Map<String, dynamic> catalogue(String language) =>
    jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  final french = catalogue('fr');
  final keys = french.keys.where((k) => !k.startsWith('@')).toSet();
  for (final language in ['fr', 'eu', 'es', 'en']) {
    final locale = Locale(language);
    final l10n = lookupAppLocalizations(locale);
    test('$language: complete catalogues, placeholders and Mus vocabulary', () {
      final translated = catalogue(language);
      expect(translated.keys.where((k) => !k.startsWith('@')).toSet(), keys);
      for (final key in keys) {
        final source = french[key] as String;
        final text = translated[key] as String;
        expect(text.trim(), isNotEmpty, reason: '$language / $key');
        final placeholder = RegExp(r'\{(\w+)\}');
        expect(
          placeholder.allMatches(text).map((m) => m[1]).toSet(),
          placeholder.allMatches(source).map((m) => m[1]).toSet(),
          reason: '$language / $key: placeholders',
        );
        for (final term in protectedMusTerms) {
          final pattern = RegExp(
            '(?<![A-Za-z])${RegExp.escape(term)}(?![A-Za-z])',
          );
          expect(
            pattern.allMatches(text).length,
            greaterThanOrEqualTo(pattern.allMatches(source).length),
            reason: '$language / $key: preserve $term',
          );
        }
      }
      expect(l10n.legalTermsBody, startsWith('ISAMUS'));
      expect(l10n.legalPrivacyBody, startsWith('ISAMUS'));
      expect(catalogName(l10n, 'shop_top_striped', 'FR'), l10n.catalogStriped);
      expect(
        questTitle(l10n, {'id': 'ranked_wins', 'target': 2}),
        l10n.questRanked('2'),
      );
      expect(
        GameInvitationMode.rankedDuo.title(l10n),
        l10n.invitationRankedTitle,
      );
    });

    ProviderContainer? activeContainer;
    Future<void> clear(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      activeContainer?.dispose();
      activeContainer = null;
      await tester.pump();
    }

    Future<void> mount(WidgetTester tester, Widget home) async {
      await clear(tester);
      final container = ProviderContainer(
        overrides: [
          audioHapticServiceProvider.overrideWithValue(
            FakeAudioHapticService(),
          ),
          playerProfileProvider.overrideWith(
            (ref) async => {
              'username': 'Ane',
              'elo': 1200,
              'sound_enabled': true,
              'coins': 1000,
              'avatar_config': const AvatarConfig().toJson(),
            },
          ),
          inventoryProvider.overrideWith((ref) async => <String>{}),
          cosmeticsProvider.overrideWith((ref) async => []),
          friendshipsProvider.overrideWith((ref) => Stream.value([])),
          blockedUsersProvider.overrideWith((ref) => Stream.value([])),
          matchHistoryProvider.overrideWith((ref) async => []),
          shopStateProvider.overrideWith(
            (ref) async => const ShopState(
              items: shopTestItems,
              profile: {'coins': 1000},
              owned: {},
            ),
          ),
          vipPackageProvider.overrideWith((ref) async => null),
          retentionStatusProvider.overrideWith(
            (ref) async => {
              'coins': 1000,
              'level': 1,
              'xp': 0,
              'vip': false,
              'rewards': [],
              'claims': [],
              'quests': [
                {
                  'id': 'ranked_wins',
                  'target': 2,
                  'progress': 0,
                  'reward_xp': 500,
                },
              ],
            },
          ),
        ],
      );
      activeContainer = container;
      addTearDown(container.dispose);
      container.read(appLocaleProvider.notifier).select(locale);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MyApp(home: home),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('$language: settings and legal documents', (tester) async {
      await mount(tester, const SettingsScreen());
      expect(find.text(l10n.menuSoundEffects), findsOneWidget);
      expect(find.text(l10n.settingsTitle), findsOneWidget);
      for (final entry in [
        ('settings-terms-button', l10n.legalTermsBody),
        ('settings-privacy-button', l10n.legalPrivacyBody),
      ]) {
        await tester.ensureVisible(find.byKey(ValueKey(entry.$1)));
        await tester.tap(find.byKey(ValueKey(entry.$1)));
        await tester.pumpAndSettle();
        expect(find.byType(SelectableText), findsOneWidget);
        expect(
          tester.widget<SelectableText>(find.byType(SelectableText)).data,
          entry.$2,
        );
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await clear(tester);
    });

    testWidgets('$language: shop, profile and avatar editor', (tester) async {
      await mount(tester, const ShopScreen());
      expect(find.text(l10n.catalogStriped), findsOneWidget);
      expect(find.text(l10n.menuOutfits), findsOneWidget);
      await mount(tester, Scaffold(body: ProfileTab(onChanged: () {})));
      expect(find.text(l10n.menuPlayerProfile352), findsOneWidget);
      await mount(
        tester,
        const AvatarEditorScreen(initialConfig: AvatarConfig()),
      );
      expect(find.text(l10n.menuEditMyAvatar), findsOneWidget);
      expect(find.text(l10n.menuSkin), findsOneWidget);
      expect(tester.takeException(), isNull);
      await clear(tester);
    });

    testWidgets('$language: friends, quests and inventory', (tester) async {
      await mount(
        tester,
        const Scaffold(
          body: FriendsTab(userId: 'local', username: 'Ane'),
        ),
      );
      expect(find.text(l10n.menuFriendsPrivateRooms), findsOneWidget);
      expect(find.text(l10n.menuRequests), findsOneWidget);
      await mount(tester, const Scaffold(body: WeeklyQuestsSheet()));
      expect(find.text(l10n.menuWeeklyQuests), findsOneWidget);
      expect(find.text(l10n.questRanked('2')), findsOneWidget);
      await mount(tester, const InventoryScreen());
      expect(find.text(l10n.classicCardBack), findsOneWidget);
      expect(tester.takeException(), isNull);
      await clear(tester);
    });

    testWidgets('$language: sign-in and registration', (tester) async {
      await mount(tester, const LoginScreen());
      expect(find.text(l10n.menuYourTableIsWaiting), findsOneWidget);
      await tester.tap(find.text(l10n.menuSignIn));
      await tester.pumpAndSettle();
      expect(find.text(l10n.menuEnterAValidEmailAddress), findsOneWidget);
      await mount(tester, const RegisterScreen());
      expect(find.text(l10n.menuJoinIsaMus), findsOneWidget);
      expect(tester.takeException(), isNull);
      await clear(tester);
    });

    testWidgets('$language: season pass, rules and guided tutorial', (
      tester,
    ) async {
      await mount(tester, const BattlePassScreen());
      expect(find.text(l10n.seasonPassTitle), findsOneWidget);
      await mount(tester, const RulesScreen());
      expect(
        find.text(l10n.menuFrenchMusChampionshipRegulations),
        findsOneWidget,
      );
      await mount(tester, const TutorialScreen());
      expect(find.text(l10n.menuMusOrMintza), findsOneWidget);
      expect(find.text(l10n.menuGotIt), findsOneWidget);
      expect(tester.takeException(), isNull);
      await clear(tester);
    });
  }
}
