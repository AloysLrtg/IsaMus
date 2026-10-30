import 'package:flutter/material.dart';
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
  bool _failed = false;

  Future<void> _run(
    Future<void> Function() action, {
    bool refreshProfile = false,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await action();
      if (!mounted) return;
      if (refreshProfile) ref.invalidate(playerProfileProvider);
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
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

  Future<void> _legal(bool privacy) => Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => _LegalDocument(privacy: privacy)),
  );

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
              onChanged: _busy
                  ? null
                  : (value) {
                      if (value != null) {
                        _run(
                          () =>
                              ref.read(appLocaleProvider.notifier).save(value),
                          refreshProfile: true,
                        );
                      }
                    },
              items: [
                DropdownMenuItem(
                  value: Locale('fr'),
                  child: Text(l10n.languageFrench),
                ),
                DropdownMenuItem(
                  value: Locale('eu'),
                  child: Text(l10n.languageBasque),
                ),
                DropdownMenuItem(
                  value: Locale('es'),
                  child: Text(l10n.languageSpanish),
                ),
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text(l10n.languageEnglish),
                ),
              ],
            ),
          ),
          profile.when(
            loading: () => ListTile(
              title: Text(AppLocalizations.of(context)!.menuSoundEffects),
              trailing: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, _) => ListTile(
              title: Text(AppLocalizations.of(context)!.menuSoundEffects),
              subtitle: Text(
                AppLocalizations.of(context)!.menuPreferenceUnavailable,
              ),
              trailing: TextButton(
                onPressed: () => ref.invalidate(playerProfileProvider),
                child: Text(AppLocalizations.of(context)!.menuTryAgain),
              ),
            ),
            data: (p) => SwitchListTile(
              key: const ValueKey('settings-sound-toggle'),
              title: Text(AppLocalizations.of(context)!.menuSoundEffects),
              value: p['sound_enabled'] == true,
              onChanged: _busy || profile.isLoading ? null : _setSound,
            ),
          ),
          ListTile(
            key: const ValueKey('settings-account-button'),
            leading: const Icon(Icons.lock_outline),
            title: Text(AppLocalizations.of(context)!.menuAccountSecurity),
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
              title: Text(AppLocalizations.of(context)!.menuAdPrivacyChoices),
              trailing: const Icon(Icons.chevron_right),
              onTap: _busy ? null : () => _run(AdsConsent.privacy),
            ),
          ListTile(
            key: const ValueKey('settings-terms-button'),
            leading: const Icon(Icons.description_outlined),
            title: Text(AppLocalizations.of(context)!.menuTermsOfUse),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _legal(false),
          ),
          ListTile(
            key: const ValueKey('settings-privacy-button'),
            leading: const Icon(Icons.policy_outlined),
            title: Text(AppLocalizations.of(context)!.menuPrivacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _legal(true),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_failed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                key: const ValueKey('settings-error'),
                liveRegion: true,
                child: Text(
                  l10n.menuUnableToCompleteThisActionCheckYourConnectionAnd,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegalDocument extends StatelessWidget {
  const _LegalDocument({required this.privacy});
  final bool privacy;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(privacy ? l10n.menuPrivacyPolicy : l10n.menuTermsOfUse),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SelectableText(
          privacy ? l10n.legalPrivacyBody : l10n.legalTermsBody,
        ),
      ),
    );
  }
}
