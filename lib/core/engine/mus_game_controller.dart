/// Machine à états d'une partie de Mus (Notifier Riverpod).
///
/// Règles : `SPEC_MUS.md`. Les comparaisons de cartes sont déléguées à
/// `mus_evaluator.dart`.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_haptic_service.dart';
import '../models/card.dart';
import '../models/avatar_config.dart';
import 'bot_ai.dart';
import 'bot_profile.dart';
import 'mus_evaluator.dart';
import 'mus_game_state.dart';
import 'mus_sign.dart';
import 'mus_table_feedback.dart';
import '../network/supabase_repository.dart';
import '../network/game_sign_repository.dart';
import '../network/table_chat_event.dart';
import '../network/player_repository.dart';

/// Source d'aléatoire (surchargeable dans les tests).
final botLineupRandomProvider = Provider<Random>((ref) => Random());

final musRandomProvider = Provider<Random>((ref) => Random());

/// Désactivable pour les tests du moteur ou une future partie réseau.
final musBotsEnabledProvider = Provider<bool>((ref) => true);
final musBotDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 1700),
);
final musBotAIProvider = Provider<MusBotAI>(
  (ref) => MusBotAI(random: ref.watch(musBotRandomProvider)),
);

/// null désactive le délai pour les tests qui pilotent les quatre sièges.
final musTurnTimeoutProvider = Provider<Duration?>(
  (ref) => const Duration(seconds: 10),
);

/// Délai d'affichage pour les phases sans participants ou annonces Bai / Ez.
final musEmptyPhaseDelayProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

/// Délai de visibilité pour la clôture d'une sous-phase (Iduki, Tira, allPaso).
final musBidResolutionDelayProvider = Provider<Duration>(
  (ref) => ref.watch(musEmptyPhaseDelayProvider),
);

/// Délai d'affichage du décompte de fin de donne avant la transition automatique vers la donne suivante.
final musRoundScoringDelayProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 8),
);

/// Délai de grâce réseau accordé par l'hôte aux joueurs distants avant le déclenchement du fallback.
final musHostFallbackGraceProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 3),
);

/// Tirage des signes indépendant du mélange des cartes.
final musBotRandomProvider = Provider<Random>((ref) => Random());

/// Provider du contrôleur de partie.
final musGameControllerProvider =
    NotifierProvider<MusGameController, MusGameState>(MusGameController.new);

class MusGameController extends Notifier<MusGameState> {
  Timer? _botTimer;
  Timer? _turnTimer;
  Timer? _fallbackTimer;
  Timer? _emptyPhaseTimer;
  Timer? _bidResolutionTimer;
  Timer? _roundScoringTimer;
  final Map<int, Timer> _signTimers = {};
  GameSignSession? _signSession;
  StreamSubscription<SignBroadcast>? _signSubscription;
  StreamSubscription<TableChatEvent>? _chatSubscription;
  final _seenChats = <String>{};
  int _chatSequence = 0;
  String? _signRoom;
  List<dynamic> _signRoster = const [];
  final _seenSigns = <String>{};
  int _signRevision = 0;

  String? gameId;
  int localSeat = 0;
  SupabaseRepository? _repository;
  bool _isSyncing = false;
  List<MusPlayer>? _configuredPlayers;

  int get hostSeat =>
      _configuredPlayers?.where((p) => p.isHost).firstOrNull?.seat ?? 0;
  bool get isHost => gameId == null || localSeat == hostSeat;
  bool get _isHost => isHost;

  bool _canPushStateFor(int seat) {
    if (seat == localSeat) return true;
    if (_isHost && gameId != null) return true;
    return false;
  }

  void configureMultiplayer({
    String? gameId,
    int? localSeat,
    List<dynamic>? players,
    SupabaseRepository? repository,
  }) {
    this.gameId = gameId;
    if (localSeat != null) this.localSeat = localSeat;
    if (repository != null) _repository = repository;
    if (players != null && players.isNotEmpty) {
      final parsed = <MusPlayer>[];
      final hasHost = players.any(
        (p) => p is Map && (p['is_host'] == true || p['isHost'] == true),
      );
      for (var i = 0; i < 4; i++) {
        dynamic found;
        for (final item in players) {
          if (item is Map && item['seat'] == i) {
            found = item;
            break;
          }
        }
        if (found is Map) {
          parsed.add(MusPlayer.fromJson(Map<String, dynamic>.from(found)));
        } else {
          parsed.add(
            MusPlayer(seat: i, isHost: !hasHost && i == 0, isBot: i != 0),
          );
        }
      }
      _shuffleOfflineBots = !parsed.any(
        (p) => p.isBot && p.botPersonality != null,
      );
      _configuredPlayers = _withAvatars(parsed);
    }
    _configureSignChannel(gameId, players);
  }

  bool _shuffleOfflineBots = true;

  List<MusPlayer> _withAvatars(List<MusPlayer> players) {
    final used = <BotPersonality>{};
    return [
      for (final player in players)
        if (player.isBot)
          (() {
            final requested = player.botPersonality;
            final personality = requested != null && !used.contains(requested)
                ? requested
                : BotPersonality.values.firstWhere((p) => !used.contains(p));
            used.add(personality);
            return player.withBotProfile(
              BotProfile.forPersonality(personality),
            );
          })()
        else
          player.avatarConfig != null
              ? player
              : player.withAvatar(AvatarConfig.forSeat(player.seat)),
    ];
  }

  void disconnectSignChannel() {
    _signSubscription?.cancel();
    _chatSubscription?.cancel();
    _chatSubscription = null;
    final session = _signSession;
    if (session != null) unawaited(session.close().catchError((_) {}));
    _signSession = null;
    _signSubscription = null;
    _signRoom = null;
    _signRoster = const [];
    _seenChats.clear();
    _scheduleChatReset(null);
  }

  void _scheduleChatReset(String? room) {
    if (!ref.mounted) return;
    final old = ref.read(musTableFeedbackProvider).chatHistory.toSet();
    if (old.isEmpty) return;
    scheduleMicrotask(() {
      if (ref.mounted && _signRoom == room) {
        ref
            .read(musTableFeedbackProvider.notifier)
            .clearChatHistory(entries: old);
      }
    });
  }

  void _configureSignChannel(String? room, List<dynamic>? players) {
    if (_signRoom != room) {
      _chatSubscription?.cancel();
      _chatSubscription = null;
      _seenChats.clear();
      _scheduleChatReset(room);
      _signSubscription?.cancel();
      final old = _signSession;
      if (old != null) unawaited(old.close().catchError((_) {}));
      _signSession = null;
      _signSubscription = null;
      _signRoom = room;
      _signRoster = const [];
      _seenSigns.clear();
    }
    if (players != null) _signRoster = players;
    if (room == null) return;
    try {
      if (_signSession == null) {
        _signSession = ref.read(gameSignRepositoryProvider).open(room);
        _signSubscription = _signSession!.events.listen(_receiveSign);
        final session = _signSession;
        if (session is GameChatSession) {
          _chatSubscription = (session as GameChatSession).chatEvents.listen((
            event,
          ) {
            if (identical(_signSession, session) && _signRoom == room) {
              _receiveChat(event);
            }
          });
        }
      }
      _signSession!.updateRoster(_signRoster);
    } catch (_) {
      // Unavailable in offline tests; sendSign surfaces a transmission error.
    }
  }

