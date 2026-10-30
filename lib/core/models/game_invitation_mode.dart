import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

enum GameInvitationMode {
  privateRoom('private', Icons.lock_outline_rounded),
  casualDuo('casual', Icons.groups_outlined),
  rankedDuo('ranked', Icons.emoji_events_outlined);

  const GameInvitationMode(this.value, this.icon);
  final String value;
  final IconData icon;
  String title(AppLocalizations l10n) => switch (this) {
    privateRoom => l10n.invitationPrivateTitle,
    casualDuo => l10n.invitationCasualTitle,
    rankedDuo => l10n.invitationRankedTitle,
  };
  String label(AppLocalizations l10n) => switch (this) {
    privateRoom => l10n.invitationPrivateLabel,
    casualDuo => l10n.invitationCasualLabel,
    rankedDuo => l10n.invitationRankedLabel,
  };
  bool get isPublic => this != privateRoom;
  static GameInvitationMode parse(Object? value) =>
      values.where((m) => m.value == value).firstOrNull ?? privateRoom;
}
