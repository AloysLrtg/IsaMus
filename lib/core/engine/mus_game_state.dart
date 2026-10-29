/// État immuable d'une partie de Mus (voir `SPEC_MUS.md`).
///
/// Convention des sièges : les joueurs sont indexés de 0 à 3 ; l'équipe A est
/// formée des sièges 0 et 2, l'équipe B des sièges 1 et 3 (`teamOf(seat)` vaut
/// 0 pour A et 1 pour B). L'ordre de parole va de l'Esku vers `eskuIndex + 1`,
/// etc. (modulo 4) ; `eskuOrder` d'un siège = distance à l'Esku (0 à 3).
library;

import '../models/card.dart';
import '../models/avatar_config.dart';
import 'mus_sign.dart';
import 'bot_profile.dart';

/// Score (tantto) à atteindre pour gagner une manche.
const int mancheTarget = 40;

/// Score de victoire par défaut d'une équipe (40 points).
const int pointsToWin = 40;

/// Nombre de manches à gagner pour remporter la partie.
const int manchesToWin = 3;

/// Équipe d'un siège : 0 = A (sièges 0, 2), 1 = B (sièges 1, 3).
int teamOf(int seat) => seat % 2;

/// Phases principales d'un tour.
enum MusPhase {
  dealing,
  musDecision,
  discarding,
  bidding,
  roundScoring,
  gameOver,
}

/// Choix lors de la phase de Mus.
enum MusChoice { mus, mintza }

/// Sous-phases d'enchères.
enum BidPhase { grand, petit, paires, jeu, point }

/// Actions d'enchère.
enum BidActionType {
  paso,
  embido,
  gehiago,
  hordago,
  iduki,
  tira,
  nereGatikTira,
}

/// Étape d'une sous-phase d'enchères.
enum BidStage {
  /// Aucune mise : chacun parle à son tour (Paso / Embido / Hordago).
  opening,

  /// Une mise est sur la table : l'équipe adverse répond.
  responding,
}

/// Issue d'une sous-phase d'enchères.
enum OutcomeKind {
  /// Tous les participants ont passé.
  allPaso,

  /// Une mise a été acceptée (Iduki).
  accepted,

  /// Une mise a été refusée (Tira) : points déjà marqués.
  refused,

  /// Hordago accepté : la manche est jouée sur cette sous-phase.
  hordagoAccepted,

  /// Une seule équipe est concernée (Paires / Jeu) : pas d'enchère.
  noBidding,
}

/// Une action dans l'historique d'une sous-phase.
class BidAction {
  final int player;
  final BidActionType type;

  /// Embido : mise ; Gehiago : montant de la relance ; Hordago : 40 ; sinon 0.
  final int amount;

  const BidAction(this.player, this.type, [this.amount = 0]);

  Map<String, dynamic> toJson() => {
    'player': player,
    'type': type.name,
    'amount': amount,
  };

  factory BidAction.fromJson(Map<String, dynamic> json) => BidAction(
    json['player'] as int? ?? 0,
    BidActionType.values.firstWhere(
      (e) => e.name == json['type']?.toString(),
      orElse: () => BidActionType.paso,
    ),
    json['amount'] as int? ?? 0,
  );

  @override
  String toString() => 'P$player:${type.name}${amount > 0 ? '($amount)' : ''}';
}

/// État de la sous-phase d'enchères en cours.
class BiddingState {
  final BidPhase phase;

  /// Joueurs participant à cette sous-phase, triés par ordre de parole.
  final List<int> participants;
  final BidStage stage;

  /// Index (dans [participants]) du joueur qui parle en [BidStage.opening].
  final int openingIndex;

  /// Mise totale actuellement sur la table (0 si aucune ; 40 si Hordago).
  final int currentBid;

  /// Alias pour [currentBid] représentant le cumul exact de la mise.
  int get amount => currentBid;

