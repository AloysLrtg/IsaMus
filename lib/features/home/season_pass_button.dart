import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../core/models/paris_season_clock.dart';
import '../../core/network/season_repository.dart';

/// A brief sweep every five seconds, with no ticker running between sweeps.
class SeasonPassButton extends ConsumerStatefulWidget {
  const SeasonPassButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  ConsumerState<SeasonPassButton> createState() => _SeasonPassButtonState();
}

class _SeasonPassButtonState extends ConsumerState<SeasonPassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;
  Timer? _sweepTimer;
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate =
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (_animate == animate) return;
    _animate = animate;
    _sweepTimer?.cancel();
    if (animate) {
      _shimmer.forward(from: 0);
      _sweepTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _shimmer.forward(from: 0);
      });
    } else {
      _shimmer.reset();
    }
  }

  @override
  void dispose() {
    _sweepTimer?.cancel();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD76B);
    final theme = Theme.of(context);
    final days = ref.watch(
      seasonNowProvider.select((now) => ParisSeasonClock.remaining(now).inDays),
    );
    final badge = days == 0
        ? AppLocalizations.of(context)!.menuLastDay
        : days <= 3
        ? AppLocalizations.of(context)!.menuOnlyArg0DLeft((days).toString())
        : AppLocalizations.of(context)!.menuSeasonInProgress;

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: .16),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: const Color(0xFF392B19),
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF59411E), Color(0xFF242D43)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: gold.withValues(alpha: .7)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shimmer,
                      builder: (context, _) =>
                          CustomPaint(painter: _ShimmerPainter(_shimmer.value)),
                    ),
                  ),
                ),
                InkWell(
                  key: const ValueKey('open-battle-pass'),
                  onTap: widget.onPressed,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: gold,
                          size: 34,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                key: const ValueKey('season-pass-badge'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: gold,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  badge,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF30200D),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                AppLocalizations.of(context)!.seasonPassTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: gold),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  const _ShimmerPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.width * (-.5 + 2 * progress);
    final band = Rect.fromLTWH(center - 70, 0, 140, size.height);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: .18),
            Colors.white.withValues(alpha: 0),
          ],
          transform: const GradientRotation(-.3),
        ).createShader(band),
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
