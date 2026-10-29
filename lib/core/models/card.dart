/// Modèle de carte du jeu espagnol de 40 cartes utilisé au Mus (FFM, Iparralde).
///
/// Voir `SPEC_MUS.md` §2 : pas de 8 ni de 9, et 4 Rois / 4 As véritables
/// (les 3 ne sont pas des Rois, les 2 ne sont pas des As).
library;

/// Les 4 couleurs du jeu espagnol.
enum Suit {
  /// Or (Oros)
  oros,

  /// Coupe (Copas)
  copas,

  /// Épée (Espadas)
  espadas,

  /// Bâton (Bastos)
  bastos,
}

/// Une carte : valeur faciale + couleur.
class Card {
  /// Valeurs faciales autorisées : 1 (As), 2…7, 10 (Sota), 11 (Caballo), 12 (Rey).
  static const List<int> validValues = [1, 2, 3, 4, 5, 6, 7, 10, 11, 12];

  /// Valeur faciale (1–7, 10, 11 ou 12).
  final int value;

  /// Couleur de la carte.
  final Suit suit;

  /// Crée une carte. Lève une [ArgumentError] si [value] n'est pas dans
  /// [validValues] (donc 0, 8, 9 et >12 sont refusés).
  Card(this.value, this.suit) {
    if (!validValues.contains(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Valeur de carte invalide (autorisées : $validValues)',
      );
    }
  }

  /// Valeur de la carte pour le calcul du Jeu / Point :
  /// les figures (10, 11, 12) valent 10, les autres leur chiffre.
  int get gameValue => value >= 10 ? 10 : value;

  /// Génère le paquet complet de 40 cartes (ordre déterministe, non mélangé).
  static List<Card> fullDeck() => [
    for (final suit in Suit.values)
      for (final value in validValues) Card(value, suit),
  ];

  Map<String, dynamic> toJson() => {'value': value, 'suit': suit.name};

  factory Card.fromJson(Map<String, dynamic> json) => Card(
    json['value'] as int? ?? 1,
    Suit.values.firstWhere(
      (e) => e.name == json['suit']?.toString(),
      orElse: () => Suit.oros,
    ),
  );

  @override
  bool operator ==(Object other) =>
      other is Card && other.value == value && other.suit == suit;

  @override
  int get hashCode => Object.hash(value, suit);

  @override
  String toString() => '$value${suit.name[0].toUpperCase()}';
}
