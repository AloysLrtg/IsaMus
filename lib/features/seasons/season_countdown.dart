import '../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/season_repository.dart';
import '../../core/models/paris_season_clock.dart';
import 'countdown_widget.dart';

/// A local Paris month deadline, independent of API loading or availability.
class SeasonCountdown extends ConsumerWidget {
  const SeasonCountdown({super.key, this.showName = false});
  final bool showName;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(seasonNowProvider);
    final local = ParisSeasonClock.parisTime(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showName)
          Text(
            AppLocalizations.of(context)!.menuSeasonArg0Arg1(
              (local.month.toString().padLeft(2, '0')).toString(),
              (local.year).toString(),
            ),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)!.menuSeasonEnds,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        CountdownWidget(
          key: const ValueKey('shared-season-countdown'),
          remaining: ParisSeasonClock.remaining(now),
        ),
      ],
    );
  }
}
