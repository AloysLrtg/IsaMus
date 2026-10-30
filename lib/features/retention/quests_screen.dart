import '../../core/localization/catalog_localizations.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/retention_repository.dart';

Future<void> showWeeklyQuests(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const WeeklyQuestsSheet(),
    );

class WeeklyQuestsSheet extends ConsumerWidget {
  const WeeklyQuestsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .7,
      minChildSize: .4,
      maxChildSize: .92,
      builder: (context, scrollController) => ref
          .watch(retentionStatusProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  AppLocalizations.of(context)!.menuQuestsUnavailable,
                  style: theme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => ref.invalidate(retentionStatusProvider),
                  child: Text(AppLocalizations.of(context)!.menuTryAgain),
                ),
              ],
            ),
            data: (data) {
              final quests = (data['quests'] as List? ?? []).whereType<Map>();
              final multiplier = data['vip'] == true ? 2 : 1;
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.menuWeeklyQuests,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.menuClose,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.menuANewWeekNewChallenges,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!
                        .menuResetsOnMondayAt0000UTCXPRewards,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (quests.isEmpty)
                    Text(
                      AppLocalizations.of(context)!.menuNewChallengesComingSoon,
                    ),
                  for (final quest in quests)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    questTitle(
                                      AppLocalizations.of(context)!,
                                      quest,
                                    ),
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                Icon(
                                  quest['rewarded'] == true
                                      ? Icons.check_circle_rounded
                                      : Icons.bolt_rounded,
                                  color: colors.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            LinearProgressIndicator(
                              value:
                                  ((quest['progress'] as num? ?? 0) /
                                          (quest['target'] as num? ?? 1))
                                      .clamp(0, 1)
                                      .toDouble(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${quest['progress'] ?? 0}/${quest['target']} · ${_questRewardLabel(context, quest, multiplier)}",
                              style: theme.textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
    );
  }
}

String _questRewardLabel(BuildContext context, Map quest, int multiplier) {
  if (quest['rewarded'] == true) {
    final earned = (quest['earned_xp'] as num? ?? 0).toInt();
    return earned > 0
        ? AppLocalizations.of(context)!
              .menuArg0XPRewardReceived((earned).toString())
        : AppLocalizations.of(context)!.menuRewardReceived;
  }
  final reward = quest['reward_xp'];
  return reward is num && reward > 0
      ? AppLocalizations.of(context)!
            .menuArg0XP((reward.toInt() * multiplier).toString())
      : AppLocalizations.of(context)!.menuXPRewardUnavailable;
}