  /// Mise avant la dernière relance (0 si la mise courante est la première).
  final int previousBid;
  final bool isHordago;

  /// Équipe ayant fait la dernière mise / relance.
  final int? bidderTeam;

  /// Joueurs de l'équipe qui doit répondre, triés par ordre de parole.
  final List<int> responders;
  final int responderIndex;

  /// `true` si le répondant décide après un « Nere gatik tira » de son partenaire.
  final bool partnerDecides;

  const BiddingState({
    required this.phase,
    required this.participants,
    this.stage = BidStage.opening,
    this.openingIndex = 0,
    this.currentBid = 0,
    this.previousBid = 0,
    this.isHordago = false,
    this.bidderTeam,
    this.responders = const [],
    this.responderIndex = 0,
    this.partnerDecides = false,
  });

  /// Joueur dont c'est le tour de parole.
  int get currentPlayer {
    if (stage == BidStage.opening) {
      if (participants.isEmpty) return 0;
      if (openingIndex < 0 || openingIndex >= participants.length) {
        return participants.first;
      }
      return participants[openingIndex];
    } else {
      if (responders.isEmpty) return 0;
      if (responderIndex < 0 || responderIndex >= responders.length) {
        return responders.first;
      }
      return responders[responderIndex];
    }
  }

  /// A first refusal cannot decide for an eligible teammate who has not replied.
  bool get canDeferRefusal =>
      stage == BidStage.responding &&
      !partnerDecides &&
      responderIndex + 1 < responders.length;
  BidActionType get refusalAction =>
      canDeferRefusal ? BidActionType.nereGatikTira : BidActionType.tira;

  Map<String, dynamic> toJson() => {
    'phase': phase.name,
    'participants': participants,
    'stage': stage.name,
    'openingIndex': openingIndex,
    'currentBid': currentBid,
    'previousBid': previousBid,
    'isHordago': isHordago,
    'bidderTeam': bidderTeam,
    'responders': responders,
    'responderIndex': responderIndex,
    'partnerDecides': partnerDecides,
  };

  factory BiddingState.fromJson(Map<String, dynamic> json) => BiddingState(
    phase: BidPhase.values.firstWhere(
      (e) => e.name == json['phase']?.toString(),
      orElse: () => BidPhase.grand,
    ),
    participants: (json['participants'] as List? ?? [])
        .map((p) => p as int)
        .toList(),
    stage: BidStage.values.firstWhere(
      (e) => e.name == json['stage']?.toString(),
      orElse: () => BidStage.opening,
    ),
    openingIndex: json['openingIndex'] as int? ?? 0,
    currentBid: json['currentBid'] as int? ?? 0,
    previousBid: json['previousBid'] as int? ?? 0,
    isHordago: json['isHordago'] as bool? ?? false,
    bidderTeam: json['bidderTeam'] as int?,
    responders: (json['responders'] as List? ?? [])
        .map((r) => r as int)
        .toList(),
    responderIndex: json['responderIndex'] as int? ?? 0,
    partnerDecides: json['partnerDecides'] as bool? ?? false,
  );

  BiddingState copyWith({
    BidStage? stage,
    int? openingIndex,
    int? currentBid,
    int? previousBid,
    bool? isHordago,
    int? bidderTeam,
    List<int>? responders,
    int? responderIndex,
    bool? partnerDecides,
  }) => BiddingState(
    phase: phase,
    participants: participants,
    stage: stage ?? this.stage,
    openingIndex: openingIndex ?? this.openingIndex,
    currentBid: currentBid ?? this.currentBid,
    previousBid: previousBid ?? this.previousBid,
    isHordago: isHordago ?? this.isHordago,
    bidderTeam: bidderTeam ?? this.bidderTeam,
    responders: responders ?? this.responders,
    responderIndex: responderIndex ?? this.responderIndex,
    partnerDecides: partnerDecides ?? this.partnerDecides,
  );
}

