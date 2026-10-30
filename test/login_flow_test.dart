import 'package:isamus/l10n/app_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/network/auth_repository.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/features/auth/login_screen.dart';
import 'package:isamus/features/auth/register_screen.dart';
import 'package:isamus/features/home/main_dashboard_screen.dart';
import 'package:isamus/features/profile/account_screen.dart';
import 'package:isamus/main.dart';

User identity({
  String id = '123e4567-e89b-12d3-a456-426614174000',
  bool guest = false,
}) => User(
  id: id,
  appMetadata: {'provider': guest ? 'anonymous' : 'email'},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-10-28T00:00:00Z',
  email: guest ? null : 'ane@example.com',
  isAnonymous: guest,
);

class LoginAuth extends AuthRepository {
  User? active;
  final events = StreamController<User?>.broadcast(sync: true);
  final calls = <String>[];
  bool requiresConfirmation = false;
  String? signedUpUsername;
  AuthException? error;
  Completer<void>? gate;
  @override
  User? get currentUser => active;
  @override
  String? get currentUserId => active?.id;
  @override
  Stream<User?> get userChanges => Stream.multi((sink) {
    final sub = events.stream.listen(sink.add);
    sink.add(active);
    sink.onCancel = sub.cancel;
  });
  void emit(User? user) {
    active = user;
    events.add(user);
  }

  @override
  Future<void> signIn(String email, String password) async {
    calls.add('email:${email.trim()}:$password');
    if (gate != null) await gate!.future;
    if (error != null) throw error!;
    emit(identity());
  }

  @override
  Future<bool> signUp(
    String email,
    String password, {
    required String username,
  }) async {
    calls.add('signup');
    signedUpUsername = username.trim();
    if (gate != null) await gate!.future;
    if (error != null) throw error!;
    if (requiresConfirmation) return false;
    emit(identity());
    return true;
  }

  @override
  Future<String> signInAnonymously() async {
    calls.add('guest');
    emit(identity(guest: true));
    return active!.id;
  }

  @override
  Future<void> signOut() async {
    calls.add('signout');
    emit(null);
  }

  @override
  Future<void> deleteAccount() async {
    calls.add('delete');
    emit(null);
  }

  @override
  Future<Map<String, dynamic>?> getProfile(String id) async => {
    'id': id,
    'username': 'Ane',
    'elo': 1200,
  };
}

