import 'package:flutter/material.dart';

import '../profile/profile_tab.dart' show backColor;

/// Shared Spanish card pattern, tinted without replacing its fine line work.
class CardBackView extends StatelessWidget {
  const CardBackView({super.key, this.id = 'classic'});
  final String id;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(3),
    child: Image.asset(
      'assets/cards/card_back.png',
      fit: BoxFit.cover,
      color: id == 'classic' ? null : backColor(id),
      colorBlendMode: id == 'classic' ? null : BlendMode.color,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => ColoredBox(color: backColor(id)),
    ),
  );
}
