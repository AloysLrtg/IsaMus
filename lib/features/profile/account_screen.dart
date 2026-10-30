import '../../l10n/app_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/account_repository.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  StreamSubscription<AuthState>? _subscription;
  bool _busy = false;
  String? _message;
  @override
  void initState() {
    super.initState();
    _subscription = ref.read(accountRepositoryProvider).changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String message) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      if (mounted) setState(() => _message = message);
    } on AuthException catch (_) {
      if (mounted) {
        setState(
          () => _message = AppLocalizations.of(context)!.deleteAccountError,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _message = AppLocalizations.of(context)!
                  .menuServiceUnavailableTryAgainShortly,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.menuDeleteYourAccount),
        content: Text(
          AppLocalizations.of(context)!
              .menuYourProfileFriendsAndHistoryWillBePermanentlyDeleted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.menuCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.menuDeletePermanently),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(() async {
        await ref.read(accountRepositoryProvider).deleteAccount();
      }, AppLocalizations.of(context)!.menuAccountDeleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(accountRepositoryProvider);
    final user = repo.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.menuAccountSecurity),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_circle_outlined, size: 40),
            title: Text(
              user?.isAnonymous == true
                  ? AppLocalizations.of(context)!.menuGuestAccount
                  : user?.email ??
                        AppLocalizations.of(context)!.menuSignedInAccount,
              key: const ValueKey('account-identity'),
            ),
            subtitle: Text(switch (user?.appMetadata['provider']) {
              'google' => AppLocalizations.of(context)!.providerGoogle,
              'apple' => AppLocalizations.of(context)!.providerApple,
              _ =>
                user?.isAnonymous == true
                    ? AppLocalizations.of(context)!.menuGuest
                    : AppLocalizations.of(context)!.menuEmail,
            }),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const ValueKey('account-signout'),
            onPressed: _busy
                ? null
                : () => _run(
                    repo.signOut,
                    AppLocalizations.of(context)!.menuSignedOut,
                  ),
            icon: const Icon(Icons.logout),
            label: Text(AppLocalizations.of(context)!.menuSignOut),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(_message!, key: const ValueKey('account-message')),
            ),
          TextButton(
            onPressed: _busy ? null : _delete,
            child: Text(
              AppLocalizations.of(context)!.menuDeleteMyAccount,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
