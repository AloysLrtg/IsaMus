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
          const Text(
            'Statistiques globales',
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
                    const Text('Elo actuel', style: TextStyle(fontSize: 12)),
                    Text(
                      '${statistics.elo}',
                      key: const ValueKey('current-elo'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Peak Elo', style: TextStyle(fontSize: 12)),
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
            '${statistics.global.played} parties',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            statistics.global.played == 0
                ? 'Aucune partie terminée'
                : '${statistics.global.winPercent} % de victoires',
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
              label: const Text('Détails par mode'),
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
    label:
        '${stats.won} victoires, ${stats.lost} défaites sur ${stats.played} parties',
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
                  stats.played == 0 ? 'Aucune partie' : 'de victoires',
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
        (_winColor, 'Victoires', stats.won),
        (_lossColor, 'Défaites', stats.lost),
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
              const Expanded(
                child: Text(
                  'Détails par mode',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Fermer',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          for (final entry in [
            (StatisticsMode.casual, 'Classique'),
            (StatisticsMode.ranked, 'Classé'),
            (StatisticsMode.solo, 'Solo'),
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
                    Text('${statistics.byMode[entry.$1]!.played} parties'),
                    const SizedBox(height: 8),
                    _StatisticsLegend(stats: statistics.byMode[entry.$1]!),
                  ],
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Les salons privés entre humains sont inclus dans Classique.',
            ),
          ),
          if (statistics.unclassified > 0)
            Text(
              '${statistics.unclassified} anciennes parties sans historique détaillé ne sont pas réparties par mode.',
            ),
        ],
      ),
    ),
  );
}
