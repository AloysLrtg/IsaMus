import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_controller.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/engine/mus_sign.dart';
import 'package:isamus/core/engine/mus_table_feedback.dart';
import 'package:isamus/core/models/card.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/main.dart';

class _FakeSupabaseRepository implements SupabaseRepository {
  final List<Map<String, dynamic>> pushedStates = [];
  final StreamController<Map<String, dynamic>> streamController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> updateGameState(
    String gameId,
    Map<String, dynamic> gameState,
  ) async {
    pushedStates.add(gameState);
  }

  @override
  Stream<Map<String, dynamic>> streamGame(String gameId) {
    return streamController.stream;
  }
}

void main() {
  group('1. Sérialisation JSON des Modèles et États de Jeu', () {
    test('Card serialization round-trip', () {
      final card = Card(12, Suit.oros);
      final json = card.toJson();
      expect(json, {'value': 12, 'suit': 'oros'});

      final fromJson = Card.fromJson(json);
      expect(fromJson, card);
      expect(fromJson.value, 12);
      expect(fromJson.suit, Suit.oros);
    });

    test('BidAction serialization round-trip', () {
      final action = const BidAction(1, BidActionType.embido, 2);
      final json = action.toJson();
      expect(json, {'player': 1, 'type': 'embido', 'amount': 2});

      final reconstructed = BidAction.fromJson(json);
      expect(reconstructed.player, 1);
      expect(reconstructed.type, BidActionType.embido);
      expect(reconstructed.amount, 2);
    });

    test('BiddingState serialization round-trip', () {
      final bidding = const BiddingState(
        phase: BidPhase.grand,
        participants: [0, 1, 2, 3],
        stage: BidStage.responding,
        openingIndex: 0,
        currentBid: 4,
        previousBid: 2,
        isHordago: false,
        bidderTeam: 1,
        responders: [0, 2],
        responderIndex: 1,
        partnerDecides: false,
      );

      final json = bidding.toJson();
      final reconstructed = BiddingState.fromJson(json);

      expect(reconstructed.phase, BidPhase.grand);
      expect(reconstructed.participants, [0, 1, 2, 3]);
      expect(reconstructed.stage, BidStage.responding);
      expect(reconstructed.currentBid, 4);
      expect(reconstructed.amount, 4);
      expect(reconstructed.previousBid, 2);
      expect(reconstructed.isHordago, false);
      expect(reconstructed.bidderTeam, 1);
      expect(reconstructed.responders, [0, 2]);
      expect(reconstructed.responderIndex, 1);
      expect(reconstructed.currentPlayer, 2);
    });

    test('PhaseOutcome and ScoreEvent serialization round-trip', () {
      final outcome = const PhaseOutcome(
        phase: BidPhase.petit,
        kind: OutcomeKind.accepted,
        participants: [0, 1, 2, 3],
        stake: 2,
        tiraTeam: null,
        tiraPoints: 0,
      );
      final outcomeJson = outcome.toJson();
      final reconstructedOutcome = PhaseOutcome.fromJson(outcomeJson);
      expect(reconstructedOutcome.phase, BidPhase.petit);
      expect(reconstructedOutcome.kind, OutcomeKind.accepted);
      expect(reconstructedOutcome.participants, [0, 1, 2, 3]);
      expect(reconstructedOutcome.stake, 2);

      final event = const ScoreEvent(
        BidPhase.petit,
        1,
        2,
        'Ttipia gagné par Equipe B',
      );
      final eventJson = event.toJson();
      final reconstructedEvent = ScoreEvent.fromJson(eventJson);
      expect(reconstructedEvent.phase, BidPhase.petit);
      expect(reconstructedEvent.team, 1);
      expect(reconstructedEvent.points, 2);
      expect(reconstructedEvent.reason, 'Ttipia gagné par Equipe B');
    });

    test('MusGameState complete serialization round-trip', () {
      final List<List<Card>> hands = [
        [
          Card(12, Suit.oros),
          Card(1, Suit.copas),
          Card(7, Suit.espadas),
          Card(6, Suit.bastos),
        ],
        [
          Card(11, Suit.oros),
          Card(2, Suit.copas),
          Card(5, Suit.espadas),
          Card(4, Suit.bastos),
        ],
        [
          Card(10, Suit.oros),
          Card(3, Suit.copas),
          Card(7, Suit.espadas),
          Card(1, Suit.bastos),
        ],
        [
          Card(1, Suit.oros),
          Card(1, Suit.copas),
          Card(1, Suit.espadas),
          Card(12, Suit.bastos),
        ],
      ];

      final state = MusGameState(
        version: 3,
        phase: MusPhase.bidding,
        signs: const {0: MusSign.twoKings, 2: MusSign.mediak},
        eskuIndex: 1,
        hands: hands,
        talon: [Card(3, Suit.oros), Card(4, Suit.oros)],
        discardPile: [Card(5, Suit.copas)],
        musVotes: const [MusChoice.mus, MusChoice.mus],
        currentPlayer: 2,
        deckLocked: true,
        discardSelections: const {
          0: [0, 2],
          1: [1],
        },
        bidding: const BiddingState(
          phase: BidPhase.grand,
          participants: [0, 1, 2, 3],
          stage: BidStage.responding,
          openingIndex: 0,
          currentBid: 2,
          previousBid: 0,
          isHordago: false,
          bidderTeam: 0,
          responders: [1, 3],
          responderIndex: 0,
        ),
        bidHistory: const {
          BidPhase.grand: [BidAction(0, BidActionType.embido, 2)],
        },
        outcomes: const {
          BidPhase.petit: PhaseOutcome(
            phase: BidPhase.petit,
            kind: OutcomeKind.accepted,
            participants: [0, 1, 2, 3],
            stake: 2,
          ),
        },
        scoreLog: const [
          ScoreEvent(BidPhase.petit, 0, 2, 'Petit gagné par Equipe A'),
        ],
        tantto: const [14, 18],
        manches: const [1, 0],
        mancheWinner: null,
        lastActionSeat: 2,
      );

      final json = state.toJson(lastActionSeat: 2);
      expect(json['version'], 3);
      expect(json['lastActionSeat'], 2);
      expect(json['phase'], 'bidding');
      expect(json['tantto'], [14, 18]);
      expect(json['manches'], [1, 0]);
      expect(json['eskuIndex'], 1);
      expect(json['currentPlayer'], 2);

      final reconstructed = MusGameState.fromJson(json);

      expect(reconstructed.version, 3);
      expect(reconstructed.lastActionSeat, 2);
      expect(reconstructed.phase, MusPhase.bidding);
      expect(reconstructed.tantto, [14, 18]);
      expect(reconstructed.manches, [1, 0]);
      expect(reconstructed.eskuIndex, 1);
      expect(reconstructed.currentPlayer, 2);
      expect(reconstructed.deckLocked, true);
      expect(reconstructed.talon.length, 2);
      expect(reconstructed.discardPile.length, 1);
      expect(reconstructed.musVotes, [MusChoice.mus, MusChoice.mus]);

      // Hands
      expect(reconstructed.hands.length, 4);
      expect(reconstructed.hands[0][0], Card(12, Suit.oros));
      expect(reconstructed.hands[3][3], Card(12, Suit.bastos));

      // Discard selections
      expect(reconstructed.discardSelections[0], [0, 2]);
      expect(reconstructed.discardSelections[1], [1]);

      // Bidding
      expect(reconstructed.bidding, isNotNull);
      expect(reconstructed.bidding!.currentBid, 2);
      expect(reconstructed.bidding!.amount, 2);
      expect(reconstructed.bidding!.phase, BidPhase.grand);
      expect(reconstructed.bidHistory[BidPhase.grand]?.length, 1);

      // Outcomes & scoreLog
      expect(reconstructed.outcomes.containsKey(BidPhase.petit), isTrue);
      expect(reconstructed.scoreLog.length, 1);
      expect(reconstructed.scoreLog[0].points, 2);
      expect(reconstructed.scoreLog[0].reason, 'Petit gagné par Equipe A');

      // Active signs
      expect(json.containsKey('signs'), isFalse);
      expect(reconstructed.signs, isEmpty);
    });
  });

  group('2. Rôle du Maître du Jeu (Hôte vs Clients)', () {
    test('Hôte (seat 0) génère la donne initiale et pousse vers Supabase', () {
      final fakeRepo = _FakeSupabaseRepository();
      final container = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          musRandomProvider.overrideWithValue(Random(10)),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(musGameControllerProvider.notifier);
      controller.configureMultiplayer(
        gameId: 'game-room-1',
        localSeat: 0,
        repository: fakeRepo,
      );

      expect(container.read(musGameControllerProvider).phase, MusPhase.dealing);
      expect(fakeRepo.pushedStates.isEmpty, isTrue);

      // L'hôte distribue
      controller.startGame();

      final state = container.read(musGameControllerProvider);
      expect(state.phase, MusPhase.musDecision);
      expect(state.hands.every((h) => h.length == 4), isTrue);

      // Un push a été effectué sur Supabase
      expect(fakeRepo.pushedStates.length, 1);
      final pushed = fakeRepo.pushedStates.first;
      expect(pushed['lastActionSeat'], 0);
      expect(pushed['phase'], 'musDecision');
    });

    test(
      'Client distant ne déclenche pas les timers de bot (réservé à l hôte)',
      () {
        final fakeRepo = _FakeSupabaseRepository();
        final container = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepo),
            // Bots activés mais localSeat = 1 (client distant)
            musBotsEnabledProvider.overrideWithValue(true),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
            musRandomProvider.overrideWithValue(Random(10)),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(musGameControllerProvider.notifier);
        controller.configureMultiplayer(
          gameId: 'game-room-2',
          localSeat: 1, // Non-hôte
          repository: fakeRepo,
        );

        // Si le client démarre localement ou synchronise
        controller.startGame();

        // Le bot ne doit pas avoir joué à la place du siège 0 ou 2 automatiquement
        // parce que localSeat != 0 désactive la planification des bots locaux
        expect(container.read(musGameControllerProvider).currentPlayer, 0);
      },
    );
  });

  group('3. Diffusion des Actions Locales vers Supabase', () {
    test('Action locale (Choix Mus) pousse l état avec lastActionSeat', () {
      final fakeRepo = _FakeSupabaseRepository();
      final container = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          musRandomProvider.overrideWithValue(Random(42)),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(musGameControllerProvider.notifier);
      controller.configureMultiplayer(
        gameId: 'game-room-broadcast',
        localSeat: 0,
        repository: fakeRepo,
      );

      controller.startGame();
      fakeRepo.pushedStates.clear();

      // Joueur local (siège 0) vote Mus
      controller.chooseMus(0, MusChoice.mus);

      expect(fakeRepo.pushedStates.length, 1);
      final lastPush = fakeRepo.pushedStates.last;
      expect(lastPush['lastActionSeat'], 0);
      expect(lastPush['musVotes'], ['mus']);
    });
  });

  group('4. Réception et Synchronisation Réseau (syncFromRemote)', () {
    test(
      'syncFromRemote met à jour l état local et affiche le feedback visuel',
      () {
        final fakeRepo = _FakeSupabaseRepository();
        final container = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepo),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(musGameControllerProvider.notifier);
        controller.configureMultiplayer(
          gameId: 'game-room-sync',
          localSeat: 1,
          repository: fakeRepo,
        );

        // Simulation d'un état reçu depuis l'hôte avec version > locale (1 > 0)
        final remoteState = MusGameState(
          version: 1,
          phase: MusPhase.bidding,
          signs: const {},
          eskuIndex: 0,
          hands: [
            [
              Card(12, Suit.oros),
              Card(1, Suit.copas),
              Card(7, Suit.espadas),
              Card(6, Suit.bastos),
            ],
            [
              Card(11, Suit.oros),
              Card(2, Suit.copas),
              Card(5, Suit.espadas),
              Card(4, Suit.bastos),
            ],
            [
              Card(10, Suit.oros),
              Card(3, Suit.copas),
              Card(7, Suit.espadas),
              Card(1, Suit.bastos),
            ],
            [
              Card(1, Suit.oros),
              Card(1, Suit.copas),
              Card(1, Suit.espadas),
              Card(12, Suit.bastos),
            ],
          ],
          talon: const [],
          discardPile: const [],
          musVotes: const [MusChoice.mintza],
          currentPlayer: 1,
          deckLocked: true,
          discardSelections: const {},
          bidding: const BiddingState(
            phase: BidPhase.grand,
            participants: [0, 1, 2, 3],
            stage: BidStage.responding,
            openingIndex: 0,
            currentBid: 2,
            previousBid: 0,
            isHordago: false,
            bidderTeam: 0,
            responders: [1, 3],
            responderIndex: 0,
          ),
          bidHistory: const {
            BidPhase.grand: [BidAction(0, BidActionType.embido, 2)],
          },
          outcomes: const {},
          scoreLog: const [],
          tantto: const [0, 0],
          manches: const [0, 0],
          mancheWinner: null,
          lastActionSeat: 0,
        );

        // Le client applique la mise à jour
        controller.syncFromRemote(remoteState);

        final local = container.read(musGameControllerProvider);
        expect(local.version, 1);
        expect(local.phase, MusPhase.bidding);
        expect(local.bidding?.phase, BidPhase.grand);
        expect(local.bidding?.amount, 2);
        expect(local.bidding?.bidderTeam, 0);

        // Vérification que le feedback visuel de l'enchère (bulle) a été déclenché
        final feedback = container.read(musTableFeedbackProvider);
        expect(feedback.speeches.containsKey(0), isTrue);
        expect(feedback.speeches[0]?.action, BidActionType.embido);
      },
    );

    test('Horloge logique : syncFromRemote rejette STRICTEMENT tout état avec version <= version locale', () {
      final fakeRepo = _FakeSupabaseRepository();
      final container = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(musGameControllerProvider.notifier);
      controller.configureMultiplayer(
        gameId: 'game-version-test',
        localSeat: 1,
        repository: fakeRepo,
      );

      // Initialiser un état local valide à version: 5
      final validState = MusGameState.initial().copyWith(
        version: 5,
        phase: MusPhase.bidding,
        currentPlayer: 1,
      );
      controller.syncFromRemote(validState);
      expect(container.read(musGameControllerProvider).version, 5);
      expect(container.read(musGameControllerProvider).phase, MusPhase.bidding);

      // 1. Arrivée d'un état réseau obsolète (version: 4 < 5)
      final staleState = validState.copyWith(
        version: 4,
        phase: MusPhase.musDecision, // Différente pour vérifier qu'elle n'est pas appliquée
      );
      controller.syncFromRemote(staleState);
      expect(container.read(musGameControllerProvider).version, 5);
      expect(container.read(musGameControllerProvider).phase, MusPhase.bidding);

      // 2. Arrivée d'un écho réseau identique (version: 5 == 5)
      final echoState = validState.copyWith(
        version: 5,
        phase: MusPhase.discarding,
      );
      controller.syncFromRemote(echoState);
      expect(container.read(musGameControllerProvider).version, 5);
      expect(container.read(musGameControllerProvider).phase, MusPhase.bidding);

      // 3. Arrivée d'un état plus récent (version: 6 > 5)
      final newerState = validState.copyWith(
        version: 6,
        phase: MusPhase.roundScoring,
      );
      controller.syncFromRemote(newerState);
      expect(container.read(musGameControllerProvider).version, 6);
      expect(
        container.read(musGameControllerProvider).phase,
        MusPhase.roundScoring,
      );
    });
  });

  group('5. Intégration GameScreen : Stream et Prévention des Boucles Réseau', () {
    testWidgets('Non-hôte en Dealing phase affiche l attente de l hôte', (
      tester,
    ) async {
      final fakeRepo = _FakeSupabaseRepository();
      final container = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(
            home: GameScreen(
              gameId: 'game-room-waiting',
              localSeat: 1, // Non-hôte
            ),
          ),
        ),
      );
      await tester.pump();

      // Non-hôte : pas de bouton Distribuer, mais indicateur d'attente
      expect(find.text("En attente de la donne de l'hôte..."), findsOneWidget);
      expect(find.text('Distribuer'), findsNothing);
    });

    testWidgets(
      'Réception Stream : ignore les échos locaux et intègre les actions adverses',
      (tester) async {
        final fakeRepo = _FakeSupabaseRepository();
        final container = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepo),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(
              home: GameScreen(gameId: 'game-room-stream-test', localSeat: 1),
            ),
          ),
        );
        await tester.pump();

        // 1. Écho local (lastActionSeat == localSeat == 1) -> DOIT ÊTRE IGNORÉ
        fakeRepo.streamController.add({
          'game_state': {
            'phase': 'musDecision',
            'eskuIndex': 0,
            'tantto': [4, 0],
            'manches': [0, 0],
            'currentPlayer': 1,
            'deckLocked': false,
            'musVotes': [],
            'hands': [[], [], [], []],
            'talon': [],
            'discardSelections': {},
            'discardPile': [],
            'bidHistory': {},
            'outcomes': {},
            'scoreLog': [],
            'signs': {},
            'lastActionSeat': 1, // Même siège que localSeat !
          },
        });
        await tester.pump();

        // La phase locale reste dealing car l'écho a été ignoré
        expect(
          container.read(musGameControllerProvider).phase,
          MusPhase.dealing,
        );

        // 2. Action venant de l'hôte (lastActionSeat == 0) -> DOIT ÊTRE APPLIQUÉE
        fakeRepo.streamController.add({
          'game_state': {
            'version': 1,
            'phase': 'musDecision',
            'eskuIndex': 0,
            'tantto': [0, 0],
            'manches': [0, 0],
            'currentPlayer': 0,
            'deckLocked': false,
            'musVotes': [],
            'hands': [
              [
                {'value': 12, 'suit': 'oros'},
                {'value': 1, 'suit': 'copas'},
                {'value': 7, 'suit': 'espadas'},
                {'value': 6, 'suit': 'bastos'},
              ],
              [
                {'value': 11, 'suit': 'oros'},
                {'value': 2, 'suit': 'copas'},
                {'value': 5, 'suit': 'espadas'},
                {'value': 4, 'suit': 'bastos'},
              ],
              [
                {'value': 10, 'suit': 'oros'},
                {'value': 3, 'suit': 'copas'},
                {'value': 7, 'suit': 'espadas'},
                {'value': 1, 'suit': 'bastos'},
              ],
              [
                {'value': 1, 'suit': 'oros'},
                {'value': 1, 'suit': 'copas'},
                {'value': 1, 'suit': 'espadas'},
                {'value': 12, 'suit': 'bastos'},
              ],
            ],
            'talon': [],
            'discardSelections': {},
            'discardPile': [],
            'bidHistory': {},
            'outcomes': {},
            'scoreLog': [],
            'signs': {},
            'lastActionSeat': 0, // Hôte
          },
        });
        await tester.pump();

        // L'état local est passé à musDecision avec les 4 mains synchronisées
        final updatedState = container.read(musGameControllerProvider);
        expect(updatedState.phase, MusPhase.musDecision);
        expect(updatedState.hands[1][0], Card(11, Suit.oros));
      },
    );
  });

  group('6. Robustesse Anti-Split-Brain & Enchère Gehiago', () {
    test('Aller-retour JSON strict d une enchère Gehiago : ne se transforme JAMAIS en Tira', () {
      // 1. Action individuelle Gehiago
      final gehiagoAction = const BidAction(1, BidActionType.gehiago, 3);
      final actionJson = gehiagoAction.toJson();

      expect(actionJson['type'], 'gehiago');
      expect(actionJson['amount'], 3);
      expect(actionJson['player'], 1);

      final reconstructedAction = BidAction.fromJson(actionJson);
      expect(reconstructedAction.type, BidActionType.gehiago);
      expect(reconstructedAction.type, isNot(BidActionType.tira));
      expect(reconstructedAction.amount, 3);
      expect(reconstructedAction.player, 1);

      // 2. État complet d'enchères avec Gehiago dans l'historique
      final bidding = const BiddingState(
        phase: BidPhase.grand,
        participants: [0, 1, 2, 3],
        stage: BidStage.responding,
        openingIndex: 0,
        currentBid: 5,
        previousBid: 2,
        isHordago: false,
        bidderTeam: 1,
        responders: [0, 2],
        responderIndex: 0,
        partnerDecides: false,
      );

      final fullState = MusGameState(
        phase: MusPhase.bidding,
        signs: const {},
        eskuIndex: 0,
        hands: [
          [
            Card(12, Suit.oros),
            Card(1, Suit.copas),
            Card(7, Suit.espadas),
            Card(6, Suit.bastos),
          ],
          [
            Card(11, Suit.oros),
            Card(2, Suit.copas),
            Card(5, Suit.espadas),
            Card(4, Suit.bastos),
          ],
          [
            Card(10, Suit.oros),
            Card(3, Suit.copas),
            Card(7, Suit.espadas),
            Card(1, Suit.bastos),
          ],
          [
            Card(1, Suit.oros),
            Card(1, Suit.copas),
            Card(1, Suit.espadas),
            Card(12, Suit.bastos),
          ],
        ],
        talon: const [],
        discardPile: const [],
        musVotes: const [MusChoice.mintza],
        currentPlayer: 0,
        deckLocked: true,
        discardSelections: const {},
        bidding: bidding,
        bidHistory: const {
          BidPhase.grand: [
            BidAction(0, BidActionType.embido, 2),
            BidAction(1, BidActionType.gehiago, 3), // Relance de 3 tantto
          ],
        },
        outcomes: const {},
        scoreLog: const [],
        tantto: const [0, 0],
        manches: const [0, 0],
        mancheWinner: null,
        lastActionSeat: 1,
        players: const [
          MusPlayer(seat: 0, name: 'Hôte', isHost: true, isBot: false),
          MusPlayer(seat: 1, name: 'Humain 2', isHost: false, isBot: false),
          MusPlayer(seat: 2, name: 'Humain 3', isHost: false, isBot: false),
          MusPlayer(seat: 3, name: 'Humain 4', isHost: false, isBot: false),
        ],
      );

      final stateJson = fullState.toJson();
      final reconstructedState = MusGameState.fromJson(stateJson);

      // Vérification stricte que l'action est restée 'gehiago' et n'a pas dérivé en 'tira'
      final actions = reconstructedState.bidHistory[BidPhase.grand]!;
      expect(actions.length, 2);
      expect(actions[0].type, BidActionType.embido);
      expect(actions[1].type, BidActionType.gehiago);
      expect(actions[1].type, isNot(BidActionType.tira));
      expect(actions[1].amount, 3);
      expect(reconstructedState.bidding!.currentBid, 5);
      expect(reconstructedState.bidding!.previousBid, 2);
      expect(reconstructedState.bidding!.stage, BidStage.responding);
    });

    testWidgets(
      'Multijoueur : L hôte accorde 3s de grâce puis force Tira au fallback de 13s',
      (tester) async {
        final fakeRepo = _FakeSupabaseRepository();
        final container = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepo),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(
              const Duration(seconds: 10),
            ),
            musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        try {
          final controller = container.read(musGameControllerProvider.notifier);
          // Configuration d'une table avec 4 humains distants
          controller.configureMultiplayer(
            gameId: 'game-anti-tira-test',
            localSeat: 0, // Hôte
            repository: fakeRepo,
            players: [
              {'seat': 0, 'name': 'Hôte', 'is_host': true, 'is_bot': false},
              {
                'seat': 1,
                'name': 'Adversaire',
                'is_host': false,
                'is_bot': false,
              },
              {
                'seat': 2,
                'name': 'Partenaire',
                'is_host': false,
                'is_bot': false,
              },
              {
                'seat': 3,
                'name': 'Adversaire 2',
                'is_host': false,
                'is_bot': false,
              },
            ],
          );

          // Démarrage et passage en enchère
          controller.startGame();
          controller.chooseMus(0, MusChoice.mintza);

          // L'hôte mise Embido (2 tantto)
          controller.act(0, BidActionType.embido, amount: 2);
          fakeRepo.pushedStates.clear();

          final stateAfterEmbido = container.read(musGameControllerProvider);
          expect(
            stateAfterEmbido.currentPlayer,
            3,
          ); // C'est au tour du joueur distant (siège 3)

          // Le temps s'écoule jusqu'à 11 secondes (au-delà du timeout local de 10s du client, mais avant les 13s de fallback)
          await tester.pump(const Duration(seconds: 11));

          // L'hôte n'a pas encore forcé d'action (grâce réseau en cours)
          final stateAt11s = container.read(musGameControllerProvider);
          expect(stateAt11s.currentPlayer, 3);
          expect(fakeRepo.pushedStates.isEmpty, isTrue);

          // À 13 secondes (11s + 2s), le timer de fallback de l'hôte expire et force Tira
          await tester.pump(const Duration(seconds: 2));

          final stateAfterFallback = container.read(musGameControllerProvider);
          final lastAction =
              stateAfterFallback.bidHistory[BidPhase.grand]!.last;
          expect(lastAction.type, BidActionType.nereGatikTira);
          expect(lastAction.player, 3);
          // L'action forcée a été poussée vers Supabase
          expect(fakeRepo.pushedStates.isNotEmpty, isTrue);
          expect(fakeRepo.pushedStates.first['lastActionSeat'], 3);
        } finally {
          container.dispose();
          await tester.pump();
        }
      },
    );

    test('Atomicité de syncFromRemote : écrasement pur sans réémission réseau parasite', () {
      final fakeRepo = _FakeSupabaseRepository();
      final container = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(musGameControllerProvider.notifier);
      controller.configureMultiplayer(
        gameId: 'game-atomic-sync',
        localSeat: 1, // Client distant
        repository: fakeRepo,
      );

      // État entrant représentant une relance Gehiago de l'adversaire (version 1 > version 0 locale)
      final incomingState = MusGameState(
        version: 1,
        phase: MusPhase.bidding,
        signs: const {},
        eskuIndex: 0,
        hands: [
          [
            Card(12, Suit.oros),
            Card(1, Suit.copas),
            Card(7, Suit.espadas),
            Card(6, Suit.bastos),
          ],
          [
            Card(11, Suit.oros),
            Card(2, Suit.copas),
            Card(5, Suit.espadas),
            Card(4, Suit.bastos),
          ],
          [
            Card(10, Suit.oros),
            Card(3, Suit.copas),
            Card(7, Suit.espadas),
            Card(1, Suit.bastos),
          ],
          [
            Card(1, Suit.oros),
            Card(1, Suit.copas),
            Card(1, Suit.espadas),
            Card(12, Suit.bastos),
          ],
        ],
        talon: const [],
        discardPile: const [],
        musVotes: const [MusChoice.mintza],
        currentPlayer: 1,
        deckLocked: true,
        discardSelections: const {},
        bidding: const BiddingState(
          phase: BidPhase.grand,
          participants: [0, 1, 2, 3],
          stage: BidStage.responding,
          openingIndex: 0,
          currentBid: 5,
          previousBid: 2,
          isHordago: false,
          bidderTeam: 0,
          responders: [1, 3],
          responderIndex: 0,
          partnerDecides: false,
        ),
        bidHistory: const {
          BidPhase.grand: [
            BidAction(0, BidActionType.embido, 2),
            BidAction(0, BidActionType.gehiago, 3),
          ],
        },
        outcomes: const {},
        scoreLog: const [],
        tantto: const [0, 0],
        manches: const [0, 0],
        mancheWinner: null,
        lastActionSeat: 0,
      );

      fakeRepo.pushedStates.clear();
      // Application via syncFromRemote
      controller.syncFromRemote(incomingState);

      // Vérification de l'atomicité : aucun appel à updateGameState ne doit avoir été généré en retour
      expect(fakeRepo.pushedStates.isEmpty, isTrue);

      // Vérification que le dernier coup enregistré est bien 'gehiago'
      final localState = container.read(musGameControllerProvider);
      final lastAction = localState.bidHistory[BidPhase.grand]!.last;
      expect(lastAction.type, BidActionType.gehiago);
      expect(lastAction.type, isNot(BidActionType.tira));
      expect(lastAction.amount, 3);
      expect(localState.bidding!.currentBid, 5);
    });

    test('Horloge logique : _pushStateToSupabase incrémente systématiquement state.version', () {
      final fakeRepo = _FakeSupabaseRepository();
      final container = ProviderContainer(
        overrides: [
          supabaseRepositoryProvider.overrideWithValue(fakeRepo),
          musBotsEnabledProvider.overrideWithValue(false),
          musTurnTimeoutProvider.overrideWithValue(null),
          musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(musGameControllerProvider.notifier);
      controller.configureMultiplayer(
        gameId: 'game-version-inc',
        localSeat: 0,
        repository: fakeRepo,
      );

      expect(container.read(musGameControllerProvider).version, 0);

      // startGame par l'hôte pousse l'état initial
      controller.startGame();
      expect(fakeRepo.pushedStates.isNotEmpty, isTrue);
      expect(container.read(musGameControllerProvider).version, 1);
      expect(fakeRepo.pushedStates.last['version'], 1);

      // Choix de Mus
      controller.chooseMus(0, MusChoice.mus);
      expect(container.read(musGameControllerProvider).version, 2);
      expect(fakeRepo.pushedStates.last['version'], 2);
    });

    testWidgets(
      'Centralisation : premier refus invité transmis au partenaire puis clôture par l’hôte après confirmation',
      (tester) async {
        final fakeRepoHost = _FakeSupabaseRepository();
        final fakeRepoGuest = _FakeSupabaseRepository();

        // Conteneur Hôte (Siège 0)
        final hostContainer = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepoHost),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(
              const Duration(milliseconds: 500),
            ),
          ],
        );
        addTearDown(hostContainer.dispose);
        final hostController = hostContainer.read(
          musGameControllerProvider.notifier,
        );
        hostController.configureMultiplayer(
          gameId: 'game-tira-privilege',
          localSeat: 0,
          repository: fakeRepoHost,
          players: [
            {'seat': 0, 'name': 'Hôte', 'is_host': true, 'is_bot': false},
            {'seat': 1, 'name': 'Guest1', 'is_host': false, 'is_bot': false},
            {'seat': 2, 'name': 'Partner', 'is_host': false, 'is_bot': false},
            {'seat': 3, 'name': 'Guest3', 'is_host': false, 'is_bot': false},
          ],
        );

        // Conteneur Invité (Siège 3 - adversaire qui répond en premier à l'Esku 0)
        final guestContainer = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepoGuest),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(
              const Duration(milliseconds: 500),
            ),
          ],
        );
        addTearDown(guestContainer.dispose);
        final guestController = guestContainer.read(
          musGameControllerProvider.notifier,
        );
        guestController.configureMultiplayer(
          gameId: 'game-tira-privilege',
          localSeat: 3,
          repository: fakeRepoGuest,
          players: [
            {'seat': 0, 'name': 'Hôte', 'is_host': true, 'is_bot': false},
            {'seat': 1, 'name': 'Guest1', 'is_host': false, 'is_bot': false},
            {'seat': 2, 'name': 'Partner', 'is_host': false, 'is_bot': false},
            {'seat': 3, 'name': 'Guest3', 'is_host': false, 'is_bot': false},
          ],
        );

        // 1. Démarrage de la partie par l'hôte
        final hands = [
          [
            Card(12, Suit.oros),
            Card(12, Suit.copas),
            Card(7, Suit.espadas),
            Card(6, Suit.bastos),
          ],
          [
            Card(11, Suit.oros),
            Card(2, Suit.copas),
            Card(5, Suit.espadas),
            Card(4, Suit.bastos),
          ],
          [
            Card(10, Suit.oros),
            Card(3, Suit.copas),
            Card(7, Suit.espadas),
            Card(1, Suit.bastos),
          ],
          [
            Card(1, Suit.oros),
            Card(1, Suit.copas),
            Card(1, Suit.espadas),
            Card(12, Suit.bastos),
          ],
        ];
        hostController.startGame(hands: hands);
        // Synchronisation de l'invité avec la donne de l'hôte
        guestController.syncFromRemote(
          hostContainer.read(musGameControllerProvider),
        );

        // Les deux passent en phase d'enchères Grand
        hostController.chooseMus(0, MusChoice.mintza);
        guestController.syncFromRemote(
          hostContainer.read(musGameControllerProvider),
        );

        // L'hôte (siège 0) mise Embido 2 tantto
        hostController.act(0, BidActionType.embido, amount: 2);
        final stateAfterEmbido = hostContainer.read(musGameControllerProvider);
        expect(stateAfterEmbido.currentPlayer, 3);

        // L'invité synchronise l'embido
        guestController.syncFromRemote(stateAfterEmbido);
        expect(guestContainer.read(musGameControllerProvider).currentPlayer, 3);

        fakeRepoGuest.pushedStates.clear();
        fakeRepoHost.pushedStates.clear();

        // 2. L'invité (siège 3) clique sur "Tira" !
        guestController.act(3, BidActionType.tira);

        // Vérifications côté Invité :
        final guestStateAfterTira = guestContainer.read(
          musGameControllerProvider,
        );
        // a) L'état intermédiaire montre bien Tira dans l'historique
        expect(
          guestStateAfterTira.bidHistory[BidPhase.grand]!.last.type,
          BidActionType.nereGatikTira,
        );
        // b) Le joueur courant est mis à -1 (en attente)
        expect(guestStateAfterTira.currentPlayer, 1);
        // c) L'invité reste STRICTEMENT en phase Grand (il n'a pas avancé à Petit)
        expect(guestStateAfterTira.bidding?.phase, BidPhase.grand);
        expect(guestStateAfterTira.tantto, [
          0,
          0,
        ]); // L'invité n'attribue pas les points lui-même
        // d) L'état intermédiaire a bien été poussé vers le réseau avec version incrémentée
        expect(fakeRepoGuest.pushedStates.length, 1);
        final pushedTiraState = fakeRepoGuest.pushedStates.first;
        expect(pushedTiraState['lastActionSeat'], 3);
        expect(pushedTiraState['bidding']['phase'], 'grand');

        // Le temps s'écoule côté invité (1 seconde) : l'invité ne doit TOUJOURS PAS avoir avancé de phase !
        await tester.pump(const Duration(seconds: 1));
        final guestStateStillWaiting = guestContainer.read(
          musGameControllerProvider,
        );
        expect(guestStateStillWaiting.bidding?.phase, BidPhase.grand);
        expect(guestStateStillWaiting.tantto, [0, 0]);

        // 3. L'hôte reçoit l'état Tira de l'invité
        hostController.syncFromRemote(MusGameState.fromJson(pushedTiraState));
        final hostStateAfterSync = hostContainer.read(
          musGameControllerProvider,
        );
        expect(
          hostStateAfterSync.bidHistory[BidPhase.grand]!.last.type,
          BidActionType.nereGatikTira,
        );
        expect(hostStateAfterSync.currentPlayer, 1);

        // Vérification du feedback visuel de l'hôte (la bulle Tira est visible)
        final hostFeedback = hostContainer.read(musTableFeedbackProvider);
        expect(hostFeedback.speeches[3]?.action, BidActionType.nereGatikTira);

        await tester.pump(const Duration(milliseconds: 600));
        expect(
          hostContainer.read(musGameControllerProvider).bidding!.phase,
          BidPhase.grand,
        );
        expect(hostContainer.read(musGameControllerProvider).tantto, [0, 0]);
        // Le refus du partenaire est nécessaire avant que l’hôte clôture.
        hostController.act(1, BidActionType.tira);
        // 4. L'hôte exécute son timer exclusif de transition (500ms)
        await tester.pump(const Duration(milliseconds: 600));

        // L'hôte a résolu le Tira, attribué 1 tantto à l'Équipe A (hôte), et avancé à Petit !
        final hostFinalState = hostContainer.read(musGameControllerProvider);
        expect(hostFinalState.tantto[0], 1); // Points de Tira attribués
        expect(
          hostFinalState.bidding?.phase,
          BidPhase.petit,
        ); // Passage à la phase suivante
        expect(
          fakeRepoHost.pushedStates.isNotEmpty,
          isTrue,
        ); // L'hôte a poussé la nouvelle phase

        // 5. L'invité reçoit le nouvel état officiel de l'hôte
        final hostPushedUpdate = fakeRepoHost.pushedStates.last;
        guestController.syncFromRemote(MusGameState.fromJson(hostPushedUpdate));

        final guestSynchronizedFinal = guestContainer.read(
          musGameControllerProvider,
        );
        expect(guestSynchronizedFinal.tantto[0], 1);
        expect(guestSynchronizedFinal.bidding?.phase, BidPhase.petit);
        // Les deux clients sont parfaitement synchronisés en phase Petit avec les scores exacts !

        // Écoulement du délai des bulles de parole pour libérer les timers de test
        await tester.pump(const Duration(seconds: 3));
      },
    );
  });

  group('8. Transition automatique "Donne suivante" (Auto-Next Hand)', () {
    testWidgets(
      'L\'hôte en roundScoring arme un timer de 8s, appelle nextHand et pousse à Supabase',
      (tester) async {
        final fakeRepo = _FakeSupabaseRepository();
        final container = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepo),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(musGameControllerProvider.notifier);
        controller.configureMultiplayer(
          gameId: 'game-auto-next-host',
          localSeat: 0,
          repository: fakeRepo,
        );

        controller.startGame();
        controller.chooseMus(0, MusChoice.mintza);
        // ignore: invalid_use_of_protected_member
        controller.state = controller.state.copyWith(
          phase: MusPhase.roundScoring,
          tantto: [3, 1],
        );
        fakeRepo.pushedStates.clear();

        expect(
          container.read(musGameControllerProvider).phase,
          MusPhase.roundScoring,
        );

        // À 7s, l'hôte est toujours en roundScoring
        await tester.pump(const Duration(seconds: 7));
        expect(
          container.read(musGameControllerProvider).phase,
          MusPhase.roundScoring,
        );

        // À 8s, le timer expire : l'hôte appelle nextHand et pousse la nouvelle donne
        await tester.pump(const Duration(seconds: 1));
        final nextState = container.read(musGameControllerProvider);
        expect(nextState.phase, MusPhase.musDecision);
        expect(nextState.eskuIndex, 3);

        final newPushed = fakeRepo.pushedStates.last;
        expect(newPushed['phase'], 'musDecision');
        expect(newPushed['lastActionSeat'], 0);
        expect(newPushed['eskuIndex'], 3);
      },
    );

    testWidgets(
      'En fin de partie (score >= 40 tantto), l\'hôte attend 8s en roundScoring puis bascule en gameOver sur Supabase',
      (tester) async {
        final fakeRepo = _FakeSupabaseRepository();
        final container = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepo),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(musGameControllerProvider.notifier);
        controller.configureMultiplayer(
          gameId: 'game-gameover-timer-host',
          localSeat: 0,
          repository: fakeRepo,
        );

        controller.startGame();
        controller.chooseMus(0, MusChoice.mintza);
        controller.act(0, BidActionType.hordago);
        controller.act(3, BidActionType.iduki);

        expect(
          container.read(musGameControllerProvider).phase,
          MusPhase.roundScoring,
        );
        expect(
          container.read(musGameControllerProvider).teamAScore >= 40 ||
              container.read(musGameControllerProvider).teamBScore >= 40,
          isTrue,
        );

        final pushesCount = fakeRepo.pushedStates.length;

        // Pendant les 8 secondes : toujours en roundScoring (scores visibles)
        await tester.pump(const Duration(seconds: 4));
        expect(
          container.read(musGameControllerProvider).phase,
          MusPhase.roundScoring,
        );
        expect(fakeRepo.pushedStates.length, pushesCount);

        // À l'expiration des 8 secondes : passage à gameOver et push sur Supabase
        await tester.pump(const Duration(seconds: 4));
        expect(
          container.read(musGameControllerProvider).phase,
          MusPhase.gameOver,
        );
        expect(fakeRepo.pushedStates.length, pushesCount + 1);
        final lastPush = fakeRepo.pushedStates.last;
        expect(lastPush['phase'], 'gameOver');
        expect(lastPush['lastActionSeat'], 0);

        // Appel manuel à nextHand() bloqué en gameOver
        controller.nextHand();
        expect(
          container.read(musGameControllerProvider).phase,
          MusPhase.gameOver,
        );
      },
    );

    testWidgets(
      'L\'invité en roundScoring ne déclenche aucun timer et ne pousse rien',
      (tester) async {
        final fakeRepoGuest = _FakeSupabaseRepository();
        final guestContainer = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepoGuest),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(guestContainer.dispose);

        final guestController = guestContainer.read(
          musGameControllerProvider.notifier,
        );
        guestController.configureMultiplayer(
          gameId: 'game-auto-next-guest',
          localSeat: 1, // Invité
          repository: fakeRepoGuest,
        );

        final roundScoringState = MusGameState.initial().copyWith(
          version: 10,
          phase: MusPhase.roundScoring,
        );
        guestController.syncFromRemote(roundScoringState);

        expect(
          guestContainer.read(musGameControllerProvider).phase,
          MusPhase.roundScoring,
        );

        // Le temps s'écoule (8 secondes puis 10 secondes) : l'invité ne doit pas transiter de lui-même
        await tester.pump(const Duration(seconds: 8));
        await tester.pump(const Duration(seconds: 2));

        expect(
          guestContainer.read(musGameControllerProvider).phase,
          MusPhase.roundScoring,
        );
        expect(
          fakeRepoGuest.pushedStates,
          isEmpty,
        ); // Aucun appel à Supabase par l'invité

        // Réception de l'état gameOver de l'hôte
        final gameOverState = roundScoringState.copyWith(
          version: 11,
          phase: MusPhase.gameOver,
        );
        guestController.syncFromRemote(gameOverState);
        expect(
          guestContainer.read(musGameControllerProvider).phase,
          MusPhase.gameOver,
        );
      },
    );

    testWidgets(
      'En gameOver, l\'hôte ne déclenche aucun timer de donne suivante',
      (tester) async {
        final fakeRepo = _FakeSupabaseRepository();
        final container = ProviderContainer(
          overrides: [
            supabaseRepositoryProvider.overrideWithValue(fakeRepo),
            musBotsEnabledProvider.overrideWithValue(false),
            musTurnTimeoutProvider.overrideWithValue(null),
            musEmptyPhaseDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(musGameControllerProvider.notifier);
        controller.configureMultiplayer(
          gameId: 'game-auto-gameover',
          localSeat: 0,
          repository: fakeRepo,
        );

        final winningHands = [
          [
            Card(12, Suit.oros),
            Card(12, Suit.copas),
            Card(12, Suit.espadas),
            Card(12, Suit.bastos),
          ],
          [
            Card(1, Suit.oros),
            Card(1, Suit.copas),
            Card(1, Suit.espadas),
            Card(1, Suit.bastos),
          ],
          [
            Card(4, Suit.oros),
            Card(4, Suit.copas),
            Card(4, Suit.espadas),
            Card(4, Suit.bastos),
          ],
          [
            Card(5, Suit.oros),
            Card(5, Suit.copas),
            Card(5, Suit.espadas),
            Card(5, Suit.bastos),
          ],
        ];
        controller.startGame(hands: winningHands);
        container.read(musGameControllerProvider.notifier).state = container
            .read(musGameControllerProvider)
            .copyWith(manches: [2, 0]);
        // Hordago accepté en Grand : siège 0 (4 Rois) gagne assurément -> 3e manche pour équipe 0 -> GameOver
        controller.chooseMus(0, MusChoice.mintza);
        controller.act(0, BidActionType.hordago);
        controller.act(3, BidActionType.iduki);

        expect(
          container.read(musGameControllerProvider).phase,
          MusPhase.gameOver,
        );

        // Attente de 10s : aucun passage à nextHand
        await tester.pump(const Duration(seconds: 10));
        expect(
          container.read(musGameControllerProvider).phase,
          MusPhase.gameOver,
        );
      },
    );
  });
}
