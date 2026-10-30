import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

/// Temporary language choice for this session; French is always the default.
final appLocaleProvider = NotifierProvider<AppLocale, Locale>(AppLocale.new);

class AppLocale extends Notifier<Locale> {
  @override
  Locale build() => const Locale('fr');

  void select(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) state = locale;
  }
}
