import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_evaluator.dart';
import 'package:isamus/core/models/card.dart';

/// Construit une main à partir de valeurs faciales (couleurs distinctes en
/// rotation : une main de 4 cartes n'a jamais deux fois la même carte).
List<Card> hand(List<int> values) => [
  for (var i = 0; i < values.length; i++)
    Card(values[i], Suit.values[i % Suit.values.length]),
];

/// Retourne une main (déterministe) dont le total Jeu/Point vaut [total].
List<Card> handWithTotal(int total) {
  for (final a in Card.validValues) {
    for (final b in Card.validValues) {
      for (final c in Card.validValues) {
        for (final d in Card.validValues) {
          final h = hand([a, b, c, d]);
          if (h.fold<int>(0, (s, x) => s + x.gameValue) == total) return h;
        }
      }
    }
  }
  throw StateError('Aucune main avec le total $total');
}

/// Toutes les paires (strong, weak) avec strong strictement plus fort que
/// weak dans une liste ordonnée du plus fort au plus faible.
Iterable<(int, int)> strongerWeakerPairs(List<int> strongToWeak) sync* {
  for (var i = 0; i < strongToWeak.length; i++) {
    for (var j = i + 1; j < strongToWeak.length; j++) {
      yield (strongToWeak[i], strongToWeak[j]);
    }
  }
}

