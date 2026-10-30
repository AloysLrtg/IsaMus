import 'package:isamus/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/features/avatar/avatar_editor_screen.dart';
import 'package:isamus/features/avatar/player_avatar_view.dart';
import 'package:isamus/features/profile/profile_tab.dart';

class AvatarPlayer extends PlayerRepository {
  AvatarConfig config = const AvatarConfig(glasses: 1);
  int writes = 0;
  bool fail = false;
  @override
  Future<Map<String, dynamic>> profile() async => {
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
    'sound_enabled': true,
    'avatar_config': config.toJson(),
  };
  @override
  Future<List<Map<String, dynamic>>> history() async => [];
  @override
  Future<void> saveAvatar(AvatarConfig value) async {
    writes++;
    if (fail) throw Exception('offline');
    config = value;
  }
}

void main() {
  test('avatar JSON normalise les valeurs absentes et invalides', () {
    expect(AvatarConfig.fromJson(null), const AvatarConfig());
    expect(AvatarConfig.fromJson([]), const AvatarConfig());
    expect(
      AvatarConfig.fromJson({'skin': -1, 'glasses': '2', 'top': 99}),
      const AvatarConfig(),
    );
    const config = AvatarConfig(skin: 2, glasses: 1, top: 2, hair: 1);
    expect(AvatarConfig.fromJson(config.toJson()), config);
    expect(config.withOption(AvatarPart.hair, 2).toJson(), {
      'skin': 2,
      'glasses': 1,
      'top': 2,
      'hair': 2,
      'background_color': 0,
      'hair_color': 0,
      'border': 'none',
      'exclusive_hat': 'none',
    });
  });

  Future<void> mountProfile(WidgetTester tester, AvatarPlayer repo) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [playerRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          home: Scaffold(body: ProfileTab(onChanged: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-avatar-button')));
    await tester.pumpAndSettle();
  }

  AvatarConfig preview(WidgetTester tester) => tester
      .widget<PlayerAvatarView>(find.byKey(const ValueKey('avatar-preview')))
      .config;

  testWidgets(
    'bouton Profil ouvre l’éditeur et sauvegarde les six catégories',
    (tester) async {
      final repo = AvatarPlayer();
      await mountProfile(tester, repo);
      expect(find.byType(AvatarEditorScreen), findsOneWidget);
      expect(preview(tester), repo.config);
      for (final entry in {
        'skin': 'Peau',
        'glasses': 'Lunettes',
        'top': 'Haut',
        'hair': 'Cheveux',
        'background_color': 'Couleur de fond',
        'hair_color': 'Couleur cheveux',
      }.entries) {
        await tester.ensureVisible(find.text(entry.value));
        await tester.pumpAndSettle();
        await tester.tap(find.text(entry.value));
        await tester.pumpAndSettle();
        expect(find.byKey(ValueKey('avatar-${entry.key}-0')), findsOneWidget);
        expect(find.byKey(ValueKey('avatar-${entry.key}-1')), findsOneWidget);
        expect(find.byKey(ValueKey('avatar-${entry.key}-2')), findsOneWidget);
        await tester.tap(find.byKey(ValueKey('avatar-${entry.key}-2')));
        await tester.pumpAndSettle();
      }
      expect(repo.writes, 0);
      expect(
        preview(tester),
        const AvatarConfig(
          skin: 2,
          glasses: 2,
          top: 2,
          hair: 2,
          backgroundColor: 2,
          hairColor: 2,
        ),
      );
      await tester.tap(find.text(testL10n.menuSave403));
      await tester.pumpAndSettle();
      expect(repo.writes, 1);
      expect(
        repo.config,
        const AvatarConfig(
          skin: 2,
          glasses: 2,
          top: 2,
          hair: 2,
          backgroundColor: 2,
          hairColor: 2,
        ),
      );
      expect(find.byType(AvatarEditorScreen), findsNothing);
      expect(
        tester.widget<PlayerAvatarView>(find.byType(PlayerAvatarView)).config,
        repo.config,
      );
    },
  );

  testWidgets('retour sans sauvegarder abandonne le brouillon', (tester) async {
    final repo = AvatarPlayer();
    await mountProfile(tester, repo);
    await tester.tap(find.byKey(const ValueKey('avatar-skin-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(repo.writes, 0);
    expect(repo.config, const AvatarConfig(glasses: 1));
    expect(find.byType(AvatarEditorScreen), findsNothing);
  });

  testWidgets('échec de sauvegarde garde le brouillon et permet de réessayer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = AvatarPlayer()..fail = true;
    await mountProfile(tester, repo);
    await tester.tap(find.byKey(const ValueKey('avatar-skin-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(testL10n.menuSave403));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sauvegarde impossible'), findsOneWidget);
    expect(preview(tester).skin, 2);
    expect(repo.config.skin, 0);
    repo.fail = false;
    await tester.tap(find.text(testL10n.menuSave403));
    await tester.pumpAndSettle();
    expect(repo.config.skin, 2);
    expect(find.byType(AvatarEditorScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