  String get signHandId {
    // Stable non-secret fingerprint; never send cards in a gesture payload.
    final text = jsonEncode([
      state.eskuIndex,
      state.manches,
      state.hands.map((h) => h.map((c) => c.toJson()).toList()).toList(),
    ]);
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(text)) {
      hash = (hash * 33 + byte).toUnsigned(32);
    }
    return hash.toRadixString(16);
  }

  void _receiveSign(SignBroadcast event) {
    final eventKey = '${event.senderId}:${event.id}';
    if (!ref.mounted ||
        event.handId != signHandId ||
        _seenSigns.contains(eventKey) ||
        event.id.isEmpty ||
        event.seat < 0 ||
        event.seat > 3) {
      return;
    }
    final actor = _signRoster
        .whereType<Map>()
        .where((p) => p['seat'] == event.seat)
        .firstOrNull;
    final host =
        _signRoster
            .whereType<Map>()
            .where((p) => p['is_host'] == true)
            .firstOrNull ??
        _signRoster.whereType<Map>().where((p) => p['seat'] == 0).firstOrNull;
    final authorized =
        actor != null &&
        (actor['id'] == event.senderId ||
            actor['is_bot'] == true && host?['id'] == event.senderId);
    final sign = parseMusSign(event.sign);
    if (!authorized ||
        sign == null ||
        !state.canSignal ||
        !state.availableSignsForSeat(event.seat).contains(sign)) {
      return;
    }
    _seenSigns.add(eventKey);
    if (_seenSigns.length > 128) _seenSigns.remove(_seenSigns.first);
    _displaySign(event.seat, sign);
  }

  bool isBot(int seat) {
    if (_configuredPlayers != null &&
        seat >= 0 &&
        seat < _configuredPlayers!.length) {
      return _configuredPlayers![seat].isBot;
    }
    return state.isBot(seat);
  }

  void _pushStateToSupabase({required int actionSeat}) {
    if (gameId == null || _isSyncing) return;
    try {
      final repo = _repository ?? ref.read(supabaseRepositoryProvider);
      state = state.copyWith(
        version: state.version + 1,
        lastActionSeat: actionSeat,
      );
      repo
          ?.updateGameState(gameId!, state.toJson(lastActionSeat: actionSeat))
          .catchError((_) {});
    } catch (_) {
      // Ignorer l'erreur réseau pour préserver la réactivité locale
    }
  }

  void syncFromRemote(MusGameState remoteState) {
    // Rejet strict et silencieux de tout état réseau obsolète ou écho local
    if (remoteState.version <= state.version) {
      return;
    }

    final previousState = state;
    _isSyncing = true;
    try {
      // 1. Annulation immédiate et inconditionnelle de TOUS les timers asynchrones locaux
      _turnTimer?.cancel();
      _turnTimer = null;
      _fallbackTimer?.cancel();
      _fallbackTimer = null;
      _botTimer?.cancel();
      _botTimer = null;
      _emptyPhaseTimer?.cancel();
      _emptyPhaseTimer = null;
      _bidResolutionTimer?.cancel();
      _bidResolutionTimer = null;
      _roundScoringTimer?.cancel();
      _roundScoringTimer = null;

      final feedback = ref.read(musTableFeedbackProvider.notifier);

      // Annonces de Mus (différence de votes)
      if (remoteState.musVotes.length > state.musVotes.length) {
        final order = musDecisionOrder(remoteState.eskuIndex);
        final newIndex = state.musVotes.length;
        if (newIndex < order.length && newIndex < remoteState.musVotes.length) {
          final voter = order[newIndex];
          final vote = remoteState.musVotes[newIndex];
          feedback.say(
            voter,
            TableSpeech(
              vote == MusChoice.mus ? SpeechKind.mus : SpeechKind.mintza,
            ),
          );
        }
      }

      // Annonces d'enchères
      if (remoteState.bidding != null) {
        final curPhase = remoteState.bidding!.phase;
        final oldActions = state.bidHistory[curPhase] ?? [];
        final newActions = remoteState.bidHistory[curPhase] ?? [];
        if (newActions.length > oldActions.length) {
          final latest = newActions.last;
          feedback.say(
            latest.player,
            TableSpeech(
              SpeechKind.bid,
              action: latest.type,
              amount: latest.amount,
            ),
          );
        }
      }

      // Transition visuelle de phase (Bai / Ez) pour les clients distants
      if (remoteState.bidding != null &&
          remoteState.bidding!.phase != state.bidding?.phase) {
        if (remoteState.bidding!.phase == BidPhase.paires) {
          for (var s = 0; s < 4; s++) {
            feedback.say(
              s,
              TableSpeech(
                SpeechKind.custom,
                text: evaluatePaires(remoteState.hands[s]).hasPaires
                    ? 'Bai'
                    : 'Ez',
              ),
            );
          }
        } else if (remoteState.bidding!.phase == BidPhase.jeu) {
          final isPoint =
              determineJeuPointMode(remoteState.hands) == JeuPointMode.point;
          for (var s = 0; s < 4; s++) {
            feedback.say(
              s,
              TableSpeech(
                SpeechKind.custom,
                text:
                    !isPoint && evaluateJeuEtPoint(remoteState.hands[s]).hasJeu
                    ? 'Bai'
                    : 'Ez',
              ),
            );
          }
        }
      }

      if (remoteState.currentPlayer >= 0) {
        feedback.setAnnouncement(null);
      }

      // Broadcast gestures survive ordinary state updates for this hand only.
      final sameHand = jsonEncode(state.hands) == jsonEncode(remoteState.hands);
      if (!sameHand || !remoteState.canSignal) _cancelSignTimers();
      state = remoteState.copyWith(
        signs: sameHand && remoteState.canSignal ? state.signs : const {},
        signRevisions: sameHand && remoteState.canSignal
            ? state.signRevisions
            : const {},
      );
    } finally {
      _isSyncing = false;
    }

    // Privilège de l'Hôte : Si une action de fin de sous-phase arrive d'un invité
    // (Tira, Iduki, allPaso), SEUL l'hôte arme les timers de transition exclusifs.
    if (_isHost &&
        gameId != null &&
        state.phase == MusPhase.bidding &&
        state.bidding != null) {
      final curPhase = state.bidding!.phase;
      if (!state.outcomes.containsKey(curPhase)) {
        final actions = state.bidHistory[curPhase] ?? [];
        if (actions.isNotEmpty) {
          final last = actions.last;
          if (last.type == BidActionType.tira) {
            _finishRefused(state.bidding!);
          } else if (last.type == BidActionType.iduki) {
            _scheduleFinishPhase(
              PhaseOutcome(
                phase: curPhase,
                kind: state.bidding!.isHordago
                    ? OutcomeKind.hordagoAccepted
                    : OutcomeKind.accepted,
                participants: state.bidding!.participants,
                stake: state.bidding!.currentBid,
              ),
            );
          } else if (last.type == BidActionType.nereGatikTira &&
              state.bidding!.responderIndex >=
                  state.bidding!.responders.length) {
            _finishRefused(state.bidding!);
          } else if (last.type == BidActionType.paso &&
              state.bidding!.stage == BidStage.opening &&
              state.bidding!.openingIndex >=
                  state.bidding!.participants.length) {
            _scheduleFinishPhase(
              PhaseOutcome(
                phase: curPhase,
                kind: OutcomeKind.allPaso,
                participants: state.bidding!.participants,
              ),
            );
          }
        }
      }
    }

    if (_isHost && state.phase == MusPhase.roundScoring) {
      _scheduleNextHand();
    }

    if (!state.hasSameTurnAs(previousState)) {
      _onTurnChanged(previousState, state);
    }
  }

  @override
  MusGameState build() {
    ref.onDispose(() {
      _botTimer?.cancel();
      _turnTimer?.cancel();
      _fallbackTimer?.cancel();
      _emptyPhaseTimer?.cancel();
      _bidResolutionTimer?.cancel();
      _roundScoringTimer?.cancel();
      _cancelSignTimers();
      _signSubscription?.cancel();
      _chatSubscription?.cancel();
      _chatSubscription = null;
      _seenChats.clear();
      final session = _signSession;
      if (session != null) unawaited(session.close().catchError((_) {}));
      _signSession = null;
      _signSubscription = null;
      _signRoom = null;
      _signRoster = const [];
      _seenSigns.clear();
      _signRevision = 0;
      // Invalidation rebuilds this notifier; also clear its non-state fields.
      gameId = null;
      localSeat = 0;
      _repository = null;
      _configuredPlayers = null;
      _isSyncing = false;
    });
    listenSelf((previous, next) {
      if (previous == null) return;
      if (_isSyncing) return;
      if (previous.phase == MusPhase.roundScoring &&
          next.phase != MusPhase.roundScoring) {
        _roundScoringTimer?.cancel();
        _roundScoringTimer = null;
      }
      if (previous.phase != MusPhase.roundScoring &&
          next.phase == MusPhase.roundScoring) {
        if (_isHost) _scheduleNextHand();
      }
      if (next.hasSameTurnAs(previous)) return;
      _onTurnChanged(previous, next);
    });
    _configuredPlayers ??= _withAvatars(MusGameState.defaultPlayers());
    return MusGameState.initial(players: _configuredPlayers);
  }

  void _onTurnChanged(MusGameState? previous, MusGameState next) {
    _botTimer?.cancel();
    _botTimer = null;
    _turnTimer?.cancel();
    _turnTimer = null;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;

    final seat = next.currentPlayer;
    final playable =
        seat >= 0 &&
        seat < 4 &&
        next.canSignal &&
        (next.phase != MusPhase.bidding ||
            (next.bidding != null &&
                next.bidding!.participants.length > 1 &&
                next.bidding!.participants.map(teamOf).toSet().length > 1));

    final timeout = ref.read(musTurnTimeoutProvider);

    // 1. Retour Visuel : indicateur temporel (setClock) pour le currentPlayer sur tous les clients
    ref
        .read(musTableFeedbackProvider.notifier)
        .setClock(
          playable && timeout != null
              ? TurnClock(seat: seat, duration: timeout)
              : null,
        );

    if (!playable) return;

    final isLocalTurn = gameId == null || (seat == localSeat && !isBot(seat));
    final isDistantHuman = gameId != null && seat != localSeat && !isBot(seat);
    final isBotTurn = isBot(seat);

    // 2. Responsabilité locale : timer de 10s pour le joueur local (ou en solo)
    if (isLocalTurn && timeout != null) {
      _turnTimer = Timer(timeout, () {
        if (!ref.mounted || !state.hasSameTurnAs(next)) return;
        _autoPlayTimeout(seat);
        if (seat == localSeat && !isBot(seat)) {
          unawaited(
            ref
                .read(audioHapticServiceProvider)
                .feedback(GameSounds.timeout, impact: HapticImpact.heavy),
          );
        }
      });
    }

    // 3. Fallback de l'hôte (13s = 10s + 3s de grâce réseau) pour les joueurs distants
    if (_isHost && isDistantHuman && timeout != null) {
      final grace = ref.read(musHostFallbackGraceProvider);
      final fallbackDelay = timeout + grace;
      _fallbackTimer = Timer(fallbackDelay, () {
        if (!ref.mounted || !state.hasSameTurnAs(next)) return;
        _autoPlayTimeout(seat);
      });
    }

    // 4. Tour des bots : uniquement orchestré par l'hôte en multijoueur (ou en local)
    if (isBotTurn &&
        (next.phase != MusPhase.bidding || next.bidding != null) &&
        _isHost) {
      _scheduleBotTurn(seat, next);
    }
  }

  void _autoPlayTimeout(int seat) {
    if (state.currentPlayer != seat) return;
    switch (state.phase) {
      case MusPhase.musDecision:
        chooseMus(seat, MusChoice.mus);
      case MusPhase.bidding:
        if (state.bidding == null) return;
        act(
          seat,
          state.bidding!.stage == BidStage.opening
              ? BidActionType.paso
              : BidActionType.tira,
        );
      case MusPhase.discarding:
        // En l'absence de choix, conserver les quatre cartes.
        discard(seat, []);
      default:
        break;
    }
  }

  void _scheduleBotTurn(int seat, MusGameState next) {
    if (!isBot(seat)) return;
    final isNonHostInMultiplayer = gameId != null && !_isHost;
    if (isNonHostInMultiplayer) return;

    if (!botsEnabled) return;

    final delay = ref.read(musBotDelayProvider);
    final ai = ref.read(musBotAIProvider);

    _botTimer?.cancel();
    _botTimer = Timer(delay, () {
      _botTimer = null;
      if (!ref.mounted || !state.hasSameTurnAs(next)) return;
      switch (ai.decide(state, seat)) {
        case BotMusDecision(:final choice):
          chooseMus(seat, choice);
        case BotDiscardDecision(:final indices):
          discard(seat, indices);
        case BotBidDecision(:final action, :final amount):
          act(seat, action, amount: amount);
        case null:
          break;
      }
    });
  }

  Random get _rng => ref.read(musRandomProvider);

  Future<void> sendQuickChat(int seat, QuickChat message) =>
      _sendChat(seat, message.name, quick: true);

  Future<void> sendTextChat(String text) =>
      _sendChat(localSeat, TableChatEvent.normalize(text));

  // Round reveals allow chatting; the final result closes outgoing communication.
  Future<void> _sendChat(int seat, String body, {bool quick = false}) async {
    if (state.phase == MusPhase.gameOver) {
      throw StateError('La partie est terminée.');
    }
    _checkSeat(seat);
    if (gameId != null && seat != localSeat) {
      throw StateError('Message réservé au joueur local');
    }
    if (!quick && !TableChatEvent.validText(body)) {
      throw StateError('Écrivez un message de 1 à 160 caractères.');
    }
    if (quick) {
      final choice = QuickChat.values.where((m) => m.name == body).first;
      final item = choice.shopItemId;
      if (item != null &&
          !(ref.read(inventoryProvider).asData?.value.contains(item) ??
              false)) {
        throw StateError('Message non possédé');
      }
    }
    final event = TableChatEvent(
      senderId: '',
      seat: seat,
      id: '${DateTime.now().microsecondsSinceEpoch}-${++_chatSequence}',
      body: body,
      quick: quick,
    );
    final room = gameId;
    if (room != null) {
      final session = _signSession;
      if (session is! GameChatSession) throw StateError('Chat indisponible');
      await (session as GameChatSession).sendChat(event);
      if (!ref.mounted ||
          gameId != room ||
          _signRoom != room ||
          !identical(_signSession, session)) {
        return;
      }
    }
    _displayChat(event);
  }

  void _receiveChat(TableChatEvent event) {
    final key = '${event.senderId}:${event.id}';
    if (!ref.mounted ||
        event.id.isEmpty ||
        event.id.length > 100 ||
        _seenChats.contains(key) ||
        event.seat < 0 ||
        event.seat > 3) {
      return;
    }
    final actor = _signRoster
        .whereType<Map>()
        .where((p) => p['seat'] == event.seat)
        .firstOrNull;
    if (actor == null ||
        actor['id'] != event.senderId ||
        actor['is_bot'] == true) {
      return;
    }
    if (event.quick
        ? !QuickChat.values.any((q) => q.name == event.body)
        : !TableChatEvent.validText(event.body)) {
      return;
    }
    _seenChats.add(key);
    if (_seenChats.length > 128) _seenChats.remove(_seenChats.first);
    _displayChat(event);
  }

  void _displayChat(TableChatEvent event) {
    ref
        .read(musTableFeedbackProvider.notifier)
        .say(
          event.seat,
          event.quick
              ? TableSpeech(
                  SpeechKind.chat,
                  chat: QuickChat.values.firstWhere(
                    (q) => q.name == event.body,
                  ),
                )
              : TableSpeech(SpeechKind.freeChat, text: event.body),
        );
  }

  /// Ephemeral gesture: no logical version, turn or games row is changed.
  Future<void> sendSign(String sign) {
    final parsed = parseMusSign(sign);
    if (parsed == null) throw StateError('Signe inconnu');
    return sendSignForSeat(localSeat, parsed);
  }

  /// Host-only for bots in multiplayer; local simulations may control any seat.
  Future<void> sendSignForSeat(int seat, MusSign sign) {
    _checkSeat(seat);
    if (gameId != null && seat != localSeat && !(_isHost && isBot(seat))) {
      throw StateError('Signe réservé au joueur local');
    }
    if (!state.canSignal || !state.availableSignsForSeat(seat).contains(sign)) {
      throw StateError('Signe impossible avec cette main ou dans cette phase');
    }
    _displaySign(seat, sign);
    if (gameId == null) return Future.value();
    final session = _signSession;
    if (session == null) {
      return Future.error(StateError('Canal de signes indisponible'));
    }
    return session.send(
      SignBroadcast(
        senderId: '',
        seat: seat,
        sign: sign.name,
        handId: signHandId,
        id: '${DateTime.now().microsecondsSinceEpoch}-$_signRevision',
      ),
    );
  }

  void _displaySign(int seat, MusSign sign) {
    _signTimers.remove(seat)?.cancel();
    state = state.copyWith(
      signs: Map.unmodifiable({...state.signs, seat: sign}),
      signRevisions: Map.unmodifiable({
        ...state.signRevisions,
        seat: ++_signRevision,
      }),
    );
    _signTimers[seat] = Timer(const Duration(seconds: 2), () {
      _signTimers.remove(seat);
      if (!ref.mounted) return;
      state = state.copyWith(
        signs: Map.unmodifiable({...state.signs}..remove(seat)),
        signRevisions: Map.unmodifiable({...state.signRevisions}..remove(seat)),
      );
    });
  }

  void _cancelSignTimers() {
    for (final timer in _signTimers.values) {
      timer.cancel();
    }
    _signTimers.clear();
  }

  void _clearSigns() {
    _cancelSignTimers();
    if (state.signs.isNotEmpty) {
      state = state.copyWith(signs: const {}, signRevisions: const {});
    }
  }

  void _maybeSignalPartner() {
    if (!botsEnabled || !state.canSignal || (gameId != null && !_isHost)) {
      return;
    }
    final random = ref.read(musBotRandomProvider);
    for (var seat = 0; seat < 4; seat++) {
      if (!isBot(seat)) continue;
      final sign = ref.read(musBotAIProvider).chooseSign(state, seat);
      // Never let bluff personality influence Keinuak truthfulness. Check the
      // actual hand and phase immediately before the shared send path.
      if (sign != null &&
          state.availableSignsForSeat(seat).contains(sign) &&
          random.nextBool()) {
        unawaited(sendSignForSeat(seat, sign).catchError((_) {}));
      }
    }
  }

  // -------------------------------------------------------------------------
  // Démarrage / distribution
  // -------------------------------------------------------------------------

  /// Démarre une nouvelle partie (scores remis à zéro) et distribue.
  ///
  /// [hands] et [talon] permettent d'imposer la donne (tests, rejeu).
  void startGame({
    int eskuIndex = 0,
    List<List<Card>>? hands,
    List<Card>? talon,
  }) {
    _checkSeat(eskuIndex);
    if (gameId == null && _shuffleOfflineBots && _configuredPlayers != null) {
      final bots = BotProfile.shuffled(ref.read(botLineupRandomProvider));
      var index = 0;
      _configuredPlayers = [
        for (final player in _configuredPlayers!)
          player.isBot ? player.withBotProfile(bots[index++]) : player,
      ];
    }
    state = MusGameState.initial(players: _configuredPlayers)
        .copyWith(eskuIndex: eskuIndex);
    _deal(hands, talon);
    if (_isHost && gameId != null) {
      _pushStateToSupabase(actionSeat: localSeat);
    }
  }

  /// Après un décompte : fait tourner l'Esku d'un cran vers la droite (sens anti-horaire)
  /// et distribue une nouvelle main. Si la manche vient d'être gagnée, les tantto repartent à 0.
  void nextHand({List<List<Card>>? hands, List<Card>? talon}) {
    if (state.phase == MusPhase.gameOver ||
        state.teamAScore >= pointsToWin ||
        state.teamBScore >= pointsToWin ||
        state.isGameOver) {
      return;
    }
    if (state.phase != MusPhase.roundScoring) {
      throw StateError('nextHand impossible en phase ${state.phase.name}');
    }
    _roundScoringTimer?.cancel();
    _roundScoringTimer = null;
    state = state.copyWith(
      tantto: state.mancheWinner != null ? [0, 0] : state.tantto,
      eskuIndex: (state.eskuIndex - 1 + 4) % 4,
    );
    _deal(hands, talon);
    if (_isHost && gameId != null) {
      _pushStateToSupabase(actionSeat: localSeat);
    }
  }

  void _deal(List<List<Card>>? hands, List<Card>? talon) {
    _emptyPhaseTimer?.cancel();
    _emptyPhaseTimer = null;
    _bidResolutionTimer?.cancel();
    _bidResolutionTimer = null;
    _roundScoringTimer?.cancel();
    _roundScoringTimer = null;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    final feedback = ref.read(musTableFeedbackProvider.notifier);
    feedback.clearSpeeches();
    feedback.setAnnouncement(null);
    _clearSigns();
    state = state.copyWith(phase: MusPhase.dealing);
    final List<List<Card>> dealt;
    final List<Card> rest;
    if (hands != null) {
      if (hands.length != 4 || hands.any((h) => h.length != handSize)) {
        throw ArgumentError('Il faut 4 mains de $handSize cartes');
      }
      dealt = [for (final h in hands) List<Card>.of(h)];
      final used = hands.expand((h) => h).toSet();
      rest = talon != null
          ? List<Card>.of(talon)
          : (Card.fullDeck().where((c) => !used.contains(c)).toList()
              ..shuffle(_rng));
    } else {
      final deck = Card.fullDeck()..shuffle(_rng);
      dealt = [
        for (var i = 0; i < 4; i++)
          deck.sublist(i * handSize, (i + 1) * handSize),
      ];
      rest = talon != null ? List<Card>.of(talon) : deck.sublist(4 * handSize);
    }
    state = state.copyWith(
      phase: MusPhase.musDecision,
      hands: dealt,
      talon: rest,
      discardPile: [],
      musVotes: [],
      currentPlayer: state.eskuIndex,
      deckLocked: false,
      discardSelections: {},
      bidding: null,
      bidHistory: {},
      outcomes: {},
      scoreLog: [],
      mancheWinner: null,
    );
    _maybeSignalPartner();
  }

  // -------------------------------------------------------------------------
  // Phase de Mus
  // -------------------------------------------------------------------------

  /// Ordre de parole pour la décision du Mus :
  /// L'équipe de l'Esku d'abord (Esku puis partenaire),
  /// puis l'équipe adverse (sens anti-horaire, vers la droite).
  static List<int> musDecisionOrder(int esku) => [
    esku,
    (esku + 2) % 4,
    (esku + 3) % 4,
    (esku + 1) % 4,
  ];

  /// Choix « Mus » (Zuetan) ou « Mintza » du joueur [seat].
  void chooseMus(int seat, MusChoice choice) {
    _require(MusPhase.musDecision, seat);
    ref
        .read(musTableFeedbackProvider.notifier)
        .say(
          seat,
          TableSpeech(
            choice == MusChoice.mus ? SpeechKind.mus : SpeechKind.mintza,
          ),
        );
    final votes = [...state.musVotes, choice];
    if (choice == MusChoice.mintza) {
      // Le paquet est verrouillé : plus d'échange de cartes.
      state = state.copyWith(musVotes: votes, deckLocked: true);
      _beginPhase(BidPhase.grand);
    } else if (votes.length == 4) {
      state = state.copyWith(
        musVotes: votes,
        phase: MusPhase.discarding,
        currentPlayer: state.eskuIndex,
        discardSelections: {},
      );
    } else {
      final order = musDecisionOrder(state.eskuIndex);
      state = state.copyWith(
        musVotes: votes,
        currentPlayer: order[votes.length],
      );
    }
    if (_canPushStateFor(seat)) {
      _pushStateToSupabase(actionSeat: seat);
    }
  }

  /// Le joueur [seat] jette les cartes d'indices [cardIndices] (0 à 4 cartes).
  /// Quand les 4 joueurs ont choisi, la distribution des cartes manquantes a
  /// lieu et une nouvelle phase de Mus commence.
  void discard(int seat, List<int> cardIndices) {
    _require(MusPhase.discarding, seat);
    final unique = cardIndices.toSet();
    if (unique.length != cardIndices.length ||
        unique.any((i) => i < 0 || i >= handSize)) {
      throw ArgumentError('Indices de défausse invalides : $cardIndices');
    }
    final selections = {
      ...state.discardSelections,
      seat: (unique.toList()..sort()),
    };
    ref
        .read(musTableFeedbackProvider.notifier)
        .say(seat, TableSpeech(SpeechKind.discard, amount: cardIndices.length));
    if (selections.length < 4) {
      state = state.copyWith(
        discardSelections: selections,
        currentPlayer: (seat - 1 + 4) % 4,
      );
      if (_canPushStateFor(seat)) {
        _pushStateToSupabase(actionSeat: seat);
      }
      return;
    }
    _resolveDiscards(selections);
    if (_canPushStateFor(seat)) {
      _pushStateToSupabase(actionSeat: seat);
    }
  }

  void _resolveDiscards(Map<int, List<int>> selections) {
    _clearSigns();
    // Phase `dealing` : distribution des cartes manquantes (synchrone).
    state = state.copyWith(
      phase: MusPhase.dealing,
      discardSelections: selections,
    );
    final pile = <Card>[];
    final newHands = <List<Card>>[];
    for (var seat = 0; seat < 4; seat++) {
      final kept = <Card>[];
      final sel = selections[seat] ?? const [];
      final currentHand = state.hands[seat];
      for (var i = 0; i < handSize && i < currentHand.length; i++) {
        final card = currentHand[i];
        (sel.contains(i) ? pile : kept).add(card);
      }
      newHands.add(kept);
    }
    var talon = [...state.talon];
    var pool = [...state.discardPile, ...pile];
    for (var k = 0; k < 4; k++) {
      final seat = (state.eskuIndex - k + 4) % 4;
      final count = selections[seat]?.length ?? 0;
      for (var j = 0; j < count; j++) {
        if (talon.isEmpty && pool.isNotEmpty) {
          // Talon épuisé : on remélange les cartes défaussées.
          talon = [...pool]..shuffle(_rng);
          pool = [];
        }
        if (talon.isNotEmpty) {
          newHands[seat].add(talon.removeAt(0));
        }
      }
    }
    state = state.copyWith(
      phase: MusPhase.musDecision,
      hands: newHands,
      talon: talon,
      discardPile: pool,
      musVotes: [],
      currentPlayer: state.eskuIndex,
      discardSelections: {},
    );
    _maybeSignalPartner();
  }

  // -------------------------------------------------------------------------
  // Enchères
  // -------------------------------------------------------------------------

  /// Action d'enchère du joueur [seat] ([amount] : mise d'un Embido ≥ 2, ou
  /// montant d'une relance Gehiago ≥ 1 ; ignoré pour les autres actions).
  void act(int seat, BidActionType type, {int amount = 0}) {
    _require(MusPhase.bidding, seat);
    final b = state.bidding!;
    final effectiveType = type == BidActionType.tira && b.canDeferRefusal
        ? BidActionType.nereGatikTira
        : type;
    final bool isPhaseEndingAction =
        (b.stage == BidStage.opening &&
            effectiveType == BidActionType.paso &&
            b.openingIndex + 1 >= b.participants.length) ||
        (b.stage == BidStage.responding &&
            (effectiveType == BidActionType.tira ||
                effectiveType == BidActionType.iduki ||
                (effectiveType == BidActionType.nereGatikTira &&
                    b.responderIndex + 1 >= b.responders.length)));

    if (b.stage == BidStage.opening) {
      _actOpening(b, seat, effectiveType, amount);
    } else {
      _actResponding(b, seat, effectiveType, amount);
    }
    if (!isPhaseEndingAction) {
      if (_canPushStateFor(seat)) {
        _pushStateToSupabase(actionSeat: seat);
      }
    }
  }

  void _actOpening(BiddingState b, int seat, BidActionType type, int amount) {
    switch (type) {
      case BidActionType.paso:
        _record(b.phase, BidAction(seat, type));
        final next = b.openingIndex + 1;
        if (next >= b.participants.length) {
          state = state.copyWith(
            currentPlayer: -1,
            bidding: b.copyWith(openingIndex: next),
          );
          if (_canPushStateFor(seat)) {
            _pushStateToSupabase(actionSeat: seat);
          }
          if (_isHost) {
            _scheduleFinishPhase(
              PhaseOutcome(
                phase: b.phase,
                kind: OutcomeKind.allPaso,
                participants: b.participants,
              ),
            );
          }
        } else {
          state = state.copyWith(
            currentPlayer: b.participants[next],
            bidding: b.copyWith(openingIndex: next),
          );
        }
      case BidActionType.embido:
        if (amount < 2) {
          throw ArgumentError('Un Embido vaut au moins 2 (reçu $amount)');
        }
        _record(b.phase, BidAction(seat, type, amount));
        _raise(b, seat, amount, hordago: false);
      case BidActionType.hordago:
        _record(b.phase, BidAction(seat, type, mancheTarget));
        _raise(b, seat, mancheTarget, hordago: true);
      default:
        throw StateError(
          'Action ${type.name} impossible : aucune mise en cours',
        );
    }
  }

  void _actResponding(
    BiddingState b,
    int seat,
    BidActionType type,
    int amount,
  ) {
    switch (type) {
      case BidActionType.iduki:
        _record(b.phase, BidAction(seat, type));
        state = state.copyWith(currentPlayer: -1);
        if (_canPushStateFor(seat)) {
          _pushStateToSupabase(actionSeat: seat);
        }
        if (_isHost) {
          _scheduleFinishPhase(
            PhaseOutcome(
              phase: b.phase,
              kind: b.isHordago
                  ? OutcomeKind.hordagoAccepted
                  : OutcomeKind.accepted,
              participants: b.participants,
              stake: b.currentBid,
            ),
          );
        }
      case BidActionType.tira:
        _record(b.phase, BidAction(seat, type));
        state = state.copyWith(currentPlayer: -1);
        if (_canPushStateFor(seat)) {
          _pushStateToSupabase(actionSeat: seat);
        }
        if (_isHost) {
          _finishRefused(b);
        }
      case BidActionType.nereGatikTira:
        if (b.partnerDecides) {
          throw StateError(
            'Le partenaire doit trancher (Iduki, Tira, Gehiago, Hordago)',
          );
        }
        _record(b.phase, BidAction(seat, type));
        final next = b.responderIndex + 1;
        if (next >= b.responders.length) {
          // Pas de partenaire dans cette sous-phase : équivaut à Tira.
          state = state.copyWith(
            currentPlayer: -1,
            bidding: b.copyWith(responderIndex: next),
          );
          if (_canPushStateFor(seat)) {
            _pushStateToSupabase(actionSeat: seat);
          }
          if (_isHost) {
            _finishRefused(b);
          }
        } else {
          state = state.copyWith(
            currentPlayer: b.responders[next],
            bidding: b.copyWith(responderIndex: next, partnerDecides: true),
          );
        }
      case BidActionType.gehiago:
        if (b.isHordago) throw StateError('Impossible de relancer un Hordago');
        if (amount < 1) {
          throw ArgumentError('Une relance vaut au moins 1 (reçu $amount)');
        }
        _record(b.phase, BidAction(seat, type, amount));
        _raise(b, seat, b.currentBid + amount, hordago: false);
      case BidActionType.hordago:
        if (b.isHordago) throw StateError('Impossible de relancer un Hordago');
        _record(b.phase, BidAction(seat, type, mancheTarget));
        _raise(b, seat, mancheTarget, hordago: true);
      case BidActionType.paso:
      case BidActionType.embido:
        throw StateError(
          'Action ${type.name} impossible : une mise est en cours',
        );
    }
  }

  /// Nouvelle mise / relance : l'équipe adverse doit répondre.
  void _raise(BiddingState b, int seat, int newBid, {required bool hordago}) {
    final team = teamOf(seat);
    final responders = b.participants.where((s) => teamOf(s) != team).toList();
    state = state.copyWith(
      currentPlayer: responders.isNotEmpty ? responders.first : state.eskuIndex,
      bidding: b.copyWith(
        stage: BidStage.responding,
        previousBid: b.currentBid,
        currentBid: newBid,
        isHordago: hordago,
        bidderTeam: team,
        responders: responders,
        responderIndex: 0,
        partnerDecides: false,
      ),
    );
  }

  void _finishRefused(BiddingState b) {
    // 1 tantto si c'était la 1re mise (ou un Hordago d'ouverture), sinon la
    // mise précédant la relance refusée.
    final points = b.previousBid == 0 ? 1 : b.previousBid;
    _scheduleFinishPhase(
      PhaseOutcome(
        phase: b.phase,
        kind: OutcomeKind.refused,
        participants: b.participants,
        tiraTeam: b.bidderTeam,
        tiraPoints: points,
      ),
    );
  }

  void _record(BidPhase phase, BidAction action) {
    ref
        .read(musTableFeedbackProvider.notifier)
        .say(
          action.player,
          TableSpeech(
            SpeechKind.bid,
            action: action.type,
            amount: action.amount,
          ),
        );
    state = state.copyWith(
      bidHistory: {
        ...state.bidHistory,
        phase: [...?state.bidHistory[phase], action],
      },
    );
  }

  // -------------------------------------------------------------------------
  // Enchaînement des sous-phases
  // -------------------------------------------------------------------------

  List<int> _sortedSeats(Iterable<int> seats) =>
      seats.toList()
        ..sort((a, b) => state.eskuOrderOf(a).compareTo(state.eskuOrderOf(b)));

  BidPhase? _nextPhase(BidPhase p) => switch (p) {
    BidPhase.grand => BidPhase.petit,
    BidPhase.petit => BidPhase.paires,
    BidPhase.paires => BidPhase.jeu,
    BidPhase.jeu || BidPhase.point => null,
  };

  void _advance(BidPhase finished) {
    final next = _nextPhase(finished);
    if (next == null) {
      _scoreRound();
    } else {
      _beginPhase(next);
    }
  }

  void _beginPhase(BidPhase requested) {
    _emptyPhaseTimer?.cancel();
    _emptyPhaseTimer = null;
    _bidResolutionTimer?.cancel();
    _bidResolutionTimer = null;
    final delay = ref.read(musEmptyPhaseDelayProvider);
    final hands = state.hands;
    var p = requested;
    final seats = [0, 1, 2, 3];

    if (p == BidPhase.paires) {
      final participants = _sortedSeats(
        seats.where((s) => evaluatePaires(hands[s]).hasPaires),
      );
      final fb = ref.read(musTableFeedbackProvider.notifier);
      // Tous les joueurs annoncent s'ils ont des paires (Bai ou Ez)
      for (var s = 0; s < 4; s++) {
        fb.say(
          s,
          TableSpeech(
            SpeechKind.custom,
            text: evaluatePaires(hands[s]).hasPaires ? 'Bai' : 'Ez',
          ),
        );
      }
      if (participants.isEmpty) {
        if (delay > Duration.zero) {
          state = state.copyWith(
            phase: MusPhase.bidding,
            currentPlayer: -1,
            bidding: BiddingState(
              phase: BidPhase.paires,
              participants: const [],
            ),
            bidHistory: {...state.bidHistory, BidPhase.paires: <BidAction>[]},
          );
          fb.setAnnouncement('Pas de paires');
          if (gameId != null && _isHost) {
            _pushStateToSupabase(actionSeat: localSeat);
          }
          if (_isHost) {
            _emptyPhaseTimer = Timer(delay, () {
              if (!ref.mounted) return;
              _emptyPhaseTimer = null;
              ref.read(musTableFeedbackProvider.notifier).setAnnouncement(null);
              _advance(BidPhase.paires);
            });
          }
          return;
        } else {
          _advance(BidPhase.paires);
          return;
        }
      }
      if (participants.map(teamOf).toSet().length == 1) {
        // Une seule équipe concernée : affichage au centre et bulles Bai/Ez, sans enchère.
        if (delay > Duration.zero) {
          state = state.copyWith(
            phase: MusPhase.bidding,
            currentPlayer: -1,
            bidding: BiddingState(
              phase: BidPhase.paires,
              participants: participants,
            ),
            bidHistory: {...state.bidHistory, BidPhase.paires: <BidAction>[]},
          );
          fb.setAnnouncement('Une seule équipe a des paires');
          if (gameId != null && _isHost) {
            _pushStateToSupabase(actionSeat: localSeat);
          }
          if (_isHost) {
            _emptyPhaseTimer = Timer(delay, () {
              if (!ref.mounted) return;
              _emptyPhaseTimer = null;
              ref.read(musTableFeedbackProvider.notifier).setAnnouncement(null);
              _finishPhase(
                PhaseOutcome(
                  phase: p,
                  kind: OutcomeKind.noBidding,
                  participants: participants,
                ),
              );
            });
          }
          return;
        } else {
          _finishPhase(
            PhaseOutcome(
              phase: p,
              kind: OutcomeKind.noBidding,
              participants: participants,
            ),
          );
          return;
        }
      }
      // Les deux équipes ont des paires : bulles Bai/Ez pendant le délai, puis enchères.
      if (delay > Duration.zero) {
        state = state.copyWith(
          phase: MusPhase.bidding,
          currentPlayer: -1,
          bidding: BiddingState(phase: p, participants: participants),
          bidHistory: {...state.bidHistory, p: <BidAction>[]},
        );
        if (gameId != null && _isHost) {
          _pushStateToSupabase(actionSeat: localSeat);
        }
        if (_isHost) {
          _emptyPhaseTimer = Timer(delay, () {
            if (!ref.mounted) return;
            _emptyPhaseTimer = null;
            state = state.copyWith(currentPlayer: participants.first);
            if (gameId != null && _isHost) {
              _pushStateToSupabase(actionSeat: localSeat);
            }
          });
        }
        return;
      } else {
        state = state.copyWith(
          phase: MusPhase.bidding,
          currentPlayer: participants.isNotEmpty
              ? participants.first
              : state.eskuIndex,
          bidding: BiddingState(phase: p, participants: participants),
          bidHistory: {...state.bidHistory, p: <BidAction>[]},
        );
        if (gameId != null && _isHost) {
          _pushStateToSupabase(actionSeat: localSeat);
        }
        return;
      }
    }

    if (p == BidPhase.jeu) {
      final fb = ref.read(musTableFeedbackProvider.notifier);
      final isPoint = determineJeuPointMode(hands) == JeuPointMode.point;
      // Tous les joueurs annoncent s'ils ont le jeu (Bai ou Ez)
      for (var s = 0; s < 4; s++) {
        fb.say(
          s,
          TableSpeech(
            SpeechKind.custom,
            text: !isPoint && evaluateJeuEtPoint(hands[s]).hasJeu
                ? 'Bai'
                : 'Ez',
          ),
        );
      }
      if (isPoint) {
        // Aucun joueur n'a 31 ou plus : Pas de jeu, puis passage au Point.
        if (delay > Duration.zero) {
          state = state.copyWith(
            phase: MusPhase.bidding,
            currentPlayer: -1,
            bidding: BiddingState(phase: BidPhase.jeu, participants: const []),
            bidHistory: {...state.bidHistory, BidPhase.jeu: <BidAction>[]},
          );
          fb.setAnnouncement('Pas de jeu');
          if (gameId != null && _isHost) {
            _pushStateToSupabase(actionSeat: localSeat);
          }
          if (_isHost) {
            _emptyPhaseTimer = Timer(delay, () {
              if (!ref.mounted) return;
              _emptyPhaseTimer = null;
              ref.read(musTableFeedbackProvider.notifier).setAnnouncement(null);
              _beginPhase(BidPhase.point);
            });
          }
          return;
        } else {
          _beginPhase(BidPhase.point);
          return;
        }
      }
      final participants = _sortedSeats(
        seats.where((s) => evaluateJeuEtPoint(hands[s]).hasJeu),
      );
      if (participants.map(teamOf).toSet().length == 1) {
        if (delay > Duration.zero) {
          state = state.copyWith(
            phase: MusPhase.bidding,
            currentPlayer: -1,
            bidding: BiddingState(
              phase: BidPhase.jeu,
              participants: participants,
            ),
            bidHistory: {...state.bidHistory, BidPhase.jeu: <BidAction>[]},
          );
          fb.setAnnouncement('Une seule équipe a le jeu');
          if (gameId != null && _isHost) {
            _pushStateToSupabase(actionSeat: localSeat);
          }
          if (_isHost) {
            _emptyPhaseTimer = Timer(delay, () {
              if (!ref.mounted) return;
              _emptyPhaseTimer = null;
              ref.read(musTableFeedbackProvider.notifier).setAnnouncement(null);
              _finishPhase(
                PhaseOutcome(
                  phase: p,
                  kind: OutcomeKind.noBidding,
                  participants: participants,
                ),
              );
            });
          }
          return;
        } else {
          _finishPhase(
            PhaseOutcome(
              phase: p,
              kind: OutcomeKind.noBidding,
              participants: participants,
            ),
          );
          return;
        }
      }
      // Les deux équipes ont le jeu : bulles Bai/Ez pendant le délai, puis enchères.
      if (delay > Duration.zero) {
        state = state.copyWith(
          phase: MusPhase.bidding,
          currentPlayer: -1,
          bidding: BiddingState(phase: p, participants: participants),
          bidHistory: {...state.bidHistory, p: <BidAction>[]},
        );
        if (gameId != null && _isHost) {
          _pushStateToSupabase(actionSeat: localSeat);
        }
        if (_isHost) {
          _emptyPhaseTimer = Timer(delay, () {
            if (!ref.mounted) return;
            _emptyPhaseTimer = null;
            state = state.copyWith(currentPlayer: participants.first);
            if (gameId != null && _isHost) {
              _pushStateToSupabase(actionSeat: localSeat);
            }
          });
        }
        return;
      } else {
        state = state.copyWith(
          phase: MusPhase.bidding,
          currentPlayer: participants.isNotEmpty
              ? participants.first
              : state.eskuIndex,
          bidding: BiddingState(phase: p, participants: participants),
          bidHistory: {...state.bidHistory, p: <BidAction>[]},
        );
        if (gameId != null && _isHost) {
          _pushStateToSupabase(actionSeat: localSeat);
        }
        return;
      }
    }

    final participants = _sortedSeats(seats);
    state = state.copyWith(
      phase: MusPhase.bidding,
      currentPlayer: participants.isNotEmpty
          ? participants.first
          : state.eskuIndex,
      bidding: BiddingState(phase: p, participants: participants),
      bidHistory: {...state.bidHistory, p: <BidAction>[]},
    );
    if (gameId != null && _isHost) {
      _pushStateToSupabase(actionSeat: localSeat);
    }
  }

  void _scheduleFinishPhase(PhaseOutcome outcome) {
    if (!_isHost) return;
    _bidResolutionTimer?.cancel();
    _bidResolutionTimer = null;
    final delay = ref.read(musBidResolutionDelayProvider);
    if (delay > Duration.zero) {
      state = state.copyWith(currentPlayer: -1);
      _bidResolutionTimer = Timer(delay, () {
        if (!ref.mounted) return;
        _bidResolutionTimer = null;
        _finishPhase(outcome);
      });
    } else {
      _finishPhase(outcome);
    }
  }

  void _finishPhase(PhaseOutcome outcome) {
    if (!_isHost) return;
    _bidResolutionTimer?.cancel();
    _bidResolutionTimer = null;
    state = state.copyWith(
      outcomes: {...state.outcomes, outcome.phase: outcome},
      bidding: null,
    );
    switch (outcome.kind) {
      case OutcomeKind.refused:
        final e = ScoreEvent(
          outcome.phase,
          outcome.tiraTeam!,
          outcome.tiraPoints,
          'tira',
        );
        if (_addPoints(e)) {
          _endManche(e.team);
          return;
        }
      case OutcomeKind.hordagoAccepted:
        final team = teamOf(_bestSeat(outcome.phase, outcome.participants));
        final e = ScoreEvent(
          outcome.phase,
          team,
          mancheTarget - state.tantto[team],
          'hordago',
        );
        _addPoints(e);
        _endManche(team);
        return;
      default:
        break;
    }
    _advance(outcome.phase);
  }

  // -------------------------------------------------------------------------
  // Points, décompte, fin de manche
  // -------------------------------------------------------------------------

  /// Ajoute des tantto ; retourne `true` si l'équipe atteint 40.
  bool _addPoints(ScoreEvent e) {
    final t = [...state.tantto];
    t[e.team] = min(mancheTarget, t[e.team] + e.points);
    state = state.copyWith(tantto: t, scoreLog: [...state.scoreLog, e]);
    return t[e.team] >= mancheTarget;
  }

  void _endManche(int winner) {
    _clearSigns();
    final manches = [...state.manches];
    manches[winner]++;
    state = state.copyWith(
      manches: manches,
      mancheWinner: winner,
      bidding: null,
      phase: manches[winner] >= manchesToWin
          ? MusPhase.gameOver
          : MusPhase.roundScoring,
    );
    if (gameId != null && _isHost) {
      _pushStateToSupabase(actionSeat: localSeat);
    }
    if (_isHost && state.phase == MusPhase.roundScoring) {
      _scheduleNextHand();
    }
  }

  /// Décompte de fin de tour : Grand, Petit, Paires, Jeu/Point dans l'ordre,
  /// avec arrêt dès qu'une équipe atteint 40.
  void _scoreRound() {
    _clearSigns();
    state = state.copyWith(phase: MusPhase.roundScoring, bidding: null);
    final order = [
      BidPhase.grand,
      BidPhase.petit,
      BidPhase.paires,
      state.outcomes.containsKey(BidPhase.jeu) ? BidPhase.jeu : BidPhase.point,
    ];
    for (final p in order) {
      final outcome = state.outcomes[p];
      if (outcome == null) continue;
      for (final e in _scoringEvents(outcome)) {
        if (e.points <= 0) continue;
        if (_addPoints(e)) {
          _endManche(e.team);
          return;
        }
      }
    }
    if (gameId != null && _isHost) {
      _pushStateToSupabase(actionSeat: localSeat);
    }
    if (_isHost && state.phase == MusPhase.roundScoring) {
      _scheduleNextHand();
    }
  }

  bool get autoAdvanceRounds => true;
  bool get botsEnabled => ref.read(musBotsEnabledProvider);

  void _scheduleNextHand() {
    _roundScoringTimer?.cancel();
    _roundScoringTimer = null;
    if (!_isHost || !autoAdvanceRounds) return;
    if (state.phase != MusPhase.roundScoring) return;
    final delay = ref.read(musRoundScoringDelayProvider);
    _roundScoringTimer = Timer(delay, () {
      _roundScoringTimer = null;
      if (!ref.mounted) return;
      if (state.phase != MusPhase.roundScoring || !_isHost) return;
      if (state.teamAScore >= pointsToWin ||
          state.teamBScore >= pointsToWin ||
          state.isGameOver) {
        state = state.copyWith(phase: MusPhase.gameOver);
        if (gameId != null) {
          _pushStateToSupabase(actionSeat: localSeat);
        }
      } else {
        nextHand();
      }
    });
  }

  List<ScoreEvent> _scoringEvents(PhaseOutcome o) {
    if (o.participants.isEmpty) return const [];
    final team = teamOf(_bestSeat(o.phase, o.participants));
    final accepted = o.kind == OutcomeKind.accepted;
    final allPaso = o.kind == OutcomeKind.allPaso;
    int teamBonus(int Function(List<Card>) bonus) => [0, 1, 2, 3]
        .where((s) => teamOf(s) == team)
        .fold(0, (sum, s) => sum + bonus(state.hands[s]));

    switch (o.phase) {
      case BidPhase.grand:
      case BidPhase.petit:
        // 1 si Paso général, mises si Iduki, 0 si Tira.
        return [
          ScoreEvent(
            o.phase,
            team,
            allPaso ? 1 : (accepted ? o.stake : 0),
            'phase',
          ),
        ];
      case BidPhase.paires:
        return [
          if (accepted) ScoreEvent(o.phase, team, o.stake, 'mise'),
          ScoreEvent(
            o.phase,
            team,
            teamBonus((h) => evaluatePaires(h).bonus),
            'bonus',
          ),
        ];
      case BidPhase.jeu:
        return [
          if (accepted) ScoreEvent(o.phase, team, o.stake, 'mise'),
          ScoreEvent(
            o.phase,
            team,
            teamBonus((h) => evaluateJeuEtPoint(h).jeuBonus),
            'bonus',
          ),
        ];
      case BidPhase.point:
        return [
          if (accepted) ScoreEvent(o.phase, team, o.stake, 'mise'),
          // Pontua : 1 tantto (Paso général ou mise acceptée) ; 0 si Tira.
          ScoreEvent(
            o.phase,
            team,
            (allPaso || accepted) ? pontuaBonus : 0,
            'pontua',
          ),
        ];
    }
  }

  /// Siège gagnant de la sous-phase parmi [participants] (départage Esku inclus).
  int _bestSeat(BidPhase phase, List<int> participants) {
    if (participants.isEmpty) return state.eskuIndex;
    final mode = phase == BidPhase.jeu ? JeuPointMode.jeu : JeuPointMode.point;
    var best = participants.first;
    for (final s in participants.skip(1)) {
      final a = state.hands[best];
      final b = state.hands[s];
      final oa = state.eskuOrderOf(best);
      final ob = state.eskuOrderOf(s);
      final side = switch (phase) {
        BidPhase.grand => compareGrand(a, b, eskuOrderA: oa, eskuOrderB: ob),
        BidPhase.petit => comparePetit(a, b, eskuOrderA: oa, eskuOrderB: ob),
        BidPhase.paires => comparePaires(a, b, eskuOrderA: oa, eskuOrderB: ob),
        BidPhase.jeu || BidPhase.point => compareJeuEtPoint(
          a,
          b,
          eskuOrderA: oa,
          eskuOrderB: ob,
          mode: mode,
        ),
      };
      if (side == Side.b) best = s;
    }
    return best;
  }

  // -------------------------------------------------------------------------
  // Garde-fous
  // -------------------------------------------------------------------------

  void _checkSeat(int seat) {
    if (seat < 0 || seat > 3) {
      throw ArgumentError.value(seat, 'seat', 'Entre 0 et 3');
    }
  }

  void _require(MusPhase phase, int seat) {
    _checkSeat(seat);
    if (state.phase != phase) {
      throw StateError(
        'Action impossible en phase ${state.phase.name} '
        '(attendu : ${phase.name})',
      );
    }
    if (state.currentPlayer != seat) {
      throw StateError(
        'Ce n\'est pas le tour du joueur $seat '
        '(tour du joueur ${state.currentPlayer})',
      );
    }
  }
}
