import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isamus/core/localization/app_locale.dart';
import 'package:isamus/core/network/auth_repository.dart';
import 'package:isamus/core/network/auth_service.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/features/settings/settings_screen.dart';
import 'package:isamus/main.dart';
import 'package:isamus/l10n/app_localizations.dart';

class LanguageAuth extends AuthRepository {
  String? id = 'player-a';
  Map<String, dynamic>? profile = {'language': 'eu'};
  Completer<Map<String, dynamic>?>? pending;
  @override
  String? get currentUserId => id;
  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async =>
      pending == null ? profile : await pending!.future;
}

class LanguagePlayer extends PlayerRepository {
  final saved = <String>[];
  bool fail = false;
  @override
  Future<Map<String, dynamic>> profile() async => {'sound_enabled': true};
  @override
  Future<void> language(String playerId, String code) async {
    if (fail) throw Exception('offline');
    saved.add('$playerId:$code');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LanguageAuth auth;
  late LanguagePlayer player;
  ProviderContainer container() => ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      playerRepositoryProvider.overrideWithValue(player),
    ],
  );
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    auth = LanguageAuth();
    player = LanguagePlayer();
  });

  test(
    'profile PATCH filters the captured identity and detects missing rows',
    () async {
      final requests = <http.Request>[];
      var missing = false;
      final client = SupabaseClient(
        'https://example.test',
        'public-test-key',
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            missing
                ? '{"message":"No row","code":"PGRST116"}'
                : '{"id":"player-a"}',
            missing ? 406 : 200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final repository = PlayerRepository(clientInstance: client);
      await repository.language('player-a', 'eu');
      expect(requests.single.method, 'PATCH');
      expect(requests.single.url.path, '/rest/v1/profiles');
      expect(requests.single.url.queryParameters['id'], 'eq.player-a');
      expect(jsonDecode(requests.single.body), {'language': 'eu'});
      missing = true;
      await expectLater(
        repository.language('player-a', 'en'),
        throwsA(isA<PostgrestException>()),
      );
      await expectLater(
        repository.language('player-a', 'de'),
        throwsFormatException,
      );
      expect(requests.length, 2);
    },
  );

  test(
    'server preference wins over cache on login and restored session',
    () async {
      SharedPreferences.setMockInitialValues({'language.player-a': 'es'});
      final scope = container();
      addTearDown(scope.dispose);
      await scope.read(sessionLanguageProvider('player-a').future);
      expect(scope.read(appLocaleProvider), const Locale('eu'));
      expect(
        (await SharedPreferences.getInstance()).getString('language.player-a'),
        'eu',
      );
      final restored = container();
      addTearDown(restored.dispose);
      await restored.read(sessionLanguageProvider('player-a').future);
      expect(restored.read(appLocaleProvider), const Locale('eu'));
    },
  );

  test(
    'saves both locally and remotely then restores after logout/login',
    () async {
      final scope = container();
      await scope.read(appLocaleProvider.notifier).save(const Locale('en'));
      expect(scope.read(appLocaleProvider), const Locale('en'));
      expect(player.saved, ['player-a:en']);
      auth.profile = {'language': 'en'};
      scope.dispose();
      final next = container();
      addTearDown(next.dispose);
      await next.read(sessionLanguageProvider('player-a').future);
      expect(next.read(appLocaleProvider), const Locale('en'));
    },
  );

  test(
    'offline fallback is isolated per account; unknown language defaults to FR',
    () async {
      SharedPreferences.setMockInitialValues({
        'language': 'en',
        'language.player-a': 'es',
      });
      auth.profile = null;
      final scope = container();
      addTearDown(scope.dispose);
      await scope.read(appLocaleProvider.notifier).restore('player-a');
      expect(scope.read(appLocaleProvider), const Locale('es'));
      final other = container();
      addTearDown(other.dispose);
      await other.read(appLocaleProvider.notifier).restore('player-b');
      expect(other.read(appLocaleProvider), const Locale('fr'));
      auth.profile = {'language': 'de'};
      await scope.read(appLocaleProvider.notifier).restore('player-a');
      expect(scope.read(appLocaleProvider), const Locale('fr'));
    },
  );

  test('late profile cannot replace a newer explicit choice', () async {
    auth.pending = Completer();
    final scope = container();
    addTearDown(scope.dispose);
    final restore = scope.read(appLocaleProvider.notifier).restore('player-a');
    await Future<void>.delayed(Duration.zero);
    await scope.read(appLocaleProvider.notifier).save(const Locale('en'));
    auth.pending!.complete({'language': 'eu'});
    await restore;
    expect(scope.read(appLocaleProvider), const Locale('en'));
  });

  test('late response from disposed session does not touch cache', () async {
    auth.pending = Completer();
    final scope = container();
    final restore = scope.read(appLocaleProvider.notifier).restore('player-a');
    await Future<void>.delayed(Duration.zero);
    scope.dispose();
    auth.pending!.complete({'language': 'eu'});
    await restore;
    expect(
      (await SharedPreferences.getInstance()).getString('language'),
      isNull,
    );
  });

  test('signed-out choice is local only', () async {
    auth.id = null;
    final scope = container();
    addTearDown(scope.dispose);
    await scope.read(appLocaleProvider.notifier).save(const Locale('es'));
    expect(player.saved, isEmpty);
    final next = container();
    addTearDown(next.dispose);
    await next.read(sessionLanguageProvider(null).future);
    expect(next.read(appLocaleProvider), const Locale('es'));
  });

  testWidgets(
    'settings updates MaterialApp and both stores; failed save is visible',
    (tester) async {
      final scope = container();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scope,
          child: const MyApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> choose(String language) async {
        tester
            .widget<DropdownButton<Locale>>(
              find.byKey(const ValueKey('settings-language-selector')),
            )
            .onChanged!(Locale(language));
        await tester.pumpAndSettle();
      }

      await choose('en');
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        const Locale('en'),
      );
      expect(player.saved, ['player-a:en']);
      expect(
        (await SharedPreferences.getInstance()).getString('language.player-a'),
        'en',
      );
      player.fail = true;
      await choose('es');
      expect(
        find.text(
          lookupAppLocalizations(const Locale('es'))
              .menuUnableToCompleteThisActionCheckYourConnectionAnd,
        ),
        findsOneWidget,
      );
      expect(player.saved, ['player-a:en']);
      expect(scope.read(appLocaleProvider), const Locale('es'));
      await tester.pumpWidget(const SizedBox.shrink());
      scope.dispose();
    },
  );
}
