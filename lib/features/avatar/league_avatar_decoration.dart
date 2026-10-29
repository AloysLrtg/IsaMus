import 'package:flutter/material.dart';

import '../../core/models/avatar_config.dart';

class LeagueAvatarDecoration extends StatelessWidget {
  const LeagueAvatarDecoration({
    super.key,
    required this.config,
    required this.size,
    required this.child,
  });
  final AvatarConfig config;
  final double size;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final color = switch (config.border) {
      AvatarBorder.bronze => const Color(0xFFCD8852),
      AvatarBorder.silver => const Color(0xFFD0DAE6),
      AvatarBorder.gold => const Color(0xFFFFD54F),
      AvatarBorder.diamond => const Color(0xFF75E4FF),
      AvatarBorder.none => Colors.transparent,
    };
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (config.exclusiveHat != ExclusiveHat.none)
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/avatars/hat_${config.exclusiveHat.name}.png',
                key: ValueKey(
                  'avatar-exclusive-hat-${config.exclusiveHat.name}',
                ),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Center(
                  child: AspectRatio(
                    aspectRatio: .8,
                    child: CustomPaint(
                      key: ValueKey(
                        'avatar-hat-fallback-${config.exclusiveHat.name}',
                      ),
                      painter: _HatPainter(config.exclusiveHat),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (config.border != AvatarBorder.none)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                key: ValueKey('avatar-border-${config.border.name}'),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: (size * .04).clamp(1.5, 5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .35),
                      blurRadius: size * .08,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HatPainter extends CustomPainter {
  const _HatPainter(this.hat);
  final ExclusiveHat hat;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint()
      ..color = hat == ExclusiveHat.txapela
          ? const Color(0xFF302522)
          : const Color(0xFFFFD54F);
    if (hat == ExclusiveHat.cap || hat == ExclusiveHat.beanie) {
      paint.color = hat == ExclusiveHat.cap
          ? const Color(0xFF2563EB)
          : const Color(0xFFB45309);
      canvas.drawArc(
        const Rect.fromLTWH(24, 6, 52, 44),
        3.14159,
        3.14159,
        true,
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(23, 24, 54, 8),
          const Radius.circular(3),
        ),
        paint,
      );
      if (hat == ExclusiveHat.cap) {
        canvas.drawOval(const Rect.fromLTWH(50, 27, 36, 7), paint);
      } else {
        canvas.drawCircle(const Offset(50, 6), 6, paint);
      }
    } else if (hat == ExclusiveHat.txapela) {
      canvas.drawOval(const Rect.fromLTWH(22, 8, 58, 22), paint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(32, 24, 40, 5),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.drawLine(
        const Offset(52, 8),
        const Offset(53, 4),
        paint..strokeWidth = 3,
      );
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(27, 29)
          ..lineTo(23, 10)
          ..lineTo(39, 18)
          ..lineTo(50, 3)
          ..lineTo(61, 18)
          ..lineTo(77, 10)
          ..lineTo(73, 29)
          ..close(),
        paint,
      );
      canvas.drawCircle(
        const Offset(50, 23),
        3,
        paint..color = const Color(0xFFEF4444),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatPainter oldDelegate) => oldDelegate.hat != hat;
}
