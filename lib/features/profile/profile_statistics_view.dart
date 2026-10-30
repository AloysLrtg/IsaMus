import '../../l10n/app_localizations.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/models/profile_statistics.dart';

const _winColor = Color(0xFF38C9A2);
const _lossColor = Color(0xFFEC7184);

class ProfileStatisticsView extends StatelessWidget {
  const ProfileStatisticsView({super.key, required this.statistics});
  final ProfileStatistics statistics;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.menuOverallStatistics,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (_, constraints) {
              final diameter = math.min(250.0, constraints.maxWidth);
              return _StatisticsPie(
                id: 'global',
                stats: statistics.global,
                diameter: diameter,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.menuCurrentElo,
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${statistics.elo}',
                      key: const ValueKey('current-elo'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.menuPeakElo,
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${statistics.peakElo}',
                      key: const ValueKey('peak-elo'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!
                .gamesPlayedCount(statistics.global.played.toString()),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            statistics.global.played == 0
                ? AppLocalizations.of(context)!.menuNoCompletedGames
                : AppLocalizations.of(context)!
                      .menuArg0Wins((statistics.global.winPercent).toString()),
          ),
          const SizedBox(height: 12),
          _StatisticsLegend(stats: statistics.global),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('mode-statistics-button'),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => _ModeStatisticsSheet(statistics: statistics),
              ),
              icon: const Icon(Icons.pie_chart_outline),
              label: Text(AppLocalizations.of(context)!.menuDetailsByMode),
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatisticsPie extends StatelessWidget {
  const _StatisticsPie({
    required this.id,
    required this.stats,
    required this.diameter,
    this.center,
  });
  final String id;
  final GameStatistics stats;
  final double diameter;
  final Widget? center;
  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context)!.menuArg0WinsArg1LossesInArg2Games(
      (stats.won).toString(),
      (stats.lost).toString(),
      (stats.played).toString(),
    ),
    child: SizedBox.square(
      dimension: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            key: ValueKey('stats-$id-pie'),
            PieChartData(
              startDegreeOffset: 270,
              centerSpaceRadius: diameter * .31,
              sectionsSpace:
                  stats.played == 0 || stats.won == 0 || stats.lost == 0
                  ? 0
                  : 3,
              pieTouchData: PieTouchData(enabled: false),
              sections: [
                if (stats.played == 0)
                  PieChartSectionData(
                    value: 1,
                    color: Colors.blueGrey.withValues(alpha: .35),
                    radius: diameter * .13,
                    showTitle: false,
                  ),
                if (stats.won > 0)
                  PieChartSectionData(
                    value: stats.won.toDouble(),
                    color: _winColor,
                    radius: diameter * .13,
                    showTitle: false,
                  ),
                if (stats.lost > 0)
                  PieChartSectionData(
                    value: stats.lost.toDouble(),
                    color: _lossColor,
                    radius: diameter * .13,
                    showTitle: false,
                  ),
              ],
            ),
            duration: const Duration(milliseconds: 250),
          ),
          if (center != null)
            SizedBox(
              width: diameter * .59,
              child: Center(child: center),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stats.played == 0 ? '—' : '${stats.winPercent} %',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stats.played == 0
                      ? AppLocalizations.of(context)!.menuNoGames
                      : AppLocalizations.of(context)!.menuWins,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

class _StatisticsLegend extends StatelessWidget {
  const _StatisticsLegend({required this.stats});
  final GameStatistics stats;
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 16,
    runSpacing: 8,
    children: [
      for (final entry in [
        (_winColor, AppLocalizations.of(context)!.menuWins309, stats.won),
        (_lossColor, AppLocalizations.of(context)!.menuLosses, stats.lost),
      ])
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: entry.$1,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text('${entry.$2} : ${entry.$3}'),
          ],
        ),
    ],
  );
}

class _ModeStatisticsSheet extends StatelessWidget {
  const _ModeStatisticsSheet({required this.statistics});
  final ProfileStatistics statistics;
  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: .9,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.menuDetailsByMode,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.menuClose,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          for (final entry in [
            (StatisticsMode.casual, AppLocalizations.of(context)!.menuCasual),
            (StatisticsMode.ranked, AppLocalizations.of(context)!.menuRanked),
            (StatisticsMode.solo, AppLocalizations.of(context)!.menuSolo),
          ])
            Card(
              key: ValueKey('stats-mode-${entry.$1.name}'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      entry.$2,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _StatisticsPie(
                      id: entry.$1.name,
                      stats: statistics.byMode[entry.$1]!,
                      diameter: 170,
                    ),
                    Text(
                      AppLocalizations.of(context)!.gamesPlayedCount(
                        statistics.byMode[entry.$1]!.played.toString(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatisticsLegend(stats: statistics.byMode[entry.$1]!),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              AppLocalizations.of(context)!
                  .menuPrivateRoomsWithHumanPlayersAreIncludedInCasual,
            ),
          ),
          if (statistics.unclassified > 0)
            Text(
              AppLocalizations.of(context)!
                  .menuArg0OlderGamesWithoutDetailedHistoryAreNotAssigned(
                    (statistics.unclassified).toString(),
                  ),
            ),
        ],
      ),
    ),
  );
}
