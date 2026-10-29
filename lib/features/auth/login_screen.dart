import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/auth_repository.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialError});
  final String? initialError;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function(AuthRepository) action) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action(ref.read(authRepositoryProvider));
    } on AuthException catch (error) {
      if (mounted) {
        setState(
          () => _message = switch (error.code) {
            'invalid_credentials' => 'E-mail ou mot de passe incorrect.',
            'email_not_confirmed' =>
              'Confirmez votre adresse e-mail avant de vous connecter.',
            'over_email_send_rate_limit' || 'over_request_rate_limit' =>
              'Trop de tentatives. Réessayez dans quelques instants.',
            _ =>
              'Connexion impossible. Vérifiez vos informations et réessayez.',
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'Service indisponible. Vérifiez votre connexion et réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _emailAction() async {
    if (!_form.currentState!.validate()) return;
    await _run((repo) => repo.signIn(_email.text, _password.text));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17352F), Color(0xFF0B1221), Color(0xFF152139)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      label: 'IsaMus',
                      image: true,
                      child: Column(
                        children: [
                          Icon(
                            Icons.style_rounded,
                            size: 64,
                            color: Color(0xFFE6C76B),
                          ),
                          Text(
                            'IsaMus',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE6C76B),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Votre table vous attend.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _form,
                      child: Column(
                        children: [
                          TextFormField(
                            key: const ValueKey('login-email'),
                            controller: _email,
                            enabled: !_busy,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.mail_outline),
                              filled: true,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value != null &&
                                    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                        .hasMatch(value.trim())
                                ? null
                                : 'Saisissez une adresse e-mail valide.',
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const ValueKey('login-password'),
                            controller: _password,
                            enabled: !_busy,
                            obscureText: _obscure,
                            enableSuggestions: false,
                            autocorrect: false,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) {
                              if (!_busy) _emailAction();
                            },
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline),
                              filled: true,
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                tooltip: _obscure
                                    ? 'Afficher le mot de passe'
                                    : 'Masquer le mot de passe',
                                onPressed: _busy
                                    ? null
                                    : () =>
                                          setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Saisissez votre mot de passe.'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const ValueKey('login-submit'),
                      onPressed: _busy ? null : _emailAction,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: const Text('Se connecter'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      key: const ValueKey('login-guest'),
                      onPressed: _busy
                          ? null
                          : () => _run((repo) async {
                              await repo.signInAnonymously();
                            }),
                      child: const Text('Jouer en tant qu’invité'),
                    ),
                    TextButton(
                      key: const ValueKey('login-signup'),
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).push<void>(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                      child: const Text("Pas encore de compte ? S'inscrire"),
                    ),
                    if (_busy) const LinearProgressIndicator(),
                    if (_message != null || widget.initialError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _message ?? widget.initialError!,
                            key: const ValueKey('login-message'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
