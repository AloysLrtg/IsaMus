// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/player_repository.dart';
import '../../core/network/retention_repository.dart';
import '../../core/engine/mus_game_controller.dart';
import '../../core/engine/mus_game_state.dart';
import '../../core/engine/mus_table_feedback.dart';

import '../home/main_dashboard_screen.dart';
import '../../l10n/app_localizations.dart';

const _gold = Color(0xFFFFD54F);
const _goldAccent = Color(0xFFFFB300);
const _cyanA = Color(0xFF38BDF8);
const _orangeB = Color(0xFFFB923C);
const _defeatRed = Color(0xFFEF5350);

/// Overlay affiché en fin de partie (lorsqu'une équipe atteint 40 tantto ou en gameOver).
/// Célèbre la victoire ou annonce la défaite du joueur local avec les scores finaux
/// et un bouton stylisé pour retourner à l'accueil.
class GameOverOverlay extends ConsumerStatefulWidget {
  const GameOverOverlay({
    super.key,
    required this.state,
    required this.localSeat,
    this.onHomePressed,
    this.chatActions,
    this.mode = 'casual',
    this.userId,
    this.playerElo,
    this.gameId,
  });

  final MusGameState state;
  final int localSeat;
  final VoidCallback? onHomePressed;
  final Widget? chatActions;
  final String mode;
  final String? userId;
  final int? playerElo;
  final String? gameId;

  bool get isRanked => mode == 'ranked';

  int get winningTeamIndex {
    if (state.gameWinner != null) return state.gameWinner!;
    if (state.mancheWinner != null) return state.mancheWinner!;
    if (state.teamAScore >= 40) return 0;
    if (state.teamBScore >= 40) return 1;
    return state.teamAScore >= state.teamBScore ? 0 : 1;
  }

  @override
  ConsumerState<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends ConsumerState<GameOverOverlay> {
  int? _eloDelta;
  int? _newElo;
  int _xpEarned = 0;
  bool _saving = false;
  bool _saveError = false;

  @override
  void initState() {
    super.initState();
    if (widget.gameId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _saveResult());
    }
  }

