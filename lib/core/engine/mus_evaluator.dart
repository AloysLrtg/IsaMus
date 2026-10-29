/// Évaluateur de mains de Mus (Dart pur, sans dépendance Flutter).
///
/// Toutes les règles sont définies dans `SPEC_MUS.md` (§3 et §5).
///
/// Convention : toutes les fonctions `compareXxx` comparent deux mains
/// (A et B) et retournent le [Side] gagnant. En cas d'égalité parfaite,
/// le joueur dont `eskuOrder` est le plus proche de 0 (l'Esku) l'emporte.
library;

import '../models/card.dart';

/// Camp gagnant d'une comparaison entre la main A et la main B.
enum Side { a, b }

/// Nombre de cartes par main.
const int handSize = 4;

// ---------------------------------------------------------------------------
// Validation et départage
// ---------------------------------------------------------------------------

void _checkHand(List<Card> hand, String name) {
  if (hand.length != handSize) {
    throw ArgumentError.value(
      hand.length,
      name,
      'Une main doit contenir exactement $handSize cartes',
    );
  }
}

void _checkOrders(int eskuOrderA, int eskuOrderB) {
  for (final o in [eskuOrderA, eskuOrderB]) {
    if (o < 0 || o > 3) {
      throw ArgumentError.value(
        o,
        'eskuOrder',
        'Doit être compris entre 0 et 3',
      );
    }
  }
  if (eskuOrderA == eskuOrderB) {
    throw ArgumentError(
      'Deux joueurs différents ne peuvent pas avoir le même eskuOrder '
      '($eskuOrderA)',
    );
  }
}

/// Transforme un résultat brut (>0 : A meilleur, <0 : B meilleur, 0 : égalité
/// parfaite) en [Side], en départageant les égalités par `eskuOrder`.
Side _resolve(int raw, int eskuOrderA, int eskuOrderB) {
  if (raw > 0) return Side.a;
  if (raw < 0) return Side.b;
  return eskuOrderA < eskuOrderB ? Side.a : Side.b;
}

List<int> _sortedValues(List<Card> hand, {required bool descending}) {
  final values = hand.map((c) => c.value).toList()..sort();
  return descending ? values.reversed.toList() : values;
}

// ---------------------------------------------------------------------------
// Grand (Haundia) : 12 > 11 > 10 > 7 > 6 > 5 > 4 > 3 > 2 > 1
// ---------------------------------------------------------------------------

/// Comparaison brute au Grand, sans départage : >0 si A gagne, <0 si B gagne,
/// 0 en cas d'égalité parfaite.
///
/// L'ordre de force 12 > 11 > 10 > 7 > … > 1 coïncide avec l'ordre numérique
/// des valeurs faciales (il n'y a ni 8 ni 9).
int rawCompareGrand(List<Card> a, List<Card> b) {
  _checkHand(a, 'a');
  _checkHand(b, 'b');
  final va = _sortedValues(a, descending: true);
  final vb = _sortedValues(b, descending: true);
  for (var i = 0; i < handSize; i++) {
    if (va[i] != vb[i]) return va[i].compareTo(vb[i]);
  }
  return 0;
}

/// Gagnant du Grand : comparaison carte par carte de la plus haute à la plus
/// basse. Égalité parfaite → le plus proche de l'Esku l'emporte.
Side compareGrand(
  List<Card> a,
  List<Card> b, {
  required int eskuOrderA,
  required int eskuOrderB,
}) {
  _checkOrders(eskuOrderA, eskuOrderB);
  return _resolve(rawCompareGrand(a, b), eskuOrderA, eskuOrderB);
}

// ---------------------------------------------------------------------------
// Petit (Ttiki) : 1 < 2 < 3 < 4 < 5 < 6 < 7 < 10 < 11 < 12 (le plus bas gagne)
// ---------------------------------------------------------------------------

/// Comparaison brute au Petit, sans départage : >0 si A gagne, <0 si B gagne,
/// 0 en cas d'égalité parfaite.
int rawComparePetit(List<Card> a, List<Card> b) {
  _checkHand(a, 'a');
  _checkHand(b, 'b');
  final va = _sortedValues(a, descending: false);
  final vb = _sortedValues(b, descending: false);
  for (var i = 0; i < handSize; i++) {
    // La plus petite carte gagne : A est meilleur si va[i] < vb[i].
    if (va[i] != vb[i]) return vb[i].compareTo(va[i]);
  }
  return 0;
}

