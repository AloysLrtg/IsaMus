import 'package:isamus/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/main.dart';
import 'package:isamus/core/network/account_repository.dart';
import 'package:isamus/features/profile/account_screen.dart';
import 'package:isamus/features/settings/settings_screen.dart';

class SettingsPlayer extends PlayerRepository {
  bool soundEnabled = true;
  bool failSave = false;
  bool failLoad = false;
  final saved = <bool>[];
  @override
  Future<Map<String, dynamic>> profile() async {
    if (failLoad) throw Exception('offline');
    return {'username': 'Ane', 'elo': 1200, 'sound_enabled': soundEnabled};
  }

  @override
  Future<void> sound(bool enabled) async {
    if (failSave) throw Exception('offline');
    saved.add(enabled);
    soundEnabled = enabled;
  }
}

class SettingsAccount extends AccountRepository {
  @override
  User? get user => null;
  @override
  Stream<AuthState> get changes => const Stream.empty();
}

void main() {
  Future<void> mount(WidgetTester tester, SettingsPlayer repo) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerRepositoryProvider.overrideWithValue(repo),
          accountRepositoryProvider.overrideWithValue(SettingsAccount()),
        ],
        child: const MyApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  SwitchListTile sound(WidgetTester tester) => tester.widget<SwitchListTile>(
    find.byKey(const ValueKey('settings-sound-toggle')),
  );

  testWidgets(
    'Réglages enregistre le son et recharge la préférence persistée',
    (tester) async {
      final repo = SettingsPlayer();
      await mount(tester, repo);
      expect(find.text('Réglages'), findsOneWidget);
      expect(sound(tester).value, isTrue);
      await tester.tap(find.byKey(const ValueKey('settings-sound-toggle')));
      await tester.pumpAndSettle();
      expect(repo.saved, [false]);
      expect(sound(tester).value, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      await mount(tester, repo);
      expect(sound(tester).value, isFalse);
      expect(find.text(testL10n.menuAccountSecurity), findsOneWidget);
      expect(find.text(testL10n.menuTermsOfUse), findsOneWidget);
      expect(find.text(testL10n.menuPrivacyPolicy), findsOneWidget);
    },
  );
  testWidgets(
    'échec de sauvegarde garde le son précédent et autorise une reprise',
    (tester) async {
      final repo = SettingsPlayer()..failSave = true;
      await mount(tester, repo);
      await tester.tap(find.byKey(const ValueKey('settings-sound-toggle')));
      await tester.pumpAndSettle();
      expect(sound(tester).value, isTrue);
      expect(find.textContaining('Action impossible'), findsOneWidget);
      repo.failSave = false;
      await tester.tap(find.byKey(const ValueKey('settings-sound-toggle')));
      await tester.pumpAndSettle();
      expect(sound(tester).value, isFalse);
      expect(find.textContaining('Action impossible'), findsNothing);
    },
  );
  testWidgets('compte et documents légaux accessibles depuis Réglages', (
    tester,
  ) async {
    await mount(tester, SettingsPlayer());
    await tester.tap(find.byKey(const ValueKey('settings-account-button')));
    await tester.pumpAndSettle();
    expect(find.byType(AccountScreen), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    for (final entry in {
      'settings-terms-button': testL10n.menuTermsOfUse,
      'settings-privacy-button': testL10n.menuPrivacyPolicy,
    }.entries) {
      await tester.tap(find.byKey(ValueKey(entry.key)));
      await tester.pumpAndSettle();
      expect(find.byType(SelectableText), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(entry.value),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'compte et documents restent accessibles si le profil ne charge pas',
    (tester) async {
      await mount(tester, SettingsPlayer()..failLoad = true);
      expect(find.text(testL10n.menuPreferenceUnavailable), findsOneWidget);
      expect(
        find.byKey(const ValueKey('settings-account-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('settings-terms-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('settings-privacy-button')),
        findsOneWidget,
      );
      expect(find.text(testL10n.menuTryAgain), findsOneWidget);
    },
  );
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
