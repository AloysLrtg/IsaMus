import '../models/card.dart';
import 'mus_evaluator.dart';

/// Codes réseau distincts, même lorsque deux annonces partagent un geste.
enum MusSign {
  twoKings,
  twoAces,
  mediak,
  dobliak,
  twentyNine,
  thirty,
  thirtyOne,
  game,
}

/// Signes sincères du Mus 4 Rois / 4 As. Le 29 attend la fin des paires.
List<MusSign> availableMusSigns(List<Card> hand, {bool pairsResolved = false}) {
  if (hand.length != handSize) return const [];
  final pairs = evaluatePaires(hand);
  final game = evaluateJeuEtPoint(hand);
  return [
    if (hand.where((card) => card.value == 12).length >= 2) MusSign.twoKings,
    if (hand.where((card) => card.value == 1).length >= 2) MusSign.twoAces,
    if (pairs.type == PairesType.mediak) MusSign.mediak,
    if (pairs.type == PairesType.doubles) MusSign.dobliak,
    if (game.total == 29 && pairsResolved) MusSign.twentyNine,
    if (game.total == 30) MusSign.thirty,
    if (game.total == 31) MusSign.thirtyOne,
    if (game.hasJeu && game.total != 31) MusSign.game,
  ];
}

MusSign? parseMusSign(String value) => switch (value) {
  '2 Rois' => MusSign.twoKings,
  '2 As' => MusSign.twoAces,
  'Mediak' => MusSign.mediak,
  'Dobliak' => MusSign.dobliak,
  '29' => MusSign.twentyNine,
  '30' => MusSign.thirty,
  '31' => MusSign.thirtyOne,
  'Jeu' => MusSign.game,
  _ => MusSign.values.where((s) => s.name == value).firstOrNull,
};

extension MusSignGesture on MusSign {
  String get gesture => switch (this) {
    MusSign.twoKings => 'Mordre la lèvre inférieure',
    MusSign.twoAces => 'Tirer la langue',
    MusSign.mediak => 'Remuer un côté des lèvres',
    MusSign.dobliak || MusSign.twentyNine => 'Remuer les deux côtés des lèvres',
    MusSign.thirty || MusSign.thirtyOne => 'Cligner d’un œil',
    MusSign.game => 'Lever les sourcils',
  };

  /// PNG transparents sur le canevas portrait commun de 400 × 500.
  String get eyesAsset =>
      'assets/avatars/eyes_${this == MusSign.thirty || this == MusSign.thirtyOne ? 'wink' : 'normal'}.png';
  String get mouthAsset =>
      'assets/avatars/mouth_${switch (this) {
        MusSign.twoKings => 'bite',
        MusSign.twoAces => 'tongue',
        MusSign.mediak => 'side',
        MusSign.dobliak || MusSign.twentyNine => 'both_sides',
        _ => 'normal',
      }}.png';
  String get browsAsset =>
      'assets/avatars/brows_${this == MusSign.game ? 'raised' : 'normal'}.png';
}
