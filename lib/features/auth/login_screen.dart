import '../../l10n/app_localizations.dart';

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
            'invalid_credentials' => AppLocalizations.of(
              context,
            )!.menuIncorrectEmailOrPassword,
            'email_not_confirmed' => AppLocalizations.of(
              context,
            )!.menuConfirmYourEmailAddressBeforeSigningIn,
            'over_email_send_rate_limit' || 'over_request_rate_limit' =>
              AppLocalizations.of(context)!.menuTooManyAttemptsTryAgainShortly,
            _ => AppLocalizations.of(
              context,
            )!.menuUnableToSignInCheckYourDetailsAndTry,
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _message = AppLocalizations.of(context)!
                  .menuServiceUnavailableCheckYourConnectionAndTryAgain,
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
                      label: AppLocalizations.of(context)!.appTitle,
                      image: true,
                      child: Column(
                        children: [
                          Icon(
                            Icons.style_rounded,
                            size: 64,
                            color: Color(0xFFE6C76B),
                          ),
                          Text(
                            AppLocalizations.of(context)!.appTitle,
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
                    Text(
                      AppLocalizations.of(context)!.menuYourTableIsWaiting,
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
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .menuEmail,
                              prefixIcon: Icon(Icons.mail_outline),
                              filled: true,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value != null &&
                                    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                        .hasMatch(value.trim())
                                ? null
                                : AppLocalizations.of(context)!
                                      .menuEnterAValidEmailAddress,
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
                              labelText: AppLocalizations.of(context)!
                                  .menuPassword,
                              prefixIcon: const Icon(Icons.lock_outline),
                              filled: true,
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                tooltip: _obscure
                                    ? AppLocalizations.of(context)!
                                          .menuShowPassword
                                    : AppLocalizations.of(context)!
                                          .menuHidePassword,
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
                                ? AppLocalizations.of(context)!
                                      .menuEnterYourPassword
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
                      child: Text(AppLocalizations.of(context)!.menuSignIn),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      key: const ValueKey('login-guest'),
                      onPressed: _busy
                          ? null
                          : () => _run((repo) async {
                              await repo.signInAnonymously();
                            }),
                      child: Text(
                        AppLocalizations.of(context)!.menuPlayAsAGuest,
                      ),
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
                      child: Text(
                        AppLocalizations.of(context)!.menuNoAccountYetSignUp,
                      ),
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