  Future<void> _saveResult() async {
    if (_saving || !mounted || widget.gameId == null) return;
    setState(() {
      _saving = true;
      _saveError = false;
    });
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        final result = await ref
            .read(playerRepositoryProvider)
            .finish(widget.gameId!)
            .timeout(const Duration(seconds: 15));
        if (!mounted) return;
        if (result == null) throw StateError('Résultat en attente');
        ref.invalidate(playerProfileProvider);
        ref.invalidate(matchHistoryProvider);
        ref.invalidate(retentionStatusProvider);
        setState(() {
          _xpEarned = (result['xp_earned'] as num? ?? 0).toInt();
          _newElo = (result['elo_after'] as num).toInt();
          _eloDelta = _newElo! - (result['elo_before'] as num).toInt();
          _saving = false;
        });
        return;
      } catch (_) {
        if (!mounted) return;
        if (attempt < 3) await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    if (mounted) {
      setState(() {
        _saving = false;
        _saveError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('fr'));
    final state = widget.state;
    final localTeamIndex = widget.localSeat % 2;
    final localTeam = localTeamIndex == 0 ? 'A' : 'B';
    final winningTeam = widget.winningTeamIndex == 0 ? 'A' : 'B';
    final isVictory = localTeamIndex == widget.winningTeamIndex;

    final primaryColor = isVictory ? _gold : _defeatRed;
    final titleText = isVictory ? l.victoryTitle : l.defeatTitle;
    final subtitleText = isVictory
        ? l.congratulationsTeam(localTeam)
        : l.defeatTeam(winningTeam);

    return Positioned.fill(
      key: const Key('game-over-overlay'),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black87,
          alignment: Alignment.center,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final cardWidth = math.min(availableWidth - 24, 400.0);
                final isCompactHeight = constraints.maxHeight < 400;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: cardWidth,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: cardWidth < 300 ? 14 : 22,
                          vertical: isCompactHeight ? 16 : 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isVictory
                                ? [
                                    const Color(0xFF1E293B).withOpacity(0.95),
                                    const Color(0xFF0F172A).withOpacity(0.98),
                                  ]
                                : [
                                    const Color(0xFF281014).withOpacity(0.95),
                                    const Color(0xFF0F172A).withOpacity(0.98),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.45),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isVictory ? _goldAccent : _defeatRed)
                                  .withOpacity(0.25),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Badge Icone
                            Container(
                              width: isCompactHeight ? 56 : 70,
                              height: isCompactHeight ? 56 : 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor.withOpacity(0.15),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.6),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isVictory
                                    ? Icons.emoji_events_rounded
                                    : Icons.sentiment_dissatisfied_rounded,
                                size: isCompactHeight ? 34 : 42,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: isCompactHeight ? 10 : 14),

                            // Titre VICTOIRE / DÉFAITE
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                titleText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isCompactHeight ? 30 : 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4.0,
                                  color: primaryColor,
                                  shadows: [
                                    Shadow(
                                      color:
                                          (isVictory ? _goldAccent : _defeatRed)
                                              .withOpacity(0.9),
                                      blurRadius: 20,
                                    ),
                                    if (isVictory)
                                      const Shadow(
                                        color: Colors.white,
                                        blurRadius: 4,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Sous-titre
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                subtitleText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isVictory
                                      ? Colors.white70
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            ),

                            if (_xpEarned > 0)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '+$_xpEarned XP',
                                  key: const ValueKey('match-earned-xp'),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                              ),
                            // Gain ou perte d'Elo (uniquement en partie classée)
                            if (_saving)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(l.savingMatchResult),
                              ),
                            if (_saveError) ...[
                              Text(
                                l.matchResultSyncPending,
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                onPressed: _saveResult,
                                child: Text(l.retrySavingResult),
                              ),
                            ],
                            if (widget.isRanked && _eloDelta != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                key: const Key('game-over-elo-badge'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (_eloDelta! >= 0
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444))
                                          .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _eloDelta! >= 0
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                    width: 1.5,
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _eloDelta! >= 0
                                            ? Icons.trending_up_rounded
                                            : Icons.trending_down_rounded,
                                        size: 18,
                                        color: _eloDelta! >= 0
                                            ? const Color(0xFF34D399)
                                            : const Color(0xFFF87171),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l.rankedEloChange(
                                          _eloDelta! >= 0
                                              ? "+$_eloDelta"
                                              : "$_eloDelta",
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          color: _eloDelta! >= 0
                                              ? const Color(0xFF34D399)
                                              : const Color(0xFFF87171),
                                        ),
                                      ),
                                      if (_newElo != null) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '($_newElo)',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: isCompactHeight ? 12 : 18),

                            // Carte des Scores Finaux
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isCompactHeight ? 10 : 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B132B).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white12,
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l.finalScores,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _ScorePill(
                                          teamName: l.team('A'),
                                          score: state.teamAScore,
                                          color: _cyanA,
                                          isWinner:
                                              widget.winningTeamIndex == 0,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            ':',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ),
                                        _ScorePill(
                                          teamName: l.team('B'),
                                          score: state.teamBScore,
                                          color: _orangeB,
                                          isWinner:
                                              widget.winningTeamIndex == 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isCompactHeight ? 16 : 24),

                            if (widget.chatActions != null) ...[
                              Text(
                                l.discussMatch,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              widget.chatActions!,
                              const SizedBox(height: 12),
                            ],
                            // Bouton Retour à l'accueil
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                key: const Key('return-home-button'),
                                onPressed: () {
                                  ref.invalidate(musGameControllerProvider);
                                  ref.invalidate(musTableFeedbackProvider);
                                  if (widget.onHomePressed != null) {
                                    widget.onHomePressed!();
                                  } else {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MainDashboardScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.home_rounded, size: 22),
                                label: Text(
                                  l.returnHome,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isVictory
                                      ? _gold
                                      : const Color(0xFF334155),
                                  foregroundColor: isVictory
                                      ? const Color(0xFF0B1221)
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: BorderSide(
                                      color: isVictory
                                          ? const Color(0xFFFFE082)
                                          : const Color(0xFF64748B),
                                      width: 1.5,
                                    ),
                                  ),
                                  elevation: isVictory ? 6 : 2,
                                  shadowColor: isVictory
                                      ? _goldAccent
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.teamName,
    required this.score,
    required this.color,
    required this.isWinner,
  });

  final String teamName;
  final int score;
  final Color color;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWinner ? color : color.withOpacity(0.3),
          width: isWinner ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWinner) ...[
            Icon(Icons.star_rounded, size: 15, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            teamName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isWinner ? color : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
