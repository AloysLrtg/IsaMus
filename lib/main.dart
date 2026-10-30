import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/home/main_dashboard_screen.dart';
import 'features/social/social_banners.dart';
import 'features/auth/login_screen.dart';
import 'core/network/auth_repository.dart';
import 'core/network/presence_session.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  await Supabase.initialize(
    url: 'https://nakbrpgecwpphyynsdor.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ha2JycGdlY3dwcGh5eW5zZG9yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI5NDg5NDIsImV4cCI6MjEwODUyNDk0Mn0.A6c2KOqqWuE70JVuL7eJda98nu1AjLbfp9ifUafYO14',
  );

  runApp(const ProviderScope(child: MyApp()));
}

/// Each identity owns a fresh container, including its navigator and all user
/// providers. Disposing it closes game timers, Realtime channels and audio.
final sessionContainerFactoryProvider =
    Provider<ProviderContainer Function(AuthRepository)>(
      (ref) =>
          (auth) => ProviderContainer(
            overrides: [authRepositoryProvider.overrideWithValue(auth)],
          ),
    );

class MyApp extends ConsumerWidget {
  const MyApp({super.key, this.home});
  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Explicit home remains useful for isolated widget previews and tests.
    if (home != null) return _application(home!);
    final auth = ref.watch(authSessionProvider);
    return auth.when(
      data: (session) => _SessionApplication(
        key: ValueKey(
          'session-${session.generation}-${session.user?.id ?? 'signed-out'}',
        ),
        user: session.user,
        repository: ref.read(authRepositoryProvider),
        createContainer: ref.read(sessionContainerFactoryProvider),
      ),
      loading: () => _application(
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, _) => _application(
        const LoginScreen(initialError: 'Connexion indisponible. Réessayez.'),
      ),
    );
  }
}

class _SessionApplication extends StatefulWidget {
  const _SessionApplication({
    super.key,
    required this.user,
    required this.repository,
    required this.createContainer,
  });
  final User? user;
  final AuthRepository repository;
  final ProviderContainer Function(AuthRepository) createContainer;
  @override
  State<_SessionApplication> createState() => _SessionApplicationState();
}

class _SessionApplicationState extends State<_SessionApplication> {
  late final ProviderContainer _container = widget.createContainer(
    widget.repository,
  );
  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UncontrolledProviderScope(
    container: _container,
    child: PresenceSessionHost(
      userId: widget.user?.id,
      child: _application(
        widget.user == null ? const LoginScreen() : const MainDashboardScreen(),
      ),
    ),
  );
}

Widget _application(Widget home) => _Application(home: home);

class _Application extends StatefulWidget {
  const _Application({required this.home});
  final Widget home;
  @override
  State<_Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<_Application> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFFD9BC72),
      scaffoldBackgroundColor: const Color(0xFF0B1221),
      appBarTheme: const AppBarThemeData(
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    ),
    builder: (context, child) {
      final content = ColoredBox(
        color: const Color(0xFF0B1221),
        child: child ?? const SizedBox.shrink(),
      );
      // Isolated previews can provide their own scope below the application.
      try {
        ProviderScope.containerOf(context, listen: false);
      } catch (_) {
        return content;
      }
      return SocialBannerHost(navigatorKey: _navigatorKey, child: content);
    },
    navigatorKey: _navigatorKey,
    home: widget.home,
  );
}
