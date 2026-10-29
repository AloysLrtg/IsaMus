import 'dart:math' as math;

/// Moteur de calcul de classement Elo pour IsaMus.
///
/// Formule officielle :
/// - Espérance : E = 1 / (1 + 10 ^ ((Elo_Adversaire - Elo_Joueur) / 400))
/// - Variation (Delta) : Δ = round(K * (Résultat - E))
/// - Nouvel Elo : Nouvel_Elo = Ancien_Elo + Δ
/// où Résultat = 1.0 (Victoire) ou 0.0 (Défaite), et K = 32 par défaut.
class EloCalculator {
  const EloCalculator._();

  /// Facteur d'ajustement K par défaut (rythme rapide / compétitif).
  static const int defaultK = 32;

  /// Score moyen de l'équipe adverse par défaut (MVP).
  static const int defaultOpponentElo = 1200;

  /// Calcule l'espérance mathématique de gain pour le joueur face à l'adversaire.
  ///
  /// Retourne une valeur comprise entre 0.0 et 1.0.
  static double calculateExpectedScore(int playerElo, int opponentElo) {
    final exponent = (opponentElo - playerElo) / 400.0;
    return 1.0 / (1.0 + math.pow(10.0, exponent));
  }

  /// Calcule la variation d'Elo (gain ou perte) pour un match.
  ///
  /// [playerElo] : Elo initial du joueur.
  /// [opponentElo] : Elo (ou moyenne d'Elo) de l'équipe adverse.
  /// [isVictory] : true si le joueur a gagné (score 1.0), false s'il a perdu (score 0.0).
  /// [kFactor] : Facteur K utilisé (32 par défaut).
  ///
  /// Retourne un entier positif (gain) ou négatif (perte).
  static int calculateDelta({
    required int playerElo,
    required int opponentElo,
    required bool isVictory,
    int kFactor = defaultK,
  }) {
    final actualScore = isVictory ? 1.0 : 0.0;
    final expectedScore = calculateExpectedScore(playerElo, opponentElo);
    final delta = (kFactor * (actualScore - expectedScore)).round();
    return delta;
  }

  /// Calcule le nouvel Elo après le match en ajoutant la variation au score initial.
  ///
  /// Garantit un Elo non-négatif (minimum 0).
  static int calculateNewElo({
    required int playerElo,
    required int opponentElo,
    required bool isVictory,
    int kFactor = defaultK,
  }) {
    final delta = calculateDelta(
      playerElo: playerElo,
      opponentElo: opponentElo,
      isVictory: isVictory,
      kFactor: kFactor,
    );
    final newElo = playerElo + delta;
    return newElo < 0 ? 0 : newElo;
  }
}
