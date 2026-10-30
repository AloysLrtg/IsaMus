import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_haptic_service.dart';
import '../../core/localization/app_locale.dart';
import '../../l10n/app_localizations.dart';
import '../../core/monetization/ads_banner.dart';
import '../../core/network/player_repository.dart';
import '../profile/account_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _run(
    Future<void> Function() action, {
    bool refreshProfile = false,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      if (!mounted) return;
      if (refreshProfile) ref.invalidate(playerProfileProvider);
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'Action impossible. Vérifiez votre connexion et réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setSound(bool enabled) async {
    if (_busy) return;
    final effects = ref.read(audioHapticServiceProvider);
    final previous = effects.isSoundEnabled;
    // Stop immediately, even on a slow network. Roll back a rejected save.
    effects.setSoundEnabled(enabled);
    await _run(() async {
      try {
        await ref.read(playerRepositoryProvider).sound(enabled);
      } catch (_) {
        effects.setSoundEnabled(previous);
        rethrow;
      }
      ref.invalidate(playerProfileProvider);
    });
  }

  Future<void> _legal(String title, String asset) async {
    try {
      final text = await rootBundle.loadString(asset);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(title)),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SelectableText(text),
            ),
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Document indisponible. Réessayez.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(appLocaleProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.languageTitle),
            trailing: DropdownButton<Locale>(
              key: const ValueKey('settings-language-selector'),
              value: locale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appLocaleProvider.notifier).select(value);
                }
              },
              items: const [
                DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
                DropdownMenuItem(value: Locale('eu'), child: Text('Euskara')),
                DropdownMenuItem(value: Locale('es'), child: Text('Español')),
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
              ],
            ),
          ),
          profile.when(
            loading: () => const ListTile(
              title: Text('Effets sonores'),
              trailing: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, _) => ListTile(
              title: const Text('Effets sonores'),
              subtitle: const Text('Préférence indisponible'),
              trailing: TextButton(
                onPressed: () => ref.invalidate(playerProfileProvider),
                child: const Text('Réessayer'),
              ),
            ),
            data: (p) => SwitchListTile(
              key: const ValueKey('settings-sound-toggle'),
              title: const Text('Effets sonores'),
              value: p['sound_enabled'] == true,
              onChanged: _busy || profile.isLoading ? null : _setSound,
            ),
          ),
          ListTile(
            key: const ValueKey('settings-account-button'),
            leading: const Icon(Icons.lock_outline),
            title: const Text('Compte & sécurité'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _busy
                ? null
                : () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute(builder: (_) => const AccountScreen()),
                    );
                    if (mounted) ref.invalidate(playerProfileProvider);
                  },
          ),
          const Divider(),
          if (adsEnabled)
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Choix de confidentialité publicitaire'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _busy ? null : () => _run(AdsConsent.privacy),
            ),
          ListTile(
            key: const ValueKey('settings-terms-button'),
            leading: const Icon(Icons.description_outlined),
            title: const Text('Conditions d’utilisation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                _legal('Conditions d’utilisation', 'assets/legal/terms.txt'),
          ),
          ListTile(
            key: const ValueKey('settings-privacy-button'),
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Politique de confidentialité'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _legal(
              'Politique de confidentialité',
              'assets/legal/privacy.txt',
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(liveRegion: true, child: Text(_message!)),
            ),
        ],
      ),
    );
  }
}
