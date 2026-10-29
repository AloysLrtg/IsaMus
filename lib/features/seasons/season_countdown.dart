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
            'Saison ${local.month.toString().padLeft(2, '0')}/${local.year}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        const SizedBox(height: 6),
        Text('Fin de saison', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        CountdownWidget(
          key: const ValueKey('shared-season-countdown'),
          remaining: ParisSeasonClock.remaining(now),
        ),
      ],
    );
  }
}