void main() {
  // -------------------------------------------------------------------------
  group('Card', () {
    test('valeurs valides : 1-7, 10, 11, 12', () {
      for (final v in [1, 2, 3, 4, 5, 6, 7, 10, 11, 12]) {
        expect(() => Card(v, Suit.oros), returnsNormally);
      }
    });

    test('valeurs invalides refusées (0, 8, 9, 13, négatif)', () {
      for (final v in [0, 8, 9, 13, -1, 100]) {
        expect(() => Card(v, Suit.oros), throwsArgumentError, reason: '$v');
      }
    });

    test('gameValue : figures = 10, le reste = sa valeur', () {
      expect(Card(12, Suit.oros).gameValue, 10);
      expect(Card(11, Suit.copas).gameValue, 10);
      expect(Card(10, Suit.espadas).gameValue, 10);
      for (final v in [1, 2, 3, 4, 5, 6, 7]) {
        expect(Card(v, Suit.bastos).gameValue, v);
      }
    });

    test('un 3 reste un 3 et un 2 reste un 2 (pas de Roi/As cachés)', () {
      expect(Card(3, Suit.oros).value, 3);
      expect(Card(3, Suit.oros).gameValue, 3);
      expect(Card(2, Suit.oros).value, 2);
      expect(Card(2, Suit.oros).gameValue, 2);
    });

    test('paquet : 40 cartes uniques, 4 par valeur, 10 par couleur', () {
      final deck = Card.fullDeck();
      expect(deck.length, 40);
      expect(deck.toSet().length, 40);
      for (final v in Card.validValues) {
        expect(deck.where((c) => c.value == v).length, 4);
      }
      for (final s in Suit.values) {
        expect(deck.where((c) => c.suit == s).length, 10);
      }
      expect(deck.any((c) => c.value == 8 || c.value == 9), isFalse);
    });

    test('égalité et hashCode', () {
      expect(Card(5, Suit.oros), Card(5, Suit.oros));
      expect(Card(5, Suit.oros).hashCode, Card(5, Suit.oros).hashCode);
      expect(Card(5, Suit.oros), isNot(Card(5, Suit.copas)));
      expect(Card(5, Suit.oros), isNot(Card(6, Suit.oros)));
    });
  });

  // -------------------------------------------------------------------------
  group('Validation des entrées', () {
    final good = hand([1, 2, 3, 4]);

    test('main de taille incorrecte', () {
      final short = hand([1, 2, 3]);
      final long = hand([1, 2, 3, 4, 5]);
      expect(
        () => compareGrand(short, good, eskuOrderA: 0, eskuOrderB: 1),
        throwsArgumentError,
      );
      expect(
        () => comparePetit(good, long, eskuOrderA: 0, eskuOrderB: 1),
        throwsArgumentError,
      );
      expect(() => evaluatePaires(short), throwsArgumentError);
      expect(() => evaluateJeuEtPoint(long), throwsArgumentError);
    });

    test('eskuOrder hors plage', () {
      expect(
        () => compareGrand(good, good, eskuOrderA: -1, eskuOrderB: 1),
        throwsArgumentError,
      );
      expect(
        () => compareGrand(good, good, eskuOrderA: 0, eskuOrderB: 4),
        throwsArgumentError,
      );
    });

    test('eskuOrder identiques refusés', () {
      expect(
        () => compareGrand(good, good, eskuOrderA: 2, eskuOrderB: 2),
        throwsArgumentError,
      );
      expect(
        () => comparePaires(good, good, eskuOrderA: 1, eskuOrderB: 1),
        throwsArgumentError,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('compareGrand', () {
    // Ordre de force : 12 > 11 > 10 > 7 > 6 > 5 > 4 > 3 > 2 > 1
    const grandOrder = [12, 11, 10, 7, 6, 5, 4, 3, 2, 1];

    test('la carte la plus haute gagne (toutes les paires de valeurs)', () {
      for (final (strong, weak) in strongerWeakerPairs(grandOrder)) {
        // Esku donné au perdant pour prouver que l'Esku ne joue pas ici.
        expect(
          compareGrand(
            hand([strong, 1, 1, 1]),
            hand([weak, 1, 1, 1]),
            eskuOrderA: 3,
            eskuOrderB: 0,
          ),
          Side.a,
          reason: '$strong > $weak',
        );
        expect(
          compareGrand(
            hand([weak, 1, 1, 1]),
            hand([strong, 1, 1, 1]),
            eskuOrderA: 0,
            eskuOrderB: 3,
          ),
          Side.b,
          reason: '$weak < $strong',
        );
      }
    });

    test('un 3 n\'est pas un Roi : 12 bat 3, 3 ne vaut pas 12', () {
      expect(
        compareGrand(
          hand([12, 1, 1, 1]),
          hand([3, 3, 3, 3]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
    });

    test('un 2 n\'est pas un As : 2 bat 1 au Grand', () {
      expect(
        compareGrand(
          hand([2, 2, 2, 2]),
          hand([1, 1, 1, 1]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
    });

    test('comparaison carte par carte (2e carte départage)', () {
      expect(
        compareGrand(
          hand([12, 11, 1, 1]),
          hand([12, 10, 7, 7]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
    });

    test('comparaison carte par carte (3e carte départage)', () {
      expect(
        compareGrand(
          hand([12, 12, 7, 1]),
          hand([12, 12, 6, 6]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
    });

    test('comparaison carte par carte (4e carte départage)', () {
      expect(
        compareGrand(
          hand([12, 12, 7, 4]),
          hand([12, 12, 7, 3]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
      expect(
        compareGrand(
          hand([12, 12, 7, 3]),
          hand([12, 12, 7, 4]),
          eskuOrderA: 0,
          eskuOrderB: 3,
        ),
        Side.b,
      );
    });

    test('l\'ordre des cartes dans la main est sans importance', () {
      expect(
        compareGrand(
          hand([1, 7, 12, 4]),
          hand([4, 12, 6, 1]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a, // [12,7,4,1] > [12,6,4,1]
      );
    });

    test('égalité parfaite : le plus proche de l\'Esku gagne', () {
      final h1 = hand([12, 11, 7, 1]);
      final h2 = hand([1, 7, 11, 12]); // mêmes valeurs, autre ordre
      for (var a = 0; a < 4; a++) {
        for (var b = 0; b < 4; b++) {
          if (a == b) continue;
          expect(
            compareGrand(h1, h2, eskuOrderA: a, eskuOrderB: b),
            a < b ? Side.a : Side.b,
            reason: 'A=$a B=$b',
          );
        }
      }
    });

    test('égalité parfaite avec couleurs différentes → Esku', () {
      final h1 = [
        Card(12, Suit.oros),
        Card(11, Suit.oros),
        Card(10, Suit.oros),
        Card(7, Suit.oros),
      ];
      final h2 = [
        Card(12, Suit.bastos),
        Card(11, Suit.bastos),
        Card(10, Suit.bastos),
        Card(7, Suit.bastos),
      ];
      expect(compareGrand(h1, h2, eskuOrderA: 1, eskuOrderB: 2), Side.a);
      expect(compareGrand(h1, h2, eskuOrderA: 2, eskuOrderB: 1), Side.b);
    });

    test('rawCompareGrand retourne 0 en égalité parfaite', () {
      expect(rawCompareGrand(hand([12, 11, 7, 1]), hand([12, 11, 7, 1])), 0);
      expect(
        rawCompareGrand(hand([12, 11, 7, 2]), hand([12, 11, 7, 1])),
        greaterThan(0),
      );
      expect(
        rawCompareGrand(hand([12, 11, 7, 1]), hand([12, 11, 7, 2])),
        lessThan(0),
      );
    });
  });

  // -------------------------------------------------------------------------
  group('comparePetit', () {
    // Ordre de force (le plus bas gagne) : 1 < 2 < 3 < 4 < 5 < 6 < 7 < 10 < 11 < 12
    const petitOrder = [1, 2, 3, 4, 5, 6, 7, 10, 11, 12]; // meilleur → pire

    test('la carte la plus basse gagne (toutes les paires de valeurs)', () {
      for (final (strong, weak) in strongerWeakerPairs(petitOrder)) {
        expect(
          comparePetit(
            hand([strong, 12, 12, 12]),
            hand([weak, 12, 12, 12]),
            eskuOrderA: 3,
            eskuOrderB: 0,
          ),
          Side.a,
          reason: '$strong meilleur que $weak au Petit',
        );
        expect(
          comparePetit(
            hand([weak, 12, 12, 12]),
            hand([strong, 12, 12, 12]),
            eskuOrderA: 0,
            eskuOrderB: 3,
          ),
          Side.b,
        );
      }
    });

    test('le 1 est plus bas que le 2 (le 2 n\'est pas un As)', () {
      expect(
        comparePetit(
          hand([1, 12, 12, 12]),
          hand([2, 2, 2, 2]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
    });

    test('carte par carte de la plus basse à la plus haute', () {
      // même plus bas (1), 2e plus bas : 2 < 3
      expect(
        comparePetit(
          hand([1, 2, 12, 12]),
          hand([1, 3, 3, 3]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
      // 3e carte
      expect(
        comparePetit(
          hand([1, 2, 3, 12]),
          hand([1, 2, 4, 4]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
      // 4e carte
      expect(
        comparePetit(
          hand([1, 2, 3, 10]),
          hand([1, 2, 3, 11]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
      expect(
        comparePetit(
          hand([1, 2, 3, 11]),
          hand([1, 2, 3, 10]),
          eskuOrderA: 0,
          eskuOrderB: 3,
        ),
        Side.b,
      );
    });

    test('l\'ordre des cartes dans la main est sans importance', () {
      expect(
        comparePetit(
          hand([12, 1, 5, 3]),
          hand([6, 12, 1, 3]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a, // [1,3,5,12] < [1,3,6,12]
      );
    });

    test('égalité parfaite : le plus proche de l\'Esku gagne', () {
      final h1 = hand([1, 2, 5, 12]);
      final h2 = hand([12, 5, 2, 1]);
      for (var a = 0; a < 4; a++) {
        for (var b = 0; b < 4; b++) {
          if (a == b) continue;
          expect(
            comparePetit(h1, h2, eskuOrderA: a, eskuOrderB: b),
            a < b ? Side.a : Side.b,
            reason: 'A=$a B=$b',
          );
        }
      }
    });

    test('rawComparePetit retourne 0 en égalité parfaite', () {
      expect(rawComparePetit(hand([1, 2, 5, 12]), hand([1, 2, 5, 12])), 0);
      expect(
        rawComparePetit(hand([1, 2, 5, 11]), hand([1, 2, 5, 12])),
        greaterThan(0),
      );
    });
  });

  // -------------------------------------------------------------------------
  group('evaluatePaires', () {
    test('aucune paire', () {
      final r = evaluatePaires(hand([12, 11, 10, 7]));
      expect(r.type, PairesType.none);
      expect(r.hasPaires, isFalse);
      expect(r.bonus, 0);
    });

    test('3 et 12 ne forment pas une paire, 2 et 1 non plus', () {
      expect(evaluatePaires(hand([12, 3, 5, 6])).type, PairesType.none);
      expect(evaluatePaires(hand([1, 2, 5, 6])).type, PairesType.none);
      expect(evaluatePaires(hand([12, 3, 3, 6])).type, PairesType.simple);
      expect(evaluatePaires(hand([12, 3, 3, 6])).high, 3);
    });

    test('paire simple = 1 tantto', () {
      final r = evaluatePaires(hand([7, 7, 1, 12]));
      expect(r.type, PairesType.simple);
      expect(r.high, 7);
      expect(r.bonus, 1);
      expect(r.hasPaires, isTrue);
    });

    test('mediak (brelan) = 2 tantto', () {
      final r = evaluatePaires(hand([5, 5, 5, 12]));
      expect(r.type, PairesType.mediak);
      expect(r.high, 5);
      expect(r.bonus, 2);
    });

    test('doubles (2 paires) = 3 tantto', () {
      final r = evaluatePaires(hand([12, 5, 12, 5]));
      expect(r.type, PairesType.doubles);
      expect(r.high, 12);
      expect(r.low, 5);
      expect(r.bonus, 3);
    });

    test('doubles (4 cartes identiques) = 3 tantto, paire haute = basse', () {
      final r = evaluatePaires(hand([7, 7, 7, 7]));
      expect(r.type, PairesType.doubles);
      expect(r.high, 7);
      expect(r.low, 7);
      expect(r.bonus, 3);
    });

    test('doubles : l\'ordre des cartes ne compte pas', () {
      expect(
        evaluatePaires(hand([5, 12, 5, 12])),
        evaluatePaires(hand([12, 12, 5, 5])),
      );
    });

    test('tous les types pour toutes les valeurs', () {
      for (final v in Card.validValues) {
        final others = Card.validValues.where((x) => x != v).toList();
        expect(
          evaluatePaires(hand([v, v, others[0], others[1]])).type,
          PairesType.simple,
        );
        expect(
          evaluatePaires(hand([v, v, v, others[0]])).type,
          PairesType.mediak,
        );
        expect(evaluatePaires(hand([v, v, v, v])).type, PairesType.doubles);
        expect(
          evaluatePaires(hand([v, v, others[0], others[0]])).type,
          PairesType.doubles,
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  group('comparePaires', () {
    // Esku donné systématiquement au perdant attendu pour montrer qu'il ne
    // joue que sur égalité parfaite.
    Side cmp(List<int> a, List<int> b, {int ea = 3, int eb = 0}) =>
        comparePaires(hand(a), hand(b), eskuOrderA: ea, eskuOrderB: eb);

    test('hiérarchie : Doubles > Mediak > Simple > Aucune', () {
      expect(cmp([2, 2, 1, 1], [12, 12, 12, 1]), Side.a);
      expect(cmp([2, 2, 2, 1], [12, 12, 1, 3]), Side.a);
      expect(cmp([2, 2, 1, 3], [12, 11, 10, 7]), Side.a);
      expect(cmp([2, 2, 2, 2], [12, 12, 12, 1]), Side.a); // carré = doubles
      // symétrie
      expect(cmp([12, 12, 12, 1], [2, 2, 1, 1], ea: 0, eb: 3), Side.b);
      expect(cmp([12, 11, 10, 7], [2, 2, 1, 3], ea: 0, eb: 3), Side.b);
    });

    test('paire simple : la plus haute gagne (ordre du Grand)', () {
      const order = [12, 11, 10, 7, 6, 5, 4, 3, 2, 1];
      for (final (strong, weak) in strongerWeakerPairs(order)) {
        // mains sans autre paire : cartes complémentaires distinctes
        final fillS = Card.validValues
            .where((x) => x != strong)
            .take(2)
            .toList();
        final fillW = Card.validValues.where((x) => x != weak).take(2).toList();
        expect(
          cmp([strong, strong, ...fillS], [weak, weak, ...fillW]),
          Side.a,
          reason: 'paire de $strong > paire de $weak',
        );
      }
    });

    test('un 3 n\'est pas un Roi : paire de 12 bat paire de 3', () {
      expect(cmp([3, 3, 1, 2], [12, 12, 1, 2], ea: 0, eb: 3), Side.b);
    });

    test('un 2 n\'est pas un As : paire de 2 bat paire de 1', () {
      expect(cmp([2, 2, 12, 11], [1, 1, 12, 11]), Side.a);
    });

    test('mediak : le plus haut brelan gagne', () {
      expect(cmp([7, 7, 7, 1], [6, 6, 6, 12]), Side.a);
      expect(cmp([6, 6, 6, 12], [7, 7, 7, 1], ea: 0, eb: 3), Side.b);
    });

    test('doubles : la paire haute décide d\'abord', () {
      expect(cmp([12, 12, 1, 1], [11, 11, 10, 10]), Side.a);
    });

    test('Article 12 : même paire haute → la paire basse la plus forte gagne, '
        'même contre l\'Esku', () {
      // A (non-Esku, ordre 3) : 12-12-7-7 ; B (Esku, ordre 0) : 12-12-5-5
      expect(cmp([12, 12, 7, 7], [12, 12, 5, 5], ea: 3, eb: 0), Side.a);
      // Et inversement, quel que soit le côté de l'Esku
      expect(cmp([12, 12, 5, 5], [12, 12, 7, 7], ea: 0, eb: 3), Side.b);
      expect(cmp([12, 12, 5, 5], [12, 12, 7, 7], ea: 3, eb: 0), Side.b);
      expect(cmp([12, 12, 7, 7], [12, 12, 5, 5], ea: 0, eb: 3), Side.a);
    });

    test('Article 12 avec 4 cartes identiques : carré de 7 bat 7-7-5-5', () {
      expect(cmp([7, 7, 7, 7], [7, 7, 5, 5], ea: 3, eb: 0), Side.a);
      expect(cmp([7, 7, 5, 5], [7, 7, 7, 7], ea: 0, eb: 3), Side.b);
    });

    test(
      'carré de 12 bat 12-12-11-11, mais carré de 5 perd contre 12-12-1-1',
      () {
        expect(cmp([12, 12, 12, 12], [12, 12, 11, 11], ea: 3, eb: 0), Side.a);
        expect(cmp([5, 5, 5, 5], [12, 12, 1, 1], ea: 0, eb: 3), Side.b);
      },
    );

    test('égalité parfaite en doubles → Esku', () {
      expect(cmp([12, 12, 5, 5], [5, 5, 12, 12], ea: 1, eb: 2), Side.a);
      expect(cmp([12, 12, 5, 5], [5, 5, 12, 12], ea: 2, eb: 1), Side.b);
    });

    test('égalité parfaite en paire simple (couleurs différentes) → Esku', () {
      expect(cmp([7, 7, 1, 12], [7, 7, 1, 12], ea: 0, eb: 3), Side.a);
      expect(cmp([7, 7, 1, 12], [7, 7, 1, 12], ea: 3, eb: 0), Side.b);
    });

    test('égalité parfaite en mediak (cas synthétique) → Esku', () {
      expect(cmp([5, 5, 5, 12], [5, 5, 5, 12], ea: 2, eb: 3), Side.a);
      expect(cmp([5, 5, 5, 12], [5, 5, 5, 12], ea: 3, eb: 2), Side.b);
    });

    test('égalité parfaite en carré (cas synthétique) → Esku', () {
      expect(cmp([7, 7, 7, 7], [7, 7, 7, 7], ea: 0, eb: 1), Side.a);
      expect(cmp([7, 7, 7, 7], [7, 7, 7, 7], ea: 1, eb: 0), Side.b);
    });

    test('l\'ordre des cartes ne compte pas en cas d\'égalité (simple)', () {
      // même paire de 7, kickers différents : égalité parfaite aux Paires
      expect(cmp([7, 7, 1, 12], [12, 7, 1, 7], ea: 1, eb: 2), Side.a);
      expect(rawComparePaires(hand([7, 7, 1, 12]), hand([7, 7, 3, 4])), 0);
    });

    test('rawComparePaires retourne 0 en égalité parfaite et signe sinon', () {
      expect(rawComparePaires(hand([12, 12, 5, 5]), hand([5, 5, 12, 12])), 0);
      expect(
        rawComparePaires(hand([12, 12, 7, 7]), hand([12, 12, 5, 5])),
        greaterThan(0),
      );
      expect(
        rawComparePaires(hand([12, 12, 5, 5]), hand([12, 12, 7, 7])),
        lessThan(0),
      );
    });
  });

  // -------------------------------------------------------------------------
  group('evaluateJeuEtPoint', () {
    test('figures valent 10, autres valent leur chiffre', () {
      expect(evaluateJeuEtPoint(hand([12, 11, 10, 1])).total, 31);
      expect(evaluateJeuEtPoint(hand([10, 10, 10, 1])).total, 31);
      expect(evaluateJeuEtPoint(hand([7, 7, 7, 7])).total, 28);
      expect(evaluateJeuEtPoint(hand([12, 12, 12, 12])).total, 40);
      expect(evaluateJeuEtPoint(hand([1, 1, 1, 1])).total, 4);
      expect(evaluateJeuEtPoint(hand([3, 2, 12, 7])).total, 22);
    });

    test('hasJeu à partir de 31 inclus', () {
      expect(evaluateJeuEtPoint(handWithTotal(30)).hasJeu, isFalse);
      expect(evaluateJeuEtPoint(handWithTotal(31)).hasJeu, isTrue);
      expect(evaluateJeuEtPoint(handWithTotal(4)).hasJeu, isFalse);
      expect(evaluateJeuEtPoint(handWithTotal(40)).hasJeu, isTrue);
    });

    test('bonus de Jeu : 31 = 3 tantto, autres Jeux = 2, pas de Jeu = 0', () {
      expect(evaluateJeuEtPoint(handWithTotal(31)).jeuBonus, 3);
      for (final t in [32, 33, 34, 35, 36, 37, 40]) {
        expect(evaluateJeuEtPoint(handWithTotal(t)).jeuBonus, 2, reason: '$t');
      }
      for (final t in [4, 20, 29, 30]) {
        expect(evaluateJeuEtPoint(handWithTotal(t)).jeuBonus, 0, reason: '$t');
      }
    });

    test('pontuaBonus vaut 1', () {
      expect(pontuaBonus, 1);
    });

    test('totaux atteignables : 4 à 37 et 40 (38 et 39 sont impossibles)', () {
      for (var t = 4; t <= 37; t++) {
        expect(evaluateJeuEtPoint(handWithTotal(t)).total, t);
      }
      expect(evaluateJeuEtPoint(handWithTotal(40)).total, 40);
      expect(() => handWithTotal(38), throwsStateError);
      expect(() => handWithTotal(39), throwsStateError);
    });
  });

  // -------------------------------------------------------------------------
  group('determineJeuPointMode', () {
    test('Jeu si au moins une main a >= 31', () {
      expect(
        determineJeuPointMode([
          handWithTotal(20),
          handWithTotal(30),
          handWithTotal(31),
        ]),
        JeuPointMode.jeu,
      );
    });

    test('Point si personne n\'a >= 31', () {
      expect(
        determineJeuPointMode([
          handWithTotal(4),
          handWithTotal(30),
          handWithTotal(29),
        ]),
        JeuPointMode.point,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('compareJeuEtPoint — Jeu', () {
    // 31 > 32 > 40 > 37 > 36 > 35 > 34 > 33
    const jeuOrder = [31, 32, 40, 37, 36, 35, 34, 33];

    test('ordre de force du Jeu (toutes les paires de totaux)', () {
      for (final (strong, weak) in strongerWeakerPairs(jeuOrder)) {
        expect(
          compareJeuEtPoint(
            handWithTotal(strong),
            handWithTotal(weak),
            eskuOrderA: 3,
            eskuOrderB: 0,
          ),
          Side.a,
          reason: '$strong > $weak',
        );
        expect(
          compareJeuEtPoint(
            handWithTotal(weak),
            handWithTotal(strong),
            eskuOrderA: 0,
            eskuOrderB: 3,
          ),
          Side.b,
          reason: '$weak < $strong',
        );
      }
    });

    test('cas emblématiques : 31 bat 32, 32 bat 40, 40 bat 37, 33 est le plus faible', () {
      Side c(int a, int b) => compareJeuEtPoint(
        handWithTotal(a),
        handWithTotal(b),
        eskuOrderA: 3,
        eskuOrderB: 0,
      );
      expect(c(31, 32), Side.a);
      expect(c(32, 40), Side.a);
      expect(c(40, 37), Side.a);
      expect(c(37, 36), Side.a);
      expect(c(34, 33), Side.a);
      expect(c(33, 34), Side.b);
    });

    test('une main avec Jeu bat une main sans Jeu (même si l\'Esku est de l\'autre côté)', () {
      expect(
        compareJeuEtPoint(
          handWithTotal(33),
          handWithTotal(30),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
      expect(
        compareJeuEtPoint(
          handWithTotal(30),
          handWithTotal(33),
          eskuOrderA: 0,
          eskuOrderB: 3,
        ),
        Side.b,
      );
    });

    test('égalité parfaite au Jeu (même total) → Esku, pour chaque total', () {
      for (final t in jeuOrder) {
        final h1 = handWithTotal(t);
        final h2 = handWithTotal(t);
        expect(
          compareJeuEtPoint(h1, h2, eskuOrderA: 1, eskuOrderB: 3),
          Side.a,
          reason: 'total $t',
        );
        expect(
          compareJeuEtPoint(h1, h2, eskuOrderA: 3, eskuOrderB: 1),
          Side.b,
          reason: 'total $t',
        );
      }
    });

    test('égalité parfaite avec compositions différentes → Esku', () {
      // 12-11-10-1 et 10-10-10-1 valent tous deux 31
      expect(
        compareJeuEtPoint(
          hand([12, 11, 10, 1]),
          hand([10, 10, 10, 1]),
          eskuOrderA: 2,
          eskuOrderB: 0,
        ),
        Side.b,
      );
      expect(
        compareJeuEtPoint(
          hand([12, 11, 10, 1]),
          hand([10, 10, 10, 1]),
          eskuOrderA: 0,
          eskuOrderB: 2,
        ),
        Side.a,
      );
    });

    test('mode Jeu imposé par la table : deux mains sans Jeu → erreur', () {
      expect(
        () => compareJeuEtPoint(
          handWithTotal(30),
          handWithTotal(29),
          eskuOrderA: 0,
          eskuOrderB: 1,
          mode: JeuPointMode.jeu,
        ),
        throwsArgumentError,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('compareJeuEtPoint — Point', () {
    test('le plus proche de 30 gagne : 30 > 29 > 28 > … > 4', () {
      for (var strong = 30; strong > 4; strong--) {
        for (var weak = strong - 1; weak >= 4; weak--) {
          expect(
            compareJeuEtPoint(
              handWithTotal(strong),
              handWithTotal(weak),
              eskuOrderA: 3,
              eskuOrderB: 0,
            ),
            Side.a,
            reason: '$strong > $weak',
          );
          expect(
            compareJeuEtPoint(
              handWithTotal(weak),
              handWithTotal(strong),
              eskuOrderA: 0,
              eskuOrderB: 3,
            ),
            Side.b,
            reason: '$weak < $strong',
          );
        }
      }
    });

    test(
      'égalité parfaite au Point (même total) → Esku, pour chaque total',
      () {
        for (var t = 4; t <= 30; t++) {
          final h1 = handWithTotal(t);
          final h2 = handWithTotal(t);
          expect(
            compareJeuEtPoint(h1, h2, eskuOrderA: 0, eskuOrderB: 2),
            Side.a,
            reason: 'total $t',
          );
          expect(
            compareJeuEtPoint(h1, h2, eskuOrderA: 2, eskuOrderB: 0),
            Side.b,
            reason: 'total $t',
          );
        }
      },
    );

    test('mode Point déduit automatiquement des deux mains', () {
      // 12-11-7-1 = 28 ; 12-7-6-4 = 27 → 28 est plus proche de 30
      expect(
        compareJeuEtPoint(
          hand([12, 11, 7, 1]),
          hand([12, 7, 6, 4]),
          eskuOrderA: 3,
          eskuOrderB: 0,
        ),
        Side.a,
      );
    });

    test('mode Point imposé avec une main ayant le Jeu → erreur', () {
      expect(
        () => compareJeuEtPoint(
          handWithTotal(31),
          handWithTotal(29),
          eskuOrderA: 0,
          eskuOrderB: 1,
          mode: JeuPointMode.point,
        ),
        throwsArgumentError,
      );
    });

    test('rawCompareJeuEtPoint : signe et égalité', () {
      expect(
        rawCompareJeuEtPoint(
          handWithTotal(30),
          handWithTotal(29),
          JeuPointMode.point,
        ),
        greaterThan(0),
      );
      expect(
        rawCompareJeuEtPoint(
          handWithTotal(29),
          handWithTotal(30),
          JeuPointMode.point,
        ),
        lessThan(0),
      );
      expect(
        rawCompareJeuEtPoint(
          handWithTotal(25),
          handWithTotal(25),
          JeuPointMode.point,
        ),
        0,
      );
      expect(
        rawCompareJeuEtPoint(
          handWithTotal(32),
          handWithTotal(32),
          JeuPointMode.jeu,
        ),
        0,
      );
    });
  });
}
