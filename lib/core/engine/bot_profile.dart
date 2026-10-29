import 'dart:math';

import '../models/avatar_config.dart';

enum BotPersonality { conservative, balanced, bluffer }

class BotProfile {
  const BotProfile(this.personality, this.name, this.avatar);
  final BotPersonality personality;
  final String name;
  final AvatarConfig avatar;

  static List<BotProfile> shuffled(Random random) =>
      [...profiles]..shuffle(random);

  static const profiles = [
    BotProfile(
      BotPersonality.conservative,
      'Patxi',
      AvatarConfig(
        skin: 0,
        hair: 0,
        glasses: 1,
        top: 2,
        backgroundColor: 1,
        hairColor: 4,
      ),
    ),
    BotProfile(
      BotPersonality.balanced,
      'Mikel',
      AvatarConfig(
        skin: 1,
        hair: 0,
        glasses: 0,
        top: 1,
        backgroundColor: 0,
        hairColor: 0,
      ),
    ),
    BotProfile(
      BotPersonality.bluffer,
      'Txomin',
      AvatarConfig(
        skin: 2,
        hair: 2,
        glasses: 2,
        top: 0,
        backgroundColor: 3,
        hairColor: 5,
      ),
    ),
  ];
  static BotProfile forPersonality(BotPersonality personality) =>
      profiles[personality.index];
}
