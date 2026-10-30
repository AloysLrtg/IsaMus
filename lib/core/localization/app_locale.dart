import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../network/auth_repository.dart';
import '../network/player_repository.dart';

final languagePreferencesProvider = Provider<Future<SharedPreferences>>(
  (ref) => SharedPreferences.getInstance(),
);
final appLocaleProvider = NotifierProvider<AppLocale, Locale>(AppLocale.new);

class AppLocale extends Notifier<Locale> {
  int _revision = 0;
  bool _disposed = false;

  @override
  Locale build() {
    ref.onDispose(() => _disposed = true);
    return const Locale('fr');
  }

  static bool supported(String? code) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code);

  /// Immediate in-memory update, also used by isolated previews.
  void select(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      _revision++;
      state = locale;
    }
  }

  /// A session owns this notifier. Late responses from a disposed session cannot
  /// change the next user's locale or overwrite a more recent explicit choice.
  Future<void> restore(String? userId) async {
    final revision = _revision;
    bool current() => !_disposed && revision == _revision;
    SharedPreferences? preferences;
    final key = userId == null ? 'language' : 'language.$userId';
    try {
      preferences = await ref.read(languagePreferencesProvider);
      final cached = preferences?.getString(key);
      if (current() && supported(cached)) state = Locale(cached!);
    } catch (_) {
      // A blocked browser store must not prevent reading the server profile.
    }
    if (userId == null || !current()) return;
    try {
      final profile = await ref
          .read(authRepositoryProvider)
          .getProfile(userId)
          .timeout(const Duration(seconds: 10));
      if (!current()) return;
      final code = profile?['language'] as String?;
      if (profile == null) {
        return; // Offline: keep this account's cached locale.
      }
      state = Locale(supported(code) ? code! : 'fr');
      await preferences?.setString(key, state.languageCode);
      if (current()) {
        await preferences?.setString('language', state.languageCode);
      }
    } catch (_) {
      // Keep the local fallback if the profile is temporarily unavailable.
    }
  }

  /// Settings keeps the selected language locally even if a remote save fails;
  /// the caller displays the failure so the player can retry.
  Future<void> save(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    final userId = ref.read(authRepositoryProvider).currentUserId;
    final repository = ref.read(playerRepositoryProvider);
    final preferencesFuture = ref.read(languagePreferencesProvider);
    select(locale);
    try {
      final preferences = await preferencesFuture;
      await preferences.setString('language', locale.languageCode);
      if (userId != null) {
        await preferences.setString('language.$userId', locale.languageCode);
      }
    } finally {
      if (userId != null) {
        // Capture the identity before awaiting local IO: never target a later login.
        await repository.language(userId, locale.languageCode);
      }
    }
  }
}
