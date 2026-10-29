import '../models/card.dart';
import 'mus_evaluator.dart';
import 'mus_game_state.dart';

/// Percentile against ONE eligible unknown opponent hand, ties worth half.
/// Enumerates rank multisets weighted by C(remaining cards, multiplicity):
/// exact 4-Rois/4-As odds over the 36 unseen cards, without reading opponents.
/// At most 715 multisets per uncached hand, shared across all five lances.
abstract final class BotHandStrength {
  static final _cache = <String, Map<BidPhase, double>>{};
  static Map<BidPhase, double> evaluate(List<Card> hand) {
    if (hand.length != handSize || hand.toSet().length != handSize) {
      throw ArgumentError('Une main doit contenir quatre cartes distinctes.');
    }
    final values = hand.map((c) => c.value).toList()..sort();
    final key = values.join(',');
    final cached = _cache[key];
    if (cached != null) return cached;
    final available = {for (final v in Card.validValues) v: 4};
    for (final v in values) {
      available[v] = available[v]! - 1;
    }
    final own = _ranks(hand);
    final totals = {for (final p in BidPhase.values) p: 0.0};
    final wins = {for (final p in BidPhase.values) p: 0.0};
    final chosen = <Card>[];
    void visit(int index, int remaining, int weight) {
      if (remaining == 0) {
        final other = _ranks(chosen);
        for (final phase in BidPhase.values) {
          final a = own[phase], b = other[phase];
          if (b == null) {
            continue; // Exclude non-participants at Paires/Jeu/Point.
          }
          totals[phase] = totals[phase]! + weight;
          if (a != null) {
            wins[phase] =
                wins[phase]! +
                (a > b
                    ? weight
                    : a == b
                    ? weight / 2
                    : 0);
          }
        }
        return;
      }
      if (index >= Card.validValues.length) return;
      final value = Card.validValues[index];
      final count = available[value]!;
      for (var n = 0; n <= remaining && n <= count; n++) {
        for (var j = 0; j < n; j++) {
          chosen.add(Card(value, Suit.values[j]));
        }
        visit(index + 1, remaining - n, weight * _choose(count, n));
        chosen.removeRange(chosen.length - n, chosen.length);
      }
    }

    visit(0, handSize, 1);
    final result = Map<BidPhase, double>.unmodifiable({
      for (final p in BidPhase.values)
        p: own[p] == null || totals[p] == 0 ? 0.0 : 100 * wins[p]! / totals[p]!,
    });
    if (_cache.length >= 512) _cache.remove(_cache.keys.first);
    _cache[key] = result;
    return result;
  }

  static int _choose(int n, int k) {
    var result = 1;
    for (var i = 1; i <= k; i++) {
      result = result * (n - i + 1) ~/ i;
    }
    return result;
  }

  static Map<BidPhase, int?> _ranks(List<Card> hand) {
    final values = hand.map((c) => c.value).toList()..sort();
    int encode(Iterable<int> order) =>
        order.fold(0, (rank, value) => rank * 13 + value);
    final pairs = evaluatePaires(hand);
    final game = evaluateJeuEtPoint(hand);
    return {
      BidPhase.grand: encode(values.reversed),
      BidPhase.petit: -encode(values),
      BidPhase.paires: pairs.hasPaires
          ? pairs.type.index * 169 + pairs.high * 13 + pairs.low
          : null,
      BidPhase.jeu: game.hasJeu ? game.jeuStrength : null,
      BidPhase.point: !game.hasJeu ? game.total : null,
    };
  }
}
