import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/models/card.dart';

List<Card> h(int seat, List<int> values) => [
  for (var i = 0; i < values.length; i++)
    Card(values[i], Suit.values[(seat + i) % 4]),
];

List<List<Card>> table(List<List<int>> values) => [
  for (var s = 0; s < 4; s++) h(s, values[s]),
];

/// Aucune paire, aucun Jeu. Grand → siège 0 (A), Petit → siège 1 (B),
/// Point → siège 1 (B, total 24).
final basicHands = table([
  [12, 5, 3, 2], // 20
  [11, 7, 6, 1], // 24
  [10, 6, 4, 2], // 22
  [7, 5, 4, 3], // 19
]);

const paso = BidActionType.paso;
const embido = BidActionType.embido;
const gehiago = BidActionType.gehiago;
const hordago = BidActionType.hordago;
const iduki = BidActionType.iduki;
const tira = BidActionType.tira;
const nereGatikTira = BidActionType.nereGatikTira;

void main() {
  late ProviderContainer container;
  late MusGameController c;
  MusGameState s() => container.read(musGameControllerProvider);

  setUp(() {
    container = ProviderContainer(
      overrides: [
        musRandomProvider.overrideWithValue(Random(42)),
        // Ces scénarios pilotent explicitement les quatre sièges.
        musBotsEnabledProvider.overrideWithValue(false),
        musTurnTimeoutProvider.overrideWithValue(null),
        musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    c = container.read(musGameControllerProvider.notifier);
  });

  /// Tous les joueurs de la sous-phase en cours passent.
  void allPaso() {
    final b = s().bidding!;
    for (final seat in b.participants) {
      c.act(seat, paso);
    }
  }

  group('Distribution et état initial', () {
    test('état initial', () {
      expect(s().phase, MusPhase.dealing);
      expect(s().tantto, [0, 0]);
      expect(s().manches, [0, 0]);
    });

    test(
      'startGame aléatoire : 4 mains de 4 cartes + talon de 24, tout unique',
      () {
        c.startGame(eskuIndex: 2);
        expect(s().phase, MusPhase.musDecision);
        expect(s().currentPlayer, 2);
        expect(s().hands.every((x) => x.length == 4), isTrue);
        expect(s().talon.length, 24);
        final all = [...s().hands.expand((x) => x), ...s().talon];
        expect(all.toSet().length, 40);
      },
    );
  });

  group('Phase de Mus', () {
    test('Mintza verrouille le paquet et ouvre les enchères au Grand', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);
      expect(s().deckLocked, isTrue);
      expect(s().phase, MusPhase.bidding);
      expect(s().bidding!.phase, BidPhase.grand);
      expect(s().currentPlayer, 0);
      expect(() => c.chooseMus(0, MusChoice.mus), throwsStateError);
    });

    test('Mintza du 3e joueur après deux Mus (ordre équipe)', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mus);
      expect(s().currentPlayer, 2);
      c.chooseMus(2, MusChoice.mus);
      expect(s().currentPlayer, 3);
      c.chooseMus(3, MusChoice.mintza);
      expect(s().phase, MusPhase.bidding);
    });

    test('Ordre de parole en équipe lors de la décision du Mus', () {
      // Esku = 0 : 0 -> 2 -> 3 -> 1 (sens anti-horaire)
      c.startGame(eskuIndex: 0, hands: basicHands);
      expect(s().currentPlayer, 0);
      c.chooseMus(0, MusChoice.mus);
      expect(s().currentPlayer, 2);
      c.chooseMus(2, MusChoice.mus);
      expect(s().currentPlayer, 3);
      c.chooseMus(3, MusChoice.mus);
      expect(s().currentPlayer, 1);
      c.chooseMus(1, MusChoice.mus);
      expect(s().phase, MusPhase.discarding);

      // Esku = 1 : 1 -> 3 -> 0 -> 2
      c.startGame(eskuIndex: 1, hands: basicHands);
      expect(s().currentPlayer, 1);
      c.chooseMus(1, MusChoice.mus);
      expect(s().currentPlayer, 3);
      c.chooseMus(3, MusChoice.mus);
      expect(s().currentPlayer, 0);
      c.chooseMus(0, MusChoice.mus);
      expect(s().currentPlayer, 2);
      c.chooseMus(2, MusChoice.mus);
      expect(s().phase, MusPhase.discarding);

      // Si l'Esku dit Mus et le partenaire dit Mintza, le jeu s'ouvre
      c.startGame(eskuIndex: 0, hands: basicHands);
      c.chooseMus(0, MusChoice.mus);
      c.chooseMus(2, MusChoice.mintza);
      expect(s().phase, MusPhase.bidding);
      expect(s().deckLocked, isTrue);
    });

    test('4 Mus → défausse → distribution → nouvelle décision de Mus', () {
      final talon = [for (final v in Card.validValues) Card(v, Suit.oros)];
      c.startGame(hands: basicHands, talon: talon);
      for (final seat in [0, 2, 3, 1]) {
        c.chooseMus(seat, MusChoice.mus);
      }
      expect(s().phase, MusPhase.discarding);
      expect(s().currentPlayer, 0);

      c.discard(0, [0, 1]);
      c.discard(3, [0, 1, 2, 3]);
      c.discard(2, [3]);
      expect(s().phase, MusPhase.discarding);
      c.discard(1, []);

      expect(s().phase, MusPhase.musDecision);
      expect(s().currentPlayer, 0);
      expect(s().musVotes, isEmpty);
      expect(s().hands.every((x) => x.length == 4), isTrue);
      // Distribution dans l'ordre de parole : 0 reçoit 2, 1 reçoit 4, 2 reçoit 1, 3 reçoit 0.
      expect(s().hands[0].sublist(2), [talon[0], talon[1]]);
      expect(s().hands[3], talon.sublist(2, 6));
      expect(s().hands[2].last, talon[6]);
      expect(s().hands[1], basicHands[1]);
      expect(s().talon, talon.sublist(7));
      expect(s().discardPile.length, 7);
    });

    test('talon épuisé : les défausses du tour sont remélangées', () {
      final talon = [
        for (final v in [1, 2, 3]) Card(v, Suit.oros),
      ];
      c.startGame(hands: basicHands, talon: talon);
      for (final seat in [0, 2, 3, 1]) {
        c.chooseMus(seat, MusChoice.mus);
      }
      c.discard(0, [0, 1]);
      c.discard(3, [0, 1, 2, 3]);
      c.discard(2, [3]);
      c.discard(1, []); // 7 cartes demandées pour 3 en talon
      expect(s().phase, MusPhase.musDecision);
      expect(s().hands.every((x) => x.length == 4), isTrue);
      expect(s().talon.length, 3); // 3 + 7 défausses - 7 distribuées
      expect(s().discardPile, isEmpty);
      final all = [...s().hands.expand((x) => x), ...s().talon];
      expect(all.length, 19);
    });

    test('défausse invalide ou hors tour refusée', () {
      c.startGame(hands: basicHands);
      for (final seat in [0, 2, 3, 1]) {
        c.chooseMus(seat, MusChoice.mus);
      }
      expect(() => c.discard(1, [0]), throwsStateError);
      expect(() => c.discard(0, [0, 0]), throwsArgumentError);
      expect(() => c.discard(0, [4]), throwsArgumentError);
    });
  });

  group('Tour complet de 4 Paso', () {
    test('décompte de base : Grand 1 (A), Petit 1 (B), Point 1 (B)', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);

      // Grand : ordre de parole 0, 1, 2, 3.
      expect(s().bidding!.phase, BidPhase.grand);
      for (final seat in [0, 3, 2, 1]) {
        expect(s().currentPlayer, seat);
        c.act(seat, paso);
      }
      // Petit
      expect(s().bidding!.phase, BidPhase.petit);
      allPaso();
      // Paires sautées (aucune paire), pas de Jeu → Point
      expect(s().bidding!.phase, BidPhase.point);
      expect(s().outcomes.containsKey(BidPhase.paires), isFalse);
      allPaso();

      expect(s().phase, MusPhase.roundScoring);
      expect(s().tantto, [1, 2]);
      expect(s().mancheWinner, isNull);
      expect(s().bidHistory[BidPhase.grand]!.length, 4);
      expect(s().scoreLog.map((e) => '$e'), [
        'grand:team0+1(phase)',
        'petit:team1+1(phase)',
        'point:team1+1(pontua)',
      ]);

      // Rotation de l'Esku et nouvelle main (tantto conservés).
      c.nextHand(hands: basicHands);
      expect(s().eskuIndex, 3);
      expect(s().phase, MusPhase.musDecision);
      expect(s().currentPlayer, 3);
      expect(s().tantto, [1, 2]);
      expect(s().scoreLog, isEmpty);
    });
  });

  group('Mintza, relance, Hordago accepté', () {
    test('Hordago Iduki arrête immédiatement la manche', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);

      c.act(0, embido, amount: 2); // A mise 2
      expect(
        s().currentPlayer,
        3,
      ); // B répond, le plus proche de l'Esku d'abord
      c.act(3, gehiago, amount: 3); // B relance : total 5
      expect(s().bidding!.currentBid, 5);
      expect(s().currentPlayer, 0);
      c.act(0, hordago); // A : tapis
      expect(s().bidding!.isHordago, isTrue);
      expect(s().currentPlayer, 3);
      expect(() => c.act(3, gehiago, amount: 2), throwsStateError);
      c.act(3, iduki); // B accepte

      // Siège 0 a le meilleur Grand (12) → A gagne la manche.
      expect(s().phase, MusPhase.roundScoring);
      expect(s().mancheWinner, 0);
      expect(s().tantto, [40, 0]);
      expect(s().manches, [1, 0]);
      expect(s().bidding, isNull);
      expect(s().outcomes.keys, [BidPhase.grand]); // rien d'autre n'est joué
      expect(s().outcomes[BidPhase.grand]!.kind, OutcomeKind.hordagoAccepted);

      // Fin de partie à 40 tantto : nextHand() est bloqué et ne fait rien.
      c.nextHand(hands: basicHands);
      expect(s().tantto, [40, 0]);
      expect(s().manches, [1, 0]);
      expect(s().phase, MusPhase.roundScoring);
    });

    test('Hordago accepté au Petit : le meilleur Petit (siège 1, B) gagne', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);
      allPaso(); // Grand
      c.act(0, hordago);
      c.act(3, iduki);
      expect(s().mancheWinner, 1);
      expect(s().tantto, [0, 40]);
    });

    test('Hordago refusé : 1 tantto à l\'équipe qui a lancé', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);
      c.act(0, hordago);
      c.act(3, tira);
      c.act(1, tira);
      expect(s().tantto, [1, 0]);
      expect(s().bidding!.phase, BidPhase.petit);
    });

    test('la partie se termine après 3 manches gagnées', () {
      // Siège 0 a toujours le meilleur Grand ; A gagne chaque Hordago.
      final hands = table([
        [12, 12, 11, 11],
        [10, 7, 6, 5],
        [4, 3, 2, 1],
        [10, 7, 6, 4],
      ]);
      c.startGame(hands: hands);
      for (var m = 1; m <= 3; m++) {
        expect(s().phase, MusPhase.musDecision);
        final esku = s().eskuIndex;
        c.chooseMus(esku, MusChoice.mintza);
        c.act(esku, hordago);
        c.act(s().currentPlayer, iduki);
        expect(s().manches[0], m);
        if (m < 3) {
          expect(s().phase, MusPhase.roundScoring);
          // ignore: invalid_use_of_protected_member
          c.state = s().copyWith(tantto: [0, 0]);
          c.nextHand(hands: hands);
        }
      }
      expect(s().phase, MusPhase.gameOver);
      expect(s().gameWinner, 0);
      c.nextHand();
      expect(s().phase, MusPhase.gameOver);
    });
  });

  group('Tira, mises acceptées, Nere gatik tira', () {
    test(
      'Tira sur première mise = 1 tantto ; sur relance = mise précédente',
      () {
        c.startGame(hands: basicHands);
        c.chooseMus(0, MusChoice.mintza);

        c.act(0, embido, amount: 2);
        c.act(3, tira);
        c.act(1, tira); // première mise refusée → 1 pour A
        expect(s().tantto, [1, 0]);
        expect(s().outcomes[BidPhase.grand]!.kind, OutcomeKind.refused);

        // Petit : A mise 2, B relance +3 (5), A refuse → B marque la mise précédente (2).
        expect(s().bidding!.phase, BidPhase.petit);
        c.act(0, embido, amount: 2);
        c.act(3, gehiago, amount: 3);
        c.act(0, tira);
        c.act(2, tira);
        expect(s().tantto, [1, 2]);
        expect(s().bidding!.phase, BidPhase.point);
      },
    );

    test('Nere gatik tira : le partenaire tranche (ici Iduki)', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);
      c.act(0, embido, amount: 2);
      c.act(3, nereGatikTira);
      expect(s().currentPlayer, 1); // le partenaire décide
      expect(s().bidding!.partnerDecides, isTrue);
      expect(() => c.act(1, nereGatikTira), throwsStateError);
      c.act(1, iduki);
      expect(s().outcomes[BidPhase.grand]!.kind, OutcomeKind.accepted);
      expect(s().outcomes[BidPhase.grand]!.stake, 2);
      expect(s().tantto, [0, 0]); // pas de points avant le décompte
      expect(s().bidding!.phase, BidPhase.petit);
    });

    test('Nere gatik tira : le partenaire peut relancer', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);
      c.act(0, embido, amount: 2);
      c.act(3, nereGatikTira);
      c.act(1, gehiago, amount: 2); // total 4
      expect(s().bidding!.currentBid, 4);
      expect(s().currentPlayer, 0);
      c.act(0, tira);
      c.act(2, tira); // B marque la mise précédente (2)
      expect(s().tantto, [0, 2]);
    });

    test('mise acceptée : le gagnant empoche la mise au décompte', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);
      c.act(0, embido, amount: 2);
      c.act(3, iduki);
      allPaso(); // Petit
      allPaso(); // Point
      // Grand : A 2 (mise) ; Petit : B 1 ; Point : B 1.
      expect(s().phase, MusPhase.roundScoring);
      expect(s().tantto, [2, 2]);
    });

    test('Tira au Grand : 0 au décompte (déjà marqué en cours de jeu)', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);
      c.act(0, embido, amount: 2);
      c.act(3, tira);
      c.act(1, tira); // A +1
      allPaso(); // Petit : B +1
      allPaso(); // Point : B +1 (pontua)
      expect(s().tantto, [1, 2]);
    });
  });

  group('Paires et Jeu', () {
    test(
      'Paires : seuls les joueurs ayant des paires parlent ; bonus au décompte',
      () {
        final hands = table([
          [12, 7, 7, 1], // paire de 7 (A)
          [11, 5, 5, 5], // mediak (B)
          [10, 6, 4, 2],
          [6, 4, 3, 2],
        ]);
        c.startGame(hands: hands);
        c.chooseMus(0, MusChoice.mintza);
        allPaso(); // Grand
        allPaso(); // Petit
        expect(s().bidding!.phase, BidPhase.paires);
        expect(s().bidding!.participants, [0, 1]);
        expect(s().currentPlayer, 0);
        c.act(0, paso);
        expect(s().currentPlayer, 1);
        c.act(1, paso);
        // Point : aucune enchère de base sur Paso aux Paires
        expect(s().bidding!.phase, BidPhase.point);
        expect(s().tantto, [0, 0]);
        allPaso();
        // Grand A 1 ; Petit A 1 ; Paires : mediak B 2 ; Point : 25-25 → Esku (A) 1.
        expect(s().tantto, [3, 2]);
        expect(s().scoreLog.map((e) => '$e'), [
          'grand:team0+1(phase)',
          'petit:team0+1(phase)',
          'paires:team1+2(bonus)',
          'point:team0+1(pontua)',
        ]);
      },
    );

    test('une seule équipe a des paires : pas d\'enchère, bonus seul', () {
      final hands = table([
        [12, 7, 7, 1], // paire de 7 (A)
        [11, 6, 5, 1],
        [10, 6, 4, 2],
        [6, 4, 3, 2],
      ]);
      c.startGame(hands: hands);
      c.chooseMus(0, MusChoice.mintza);
      allPaso();
      allPaso();
      expect(s().outcomes[BidPhase.paires]!.kind, OutcomeKind.noBidding);
      expect(s().bidding!.phase, BidPhase.point);
      allPaso();
      // Grand A 1 ; Petit : [1,5,6,11] (siège 1) → B 1 ; Paires A 1 ;
      // Point : 25, 22, 22, 15 → A 1.
      expect(s().tantto, [3, 1]);
    });

    test(
      'Jeu (global) avec seulement les joueurs >= 31 ; 31 vaut 3 tantto',
      () {
        final hands = table([
          [12, 11, 10, 1], // 31
          [11, 10, 7, 5], // 32
          [7, 6, 4, 2],
          [6, 5, 3, 2],
        ]);
        c.startGame(hands: hands);
        c.chooseMus(0, MusChoice.mintza);
        allPaso();
        allPaso();
        expect(s().bidding!.phase, BidPhase.jeu);
        expect(s().bidding!.participants, [0, 1]);
        allPaso();
        expect(s().phase, MusPhase.roundScoring);
        expect(s().outcomes.containsKey(BidPhase.point), isFalse);
        // Grand A 1 ; Petit A 1 ; Jeu : 31 bat 32 → A 3 (aucun point de base).
        expect(s().tantto, [5, 0]);
      },
    );

    test('Jeu : une seule équipe concernée → bonus 2 pour un 33-40', () {
      final hands = table([
        [12, 11, 10, 3], // 33
        [7, 6, 4, 2],
        [6, 5, 3, 2],
        [7, 5, 4, 1],
      ]);
      c.startGame(hands: hands);
      c.chooseMus(0, MusChoice.mintza);
      allPaso();
      allPaso();
      expect(s().outcomes[BidPhase.jeu]!.kind, OutcomeKind.noBidding);
      expect(s().phase, MusPhase.roundScoring);
      // Grand A 1 ; Petit : [1,4,5,7] (siège 3) → B 1 ; Jeu : bonus 2 pour A.
      expect(s().tantto, [3, 1]);
    });
  });

  group('Limite des 40 points', () {
    test(
      'Tira à 39 tantto : la manche bascule immédiatement, sans décompte',
      () {
        c.startGame(hands: basicHands);
        c.chooseMus(0, MusChoice.mintza);
        // ignore: invalid_use_of_protected_member
        c.state = s().copyWith(tantto: [39, 0]);

        c.act(0, embido, amount: 2);
        c.act(3, tira);
        c.act(1, tira); // premier Embido refusé → +1 pour A → 40

        expect(s().phase, MusPhase.roundScoring);
        expect(s().mancheWinner, 0);
        expect(s().tantto, [40, 0]);
        expect(s().manches, [1, 0]);
        expect(s().bidding, isNull);
        // Ni Petit, ni décompte : seule la sous-phase refusée est enregistrée.
        expect(s().outcomes.keys, [BidPhase.grand]);
        expect(s().scoreLog.map((e) => '$e'), ['grand:team0+1(tira)']);
      },
    );

    test('les points de Tira sont plafonnés à 40', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);
      // ignore: invalid_use_of_protected_member
      c.state = s().copyWith(tantto: [0, 39]);

      c.act(0, embido, amount: 2);
      c.act(3, gehiago, amount: 1); // total 3
      c.act(0, tira);
      c.act(2, tira); // B marque la mise précédente (2) → plafonné à 40

      expect(s().mancheWinner, 1);
      expect(s().tantto, [0, 40]);
      expect(s().manches, [0, 1]);
      expect(s().phase, MusPhase.roundScoring);
    });

    test('à 38 tantto, un Tira de 1 point ne termine pas la manche', () {
      c.startGame(hands: basicHands);
      c.chooseMus(0, MusChoice.mintza);
      // ignore: invalid_use_of_protected_member
      c.state = s().copyWith(tantto: [38, 0]);
      c.act(0, embido, amount: 2);
      c.act(3, tira);
      c.act(1, tira);
      expect(s().tantto, [39, 0]);
      expect(s().mancheWinner, isNull);
      expect(s().phase, MusPhase.bidding);
    });
  });

  group('Garde-fous', () {
    test('action hors tour ou hors phase', () {
      c.startGame(hands: basicHands);
      expect(() => c.chooseMus(1, MusChoice.mus), throwsStateError);
      expect(() => c.act(0, paso), throwsStateError);
      c.chooseMus(0, MusChoice.mintza);
      expect(() => c.act(1, paso), throwsStateError);
      expect(() => c.act(0, iduki), throwsStateError);
      expect(() => c.act(0, embido, amount: 1), throwsArgumentError);
    });

    test(
      'Sécurités RangeError : défausses répétées vidant le talon sans crash',
      () {
        c.startGame(hands: basicHands, talon: []);
        // Talon initialement vide : les défausses sont remélangées sans lever d'exception RangeError
        for (final seat in [0, 2, 3, 1]) {
          c.chooseMus(seat, MusChoice.mus);
        }
        c.discard(0, [0, 1]);
        c.discard(3, [0]);
        c.discard(2, [0, 1]);
        c.discard(1, [0]);
        expect(s().phase, MusPhase.musDecision);
        expect(s().hands.every((h) => h.length == 4), isTrue);

        // Deuxième tour de Mus immédiat
        for (final seat in [0, 2, 3, 1]) {
          c.chooseMus(seat, MusChoice.mus);
        }
        c.discard(0, [0, 1, 2, 3]);
        c.discard(3, [0, 1, 2, 3]);
        c.discard(2, [0, 1, 2, 3]);
        c.discard(1, [0, 1, 2, 3]);
        expect(s().phase, MusPhase.musDecision);
        expect(s().hands.every((h) => h.length == 4), isTrue);
      },
    );

    test('Visibilité Paires asymétriques avec délai', () async {
      final hands = table([
        [12, 7, 7, 1], // paire pour le joueur 0 (Équipe A)
        [11, 6, 5, 1], // pas de paire
        [10, 6, 4, 2], // pas de paire
        [6, 4, 3, 2], // pas de paire
      ]);
      final timedContainer = ProviderContainer(
        overrides: [
          musRandomProvider.overrideWithValue(Random(42)),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
          musEmptyPhaseDelayProvider.overrideWithValue(
            const Duration(milliseconds: 100),
          ),
          musBidResolutionDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(timedContainer.dispose);
      final tc = timedContainer.read(musGameControllerProvider.notifier);
      MusGameState ts() => timedContainer.read(musGameControllerProvider);

      tc.startGame(hands: hands);
      tc.chooseMus(0, MusChoice.mintza);
      // Grand allPaso
      for (final seat in [0, 3, 2, 1]) {
        tc.act(seat, paso);
      }
      // Petit allPaso
      for (final seat in [0, 3, 2, 1]) {
        tc.act(seat, paso);
      }

      // La phase Pareak doit être affichée (pas sautée instantanément)
      expect(ts().bidding!.phase, BidPhase.paires);
      final fb = timedContainer.read(musTableFeedbackProvider);
      expect(fb.announcement, TableAnnouncement.onlyOneTeamHasPairs);
      expect(fb.speeches[0]?.text, 'Bai');
      expect(fb.speeches[1]?.text, 'Ez');
      expect(fb.speeches[2]?.text, 'Ez');
      expect(fb.speeches[3]?.text, 'Ez');

      // Après expiration du délai, la phase Pareak est validée sans enchère
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(ts().outcomes[BidPhase.paires]!.kind, OutcomeKind.noBidding);
      // Puis on avance vers la sous-phase suivante (Jeu)
      expect(ts().bidding!.phase, BidPhase.jeu);
    });

    test(
      'Délai de résolution des enchères (visibilité Tira/Iduki/allPaso)',
      () async {
        final timedContainer = ProviderContainer(
          overrides: [
            musRandomProvider.overrideWithValue(Random(42)),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
            musBidResolutionDelayProvider.overrideWithValue(
              const Duration(milliseconds: 100),
            ),
          ],
        );
        addTearDown(timedContainer.dispose);
        final tc = timedContainer.read(musGameControllerProvider.notifier);
        MusGameState ts() => timedContainer.read(musGameControllerProvider);

        tc.startGame();
        tc.chooseMus(0, MusChoice.mintza);

        // Joueur 0 mise Embido 2, Joueur 3 dit Tira
        tc.act(0, BidActionType.embido, amount: 2);
        tc.act(3, BidActionType.tira);
        expect(ts().currentPlayer, 1);
        tc.act(1, BidActionType.tira);

        // Immédiatement après Tira : délai actif, tour bloqué (currentPlayer == -1)
        expect(ts().currentPlayer, -1);
        final fb = timedContainer.read(musTableFeedbackProvider);
        expect(fb.speeches[3]?.action, BidActionType.nereGatikTira);
        expect(fb.speeches[1]?.action, BidActionType.tira);

        // Après expiration du délai de 100 ms, l'enchère est clôturée et on passe à Petit
        await Future<void>.delayed(const Duration(milliseconds: 150));
        expect(ts().bidding!.phase, BidPhase.petit);
        expect(ts().currentPlayer, isNot(-1));
      },
    );

    test('Annonces Bai et Ez au démarrage de Pareak avec 2 équipes', () async {
      final hands = table([
        [12, 12, 7, 1], // paire Joueur 0 (Équipe A)
        [11, 11, 5, 1], // paire Joueur 1 (Équipe B)
        [10, 6, 4, 2], // pas de paire
        [6, 4, 3, 2], // pas de paire
      ]);
      final timedContainer = ProviderContainer(
        overrides: [
          musRandomProvider.overrideWithValue(Random(42)),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
          musEmptyPhaseDelayProvider.overrideWithValue(
            const Duration(milliseconds: 100),
          ),
          musBidResolutionDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(timedContainer.dispose);
      final tc = timedContainer.read(musGameControllerProvider.notifier);
      MusGameState ts() => timedContainer.read(musGameControllerProvider);

      tc.startGame(hands: hands);
      tc.chooseMus(0, MusChoice.mintza);
      // Passer Grand et Petit
      for (final seat in [0, 3, 2, 1]) {
        tc.act(seat, paso);
      }
      for (final seat in [0, 3, 2, 1]) {
        tc.act(seat, paso);
      }

      // Au début de Pareak, les 4 joueurs annoncent Bai / Ez
      expect(ts().bidding!.phase, BidPhase.paires);
      final fb = timedContainer.read(musTableFeedbackProvider);
      expect(fb.speeches[0]?.text, 'Bai');
      expect(fb.speeches[1]?.text, 'Bai');
      expect(fb.speeches[2]?.text, 'Ez');
      expect(fb.speeches[3]?.text, 'Ez');

      // Pendant les 100 ms d'annonce, les enchères sont bloquées (currentPlayer == -1)
      expect(ts().currentPlayer, -1);

      // Après 100 ms, le premier enchérisseur (Joueur 0) prend la main
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(ts().currentPlayer, 0);
    });
  });
}
