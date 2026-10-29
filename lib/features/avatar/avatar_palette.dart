import 'package:flutter/material.dart';

/// Stable palette indices persisted in avatar_config, independent of hair shape.
abstract final class AvatarPalette {
  static const hairColors = [
    Color(0xFF563322),
    Color(0xFFD9AA56),
    Color(0xFF241E23),
    Color(0xFFAB5038),
    Color(0xFFCBD1D8),
    Color(0xFF6F4C9B),
  ];
  static const backgrounds = [
    LinearGradient(colors: [Color(0xFFFF3038), Color(0xFFFF3038)]),
    LinearGradient(colors: [Color(0xFFFF8800), Color(0xFFFF8800)]),
    LinearGradient(colors: [Color(0xFFFFDA19), Color(0xFFFFDA19)]),
    LinearGradient(colors: [Color(0xFF85DC25), Color(0xFF85DC25)]),
    LinearGradient(colors: [Color(0xFF126B38), Color(0xFF126B38)]),
    LinearGradient(colors: [Color(0xFF00D9E6), Color(0xFF00D9E6)]),
    LinearGradient(colors: [Color(0xFF152962), Color(0xFF152962)]),
    LinearGradient(colors: [Color(0xFF6523A8), Color(0xFF6523A8)]),
    LinearGradient(colors: [Color(0xFFF529B8), Color(0xFFF529B8)]),
    LinearGradient(colors: [Color(0xFF794326), Color(0xFF794326)]),
    LinearGradient(colors: [Color(0xFFD6DBE0), Color(0xFFD6DBE0)]),
    LinearGradient(colors: [Color(0xFF202329), Color(0xFF202329)]),
  ];
  static const backgroundLabels = [
    'Rouge vif',
    'Orange',
    'Jaune soleil',
    'Vert pomme',
    'Vert sapin',
    'Cyan',
    'Bleu marine',
    'Violet profond',
    'Rose fuchsia',
    'Marron',
    'Gris clair',
    'Anthracite',
  ];
  static const hairLabels = [
    'Brun',
    'Blond',
    'Noir',
    'Cuivré',
    'Argent',
    'Violet',
  ];
}