/// Résultat enregistré d'une sous-phase d'enchères terminée.
class PhaseOutcome {
  final BidPhase phase;
  final OutcomeKind kind;
  final List<int> participants;

  /// Mise acceptée (accepted : mise ; hordagoAccepted : 40 ; sinon 0).
  final int stake;

  /// Équipe qui marque les points de Tira (kind == refused).
  final int? tiraTeam;
  final int tiraPoints;

  const PhaseOutcome({
    required this.phase,
    required this.kind,
    required this.participants,
    this.stake = 0,
    this.tiraTeam,
    this.tiraPoints = 0,
  });

  Map<String, dynamic> toJson() => {
    'phase': phase.name,
    'kind': kind.name,
    'participants': participants,
    'stake': stake,
    'tiraTeam': tiraTeam,
    'tiraPoints': tiraPoints,
  };

  factory PhaseOutcome.fromJson(Map<String, dynamic> json) => PhaseOutcome(
    phase: BidPhase.values.firstWhere(
      (e) => e.name == json['phase']?.toString(),
      orElse: () => BidPhase.grand,
    ),
    kind: OutcomeKind.values.firstWhere(
      (e) => e.name == json['kind']?.toString(),
      orElse: () => OutcomeKind.allPaso,
    ),
    participants: (json['participants'] as List? ?? [])
        .map((p) => p as int)
        .toList(),
    stake: json['stake'] as int? ?? 0,
    tiraTeam: json['tiraTeam'] as int?,
    tiraPoints: json['tiraPoints'] as int? ?? 0,
  );
}

/// Un gain de tantto journalisé (Tira immédiat, décompte, Hordago).
class ScoreEvent {
  final BidPhase phase;
  final int team;
  final int points;
  final String reason;

  const ScoreEvent(this.phase, this.team, this.points, this.reason);

  Map<String, dynamic> toJson() => {
    'phase': phase.name,
    'team': team,
    'points': points,
    'reason': reason,
  };

  factory ScoreEvent.fromJson(Map<String, dynamic> json) => ScoreEvent(
    BidPhase.values.firstWhere(
      (e) => e.name == json['phase']?.toString(),
      orElse: () => BidPhase.grand,
    ),
    json['team'] as int? ?? 0,
    json['points'] as int? ?? 0,
    json['reason']?.toString() ?? '',
  );

  @override
  String toString() => '${phase.name}:team$team+$points($reason)';
}

/// Profil d'un joueur à la table (siège 0 à 3).
class MusPlayer {
  final int seat;
  final String name;
  final bool isHost;
  final bool isBot;
  final AvatarConfig? avatarConfig;
  final BotPersonality? botPersonality;

  const MusPlayer({
    required this.seat,
    this.name = '',
    this.isHost = false,
    this.isBot = false,
    this.avatarConfig,
    this.botPersonality,
  });

  Map<String, dynamic> toJson() => {
    'seat': seat,
    'name': name,
    'is_host': isHost,
    'is_bot': isBot,
    if (avatarConfig != null) 'avatar_config': avatarConfig!.toJson(),
    if (isBot && botPersonality != null)
      'bot_personality': botPersonality!.name,
  };

  factory MusPlayer.fromJson(Map<String, dynamic> json) => MusPlayer(
    seat: json['seat'] as int? ?? 0,
    name: json['name']?.toString() ?? '',
    isHost: (json['is_host'] ?? json['isHost']) as bool? ?? false,
    isBot: (json['is_bot'] ?? json['isBot']) as bool? ?? false,
    botPersonality: BotPersonality.values
        .where((p) => p.name == json['bot_personality'])
        .firstOrNull,
    avatarConfig: json['avatar_config'] == null
        ? null
        : AvatarConfig.fromJson(json['avatar_config']),
  );

  MusPlayer withAvatar(AvatarConfig config) => MusPlayer(
    seat: seat,
    name: name,
    isHost: isHost,
    isBot: isBot,
    avatarConfig: config,
    botPersonality: botPersonality,
  );