void main() {
  late LoginAuth auth;
  final scopes = <ProviderContainer>[];
  Future<void> mount(WidgetTester tester, {User? restored}) async {
    auth = LoginAuth()..active = restored;
    scopes.clear();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          sessionContainerFactoryProvider.overrideWithValue((repo) {
            final container = ProviderContainer(
              overrides: [
                authRepositoryProvider.overrideWithValue(repo),
                playerProfileProvider.overrideWith(
                  (ref) async => {
                    'username': 'Ane',
                    'elo': 1200,
                    'sound_enabled': false,
                  },
                ),
                musBotsEnabledProvider.overrideWithValue(false),
                musTurnTimeoutProvider.overrideWithValue(null),
              ],
            );
            scopes.add(container);
            return container;
          }),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await auth.events.close();
      await tester.pump();
    });
  }

  Future<void> fill(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'ane@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'longpassword',
    );
  }

  testWidgets(
    'lancement déconnecté : LoginScreen sans connexion anonyme automatique',
    (tester) async {
      await mount(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainDashboardScreen), findsNothing);
      expect(find.text('Continuer avec Google'), findsNothing);
      expect(find.text('Continuer avec Apple'), findsNothing);
      expect(find.byKey(const ValueKey('login-google')), findsNothing);
      expect(find.byKey(const ValueKey('login-apple')), findsNothing);
      for (final label in [
        'IsaMus',
        'Se connecter',
        "Pas encore de compte ? S'inscrire",
        'Jouer en tant qu’invité',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(auth.calls, isEmpty);
    },
  );
  testWidgets(
    'session restaurée : accès direct au dashboard, sans invité implicite',
    (tester) async {
      await mount(tester, restored: identity());
      expect(find.byType(MainDashboardScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(auth.calls, isEmpty);
    },
  );
  testWidgets('email validé puis navigation automatique à la connexion', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(auth.calls, isEmpty);
    expect(find.text(testL10n.menuEnterAValidEmailAddress), findsOneWidget);
    await fill(tester);
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(find.byType(MainDashboardScreen), findsOneWidget);
    expect(auth.calls.single, 'email:ane@example.com:longpassword');
  });
  Future<void> register(WidgetTester tester) async {
    final link = find.byKey(const ValueKey('login-signup'));
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();
  }

  Future<void> registrationForm(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const ValueKey('register-username')),
      'Ane',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-email')),
      'ane@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password')),
      'longpassword',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('register-submit')));
  }

  testWidgets('Login vers inscription séparée puis retour à Login', (
    tester,
  ) async {
    await mount(tester);
    expect(find.byKey(const ValueKey('register-username')), findsNothing);
    await register(tester);
    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('register-username')), findsOneWidget);
    expect(auth.calls, isEmpty);
    final back = find.byKey(const ValueKey('register-login'));
    await tester.ensureVisible(back);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
  });
  testWidgets(
    'inscription avec pseudo ouvre directement le dashboard et efface les routes auth',
    (tester) async {
      await mount(tester);
      await register(tester);
      await registrationForm(tester);
      await tester.tap(find.byKey(const ValueKey('register-submit')));
      await tester.pumpAndSettle();
      expect(auth.signedUpUsername, 'Ane');
      expect(auth.calls, ['signup']);
      expect(find.byType(MainDashboardScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(RegisterScreen), findsNothing);
      expect(
        Navigator.of(tester.element(find.byType(MainDashboardScreen))).canPop(),
        isFalse,
      );
    },
  );
  testWidgets(
    'inscription valide le pseudo et le mot de passe avant toute requête',
    (tester) async {
      await mount(tester);
      await register(tester);
      final submit = find.byKey(const ValueKey('register-submit'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text(testL10n.menuChooseANickname), findsOneWidget);
      expect(auth.calls, isEmpty);
      await registrationForm(tester);
      await tester.enterText(
        find.byKey(const ValueKey('register-password')),
        'short',
      );
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text(testL10n.menuUseAtLeast8Characters), findsOneWidget);
      expect(auth.calls, isEmpty);
    },
  );
  testWidgets(
    'si le serveur exige encore confirmation, aucune navigation non authentifiée',
    (tester) async {
      await mount(tester);
      auth.requiresConfirmation = true;
      await register(tester);
      await registrationForm(tester);
      await tester.tap(find.byKey(const ValueKey('register-submit')));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.byType(MainDashboardScreen), findsNothing);
      expect(
        find.textContaining('Consultez votre boîte e-mail'),
        findsOneWidget,
      );
    },
  );
  testWidgets('inscription : erreur récupérable et double soumission bloquée', (
    tester,
  ) async {
    await mount(tester);
    await register(tester);
    await registrationForm(tester);
    auth.gate = Completer();
    auth.error = const AuthException('already exists', code: 'email_exists');
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('register-submit')))
          .onPressed,
      isNull,
    );
    auth.gate!.complete();
    await tester.pumpAndSettle();
    expect(
      find.text(testL10n.menuAnAccountAlreadyUsesThisEmailAddress),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('register-submit')))
          .onPressed,
      isNotNull,
    );
  });
  testWidgets('Le mode invité reste un choix explicite', (tester) async {
    await mount(tester);
    final button = find.byKey(const ValueKey('login-guest'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(auth.calls, ['guest']);
    expect(find.byType(MainDashboardScreen), findsOneWidget);
  });
  testWidgets(
    'erreur de connexion récupérable, boutons bloqués pendant une requête',
    (tester) async {
      await mount(tester);
      auth.gate = Completer();
      auth.error = const AuthException(
        'Wrong password',
        code: 'invalid_credentials',
      );
      await fill(tester);
      await tester.tap(find.byKey(const ValueKey('login-submit')));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('login-submit')))
            .onPressed,
        isNull,
      );
      auth.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text(testL10n.menuIncorrectEmailOrPassword), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('login-submit')))
            .onPressed,
        isNotNull,
      );
    },
  );
  testWidgets(
    'déconnexion ferme les routes et purge tous les providers de la session',
    (tester) async {
      await mount(tester, restored: identity());
      final oldScope = scopes.last;
      var disposed = false;
      final probe = Provider((ref) {
        ref.onDispose(() => disposed = true);
        return 42;
      });
      oldScope.read(probe);
      oldScope.read(musGameControllerProvider.notifier).startGame();
      final context = tester.element(find.byType(MainDashboardScreen));
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const AccountScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('Lier'), findsNothing);
      expect(find.text('ane@example.com'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('account-signout')));
      await tester.pumpAndSettle();
      expect(disposed, isTrue);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AccountScreen), findsNothing);
      expect(
        Navigator.of(tester.element(find.byType(LoginScreen))).canPop(),
        isFalse,
      );
      auth.emit(identity(id: '123e4567-e89b-12d3-a456-426614174001'));
      await tester.pumpAndSettle();
      expect(identical(oldScope, scopes.last), isFalse);
      expect(
        scopes.last.read(musGameControllerProvider).phase,
        MusPhase.dealing,
      );
    },
  );
  testWidgets(
    'un rafraîchissement de session conserve la partie, reconnexion immédiate la purge',
    (tester) async {
      await mount(tester, restored: identity());
      final scope = scopes.last;
      var disposed = false;
      final probe = Provider((ref) {
        ref.onDispose(() => disposed = true);
        return 42;
      });
      scope.read(probe);
      auth.emit(identity());
      await tester.pumpAndSettle();
      expect(identical(scope, scopes.last), isTrue);
      expect(disposed, isFalse);
      auth.emit(null);
      auth.emit(identity());
      await tester.pumpAndSettle();
      expect(disposed, isTrue);
      expect(identical(scope, scopes.last), isFalse);
    },
  );
  testWidgets(
    'suppression confirmée revient à LoginScreen ; annuler préserve la session',
    (tester) async {
      await mount(tester, restored: identity());
      Navigator.of(tester.element(find.byType(MainDashboardScreen)))
          .push(MaterialPageRoute<void>(builder: (_) => const AccountScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text(testL10n.menuDeleteMyAccount));
      await tester.pumpAndSettle();
      await tester.tap(find.text(testL10n.menuCancel));
      await tester.pumpAndSettle();
      expect(auth.calls, isEmpty);
      await tester.tap(find.text(testL10n.menuDeleteMyAccount));
      await tester.pumpAndSettle();
      await tester.tap(find.text(testL10n.menuDeletePermanently));
      await tester.pumpAndSettle();
      expect(auth.calls, ['delete']);
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );
  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('inscription défile sans débordement à $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(tester);
      await register(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('register-login')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
    testWidgets('login défile sans débordement à $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('login-guest')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
