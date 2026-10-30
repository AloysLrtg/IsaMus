import '../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/leaderboard_repository.dart';

const _gold = Color(0xFFFFD54F);
const _cyan = Color(0xFF38BDF8);
const _card = Color(0xFF132238);

class LeaderboardTab extends ConsumerWidget {
  const LeaderboardTab({super.key, required this.currentUserId});

  final String? currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    Future<void> refresh() async {
      try {
        ref.invalidate(leaderboardProvider);
        await ref.read(leaderboardProvider.future);
      } catch (_) {
        // The provider exposes the error and the retry action in the UI.
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.menuTop100Players,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.menuRefreshRankings,
                onPressed: leaderboard.isLoading ? null : refresh,
                icon: const Icon(Icons.refresh_rounded, color: _gold),
              ),
            ],
          ),
        ),
        Expanded(
          child: leaderboard.when(
            skipLoadingOnRefresh: false,
            loading: () => Center(
              child: CircularProgressIndicator(
                semanticsLabel: AppLocalizations.of(context)!
                    .menuLoadingRankings,
              ),
            ),
            error: (error, stack) => _StatusMessage(
              icon: Icons.cloud_off_rounded,
              message: AppLocalizations.of(context)!
                  .menuUnableToLoadRankingsCheckYourConnectionAndTry,
              action: refresh,
              actionLabel: AppLocalizations.of(context)!.menuTryAgain,
            ),
            data: (entries) => RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (entries.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _StatusMessage(
                        icon: Icons.emoji_events_outlined,
                        message: AppLocalizations.of(context)!
                            .menuNoRankedPlayersYet,
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .menuTheHighestEloRatings,
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                            _Podium(
                              entries: entries.take(3).toList(),
                              currentUserId: currentUserId,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentUserId != null &&
                                      entries.any(
                                        (entry) => entry.id == currentUserId,
                                      )
                                  ? AppLocalizations.of(
                                      context,
                                    )!.menuYourPositionArg0(
                                      (entries.indexWhere(
                                                (entry) =>
                                                    entry.id == currentUserId,
                                              ) +
                                              1)
                                          .toString(),
                                    )
                                  : AppLocalizations.of(context)!
                                        .menuReachTheTop100ToAppearHere,
                              style: const TextStyle(
                                color: _cyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(context)!
                                  .menuRankedByDescendingElo,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final isLocal = entry.id == currentUserId;
                          return Container(
                            key: ValueKey('leaderboard-row-${entry.id}'),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isLocal ? const Color(0xFF173B55) : _card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isLocal ? _cyan : Colors.white12,
                                width: isLocal ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  color: index < 3 ? _gold : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              title: Text(
                                entry.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: isLocal
                                  ? Text(
                                      AppLocalizations.of(context)!.you,
                                      style: TextStyle(color: _cyan),
                                    )
                                  : null,
                              trailing: Text(
                                '${entry.elo} Elo',
                                style: const TextStyle(
                                  color: _gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.entries, required this.currentUserId});

  final List<LeaderboardEntry> entries;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    Widget place(int index) {
      if (index >= entries.length) return const Expanded(child: SizedBox());
      final entry = entries[index];
      final color = [
        const Color(0xFFFFD54F),
        const Color(0xFFCBD5E1),
        const Color(0xFFD99B70),
      ][index];
      return Expanded(
        child: Semantics(
          label: AppLocalizations.of(context)!.menuPositionArg0Arg1Arg2EloArg3(
            (index + 1).toString(),
            (entry.username).toString(),
            (entry.elo).toString(),
            entry.id == currentUserId
                ? AppLocalizations.of(context)!.leaderboardYouSuffix
                : '',
          ),
          excludeSemantics: true,
          child: Container(
            key: ValueKey('leaderboard-podium-${index + 1}'),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: EdgeInsets.fromLTRB(6, index == 0 ? 26 : 14, 6, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withValues(alpha: 0.2), _card],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(8),
              ),
              border: Border.all(
                color: entry.id == currentUserId
                    ? _cyan
                    : color.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: color,
                  size: index == 0 ? 40 : 30,
                ),
                const SizedBox(height: 8),
                Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    '${entry.elo} Elo',
                    style: TextStyle(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [place(1), place(0), place(2)],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.message,
    this.action,
    this.actionLabel,
  });

  final IconData icon;
  final String message;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _gold, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: action, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}