  MusPlayer withBotProfile(BotProfile profile) => MusPlayer(
    seat: seat,
    isHost: isHost,
    isBot: isBot,
    name: profile.name,
    avatarConfig: profile.avatar,
    botPersonality: profile.personality,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusPlayer &&
          runtimeType == other.runtimeType &&
          seat == other.seat &&
          name == other.name &&
          isHost == other.isHost &&
          isBot == other.isBot &&
          avatarConfig == other.avatarConfig &&
          botPersonality == other.botPersonality;

  @override
  int get hashCode =>
      Object.hash(seat, name, isHost, isBot, avatarConfig, botPersonality);
}

const Object _keep = Object();

/// État complet de la partie.
class MusGameState {
  /// Horloge logique pour la synchronisation réseau (versionning strict).
  final int version;

  final MusPhase phase;

  /// Gestes locaux de deux secondes : jamais sérialisés ni écrits dans games.
  final Map<int, MusSign> signs;
  final Map<int, int> signRevisions;

  /// Siège de l'Esku (à droite du donneur).
  final int eskuIndex;

  /// Mains des 4 sièges.
  final List<List<Card>> hands;

  /// Talon (cartes restantes à distribuer).
  final List<Card> talon;

  /// Cartes défaussées au tour de Mus courant (non encore remélangées).
  /// Les cartes défaussées lors des tours précédents sont hors jeu
  /// (SPEC §4.1 : seules celles « de ce tour » reconstituent le talon).
  final List<Card> discardPile;

  /// Choix de Mus faits pendant le tour de Mus courant, dans l'ordre.
  final List<MusChoice> musVotes;

  /// Siège dont c'est le tour (musDecision / discarding / bidding).
  final int currentPlayer;

  /// `true` dès qu'un joueur a dit Mintza : plus aucun échange de cartes.
  final bool deckLocked;

  /// Défausses choisies (siège → indices de cartes dans la main).
  final Map<int, List<int>> discardSelections;

  /// Sous-phase d'enchères en cours (null hors enchères).
  final BiddingState? bidding;

  /// Historique des actions, par sous-phase.
  final Map<BidPhase, List<BidAction>> bidHistory;

  /// Issues des sous-phases terminées.
  final Map<BidPhase, PhaseOutcome> outcomes;

  /// Journal des gains de tantto de la main (Tira, décompte, Hordago).
  final List<ScoreEvent> scoreLog;

  /// Tantto de la manche en cours : [A, B].
  final List<int> tantto;

  /// Manches gagnées : [A, B].
  final List<int> manches;

  /// Équipe ayant gagné la manche qui vient de se terminer (null sinon).
  final int? mancheWinner;

  /// Siège du joueur ayant émis la dernière action (pour la synchronisation réseau).
  final int? lastActionSeat;

  /// Les 4 joueurs de la table (sièges 0 à 3).
  final List<MusPlayer> players;

  const MusGameState({
    this.version = 0,
    this.signs = const {},
    this.signRevisions = const {},
    required this.phase,
    required this.eskuIndex,
    required this.hands,
    required this.talon,
    required this.discardPile,
    required this.musVotes,
    required this.currentPlayer,
    required this.deckLocked,
    required this.discardSelections,
    required this.bidding,
    required this.bidHistory,
    required this.outcomes,
    required this.scoreLog,
    required this.tantto,
    required this.manches,
    required this.mancheWinner,
    this.lastActionSeat,
    this.players = const [],
  });

  /// Joueurs par défaut pour une partie solo/locale.
  static List<MusPlayer> defaultPlayers() => [
    const MusPlayer(seat: 0, name: 'Vous', isHost: true),
    for (var i = 0; i < BotProfile.profiles.length; i++)
      MusPlayer(
        seat: i + 1,
        isBot: true,
      ).withBotProfile(BotProfile.profiles[i]),
  ];

