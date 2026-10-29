import 'package:flutter/material.dart';

/// Common carousel frame: preserve the established palettes and proportions.
class GameModeCard extends StatelessWidget {
  const GameModeCard({
    super.key,
    required this.colors,
    required this.accent,
    required this.glow,
    required this.child,
    this.borderOpacity = .7,
  });
  final List<Color> colors;
  final Color accent;
  final Color glow;
  final double borderOpacity;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accent.withValues(alpha: borderOpacity),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: glow,
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(28), child: child),
    ),
  );
}