/// Gagnant du Petit : comparaison carte par carte de la plus basse à la plus
/// haute (la plus basse gagne). Égalité parfaite → le plus proche de l'Esku.
Side comparePetit(
  List<Card> a,
  List<Card> b, {
  required int eskuOrderA,
  required int eskuOrderB,
}) {
  _checkOrders(eskuOrderA, eskuOrderB);
  return _resolve(rawComparePetit(a, b), eskuOrderA, eskuOrderB);
}

// ---------------------------------------------------------------------------
// Paires (Pariak)
// ---------------------------------------------------------------------------

/// Type de paires, du plus faible au plus fort (l'index sert à comparer).
enum PairesType {
  /// Aucune paire.
  none(0),

  /// Paire simple (2 cartes identiques) : 1 tantto.
  simple(1),

  /// Mediak (brelan, 3 cartes identiques) : 2 tantto.
  mediak(2),

  /// Doubles (2 paires ou 4 cartes identiques) : 3 tantto.
  doubles(3);

  /// Bonus en tantto marqué au décompte final.
  final int bonus;
  const PairesType(this.bonus);
}

/// Résultat de l'évaluation des paires d'une main.
class PairesResult {
  /// Type de paires.
  final PairesType type;

  /// Valeur principale : paire simple, brelan ou paire haute des Doubles
  /// (0 si [type] est [PairesType.none]).
  final int high;

  /// Paire basse des Doubles (4 cartes identiques → égale à [high]).
  /// 0 pour les autres types.
  final int low;

  const PairesResult(this.type, {this.high = 0, this.low = 0});

  /// `true` si la main a au moins une paire.
  bool get hasPaires => type != PairesType.none;

  /// Bonus en tantto (0 / 1 / 2 / 3).
  int get bonus => type.bonus;

  @override
  bool operator ==(Object other) =>
      other is PairesResult &&
      other.type == type &&
      other.high == high &&
      other.low == low;

  @override
  int get hashCode => Object.hash(type, high, low);

  @override
  String toString() => 'PairesResult($type, high: $high, low: $low)';
}

/// Détecte les paires d'une main de 4 cartes.
///
/// Seules les cartes de même valeur faciale sont identiques (un 3 n'est pas un
/// Roi, un 2 n'est pas un As).
PairesResult evaluatePaires(List<Card> hand) {
  _checkHand(hand, 'hand');
  final counts = <int, int>{};
  for (final c in hand) {
    counts[c.value] = (counts[c.value] ?? 0) + 1;
  }
  // Valeurs ayant au moins 2 exemplaires, de la plus haute à la plus basse.
  final multiples = counts.entries.where((e) => e.value >= 2).toList()
    ..sort((x, y) => y.key.compareTo(x.key));

  if (multiples.isEmpty) return const PairesResult(PairesType.none);

  if (multiples.length == 2) {
    // Deux paires distinctes (ex. 12-12-5-5).
    return PairesResult(
      PairesType.doubles,
      high: multiples[0].key,
      low: multiples[1].key,
    );
  }

  final only = multiples.single;
  switch (only.value) {
    case 4:
      // Quatre cartes identiques = Doubles (paire haute = paire basse).
      return PairesResult(PairesType.doubles, high: only.key, low: only.key);
    case 3:
      return PairesResult(PairesType.mediak, high: only.key);
    default:
      return PairesResult(PairesType.simple, high: only.key);
  }
}

/// Comparaison brute de deux résultats de paires : >0 si A gagne, <0 si B
/// gagne, 0 si égalité parfaite.
///
/// Ordre : type (Doubles > Mediak > Simple > Aucune), puis valeur principale
/// (ordre du Grand), puis paire basse (Doubles uniquement).
/// Article 12 : deux Doubles de même paire haute se départagent à la paire
/// basse, même contre l'Esku (l'Esku n'intervient qu'en égalité parfaite).
int rawComparePaires(List<Card> a, List<Card> b) {
  final pa = evaluatePaires(a);
  final pb = evaluatePaires(b);
  if (pa.type != pb.type) return pa.type.index.compareTo(pb.type.index);
  if (pa.high != pb.high) return pa.high.compareTo(pb.high);
  return pa.low.compareTo(pb.low);
}

/// Gagnant des Paires. Égalité parfaite → le plus proche de l'Esku.
///
/// Un joueur sans paire perd contre un joueur avec paires. Comparer deux
/// mains sans paire est sans objet en jeu (la phase est ignorée) : le
/// départage par Esku s'applique alors simplement.
Side comparePaires(
  List<Card> a,
  List<Card> b, {
  required int eskuOrderA,
  required int eskuOrderB,
}) {
  _checkOrders(eskuOrderA, eskuOrderB);
  return _resolve(rawComparePaires(a, b), eskuOrderA, eskuOrderB);
}

