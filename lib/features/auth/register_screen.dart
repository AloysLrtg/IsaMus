import '../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/auth_repository.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _message;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final connected = await ref
          .read(authRepositoryProvider)
          .signUp(_email.text, _password.text, username: _username.text);
      // The root session router opens MainDashboardScreen and discards both
      // login/register routes. Never navigate to a protected page without a session.
      if (mounted && !connected) {
        setState(
          () =>
              _message = AppLocalizations.of(context)!
                  .menuCheckYourEmailToActivateYourAccount,
        );
        _password.clear();
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(
          () => _message = switch (error.code) {
            'user_already_exists' || 'email_exists' => AppLocalizations.of(
              context,
            )!.menuAnAccountAlreadyUsesThisEmailAddress,
            'weak_password' => AppLocalizations.of(
              context,
            )!.menuChooseAStrongerPassword,
            'over_email_send_rate_limit' || 'over_request_rate_limit' =>
              AppLocalizations.of(context)!.menuTooManyAttemptsTryAgainShortly,
            _ => AppLocalizations.of(
              context,
            )!.menuUnableToSignUpTryAnotherNicknameAndCheck,
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

  void _login() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.menuSignUp),
        backgroundColor: const Color(0xFF17352F),
      ),
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
                      const Icon(
                        Icons.style_rounded,
                        size: 52,
                        color: Color(0xFFE6C76B),
                      ),
                      Text(
                        AppLocalizations.of(context)!.menuJoinIsaMus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE6C76B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!
                            .menuChooseYourNicknameAndJoinTheGame,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _form,
                        child: Column(
                          children: [
                            TextFormField(
                              key: const ValueKey('register-username'),
                              controller: _username,
                              enabled: !_busy,
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.nickname],
                              maxLength: 24,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .menuNickname,
                                prefixIcon: Icon(Icons.person_outline),
                                filled: true,
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? AppLocalizations.of(context)!
                                        .menuChooseANickname
                                  : value.trim().length > 24
                                  ? AppLocalizations.of(context)!
                                        .menu24CharactersMaximum
                                  : null,
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              key: const ValueKey('register-email'),
                              controller: _email,
                              enabled: !_busy,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
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
                            const SizedBox(height: 18),
                            TextFormField(
                              key: const ValueKey('register-password'),
                              controller: _password,
                              enabled: !_busy,
                              obscureText: _obscure,
                              enableSuggestions: false,
                              autocorrect: false,
                              autofillHints: const [AutofillHints.newPassword],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _register(),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .menuPassword,
                                helperText: AppLocalizations.of(context)!
                                    .menuAtLeast8Characters,
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
                                      : () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.length < 8
                                  ? AppLocalizations.of(context)!
                                        .menuUseAtLeast8Characters
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        key: const ValueKey('register-submit'),
                        onPressed: _busy ? null : _register,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.menuCreateMyAccount,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        key: const ValueKey('register-login'),
                        onPressed: _busy ? null : _login,
                        child: Text(
                          AppLocalizations.of(context)!
                              .menuAlreadyHaveAnAccountSignIn,
                        ),
                      ),
                      if (_busy) const LinearProgressIndicator(),
                      if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              _message!,
                              key: const ValueKey('register-message'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent),
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
    ),
  );
}
