import 'package:flutter/material.dart';

enum GameInvitationMode {
  privateRoom(
    'private',
    'Créer un Salon Privé',
    'Salon privé',
    Icons.lock_outline_rounded,
  ),
  casualDuo(
    'casual',
    'En Ligne (Classique) en Duo',
    'Classique en duo',
    Icons.groups_outlined,
  ),
  rankedDuo(
    'ranked',
    'En Ligne (Classé) en Duo',
    'Classé en duo',
    Icons.emoji_events_outlined,
  );

  const GameInvitationMode(this.value, this.title, this.label, this.icon);
  final String value, title, label;
  final IconData icon;
  bool get isPublic => this != privateRoom;
  static GameInvitationMode parse(Object? value) =>
      values.where((m) => m.value == value).firstOrNull ?? privateRoom;
}
