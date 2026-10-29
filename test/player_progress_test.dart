import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/models/player_progress.dart';

void main() {
  test('Les anciens profils démarrent au niveau 1 sans XP', () {
    final progress = PlayerProgress.fromJson({'username': 'Patxi'});
    expect(progress.level, 1);
    expect(progress.xp, 0);
    expect(progress.fraction, 0);
  });
  test('La jauge représente le surplus vers les 500 XP suivants', () {
    final progress = PlayerProgress.fromJson({'level': 8, 'xp': 250});
    expect(progress.level, 8);
    expect(progress.xp, 250);
    expect(progress.fraction, .5);
  });
  test(
    'Une donnée de progression invalide n’affiche pas une jauge incohérente',
    () {
      final progress = PlayerProgress.fromJson({'level': 0, 'xp': 500});
      expect(progress.level, 2);
      expect(progress.xp, 0);
    },
  );
  test('XP cumulée normalisée sans ajouter deux fois les niveaux', () {
    final total = PlayerProgress.fromJson({'level': 3, 'xp': 1200});
    expect(total.level, 3);
    expect(total.xp, 200);
    expect(total.fraction, .4);
    expect(total.xpRemaining, 300);
    final remainder = PlayerProgress.fromJson({'level': 3, 'xp': 200});
    expect(remainder.level, 3);
    expect(remainder.xp, 200);
    expect(remainder.xpRemaining, 300);
    expect(PlayerProgress.fromJson({'xp': 1200}).level, 3);
    final negative = PlayerProgress.fromJson({'level': 2, 'xp': -10});
    expect(negative.xp, 0);
    expect(negative.xpRemaining, 500);
  });
}
