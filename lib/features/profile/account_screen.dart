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
    } on AuthException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'Service indisponible. Réessayez dans quelques instants.',
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
        title: const Text('Supprimer votre compte ?'),
        content: const Text(
          'Votre profil, vos amis et votre historique seront supprimés définitivement. Les achats restent soumis aux règles des stores. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(() async {
        await ref.read(accountRepositoryProvider).deleteAccount();
      }, 'Compte supprimé.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(accountRepositoryProvider);
    final user = repo.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Compte & sécurité')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_circle_outlined, size: 40),
            title: Text(
              user?.isAnonymous == true
                  ? 'Compte invité'
                  : user?.email ?? 'Compte connecté',
              key: const ValueKey('account-identity'),
            ),
            subtitle: Text(switch (user?.appMetadata['provider']) {
              'google' => 'Google',
              'apple' => 'Apple',
              _ => user?.isAnonymous == true ? 'Invité' : 'E-mail',
            }),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const ValueKey('account-signout'),
            onPressed: _busy
                ? null
                : () => _run(repo.signOut, 'Déconnexion effectuée.'),
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(_message!, key: const ValueKey('account-message')),
            ),
          TextButton(
            onPressed: _busy ? null : _delete,
            child: const Text(
              'Supprimer mon compte',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
