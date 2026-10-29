import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/avatar_config.dart';
import '../../core/engine/mus_sign.dart';
import 'avatar_palette.dart';
import 'league_avatar_decoration.dart';

/// All PNG layers use the same transparent 400×500 canvas (head AND bust).
/// Missing artwork is replaced per layer, so assets can be imported gradually.
class PlayerAvatarView extends StatefulWidget {
  const PlayerAvatarView({
    super.key,
    required this.config,
    this.size = 96,
    this.currentSign,
    this.signRevision = 0,
  });
  final String? currentSign;
  final int signRevision;
  final AvatarConfig config;

  /// Maximum square footprint; the full 4:5 portrait fits inside it.
  final double size;

  List<String> get assetPaths => [
    'assets/avatars/background_${config.backgroundColor}.png',
    'assets/avatars/skin_${config.skin}.png',
    'assets/avatars/top_${config.top}.png',
    'assets/avatars/eyes_normal.png',
    'assets/avatars/hair_${config.hair}.png',
    'assets/avatars/glasses_${config.glasses}.png',
  ];

  @override
  State<PlayerAvatarView> createState() => _PlayerAvatarViewState();
}

class _PlayerAvatarViewState extends State<PlayerAvatarView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expression = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  Timer? _signTimer;
  MusSign? _activeSign;
  AvatarConfig get config => widget.config;
  double get size => widget.size;
  List<String> get assetPaths => widget.assetPaths;
  @override
  void initState() {
    super.initState();
    _refreshSign();
  }

  @override
  void didUpdateWidget(covariant PlayerAvatarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSign != widget.currentSign ||
        oldWidget.signRevision != widget.signRevision) {
      _refreshSign();
    }
  }

  void _refreshSign() {
    _signTimer?.cancel();
    _activeSign = widget.currentSign == null
        ? null
        : parseMusSign(widget.currentSign!);
    if (_activeSign != null) {
      _expression.repeat(reverse: true);
      _signTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _expression.stop();
          setState(() => _activeSign = null);
        }
      });
    } else {
      _expression.stop();
    }
  }

  @override
  void dispose() {
    _signTimer?.cancel();
    _expression.dispose();
    super.dispose();
  }

  Widget _face() => KeyedSubtree(
    key: const ValueKey('avatar-layer-3'),
    child: AnimatedBuilder(
      animation: _expression,
      builder: (_, _) => Center(
        child: AspectRatio(
          aspectRatio: .8,
          child: Stack(
            key: ValueKey(
              _activeSign == null
                  ? 'avatar-neutral-face'
                  : 'avatar-current-sign',
            ),
            fit: StackFit.expand,
            children: [
              for (final part in ['eyes', 'mouth', 'brows'])
                Image.asset(
                  switch (part) {
                    'eyes' =>
                      _activeSign?.eyesAsset ??
                          'assets/avatars/eyes_normal.png',
                    'mouth' =>
                      _activeSign?.mouthAsset ??
                          'assets/avatars/mouth_normal.png',
                    _ =>
                      _activeSign?.browsAsset ??
                          'assets/avatars/brows_normal.png',
                  },
                  key: ValueKey('avatar-face-$part'),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => CustomPaint(
                    key: ValueKey('avatar-fallback-$part'),
                    painter: _FaceLayer(part, _activeSign, _expression.value),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'Avatar : peau ${config.skin + 1}, cheveux ${config.hair + 1}, '
        'lunettes ${config.glasses}, haut ${config.top + 1}',
    image: true,
    child: ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: LeagueAvatarDecoration(
          config: config,
          size: size,
          child: ClipOval(
            key: const ValueKey('avatar-circle'),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AvatarPalette.backgrounds[config.backgroundColor],
                  ),
                ),
                for (var layer = 0; layer < assetPaths.length; layer++)
                  if (layer == 0)
                    const SizedBox.shrink()
                  else if (layer == 4 && config.hair == AvatarConfig.baldHair)
                    const SizedBox.shrink(key: ValueKey('avatar-bald'))
                  else if (layer == 4 && config.hair == AvatarConfig.mohawkHair)
                    Center(
                      child: AspectRatio(
                        aspectRatio: .8,
                        child: CustomPaint(
                          key: const ValueKey('avatar-mohawk'),
                          painter: _PortraitLayer(layer, config),
                        ),
                      ),
                    )
                  else if (layer == 3)
                    _face()
                  else if (layer == 5 && config.glasses >= 3)
                    Center(
                      child: AspectRatio(
                        aspectRatio: .8,
                        child: CustomPaint(
                          painter: _PortraitLayer(layer, config),
                        ),
                      ),
                    )
                  else
                    Image.asset(
                      assetPaths[layer],
                      fit: layer == 0 ? BoxFit.cover : BoxFit.contain,
                      color: layer == 4
                          ? AvatarPalette.hairColors[config.hairColor]
                          : null,
                      colorBlendMode: layer == 4 ? BlendMode.modulate : null,
                      key: ValueKey('avatar-layer-$layer'),
                      errorBuilder: (_, _, _) => layer == 0
                          ? CustomPaint(
                              key: ValueKey('avatar-fallback-$layer'),
                              painter: _PortraitLayer(layer, config),
                            )
                          : Center(
                              child: AspectRatio(
                                aspectRatio: .8,
                                child: CustomPaint(
                                  key: ValueKey('avatar-fallback-$layer'),
                                  painter: _PortraitLayer(layer, config),
                                ),
                              ),
                            ),
                    ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Code-native coloured silhouettes, not final artwork.
class _PortraitLayer extends CustomPainter {
  const _PortraitLayer(this.layer, this.config);
  final int layer;
  final AvatarConfig config;
  static const skins = [
    Color(0xFFF2C9A5),
    Color(0xFFC58C62),
    Color(0xFF805135),
  ];
  static const tops = [
    Color(0xFFBD3647),
    Color(0xFF2469A3),
    Color(0xFF218475),
    Color(0xFFF1F5F9),
  ];
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 125);
    final paint = Paint()..isAntiAlias = true;
    switch (layer) {
      case 0:
        canvas.drawRect(
          const Rect.fromLTWH(0, 0, 100, 125),
          paint
            ..shader = AvatarPalette.backgrounds[config.backgroundColor]
                .createShader(const Rect.fromLTWH(0, 0, 100, 125)),
        );
      case 1:
        paint.color = skins[config.skin];
        canvas.drawOval(const Rect.fromLTWH(12, 94, 76, 45), paint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(42, 74, 16, 28),
            const Radius.circular(6),
          ),
          paint,
        );
        canvas.drawOval(const Rect.fromLTWH(23, 23, 54, 65), paint);
        canvas.drawOval(const Rect.fromLTWH(19, 49, 12, 18), paint);
        canvas.drawOval(const Rect.fromLTWH(69, 49, 12, 18), paint);
      case 2:
        paint.color = tops[config.top];
        final shirt = Path()
          ..moveTo(0, 125)
          ..lineTo(5, 109)
          ..quadraticBezierTo(15, 98, 38, 94)
          ..quadraticBezierTo(50, 109, 62, 94)
          ..quadraticBezierTo(85, 98, 95, 109)
          ..lineTo(100, 125)
          ..close();
        canvas.drawPath(shirt, paint);
        if (config.top == 3) {
          canvas.save();
          canvas.clipPath(shirt);
          paint.color = const Color(0xFF2563EB);
          for (double y = 98; y < 125; y += 10) {
            canvas.drawRect(Rect.fromLTWH(0, y, 100, 5), paint);
          }
          canvas.restore();
        }
        if (config.top == 1) {
          canvas.drawRect(
            const Rect.fromLTWH(0, 116, 100, 5),
            paint..color = const Color(0xFF89D6EE),
          );
        }
        if (config.top == 2) {
          canvas.drawPath(
            Path()
              ..moveTo(37, 95)
              ..lineTo(50, 110)
              ..lineTo(63, 95),
            paint
              ..color = const Color(0xFFF0E5CF)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }
      case 4:
        paint.color = AvatarPalette.hairColors[config.hairColor];
        final hair = Path();
        if (config.hair == AvatarConfig.baldHair) return;
        if (config.hair == AvatarConfig.mohawkHair) {
          hair.moveTo(39, 34);
          hair.lineTo(38, 17);
          hair.lineTo(43, 22);
          hair.lineTo(46, 5);
          hair.lineTo(51, 13);
          hair.lineTo(56, 4);
          hair.lineTo(61, 20);
          hair.lineTo(63, 15);
          hair.lineTo(62, 34);
          hair.quadraticBezierTo(50, 27, 39, 34);
          hair.close();
        } else if (config.hair == 0) {
          hair.moveTo(22, 48);
          hair.lineTo(21, 24);
          hair.quadraticBezierTo(49, -2, 78, 24);
          hair.lineTo(79, 46);
          hair.lineTo(68, 31);
          hair.quadraticBezierTo(45, 42, 31, 31);
          hair.close();
        } else if (config.hair == 1) {
          hair.moveTo(18, 92);
          hair.quadraticBezierTo(11, 40, 25, 19);
          hair.quadraticBezierTo(57, -2, 78, 26);
          hair.quadraticBezierTo(91, 64, 81, 99);
          hair.lineTo(70, 92);
          hair.lineTo(72, 47);
          hair.lineTo(52, 27);
          hair.quadraticBezierTo(36, 39, 28, 47);
          hair.lineTo(29, 94);
          hair.close();
        } else {
          hair.moveTo(21, 41);
          hair.lineTo(16, 23);
          hair.lineTo(32, 25);
          hair.lineTo(37, 8);
          hair.lineTo(51, 18);
          hair.lineTo(67, 9);
          hair.lineTo(73, 24);
          hair.lineTo(84, 25);
          hair.lineTo(77, 47);
          hair.lineTo(65, 33);
          hair.lineTo(32, 37);
          hair.close();
        }
        canvas.drawPath(hair, paint);
      case 5:
        if (config.glasses != 0) {
          paint
            ..color = (config.glasses == 3
                ? const Color(0xFFD9BC72)
                : config.glasses == 1
                ? const Color(0xFF3C2832)
                : const Color(0xFFA72F4D))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4;
          final radius = Radius.circular(
            config.glasses == 1 || config.glasses == 4 ? 9 : 3,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(27, 45, 20, 17),
              radius,
            ),
            paint,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(53, 45, 20, 17),
              radius,
            ),
            paint,
          );
          canvas.drawLine(const Offset(47, 51), const Offset(53, 51), paint);
          canvas.drawLine(const Offset(22, 48), const Offset(27, 49), paint);
          canvas.drawLine(const Offset(73, 49), const Offset(78, 48), paint);
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PortraitLayer old) =>
      old.layer != layer || old.config != config;
}

/// Expressions drawn in the actual face layers until their PNGs are supplied.
/// Every component shares the portrait canvas; hair and glasses stay above it.
class _FaceLayer extends CustomPainter {
  const _FaceLayer(this.part, this.sign, this.progress);
  final String part;
  final MusSign? sign;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 125);
    final ink = Paint()
      ..color = const Color(0xFF302529)
      ..isAntiAlias = true;
    final line = Paint()
      ..color = const Color(0xFF713C35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final amount = sign == null ? 0.0 : Curves.easeInOut.transform(progress);
    switch (part) {
      case 'eyes':
        for (final x in [38.0, 62.0]) {
          final wink =
              x == 62 && (sign == MusSign.thirty || sign == MusSign.thirtyOne);
          final height = wink ? 10 * (1 - amount) : 10.0;
          if (height < 2) {
            canvas.drawLine(
              Offset(x - 4, 53),
              Offset(x + 4, 53),
              line..color = ink.color,
            );
          } else {
            canvas.drawOval(
              Rect.fromCenter(center: Offset(x, 53), width: 8, height: height),
              ink,
            );
            if (!wink || amount < .5) {
              canvas.drawCircle(
                Offset(x - 1, 51),
                1.6,
                Paint()..color = Colors.white,
              );
            }
          }
        }
      case 'brows':
        final lift = sign == MusSign.game ? 6 * amount : 0.0;
        for (final x in [38.0, 62.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(x - 5, 43 - lift)
              ..quadraticBezierTo(x, 40 - lift, x + 5, 43 - lift),
            line
              ..color = ink.color
              ..strokeWidth = 2,
          );
        }
      case 'mouth':
        if (sign == MusSign.twoAces) {
          canvas.drawOval(const Rect.fromLTWH(40, 68, 20, 7), ink);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(46, 70, 8, 3 + 7 * amount),
              const Radius.circular(4),
            ),
            Paint()..color = const Color(0xFFE9798D),
          );
        } else if (sign == MusSign.twoKings) {
          canvas.drawOval(
            Rect.fromLTWH(40, 68, 20, 3 + amount * 3),
            Paint()..color = const Color(0xFFB35960),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(44, 68, 12, 2 + amount * 2),
              const Radius.circular(1),
            ),
            Paint()..color = const Color(0xFFFFF5E6),
          );
        } else {
          final left =
              sign == MusSign.mediak ||
                  sign == MusSign.dobliak ||
                  sign == MusSign.twentyNine
              ? 4 * amount
              : 0.0;
          final right = sign == MusSign.dobliak || sign == MusSign.twentyNine
              ? 4 * amount
              : 0.0;
          canvas.drawPath(
            Path()
              ..moveTo(39, 70 - left)
              ..cubicTo(42, 77, 58, 77, 61, 70 - right),
            line,
          );
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FaceLayer old) =>
      old.part != part || old.sign != sign || old.progress != progress;
}
