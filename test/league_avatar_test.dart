import 'package:isamus/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/avatar_config.dart';
import 'package:isamus/core/models/game_season.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/features/avatar/player_avatar_view.dart';
import 'package:isamus/features/avatar/avatar_editor_screen.dart';

void main() {
  test(
    'Le JSON conserve les récompenses et accepte les anciennes apparences',
    () {
      final config = AvatarConfig.fromJson({
        'skin': 1,
        'border': 'gold',
        'exclusive_hat': 'txapela',
      });
      expect(config.border, AvatarBorder.gold);
      expect(config.exclusiveHat, ExclusiveHat.txapela);
      expect(AvatarConfig.fromJson(config.toJson()), config);
      expect(config.withOption(AvatarPart.skin, 2).border, AvatarBorder.gold);
      expect(AvatarConfig.fromJson({'skin': 1}).border, AvatarBorder.none);
      expect(
        AvatarConfig.fromJson({'border': 'forged', 'exclusive_hat': 99})
            .exclusiveHat,
        ExclusiveHat.none,
      );
    },
  );
  test(
    'Les accessoires payants et les bordures de ligue ont des droits distincts',
    () {
      for (final (part, option) in [
        (AvatarPart.hair, AvatarConfig.baldHair),
        (AvatarPart.hair, AvatarConfig.mohawkHair),
        (AvatarPart.top, 3),
      ]) {
        final id = AvatarConfig.cosmeticIdFor(part, option)!;
        final config = const AvatarConfig().withCosmetic(id);
        expect(config.valueFor(part), option);
        expect(AvatarConfig.fromJson(config.toJson()), config);
      }
      for (final border in AvatarBorder.values.skip(1)) {
        expect(
          AvatarConfig.cosmeticIdFor(AvatarPart.border, border.index),
          startsWith('league_border_'),
        );
      }
    },
  );
  test('Le calendrier conserve les fuseaux et arrondit les jours restants de la même façon', () {
    final season = GameSeason.fromJson({
      'id': 'season_1',
      'name': 'Saison 1',
      'start_date': '2026-10-01T00:00:00+02:00',
      'end_date': '2026-11-01T00:00:00+01:00',
    });
    expect(season.daysRemaining(DateTime.utc(2026, 10, 28, 12)), 4);
    expect(season.daysRemaining(DateTime.utc(2026, 11, 1)), 0);
  });
  for (final border in [
    AvatarBorder.bronze,
    AvatarBorder.silver,
    AvatarBorder.gold,
    AvatarBorder.diamond,
  ]) {
    testWidgets(
      'Anneau public ${border.name} et couvre-chef à taille de table',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            home: Center(
              child: PlayerAvatarView(
                size: 48,
                config: AvatarConfig(
                  border: border,
                  exclusiveHat: ExclusiveHat.txapela,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(ValueKey('avatar-border-${border.name}')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('avatar-exclusive-hat-txapela')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('avatar-circle')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'L’éditeur autorise les récompenses possédées et verrouille les autres',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryProvider.overrideWith(
              (ref) async => {'league_border_gold', 'league_hat_txapela'},
            ),
          ],
          child: MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            home: AvatarEditorScreen(initialConfig: AvatarConfig()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(testL10n.menuBorders));
      await tester.pumpAndSettle();
      await tester.tap(find.text(testL10n.menuBorders));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<InkWell>(find.byKey(const ValueKey('avatar-border-1')))
            .onTap,
        isNull,
      );
      await tester.tap(find.byKey(const ValueKey('avatar-border-3')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PlayerAvatarView>(
              find.byKey(const ValueKey('avatar-preview')),
            )
            .config
            .border,
        AvatarBorder.gold,
      );
      await tester.ensureVisible(find.text(testL10n.menuHeadwear));
      await tester.pumpAndSettle();
      await tester.tap(find.text(testL10n.menuHeadwear));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('avatar-exclusive_hat-1')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PlayerAvatarView>(
              find.byKey(const ValueKey('avatar-preview')),
            )
            .config
            .exclusiveHat,
        ExclusiveHat.txapela,
      );
    },
  );
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