// ---------------------------------------------------------------------------
// Jeu (Jokoa) / Point (Pontua)
// ---------------------------------------------------------------------------

/// Seuil à partir duquel une main a le Jeu.
const int jeuThreshold = 31;

/// Points de Pontua marqués au décompte par le gagnant du Point.
const int pontuaBonus = 1;

/// Totaux du Jeu du plus faible au plus fort :
/// 31 > 32 > 40 > 37 > 36 > 35 > 34 > 33.
const List<int> _jeuTotalsWeakToStrong = [33, 34, 35, 36, 37, 40, 32, 31];

/// Mode de la phase finale : Jeu si au moins un joueur a ≥ 31, sinon Point.
enum JeuPointMode { jeu, point }

/// Résultat de l'évaluation Jeu / Point d'une main.
class JeuPointResult {
  /// Somme des 4 cartes (figures = 10).
  final int total;

  const JeuPointResult(this.total);

  /// `true` si la main a le Jeu (total ≥ 31).
  bool get hasJeu => total >= jeuThreshold;

  /// Bonus de Jeu en tantto : 31 → 3, autres Jeux → 2, pas de Jeu → 0.
  int get jeuBonus => !hasJeu ? 0 : (total == 31 ? 3 : 2);

  /// Force au Jeu (plus grand = plus fort), 0 si la main n'a pas le Jeu.
  int get jeuStrength => hasJeu ? _jeuTotalsWeakToStrong.indexOf(total) + 1 : 0;

  /// Force au Point (plus grand = plus proche de 30). Défini seulement pour
  /// un total ≤ 30 ; sinon la main a le Jeu et ne participe pas au Point.
  int get pointStrength => hasJeu ? 0 : total;

  @override
  bool operator ==(Object other) =>
      other is JeuPointResult && other.total == total;

  @override
  int get hashCode => total.hashCode;

  @override
  String toString() => 'JeuPointResult(total: $total)';
}

/// Calcule le total d'une main et ses attributs de Jeu / Point.
JeuPointResult evaluateJeuEtPoint(List<Card> hand) {
  _checkHand(hand, 'hand');
  return JeuPointResult(hand.fold<int>(0, (sum, c) => sum + c.gameValue));
}

/// Détermine le mode de la phase finale à partir de **toutes** les mains en
/// jeu (normalement les 4) : Jeu si au moins une main a un total ≥ 31.
JeuPointMode determineJeuPointMode(Iterable<List<Card>> hands) {
  for (final hand in hands) {
    if (evaluateJeuEtPoint(hand).hasJeu) return JeuPointMode.jeu;
  }
  return JeuPointMode.point;
}

/// Comparaison brute Jeu / Point : >0 si A gagne, <0 si B gagne, 0 si égalité.
///
/// [mode] doit refléter l'ensemble de la table (voir [determineJeuPointMode]).
/// Lève une [ArgumentError] si les deux mains ne participent pas à la phase
/// (aucune n'a le Jeu en mode Jeu) ou si une main a le Jeu en mode Point.
int rawCompareJeuEtPoint(List<Card> a, List<Card> b, JeuPointMode mode) {
  final ra = evaluateJeuEtPoint(a);
  final rb = evaluateJeuEtPoint(b);
  switch (mode) {
    case JeuPointMode.jeu:
      if (!ra.hasJeu && !rb.hasJeu) {
        throw ArgumentError('Aucune des deux mains n\'a le Jeu (>= 31)');
      }
      return ra.jeuStrength.compareTo(rb.jeuStrength);
    case JeuPointMode.point:
      if (ra.hasJeu || rb.hasJeu) {
        throw ArgumentError(
          'Mode Point incompatible avec une main ayant le Jeu',
        );
      }
      return ra.pointStrength.compareTo(rb.pointStrength);
  }
}

/// Gagnant du Jeu ou du Point entre deux mains.
///
/// Si [mode] est omis, il est déduit des deux mains seulement. En partie à 4,
/// passer le mode obtenu via [determineJeuPointMode] sur les 4 mains.
/// Égalité parfaite (même total) → le plus proche de l'Esku l'emporte.
Side compareJeuEtPoint(
  List<Card> a,
  List<Card> b, {
  required int eskuOrderA,
  required int eskuOrderB,
  JeuPointMode? mode,
}) {
  _checkOrders(eskuOrderA, eskuOrderB);
  final effectiveMode = mode ?? determineJeuPointMode([a, b]);
  return _resolve(
    rawCompareJeuEtPoint(a, b, effectiveMode),
    eskuOrderA,
    eskuOrderB,
  );
}
