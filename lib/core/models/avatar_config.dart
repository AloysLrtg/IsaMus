import 'dart:math';

/// Persistent appearance. Game expressions/signs must remain transient.
enum AvatarBorder { none, bronze, silver, gold, diamond }

enum ExclusiveHat { none, txapela, crown, cap, beanie }

enum AvatarPart {
  skin,
  hair,
  glasses,
  top,
  backgroundColor,
  hairColor,
  border,
  exclusiveHat,
}

extension AvatarPartKey on AvatarPart {
  String get jsonKey => switch (this) {
    AvatarPart.backgroundColor => 'background_color',
    AvatarPart.hairColor => 'hair_color',
    AvatarPart.exclusiveHat => 'exclusive_hat',
    _ => name,
  };
}

class AvatarConfig {
  static const optionCount = 3;
  static const colorCount = 6;
  static const backgroundCount = 12;
  static const baldHair = 4;
  static const mohawkHair = 5;
  static const hairCount = 6;
  static int countFor(AvatarPart part) => switch (part) {
    AvatarPart.backgroundColor => backgroundCount,
    AvatarPart.hairColor => colorCount,
    AvatarPart.glasses => 5,
    AvatarPart.hair => hairCount,
    AvatarPart.top => optionCount + 1,
    AvatarPart.border => AvatarBorder.values.length,
    AvatarPart.exclusiveHat => ExclusiveHat.values.length,
    _ => optionCount,
  };
  static String? cosmeticIdFor(AvatarPart part, int option) => switch (part) {
    AvatarPart.border when option > 0 =>
      'league_border_${AvatarBorder.values[option].name}',
    AvatarPart.exclusiveHat when option > 0 =>
      '${option >= ExclusiveHat.cap.index ? 'shop' : 'league'}_hat_${ExclusiveHat.values[option].name}',
    AvatarPart.glasses when option == 3 => 'shop_glasses_fine',
    AvatarPart.glasses when option == 4 => 'shop_glasses_round',
    AvatarPart.hair when option == baldHair => 'shop_hair_bald',
    AvatarPart.hair when option == mohawkHair => 'shop_hair_mohawk',
    AvatarPart.top when option == 3 => 'shop_top_striped',
    _ => null,
  };
  const AvatarConfig({
    this.skin = 0,
    this.hair = 0,
    this.glasses = 0,
    this.top = 0,
    this.backgroundColor = 0,
    this.hairColor = 0,
    this.border = AvatarBorder.none,
    this.exclusiveHat = ExclusiveHat.none,
  }) : assert(skin >= 0 && skin < optionCount),
       assert(hair >= 0 && hair < hairCount && hair != 3),
       assert(glasses >= 0 && glasses < 5),
       assert(top >= 0 && top < optionCount + 1),
       assert(backgroundColor >= 0 && backgroundColor < backgroundCount),
       assert(hairColor >= 0 && hairColor < colorCount);
  final int skin;
  final int hair;
  final int glasses;
  final int top;
  final int backgroundColor;
  final int hairColor;
  final AvatarBorder border;
  final ExclusiveHat exclusiveHat;

  factory AvatarConfig.fromJson(Object? json) {
    int read(
      String key, [
      String? legacy,
      int limit = optionCount,
      int fallback = 0,
    ]) {
      final value = json is Map ? (json[key] ?? json[legacy]) : null;
      return value is int && value >= 0 && value < limit ? value : fallback;
    }

    return AvatarConfig(
      border:
          AvatarBorder.values
              .where((b) => json is Map && b.name == json['border'])
              .firstOrNull ??
          AvatarBorder.none,
      exclusiveHat:
          ExclusiveHat.values
              .where((h) => json is Map && h.name == json['exclusive_hat'])
              .firstOrNull ??
          ExclusiveHat.none,
      skin: read('skin'),
      hair: read('hair', 'head', hairCount) == 3
          ? 0
          : read('hair', 'head', hairCount),
      glasses: read('glasses', 'eyes', 5),
      top: read('top', 'mouth', optionCount + 1),
      backgroundColor: read('background_color', null, backgroundCount),
      hairColor: read('hair_color', null, colorCount, read('hair', 'head')),
    );
  }
  Map<String, Object> toJson() => {
    'skin': skin,
    'hair': hair,
    'glasses': glasses,
    'top': top,
    'background_color': backgroundColor,
    'hair_color': hairColor,
    'border': border.name,
    'exclusive_hat': exclusiveHat.name,
  };
  int valueFor(AvatarPart part) => switch (part) {
    AvatarPart.skin => skin,
    AvatarPart.hair => hair,
    AvatarPart.glasses => glasses,
    AvatarPart.top => top,
    AvatarPart.backgroundColor => backgroundColor,
    AvatarPart.hairColor => hairColor,
    AvatarPart.border => border.index,
    AvatarPart.exclusiveHat => exclusiveHat.index,
  };
  AvatarConfig withOption(AvatarPart part, int value) => AvatarConfig.fromJson({
    ...toJson(),
    part.jsonKey: switch (part) {
      AvatarPart.border => AvatarBorder.values[value].name,
      AvatarPart.exclusiveHat => ExclusiveHat.values[value].name,
      _ => value,
    },
  });

  AvatarConfig withCosmetic(String id) => switch (id) {
    'shop_hair_bald' => withOption(AvatarPart.hair, baldHair),
    'shop_hair_mohawk' => withOption(AvatarPart.hair, mohawkHair),
    'shop_glasses_fine' => withOption(AvatarPart.glasses, 3),
    'shop_glasses_round' => withOption(AvatarPart.glasses, 4),
    'shop_top_striped' => withOption(AvatarPart.top, 3),
    'shop_hat_cap' => withOption(
      AvatarPart.exclusiveHat,
      ExclusiveHat.cap.index,
    ),
    'shop_hat_beanie' => withOption(
      AvatarPart.exclusiveHat,
      ExclusiveHat.beanie.index,
    ),
    _ => this,
  };

  /// Finite shuffled pool avoids duplicate bots and unbounded random retries.
  static List<AvatarConfig> shuffledOptions(Random random) => [
    for (var skin = 0; skin < optionCount; skin++)
      for (var hair = 0; hair < optionCount; hair++)
        for (var glasses = 0; glasses < optionCount; glasses++)
          for (var top = 0; top < optionCount; top++)
            AvatarConfig(
              skin: skin,
              hair: hair,
              glasses: glasses,
              top: top,
              backgroundColor: random.nextInt(colorCount),
              hairColor: random.nextInt(colorCount),
            ),
  ]..shuffle(random);

  static AvatarConfig forSeat(int seat) => AvatarConfig(
    skin: seat % optionCount,
    hair: (seat + 1) % optionCount,
    glasses: seat % optionCount,
    top: (seat + 2) % optionCount,
    backgroundColor: seat % colorCount,
    hairColor: (seat + 1) % optionCount,
  );
  @override
  bool operator ==(Object other) =>
      other is AvatarConfig &&
      other.skin == skin &&
      other.hair == hair &&
      other.glasses == glasses &&
      other.top == top &&
      other.backgroundColor == backgroundColor &&
      other.hairColor == hairColor &&
      other.border == border &&
      other.exclusiveHat == exclusiveHat;
  @override
  int get hashCode => Object.hash(
    skin,
    hair,
    glasses,
    top,
    backgroundColor,
    hairColor,
    border,
    exclusiveHat,
  );
}
