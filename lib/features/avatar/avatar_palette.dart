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
    LinearGradient(
      colors: [Color(0xFF55C7CF), Color(0xFF185164)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(colors: [Color(0xFF2B6592), Color(0xFF2B6592)]),
    LinearGradient(colors: [Color(0xFFA8476A), Color(0xFFA8476A)]),
    LinearGradient(
      colors: [Color(0xFF9F7AEA), Color(0xFF44337A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFF6D365), Color(0xFFD1783E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(colors: [Color(0xFF263749), Color(0xFF263749)]),
  ];
  static const backgroundLabels = [
    'Dégradé turquoise',
    'Bleu',
    'Rose',
    'Dégradé violet',
    'Dégradé doré',
    'Ardoise',
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
