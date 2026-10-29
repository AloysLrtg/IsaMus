import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/elo_calculator.dart';

void main() {
  group('EloCalculator Tests', () {
    test('calculateExpectedScore retourne 0.5 lorsque les deux Elos sont identiques', () {
      final expected = EloCalculator.calculateExpectedScore(1200, 1200);
      expect(expected, closeTo(0.5, 0.0001));
    });

    test('calculateExpectedScore donne un avantage au joueur ayant un Elo supérieur', () {
      final expectedHigher = EloCalculator.calculateExpectedScore(1400, 1200);
      final expectedLower = EloCalculator.calculateExpectedScore(1000, 1200);

      expect(expectedHigher, greaterThan(0.5));
      expect(expectedLower, lessThan(0.5));
      // Symétrie de l'espérance
      expect(expectedHigher + expectedLower, closeTo(1.0, 0.0001));
    });

    test('Variation et nouvel Elo à Elos égaux (1200 vs 1200)', () {
      // Victoire : 32 * (1 - 0.5) = +16
      final deltaWin = EloCalculator.calculateDelta(
        playerElo: 1200,
        opponentElo: 1200,
        isVictory: true,
      );
      expect(deltaWin, 16);
      expect(
        EloCalculator.calculateNewElo(
          playerElo: 1200,
          opponentElo: 1200,
          isVictory: true,
        ),
        1216,
      );

      // Défaite : 32 * (0 - 0.5) = -16
      final deltaLoss = EloCalculator.calculateDelta(
        playerElo: 1200,
        opponentElo: 1200,
        isVictory: false,
      );
      expect(deltaLoss, -16);
      expect(
        EloCalculator.calculateNewElo(
          playerElo: 1200,
          opponentElo: 1200,
          isVictory: false,
        ),
        1184,
      );
    });

    test('Victoire contre un adversaire plus fort (1000 vs 1200)', () {
      final delta = EloCalculator.calculateDelta(
        playerElo: 1000,
        opponentElo: 1200,
        isVictory: true,
      );
      // Espérance ~0.24025 -> 32 * (1 - 0.24025) = 24.31 -> 24
      expect(delta, 24);
      final newElo = EloCalculator.calculateNewElo(
        playerElo: 1000,
        opponentElo: 1200,
        isVictory: true,
      );
      expect(newElo, 1024);
    });

    test('Défaite contre un adversaire plus fort (1000 vs 1200)', () {
      final delta = EloCalculator.calculateDelta(
        playerElo: 1000,
        opponentElo: 1200,
        isVictory: false,
      );
      // Espérance ~0.24025 -> 32 * (0 - 0.24025) = -7.68 -> -8
      expect(delta, -8);
      final newElo = EloCalculator.calculateNewElo(
        playerElo: 1000,
        opponentElo: 1200,
        isVictory: false,
      );
      expect(newElo, 992);
    });

    test('L\'Elo calculé ne descend jamais en dessous de 0', () {
      final newElo = EloCalculator.calculateNewElo(
        playerElo: 5,
        opponentElo: 5,
        isVictory: false,
      );
      expect(newElo, 0);
    });
  });
}