  factory MusGameState.initial({List<MusPlayer>? players}) => MusGameState(
    version: 0,
    phase: MusPhase.dealing,
    eskuIndex: 0,
    hands: const [[], [], [], []],
    talon: const [],
    discardPile: const [],
    musVotes: const [],
    currentPlayer: 0,
    deckLocked: false,
    discardSelections: const {},
    bidding: null,
    bidHistory: const {},
    outcomes: const {},
    scoreLog: const [],
    tantto: const [0, 0],
    manches: const [0, 0],
    mancheWinner: null,
    lastActionSeat: null,
    players: players ?? MusGameState.defaultPlayers(),
  );

  /// Indique si un siège est occupé par un bot.
  bool isBot(int seat) {
    if (seat < 0 || seat >= players.length) return false;
    return players[seat].isBot;
  }

  /// Distance d'un siège à l'Esku dans le sens anti-horaire, vers la droite
  /// (0 = Esku … 3 = donneur).
  int eskuOrderOf(int seat) => (eskuIndex - seat + 4) % 4;

  /// Alias deck pour le talon de cartes
  List<Card> get deck => talon;

  /// Les signes et leur expiration ne changent pas le tour de parole.
  /// Sert aux actions différées et aux dialogues de saisie de mise.
  bool hasSameTurnAs(MusGameState other) =>
      phase == other.phase &&
      currentPlayer == other.currentPlayer &&
      identical(hands, other.hands) &&
      identical(bidding, other.bidding) &&
      identical(musVotes, other.musVotes) &&
      identical(discardSelections, other.discardSelections);

  bool get canSignal =>
      phase == MusPhase.musDecision ||
      phase == MusPhase.discarding ||
      phase == MusPhase.bidding;

  /// Le 29 est interdit pendant Mus, Grande, Petite et Paires.
  List<MusSign> availableSignsForSeat(int seat) =>
      !canSignal || seat < 0 || seat >= hands.length
      ? const []
      : availableMusSigns(
          hands[seat],
          pairsResolved:
              phase == MusPhase.bidding &&
              (bidding?.phase == BidPhase.jeu ||
                  bidding?.phase == BidPhase.point),
        );

  /// Score total de l'équipe A (tantto).
  int get teamAScore => tantto.isNotEmpty ? tantto[0] : 0;

  /// Score total de l'équipe B (tantto).
  int get teamBScore => tantto.length > 1 ? tantto[1] : 0;

  /// Indique si la partie entière est terminée (gameOver ou 40 points atteints).
  bool get isGameOver =>
      phase == MusPhase.gameOver ||
      teamAScore >= pointsToWin ||
      teamBScore >= pointsToWin ||
      gameWinner != null;

