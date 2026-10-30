import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/app_locale.dart';

/// Runs once in each identity's session container, including restored sessions,
/// email sign-in, OAuth and guest sign-in. The UI waits before showing the home.
final sessionLanguageProvider = FutureProvider.family<void, String?>(
  (ref, userId) => ref.read(appLocaleProvider.notifier).restore(userId),
);