  /// Équipe gagnante de la partie (null tant qu'elle n'est pas terminée).
  int? get gameWinner {
    for (var t = 0; t < 2; t++) {
      if (manches[t] >= manchesToWin ||
          (tantto.length > t && tantto[t] >= pointsToWin)) {
        return t;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson({int? lastActionSeat}) => {
    'version': version,
    'phase': phase.name,
    'eskuIndex': eskuIndex,
    'hands': hands.map((h) => h.map((c) => c.toJson()).toList()).toList(),
    'talon': talon.map((c) => c.toJson()).toList(),
    'discardPile': discardPile.map((c) => c.toJson()).toList(),
    'musVotes': musVotes.map((v) => v.name).toList(),
    'currentPlayer': currentPlayer,
    'deckLocked': deckLocked,
    'discardSelections': discardSelections.map(
      (k, v) => MapEntry(k.toString(), v),
    ),
    'bidding': bidding?.toJson(),
    'bidHistory': bidHistory.map(
      (k, v) => MapEntry(k.name, v.map((a) => a.toJson()).toList()),
    ),
    'outcomes': outcomes.map((k, v) => MapEntry(k.name, v.toJson())),
    'scoreLog': scoreLog.map((s) => s.toJson()).toList(),
    'tantto': tantto,
    'manches': manches,
    'mancheWinner': mancheWinner,
    'lastActionSeat': lastActionSeat ?? this.lastActionSeat,
    'players': players.map((p) => p.toJson()).toList(),
  };

  factory MusGameState.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 0;
    final phase = MusPhase.values.firstWhere(
      (e) => e.name == json['phase']?.toString(),
      orElse: () => MusPhase.dealing,
    );

    final eskuIndex = json['eskuIndex'] as int? ?? 0;

    final rawHands = json['hands'] as List? ?? [];
    final List<List<Card>> hands = [
      for (var i = 0; i < 4; i++)
        if (i < rawHands.length && rawHands[i] is List)
          [
            for (final c in rawHands[i] as List)
              if (c is Map) Card.fromJson(Map<String, dynamic>.from(c)),
          ]
        else
          [],
    ];

    final rawTalon = json['talon'] as List? ?? [];
    final List<Card> talon = [
      for (final c in rawTalon)
        if (c is Map) Card.fromJson(Map<String, dynamic>.from(c)),
    ];

    final rawDiscardPile = json['discardPile'] as List? ?? [];
    final List<Card> discardPile = [
      for (final c in rawDiscardPile)
        if (c is Map) Card.fromJson(Map<String, dynamic>.from(c)),
    ];

    final rawVotes = json['musVotes'] as List? ?? [];
    final List<MusChoice> musVotes = [
      for (final v in rawVotes)
        MusChoice.values.firstWhere(
          (e) => e.name == v.toString(),
          orElse: () => MusChoice.mus,
        ),
    ];

    final currentPlayer = json['currentPlayer'] as int? ?? eskuIndex;
    final deckLocked = json['deckLocked'] as bool? ?? false;

    final rawDiscards = json['discardSelections'];
    final Map<int, List<int>> discardSelections = {};
    if (rawDiscards is Map) {
      for (final entry in rawDiscards.entries) {
        final key = int.tryParse(entry.key.toString());
        if (key != null && entry.value is List) {
          discardSelections[key] = List<int>.from(entry.value as List);
        }
      }
    }

    final rawBidding = json['bidding'];
    final BiddingState? bidding = rawBidding is Map
        ? BiddingState.fromJson(Map<String, dynamic>.from(rawBidding))
        : null;

    final rawHistory = json['bidHistory'];
    final Map<BidPhase, List<BidAction>> bidHistory = {};
    if (rawHistory is Map) {
      for (final entry in rawHistory.entries) {
        try {
          final phaseKey = BidPhase.values.firstWhere(
            (e) => e.name == entry.key.toString(),
            orElse: () => BidPhase.grand,
          );
          if (entry.value is List) {
            bidHistory[phaseKey] = [
              for (final a in entry.value as List)
                if (a is Map) BidAction.fromJson(Map<String, dynamic>.from(a)),
            ];
          }
        } catch (_) {}
      }
    }

    final rawOutcomes = json['outcomes'];
    final Map<BidPhase, PhaseOutcome> outcomes = {};
    if (rawOutcomes is Map) {
      for (final entry in rawOutcomes.entries) {
        try {
          final phaseKey = BidPhase.values.firstWhere(
            (e) => e.name == entry.key.toString(),
            orElse: () => BidPhase.grand,
          );
          if (entry.value is Map) {
            outcomes[phaseKey] = PhaseOutcome.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            );
          }
        } catch (_) {}
      }
    }

    final rawScores = json['scoreLog'] as List? ?? [];
    final List<ScoreEvent> scoreLog = [
      for (final s in rawScores)
        if (s is Map) ScoreEvent.fromJson(Map<String, dynamic>.from(s)),
    ];

    final rawTantto = json['tantto'] as List? ?? [0, 0];
    final List<int> tantto = [
      rawTantto.isNotEmpty ? (rawTantto[0] as int? ?? 0) : 0,
      rawTantto.length > 1 ? (rawTantto[1] as int? ?? 0) : 0,
    ];

    final rawManches = json['manches'] as List? ?? [0, 0];
    final List<int> manches = [
      rawManches.isNotEmpty ? (rawManches[0] as int? ?? 0) : 0,
      rawManches.length > 1 ? (rawManches[1] as int? ?? 0) : 0,
    ];

    final mancheWinner = json['mancheWinner'] as int?;
    final lastActionSeat = json['lastActionSeat'] as int?;

    final rawPlayers = json['players'] as List? ?? [];
    final List<MusPlayer> players = rawPlayers.isNotEmpty
        ? [
            for (var i = 0; i < 4; i++)
              if (i < rawPlayers.length && rawPlayers[i] is Map)
                MusPlayer.fromJson(
                  Map<String, dynamic>.from(rawPlayers[i] as Map),
                )
              else
                MusPlayer(seat: i, isHost: i == 0, isBot: i != 0),
          ]
        : MusGameState.defaultPlayers();

    return MusGameState(
      version: version,
      phase: phase,
      eskuIndex: eskuIndex,
      hands: hands,
      talon: talon,
      discardPile: discardPile,
      musVotes: musVotes,
      currentPlayer: currentPlayer,
      deckLocked: deckLocked,
      discardSelections: discardSelections,
      bidding: bidding,
      bidHistory: bidHistory,
      outcomes: outcomes,
      scoreLog: scoreLog,
      tantto: tantto,
      manches: manches,
      mancheWinner: mancheWinner,
      lastActionSeat: lastActionSeat,
      players: players,
    );
  }

  MusGameState copyWith({
    int? version,
    Map<int, MusSign>? signs,
    Map<int, int>? signRevisions,
    MusPhase? phase,
    int? eskuIndex,
    List<List<Card>>? hands,
    List<Card>? talon,
    List<Card>? discardPile,
    List<MusChoice>? musVotes,
    int? currentPlayer,
    bool? deckLocked,
    Map<int, List<int>>? discardSelections,
    Object? bidding = _keep,
    Map<BidPhase, List<BidAction>>? bidHistory,
    Map<BidPhase, PhaseOutcome>? outcomes,
    List<ScoreEvent>? scoreLog,
    List<int>? tantto,
    List<int>? manches,
    Object? mancheWinner = _keep,
    Object? lastActionSeat = _keep,
    List<MusPlayer>? players,
  }) => MusGameState(
    version: version ?? this.version,
    signs: signs ?? this.signs,
    signRevisions: signRevisions ?? this.signRevisions,
    phase: phase ?? this.phase,
    eskuIndex: eskuIndex ?? this.eskuIndex,
    hands: hands ?? this.hands,
    talon: talon ?? this.talon,
    discardPile: discardPile ?? this.discardPile,
    musVotes: musVotes ?? this.musVotes,
    currentPlayer: currentPlayer ?? this.currentPlayer,
    deckLocked: deckLocked ?? this.deckLocked,
    discardSelections: discardSelections ?? this.discardSelections,
    bidding: identical(bidding, _keep)
        ? this.bidding
        : bidding as BiddingState?,
    bidHistory: bidHistory ?? this.bidHistory,
    outcomes: outcomes ?? this.outcomes,
    scoreLog: scoreLog ?? this.scoreLog,
    tantto: tantto ?? this.tantto,
    manches: manches ?? this.manches,
    mancheWinner: identical(mancheWinner, _keep)
        ? this.mancheWinner
        : mancheWinner as int?,
    lastActionSeat: identical(lastActionSeat, _keep)
        ? this.lastActionSeat
        : lastActionSeat as int?,
    players: players ?? this.players,
  );
}
