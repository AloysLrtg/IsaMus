import 'table_chat_sheets.dart';
import 'card_back_view.dart';
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/mus_evaluator.dart';
import '../../core/engine/mus_game_controller.dart';
import '../../core/engine/mus_game_state.dart';
import '../../core/engine/mus_sign.dart';
import '../../core/engine/mus_table_feedback.dart';
import '../../core/models/card.dart' as mus;
import '../../core/network/supabase_repository.dart';
import '../../l10n/app_localizations.dart';
import 'game_over_overlay.dart';
import '../../core/network/player_repository.dart';
import '../../core/network/social_repository.dart';
import '../../core/network/auth_repository.dart';
import '../../core/network/presence_service.dart';
import '../../core/audio/audio_haptic_service.dart';
import '../profile/profile_tab.dart';
import '../home/main_dashboard_screen.dart';
import '../../core/models/avatar_config.dart';
import '../avatar/player_avatar_view.dart';
import '../profile/player_inspection_dialog.dart';
import '../tutorial/tutorial_game_controller.dart';
import '../tutorial/tutorial_actions_view.dart';
import '../settings/settings_screen.dart';

enum _GameMenuAction { settings, quit }

const _scaffoldBg = Color(0xFF0B1221);
const _tableGreenEdge = Color(0xFF032619);
const _gold = Color(0xFFFFD54F);
const _cyanA = Color(0xFF38BDF8);
const _orangeB = Color(0xFFFB923C);
const _deepGreen = Color(0xFF0A3829);

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    this.gameId,
    this.localSeat = 0,
    this.playerNames,
    this.players,
    this.mode = 'casual',
    this.userId,
    this.initialElo,
    this.publicMatchmaking = false,
    this.initialGame,
  }) : assert(localSeat >= 0 && localSeat < 4),
       assert(playerNames == null || playerNames.length == 4);

  final String? gameId;
  final int localSeat;
  final List<String>? playerNames;
  final List<dynamic>? players;
  final String mode;
  final String? userId;
  final int? initialElo;
  final bool publicMatchmaking;
  final Map<String, dynamic>? initialGame;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _selected = <int>{};
  StreamSubscription<Map<String, dynamic>>? _gameSubscription;
  Timer? _queueTimer;
  Duration _queueElapsed = Duration.zero;
  late String _mode = widget.mode;
  late List<dynamic> _roster = widget.players ?? const [];
  PresenceService? _presence;
  MusGameController? _signController;
  bool _confirmingExit = false;
  bool _quitting = false;
  bool _returningHome = false;
  bool _rosterReady = false;
  bool _settingsOpen = false;
  String? _queueError;
  bool _receivedRoomSnapshot = false;
  bool get _waitingForPublic => widget.publicMatchmaking && !_rosterReady;

  final _speechLinks = {for (var seat = 0; seat < 4; seat++) seat: LayerLink()};
  final _chatRoomFinished = ValueNotifier<bool>(false);
  bool _chatEnabled(MusGameState state) =>
      !_returningHome &&
      !_chatRoomFinished.value &&
      state.phase != MusPhase.gameOver;
  bool get _canChat => _chatEnabled(ref.read(musGameControllerProvider));
  Widget _chatSheet(Widget Function(bool enabled) builder) =>
      ValueListenableBuilder<bool>(
        valueListenable: _chatRoomFinished,
        builder: (_, _, _) => Consumer(
          builder: (_, ref, _) =>
              builder(_chatEnabled(ref.watch(musGameControllerProvider))),
        ),
      );

  void _subscribeGame() {
    _gameSubscription = ref
        .read(supabaseRepositoryProvider)
        .streamGame(widget.gameId!)
        .listen(
          _handleRemoteGameUpdate,
          onError: (Object error) {
            if (mounted && widget.publicMatchmaking && !_returningHome) {
              setState(() => _queueError = 'Connexion interrompue. Réessayez.');
            }
          },
        );
  }

  void _stopQueueTimer() {
    _queueTimer?.cancel();
    _queueTimer = null;
  }

  void _syncQueueTimer() {
    if (!_waitingForPublic || _quitting || _returningHome) {
      _stopQueueTimer();
      return;
    }
    if (_queueTimer != null) return;
    final base = _queueElapsed.inSeconds;
    _queueTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_waitingForPublic || _quitting || _returningHome) {
        _stopQueueTimer();
        return;
      }
      setState(() => _queueElapsed = Duration(seconds: base + timer.tick));
    });
  }

  String get _queueElapsedLabel =>
      '${_queueElapsed.inMinutes}:${(_queueElapsed.inSeconds % 60).toString().padLeft(2, '0')}';

  Future<void> _cancelPublicQueue() async {
    if (_quitting || _returningHome || widget.gameId == null) return;
    setState(() => _quitting = true);
    _stopQueueTimer();
    try {
      await ref
          .read(supabaseRepositoryProvider)
          .leavePublicQueue(widget.gameId!);
      if (mounted) await _goHome();
    } catch (_) {
      if (mounted) {
        setState(() {
          _quitting = false;
          _queueError = 'Annulation impossible : la partie est peut-être déjà prête. Réessayez.';
        });
        _syncQueueTimer();
      }
    }
  }

  MusGameController get _controller =>
      ref.read(musGameControllerProvider.notifier);

  bool _canDiscard(MusGameState s) =>
      s.phase == MusPhase.discarding &&
      s.currentPlayer == widget.localSeat &&
      !s.discardSelections.containsKey(widget.localSeat);

  @override
  void initState() {
    super.initState();
    _initMultiplayer();
    _syncQueueTimer();
    final initial = ref.read(musGameControllerProvider);
    if (initial.canSignal && initial.hands.any((hand) => hand.isNotEmpty)) {
      unawaited(
        ref.read(audioHapticServiceProvider).playSound(GameSounds.deal),
      );
    }
    _presence = ref.read(presenceServiceProvider);
    unawaited(_presence!.setInGame(true));
  }

  void _initMultiplayer() {
    _signController = _controller;
    _controller.configureMultiplayer(
      gameId: widget.gameId,
      localSeat: widget.localSeat,
      players: widget.players,
    );

    if (widget.gameId != null) {
      _subscribeGame();
      if (widget.initialGame != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_returningHome && !_receivedRoomSnapshot) {
            _handleRemoteGameUpdate(widget.initialGame!);
          }
        });
      }
    }
  }

  void _handleRemoteGameUpdate(Map<String, dynamic> gameData) {
    if (!mounted || _returningHome) return;
    _receivedRoomSnapshot = true;
    _chatRoomFinished.value =
        gameData['status'] == 'finished' || gameData['status'] == 'cancelled';
    if (gameData['status'] == 'cancelled') {
      _stopQueueTimer();
      if (!_quitting) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _goHome(message: 'L’hôte a fermé le salon.');
        });
        WidgetsBinding.instance.ensureVisualUpdate();
      }
      return;
    }
    if (gameData['mode'] != null) {
      _mode = gameData['mode'].toString();
    }
    if (gameData['players'] is List) {
      final roster = List<dynamic>.from(gameData['players'] as List);
      setState(() {
        _roster = roster;
        _rosterReady =
            roster.length == 4 &&
            (!widget.publicMatchmaking ||
                gameData['status'] == 'ready' ||
                gameData['status'] == 'playing');
        _queueError = null;
      });
      _syncQueueTimer();
      _controller.configureMultiplayer(
        gameId: widget.gameId,
        localSeat: widget.localSeat,
        players: roster,
      );
    }
    // The host must read the canonical bot portraits BEFORE publishing a deal.
    if (_controller.isHost &&
        gameData['status'] == 'ready' &&
        _roster.length == 4 &&
        gameData['game_state'] is! Map) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            !_returningHome &&
            _rosterReady &&
            ref.read(musGameControllerProvider).phase == MusPhase.dealing) {
          _controller.startGame();
        }
      });
    }
    final rawState = gameData['game_state'];
    if (rawState is! Map) return;

    final remoteJson = Map<String, dynamic>.from(rawState);
    if (!remoteJson.containsKey('players') && gameData['players'] is List) {
      remoteJson['players'] = gameData['players'];
    }
    final lastActionSeat = remoteJson['lastActionSeat'] as int?;

    // Éviter les boucles : si la dernière action vient du joueur local, ne pas réécraser
    if (lastActionSeat == widget.localSeat) return;

    final localJson = ref.read(musGameControllerProvider).toJson();
    if (jsonEncode(localJson) != jsonEncode(remoteJson)) {
      try {
        final remoteState = MusGameState.fromJson(remoteJson);
        _controller.syncFromRemote(remoteState);
      } catch (_) {
        // Ignorer si payload incompatible
      }
    }
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localSeat != widget.localSeat ||
        oldWidget.gameId != widget.gameId) {
      _selected.clear();
      _roster = widget.players ?? const [];
      _rosterReady = false;
      _controller.configureMultiplayer(
        gameId: widget.gameId,
        localSeat: widget.localSeat,
        players: widget.players,
      );
      if (oldWidget.gameId != widget.gameId) {
        unawaited(_gameSubscription?.cancel());
        _stopQueueTimer();
        _queueElapsed = Duration.zero;
        if (widget.gameId != null) {
          _receivedRoomSnapshot = false;
          _queueError = null;
          _subscribeGame();
        }
        _syncQueueTimer();
      }
    }
  }

  @override
  void dispose() {
    _chatRoomFinished.dispose();
    _stopQueueTimer();
    _signController?.disconnectSignChannel();
    unawaited(_gameSubscription?.cancel());
    unawaited(_presence?.setInGame(false) ?? Future.value());
    super.dispose();
  }

  Future<void> _openSigns() async {
    final state = ref.read(musGameControllerProvider);
    if (!state.canSignal) return;
    final signs = state.availableSignsForSeat(widget.localSeat);
    final options = [
      MusSign.twoKings,
      MusSign.twoAces,
      MusSign.mediak,
      signs.contains(MusSign.dobliak) ? MusSign.dobliak : MusSign.twentyNine,
      signs.contains(MusSign.thirty) ? MusSign.thirty : MusSign.thirtyOne,
      MusSign.game,
    ];
    final l = AppLocalizations.of(context)!;
    final chosen = await showModalBottomSheet<MusSign>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Keinuak',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (_, constraints) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final sign in options)
                        SizedBox(
                          width: math.min(160, (constraints.maxWidth - 8) / 2),
                          child: FilledButton.tonal(
                            key: ValueKey('send-sign-${sign.name}'),
                            onPressed: signs.contains(sign)
                                ? () => Navigator.pop(sheetContext, sign)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.face_outlined),
                                  Text(_signName(sign, l)),
                                  Text(
                                    sign.gesture,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (mounted && chosen != null) await _sendSign(chosen);
  }

  Future<void> _sendSign(MusSign sign) async {
    try {
      await _controller.sendSign(sign.name);
      unawaited(
        ref
            .read(audioHapticServiceProvider)
            .feedback(GameSounds.tap, impact: HapticImpact.light),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Signe non transmis. Vérifiez votre connexion ou votre main.',
          ),
        ),
      );
    }
  }

  Future<void> _openSettings() async {
    if (_settingsOpen || _quitting || _returningHome) return;
    _settingsOpen = true;
    try {
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    } finally {
      _settingsOpen = false;
    }
  }

  Future<void> _confirmExit() async {
    if (_waitingForPublic) {
      await _cancelPublicQueue();
      return;
    }
    if (_confirmingExit || _quitting || _returningHome) return;
    _confirmingExit = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(dialogContext)!.gameQuitTitle),
        content: Text(AppLocalizations.of(dialogContext)!.gameQuitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(dialogContext)!.menuCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppLocalizations.of(dialogContext)!.gameQuitAction),
          ),
        ],
      ),
    );
    _confirmingExit = false;
    if (confirmed != true || !mounted || _returningHome) return;
    setState(() => _quitting = true);
    try {
      if (widget.gameId != null && _controller.isHost) {
        await ref.read(supabaseRepositoryProvider).closeGame(widget.gameId!);
      }
      if (mounted) await _goHome();
    } catch (_) {
      if (!mounted) return;
      setState(() => _quitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.gameQuitFailed)),
      );
    }
  }

  Future<void> _goHome({String? message}) async {
    if (!mounted || _returningHome) return;
    setState(() => _returningHome = true);
    _stopQueueTimer();
    // Cancellation stops delivery immediately; do not block navigation on
    // the underlying Realtime channel cleanup.
    unawaited(_gameSubscription?.cancel());
    _gameSubscription = null;
    if (!mounted) return;
    ref.invalidate(musGameControllerProvider);
    ref.invalidate(musTableFeedbackProvider);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainDashboardScreen()),
      (_) => false,
    );
    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String? _playerId(int seat) {
    for (final player in _roster) {
      if (player is Map &&
          player['seat'] == seat &&
          AuthRepository.isValidUuid(player['id']?.toString())) {
        return player['id'].toString();
      }
    }
    return null;
  }

  AvatarConfig _avatarConfig(int seat, MusGameState state) {
    if (seat == widget.localSeat && !_controller.isBot(seat)) {
      final profile = ref.watch(playerProfileProvider).asData?.value;
      if (profile?['avatar_config'] != null) {
        return AvatarConfig.fromJson(profile!['avatar_config']);
      }
    }
    for (final player in _roster) {
      if (player is Map &&
          player['seat'] == seat &&
          player['avatar_config'] != null) {
        return AvatarConfig.fromJson(player['avatar_config']);
      }
    }
    return state.players
            .where((p) => p.seat == seat)
            .firstOrNull
            ?.avatarConfig ??
        AvatarConfig.forSeat(seat);
  }

  String _name(int seat, AppLocalizations l) {
    if (seat < 0 || seat > 3) return '';
    final player = ref.read(musGameControllerProvider).players[seat];
    if (seat != widget.localSeat &&
        _controller.isBot(seat) &&
        player.isBot &&
        player.name.isNotEmpty) {
      return player.name;
    }
    if (widget.publicMatchmaking) {
      final name = _roster
          .whereType<Map>()
          .where((p) => p['seat'] == seat)
          .firstOrNull?['name']
          ?.toString();
      if (name != null && name.trim().isNotEmpty) return name;
    }
    return widget.playerNames?[seat] ??
        switch ((seat - widget.localSeat + 4) % 4) {
          0 => l.you,
          2 => l.partner,
          1 => l.opponentShort(1),
          _ => l.opponentShort(2),
        };
  }

  String _team(int team, AppLocalizations l) => l.team(team == 0 ? 'A' : 'B');

  void _perform(VoidCallback action) {
    try {
      action();
    } on StateError {
      _actionError();
    } on ArgumentError {
      _actionError();
    }
  }

  void _actionError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.actionFailed)),
    );
  }

  Future<void> _openBids() async {
    final snapshot = ref.read(musGameControllerProvider);
    final result = await showModalBottomSheet<_BidSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _BidSheet(snapshot: snapshot),
    );
    if (!mounted || result == null) return;
    if (!ref.read(musGameControllerProvider).hasSameTurnAs(snapshot)) {
      _actionError();
      return;
    }
    _perform(
      () => _controller.act(
        widget.localSeat,
        result.action,
        amount: result.amount,
      ),
    );
  }

  Future<void> _openChat() async {
    if (!_canChat) return;
    final l = AppLocalizations.of(context)!;
    FocusManager.instance.primaryFocus?.unfocus();
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _chatSheet(
        (enabled) => QuickChatSheet(
          enabled: enabled,
          label: (chat) => _chatName(chat, l),
          onSend: (chat) async {
            if (!_canChat) throw StateError('La partie est terminée.');
            await _controller.sendQuickChat(widget.localSeat, chat);
            if (mounted) {
              unawaited(
                ref
                    .read(audioHapticServiceProvider)
                    .feedback(GameSounds.tap, impact: HapticImpact.light),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _openTextChat() async {
    if (!_canChat) return;
    final l = AppLocalizations.of(context)!;
    final names = [for (var seat = 0; seat < 4; seat++) _name(seat, l)];
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => _chatSheet(
        (enabled) => TextChatSheet(
          enabled: enabled,
          names: names,
          quickLabel: (chat) => _chatName(chat, l),
          onSend: (text) async {
            if (!_canChat) throw StateError('La partie est terminée.');
            await _controller.sendTextChat(text);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_returningHome) {
      return const Scaffold(backgroundColor: _scaffoldBg);
    }
    final state = ref.watch(musGameControllerProvider);
    final l = AppLocalizations.of(context)!;
    ref.listen<MusGameState>(musGameControllerProvider, (previous, next) {
      final effects = ref.read(audioHapticServiceProvider);
      final wonMatch =
          next.phase == MusPhase.gameOver &&
          previous?.phase != next.phase &&
          next.gameWinner == widget.localSeat % 2;
      final wonRound =
          next.mancheWinner == widget.localSeat % 2 &&
          previous?.mancheWinner != next.mancheWinner;
      if (wonMatch || wonRound) {
        unawaited(
          effects.feedback(GameSounds.victory, impact: HapticImpact.heavy),
        );
      } else if ((previous == null ||
              !listEquals(
                previous.hands.expand((hand) => hand).toList(),
                next.hands.expand((hand) => hand).toList(),
              )) &&
          next.hands.any((hand) => hand.isNotEmpty) &&
          next.phase != MusPhase.gameOver) {
        unawaited(effects.playSound(GameSounds.deal));
      }
      if (!_canDiscard(next) ||
          previous?.phase != next.phase ||
          !identical(previous?.hands, next.hands)) {
        if (_selected.isNotEmpty) setState(_selected.clear);
      }
    });
    ref.listen<TableFeedback>(musTableFeedbackProvider, (previous, next) {
      for (final entry in next.speeches.entries) {
        if (identical(previous?.speeches[entry.key], entry.value)) continue;
        final speech = entry.value;
        final intense = speech.action == BidActionType.hordago;
        final sound = switch (speech.kind) {
          SpeechKind.mus || SpeechKind.mintza => GameSounds.tap,
          SpeechKind.discard => GameSounds.cardSlide,
          SpeechKind.bid =>
            intense
                ? GameSounds.hordago
                : speech.action == BidActionType.paso ||
                      (speech.action == BidActionType.tira ||
                          speech.action == BidActionType.nereGatikTira)
                ? GameSounds.tap
                : GameSounds.chips,
          SpeechKind.chat || SpeechKind.custom || SpeechKind.freeChat => null,
        };
        if (sound != null) {
          unawaited(
            ref
                .read(audioHapticServiceProvider)
                .feedback(
                  sound,
                  impact: intense
                      ? HapticImpact.heavy
                      : entry.key == widget.localSeat
                      ? HapticImpact.light
                      : null,
                ),
          );
        }
      }
    });
    final showGameOver = state.phase == MusPhase.gameOver;
    final showChatDock = state.phase == MusPhase.roundScoring;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: _scaffoldBg,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    key: const ValueKey('game-board-stack'),
                    fit: StackFit.expand,
                    children: [
                      SafeArea(
                        maintainBottomViewPadding: true,
                        bottom: !showChatDock,
                        child: DefaultTextStyle.merge(
                          style: const TextStyle(color: Colors.white),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final compact =
                                  MediaQuery.sizeOf(context).height -
                                      MediaQuery.viewPaddingOf(context)
                                          .vertical <
                                  480;
                              return Column(
                                children: [
                                  _scores(state, l, compact),
                                  Expanded(child: _table(state, l, compact)),
                                  _localTray(state, l, compact),
                                  if (state.phase != MusPhase.roundScoring)
                                    _actions(
                                      state,
                                      l,
                                      compact,
                                      scoringSummaryMaxHeight: math.min(
                                        compact ? 64.0 : 150.0,
                                        constraints.maxHeight *
                                            (compact ? .16 : .24),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      if (_waitingForPublic) _publicQueueOverlay(),
                      if (state.bidding?.isHordago == true && !showGameOver)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey(
                                'hordago-${state.bidding?.phase.name}',
                              ),
                              tween: Tween(begin: 1, end: 0),
                              duration: const Duration(milliseconds: 1800),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Center(
                                  child: Transform.scale(
                                    scale: 1 + (1 - value) * 0.4,
                                    child: child,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'HORDAGO !',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: _gold,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (showGameOver)
                        GameOverOverlay(
                          state: state,
                          gameId: widget.gameId,
                          localSeat: widget.localSeat,
                          mode: _mode,
                          userId: widget.userId,
                          playerElo: widget.initialElo,
                        ),
                    ],
                  ),
                ),
                if (showChatDock) _debriefChatBar(state, l),
              ],
            ),
            if (state.phase == MusPhase.roundScoring && _chatEnabled(state))
              _revealSpeechOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _revealSpeechOverlay() => Positioned.fill(
    child: IgnorePointer(
      child: Stack(
        key: const ValueKey('reveal-speech-overlay'),
        clipBehavior: Clip.none,
        children: [
          for (var offset = 0; offset < 4; offset++)
            CompositedTransformFollower(
              link: _speechLinks[(widget.localSeat + offset) % 4]!,
              showWhenUnlinked: false,
              targetAnchor: offset == 3
                  ? Alignment.topRight
                  : offset == 2
                  ? Alignment.topCenter
                  : Alignment.topLeft,
              followerAnchor: offset == 3
                  ? Alignment.bottomRight
                  : offset == 2
                  ? Alignment.bottomCenter
                  : Alignment.bottomLeft,
              offset: const Offset(0, -4),
              child: SizedBox(
                width: math.min(150, MediaQuery.sizeOf(context).width * .42),
                child: _SpeechBubble(
                  seat: (widget.localSeat + offset) % 4,
                  compact: false,
                  floating: true,
                  alignment: offset == 3
                      ? Alignment.centerRight
                      : offset == 2
                      ? Alignment.center
                      : Alignment.centerLeft,
                ),
              ),
            ),
        ],
      ),
    ),
  );

  // Normal flex layout: the recap and communication controls have disjoint widths.
  Widget _debriefChatBar(MusGameState state, AppLocalizations l) {
    final usableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewPaddingOf(context).vertical;
    final compact = usableHeight < 480;
    return Material(
      key: const ValueKey('debrief-chat-bar'),
      color: _scaffoldBg,
      child: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            key: const ValueKey('reveal-footer-row'),
            children: [
              Expanded(
                child: ConstrainedBox(
                  key: const ValueKey('round-scoring-hitbox'),
                  constraints: const BoxConstraints(minHeight: 52),
                  child: _actions(
                    state,
                    l,
                    compact,
                    scoringSummaryMaxHeight: math.min(
                      compact ? 64.0 : 150.0,
                      usableHeight * (compact ? .16 : .24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                key: const ValueKey('reveal-chat-hitbox'),
                width: 104,
                height: 52,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _socialButtons(state, l),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _publicQueueOverlay() => Positioned.fill(
    key: const ValueKey('public-queue-overlay'),
    child: Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: ColoredBox(color: Colors.black.withValues(alpha: .6)),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_queueError == null)
                        const SizedBox.square(
                          dimension: 36,
                          child: CircularProgressIndicator(),
                        )
                      else
                        const Icon(Icons.wifi_off_rounded, size: 36),
                      const SizedBox(height: 20),
                      Text(
                        'En attente des joueurs (${_roster.length.clamp(0, 4)}/4)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Temps écoulé : $_queueElapsedLabel',
                        key: const ValueKey('queue-elapsed-time'),
                      ),
                      if (_queueError != null) ...[
                        const SizedBox(height: 12),
                        Text(_queueError!, textAlign: TextAlign.center),
                        TextButton(
                          onPressed: () {
                            setState(() => _queueError = null);
                            unawaited(_gameSubscription?.cancel());
                            _subscribeGame();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                      const SizedBox(height: 20),
                      OutlinedButton(
                        key: const ValueKey('cancel-public-queue'),
                        onPressed: _quitting ? null : _cancelPublicQueue,
                        child: Text(_quitting ? 'Annulation…' : 'Annuler'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _scores(MusGameState s, AppLocalizations l, bool compact) => Padding(
    padding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Row(
                key: const ValueKey('game-scores'),
                children: [
                  for (var team = 0; team < 2; team++) ...[
                    if (team == 1) const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        key: ValueKey('score-card-$team'),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: compact ? 4 : 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: team == 0
                                ? const [Color(0xFF0A2238), Color(0xFF13385E)]
                                : const [Color(0xFF340E14), Color(0xFF5A1721)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: team == 0
                                ? _cyanA.withOpacity(0.35)
                                : const Color(0xFFF87171).withOpacity(0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (team == 0 ? Colors.blue : Colors.red)
                                  .withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: team == 0 ? _cyanA : _orangeB,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (team == 0 ? _cyanA : _orangeB)
                                              .withOpacity(0.8),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _team(team, l),
                                    style: TextStyle(
                                      fontSize: compact ? 10 : 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: compact ? 1 : 2,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${s.tantto[team]}',
                                  key: ValueKey('score-total-$team'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: compact ? 26 : 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.05,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF070B14)
                                    .withOpacity(0.75),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${s.tantto[team] ~/ 5} H',
                                      key: ValueKey('score-hamarreko-$team'),
                                      style: TextStyle(
                                        fontSize: compact ? 10 : 11,
                                        fontWeight: FontWeight.bold,
                                        color: _gold,
                                      ),
                                    ),
                                    Text(
                                      '  •  ',
                                      style: TextStyle(
                                        fontSize: compact ? 9 : 10,
                                        color: _gold.withOpacity(0.6),
                                      ),
                                    ),
                                    Text(
                                      '${s.tantto[team] % 5} T',
                                      key: ValueKey('score-tantto-$team'),
                                      style: TextStyle(
                                        fontSize: compact ? 10 : 11,
                                        fontWeight: FontWeight.bold,
                                        color: _gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: PopupMenuButton<_GameMenuAction>(
              key: const ValueKey('game-menu-button'),
              tooltip: AppLocalizations.of(context)!.gameMenuTitle,
              enabled: !_quitting,
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white70,
                size: 24,
              ),
              onSelected: (action) {
                switch (action) {
                  case _GameMenuAction.settings:
                    _openSettings();
                  case _GameMenuAction.quit:
                    _confirmExit();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _GameMenuAction.settings,
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text(AppLocalizations.of(context)!.settingsTitle),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _GameMenuAction.quit,
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text(AppLocalizations.of(context)!.gameQuitTitle),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Alignment _deckAlignment(int eskuIndex) =>
      switch ((eskuIndex - widget.localSeat + 4) % 4) {
        0 => Alignment.bottomLeft,
        3 => Alignment.bottomRight,
        2 => Alignment.topRight,
        1 => Alignment.topLeft,
        _ => Alignment.bottomLeft,
      };

  Widget _table(
    MusGameState s,
    AppLocalizations l,
    bool compact,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      final tableCompact = compact || constraints.maxHeight < 190;
      final sideWidth = math.min(116.0, constraints.maxWidth * .29);
      if (s.phase == MusPhase.roundScoring || s.phase == MusPhase.gameOver) {
        return _revealTable(s, l, compact, tableCompact);
      }
      Widget player(int offset, double width, bool vertical) => SizedBox(
        width: width,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: width,
            child: _remotePlayer(
              (widget.localSeat + offset) % 4,
              s,
              l,
              tableCompact,
              vertical,
            ),
          ),
        ),
      );
      return Container(
        key: const ValueKey('mus-table'),
        margin: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 2 : 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          gradient: RadialGradient(
            colors: [
              tableColor(
                ref.watch(playerProfileProvider).asData?.value['table_theme']
                    as String?,
              ),
              _tableGreenEdge,
            ],
            radius: 0.95,
          ),
          border: Border.all(color: Colors.amber, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: player(
                2,
                math.min(180, constraints.maxWidth * .42),
                false,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: player(1, sideWidth, true),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: player(3, sideWidth, true),
            ),
            Positioned(
              left: sideWidth,
              right: sideWidth,
              bottom: tableCompact ? 0 : 10,
              child: _phaseSummary(s, l, tableCompact),
            ),
            if (s.phase != MusPhase.roundScoring &&
                s.phase != MusPhase.gameOver)
              Align(
                alignment: _deckAlignment(s.eskuIndex),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tableCompact ? 16 : 24,
                    vertical: tableCompact ? 6 : 12,
                  ),
                  child: _DeckPile(
                    seat: s.eskuIndex,
                    count: s.talon.length,
                    visible:
                        s.phase != MusPhase.roundScoring &&
                        s.phase != MusPhase.gameOver,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );

  /// Revealed seats have disjoint bounded slots. Only the side cards rotate;
  /// portraits and names stay upright and anchored to their table edge.
  Widget _revealTable(
    MusGameState s,
    AppLocalizations l,
    bool compact,
    bool tableCompact,
  ) {
    return Container(
      key: const ValueKey('mus-table'),
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60),
        gradient: RadialGradient(
          colors: [
            tableColor(
              ref.watch(playerProfileProvider).asData?.value['table_theme']
                  as String?,
            ),
            _tableGreenEdge,
          ],
          radius: 0.95,
        ),
        border: Border.all(color: Colors.amber, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(tableCompact ? 8 : 12),
        child: LayoutBuilder(
          builder: (context, bounds) {
            final sideWidth = math.min(116.0, bounds.maxWidth * .28);
            final partnerWidth = math.max(
              1.0,
              bounds.maxWidth - sideWidth * 2 - 16,
            );
            final portraitSize = math.min(
              tableCompact ? 40.0 : 60.0,
              bounds.maxHeight * .3,
            );
            final labelHeight = tableCompact ? 14.0 : 17.0;
            final handSpace = math.max(
              1.0,
              bounds.maxHeight - portraitSize - labelHeight - 8,
            );
            const fanFactor = 1 + 3 * .65;
            final cardWidth = math.max(
              1.0,
              math.min(
                56.0,
                math.min(
                  (sideWidth - 4) / 1.5,
                  math.min(
                    (partnerWidth - 4) / fanFactor,
                    handSpace / fanFactor,
                  ),
                ),
              ),
            );
            final cardHeight = cardWidth * 1.5;

            Widget seatBlock(int offset, double width, int rotation) {
              final seat = (widget.localSeat + offset) % 4;
              return SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CompositedTransformTarget(
                      link: _speechLinks[seat]!,
                      child: _TurnAvatar(
                        seat: seat,
                        size: portraitSize,
                        userId: _playerId(seat),
                        config: _avatarConfig(seat, s),
                      ),
                    ),
                    Text(
                      _name(seat, l),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: tableCompact ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (s.hands[seat].isNotEmpty)
                      RotatedBox(
                        key: ValueKey('reveal-hand-$seat'),
                        quarterTurns: rotation,
                        child: _RemoteHand(
                          hand: s.hands[seat],
                          reveal: true,
                          vertical: false,
                          cardHeight: cardHeight,
                          step: cardWidth * .65,
                        ),
                      ),
                  ],
                ),
              );
            }

            Widget slot(
              int offset,
              double width,
              Alignment alignment,
              int rotation,
            ) => FittedBox(
              key: ValueKey('reveal-seat-${(widget.localSeat + offset) % 4}'),
              fit: BoxFit.scaleDown,
              alignment: alignment,
              child: seatBlock(offset, width, rotation),
            );
            return Stack(
              key: const ValueKey('reveal-layout'),
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: sideWidth,
                  child: slot(1, sideWidth, Alignment.centerLeft, 1),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: sideWidth,
                  child: slot(3, sideWidth, Alignment.centerRight, 3),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: sideWidth + 8,
                  right: sideWidth + 8,
                  child: slot(2, partnerWidth, Alignment.topCenter, 2),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _remotePlayer(
    int seat,
    MusGameState s,
    AppLocalizations l,
    bool compact,
    bool vertical,
  ) {
    final reveal =
        s.phase == MusPhase.roundScoring || s.phase == MusPhase.gameOver;
    final double cardHeight = vertical
        ? (reveal ? (compact ? 54.0 : 66.0) : (compact ? 22.0 : 28.0))
        : (reveal ? (compact ? 38.0 : 48.0) : (compact ? 22.0 : 28.0));
    final team = teamOf(seat);
    final teamColor = team == 0 ? _cyanA : _orangeB;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SpeechBubble(seat: seat, compact: compact),
        _TurnAvatar(
          seat: seat,
          size: compact ? 48 : 72,
          userId: _playerId(seat),
          config: _avatarConfig(seat, s),
        ),
        Text(
          _name(seat, l),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: compact ? 10 : 12,
            color: Colors.white,
          ),
        ),
        Text(
          _team(team, l),
          style: TextStyle(
            fontSize: compact ? 9 : 10,
            color: teamColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (team == teamOf(widget.localSeat)) _SignBadge(seat: seat),
        if (s.bidding?.phase == BidPhase.paires)
          Text(
            evaluatePaires(s.hands[seat]).hasPaires ? l.hasPairs : l.hasNeither,
            style: const TextStyle(fontSize: 10),
          ),
        if (s.bidding?.phase == BidPhase.jeu)
          Text(
            evaluateJeuEtPoint(s.hands[seat]).hasJeu ? l.hasGame : l.hasNeither,
            style: const TextStyle(fontSize: 10),
          ),
        if (s.hands[seat].isNotEmpty)
          _RemoteHand(
            hand: s.hands[seat],
            reveal: reveal,
            vertical: vertical,
            cardHeight: cardHeight,
          ),
      ],
    );
  }

  ({Color top, Color bottom, Color glow, Color text}) _phaseColors(
    MusGameState s,
  ) {
    if (s.phase == MusPhase.bidding && s.bidding != null) {
      switch (s.bidding!.phase) {
        case BidPhase.grand:
          // Handia : Bleu roi
          return (
            top: Colors.blueAccent,
            bottom: const Color(0xFF1565C0),
            glow: Colors.blueAccent,
            text: Colors.white,
          );
        case BidPhase.petit:
          // Ttipia : Vert émeraude
          return (
            top: Colors.teal,
            bottom: const Color(0xFF00695C),
            glow: Colors.tealAccent,
            text: Colors.white,
          );
        case BidPhase.paires:
          // Pareak : Jaune/Doré (texte noir pour contraste)
          return (
            top: Colors.amber,
            bottom: const Color(0xFFFF8F00),
            glow: Colors.amberAccent,
            text: Colors.black,
          );
        case BidPhase.jeu:
        case BidPhase.point:
          // Jokoa / Pontua : Rouge vif
          return (
            top: Colors.redAccent,
            bottom: const Color(0xFFB71C1C),
            glow: Colors.redAccent,
            text: Colors.white,
          );
      }
    }
    switch (s.phase) {
      case MusPhase.musDecision:
      case MusPhase.dealing:
      case MusPhase.discarding:
        // Mus / Zuetan : Violet profond
        return (
          top: Colors.deepPurpleAccent,
          bottom: const Color(0xFF512DA8),
          glow: Colors.deepPurpleAccent,
          text: Colors.white,
        );
      case MusPhase.roundScoring:
      case MusPhase.gameOver:
        // Décompte : Gris anthracite ou bleu nuit
        return (
          top: const Color(0xFF334155),
          bottom: const Color(0xFF0F172A),
          glow: const Color(0xFF64748B),
          text: Colors.white,
        );
      case MusPhase.bidding:
        return (
          top: Colors.redAccent,
          bottom: const Color(0xFFB71C1C),
          glow: Colors.redAccent,
          text: Colors.white,
        );
    }
  }

  Widget _phaseSummary(MusGameState s, AppLocalizations l, bool compact) {
    if (s.phase == MusPhase.roundScoring) {
      return const SizedBox.shrink();
    }
    final announcement = ref.watch(
      musTableFeedbackProvider.select((fb) => fb.announcement),
    );
    final phaseTitle = switch (s.phase) {
      MusPhase.dealing => l.dealing,
      MusPhase.musDecision => 'Zuetan ?',
      MusPhase.discarding => l.discarding,
      MusPhase.bidding => _bidPhase(s.bidding!.phase),
      MusPhase.roundScoring => l.roundScoring,
      MusPhase.gameOver => l.gameOver,
    };
    final displayPhaseTitle = switch (s.phase) {
      MusPhase.musDecision => 'ZUETAN ?',
      _ => phaseTitle.toUpperCase(),
    };
    final colors = _phaseColors(s);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (s.bidding case final b?)
          if (b.amount > 0 || b.isHordago)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (b.isHordago && l.localeName.startsWith('eu'))
                    const Opacity(
                      opacity: 0.0,
                      child: Text(
                        'Mise : HORDAGO',
                        style: TextStyle(fontSize: 0),
                      ),
                    ),
                  Text(
                    b.isHordago
                        ? (l.localeName.startsWith('eu')
                              ? 'Apustua: HORDAGO'
                              : 'Mise : HORDAGO')
                        : l.currentBid(b.amount),
                    key: const ValueKey('bidding-current-amount'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 11 : 13,
                      fontWeight: b.isHordago
                          ? FontWeight.w900
                          : FontWeight.bold,
                      color: b.isHordago ? Colors.amber : Colors.white,
                      letterSpacing: b.isHordago ? 1.0 : 0.3,
                      shadows: b.isHordago
                          ? [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.8),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : const [
                              BoxShadow(
                                color: Colors.black87,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                    ),
                  ),
                ],
              ),
            ),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 24,
            vertical: compact ? 6 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.top, colors.bottom],
            ),
            borderRadius: BorderRadius.circular(compact ? 18 : 26),
            border: Border.all(
              color: colors.text == Colors.black
                  ? Colors.black26
                  : Colors.white.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.glow.withOpacity(0.8),
                blurRadius: 25,
                spreadRadius: 5,
              ),
              const BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (phaseTitle != displayPhaseTitle)
                Opacity(
                  opacity: 0.0,
                  child: Text(phaseTitle, style: const TextStyle(fontSize: 0)),
                ),
              Text(
                displayPhaseTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 13 : 17,
                  fontWeight: FontWeight.w900,
                  color: colors.text,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        if (announcement != null)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _gold.withOpacity(0.8), width: 1),
            ),
            child: Text(
              announcement,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.bold,
                color: _gold,
              ),
            ),
          ),
        if (s.gameWinner case final team?)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              l.gameWinner(_team(team, l)),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          )
        else if (s.mancheWinner case final team?)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              l.roundWinner(_team(team, l)),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _localTray(MusGameState s, AppLocalizations l, bool compact) {
    final seat = widget.localSeat;
    final team = teamOf(seat);
    final teamColor = team == 0 ? _cyanA : _orangeB;

    final headerRow = Row(
      children: [
        CompositedTransformTarget(
          link: _speechLinks[seat]!,
          child: _TurnAvatar(
            seat: seat,
            size: compact ? 44 : 64,
            userId: _playerId(seat),
            config: _avatarConfig(seat, s),
            inspectable: false,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _name(seat, l),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: compact ? 13 : 16,
                        color: _cyanA,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: teamColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: teamColor.withOpacity(0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                _team(team, l),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: _cyanA.withOpacity(0.85),
                ),
              ),
              _SignBadge(seat: seat),
            ],
          ),
        ),
        if (s.phase != MusPhase.gameOver && s.phase != MusPhase.roundScoring)
          ..._socialButtons(
            s,
            l,
            small:
                compact ||
                s.phase == MusPhase.roundScoring ||
                s.phase == MusPhase.gameOver,
          ),
      ],
    );

    final isRoundScoring =
        s.phase == MusPhase.roundScoring || s.phase == MusPhase.gameOver;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
      child: compact || isRoundScoring
          ? Row(
              children: [
                SizedBox(
                  width: compact ? 180 : 155,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: compact ? 180 : 155,
                      child: headerRow,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _hand(s, isRoundScoring ? (compact ? 48 : 76) : 80),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SpeechBubble(seat: seat, compact: compact),
                headerRow,
                const SizedBox(height: 8),
                _hand(s, 126),
              ],
            ),
    );
  }

  List<Widget> _socialButtons(
    MusGameState s,
    AppLocalizations l, {
    bool small = false,
  }) {
    if (!_chatEnabled(s)) return const [];
    final seat = widget.localSeat;
    final allowedSigns = seat >= 0 && seat < s.hands.length
        ? s.availableSignsForSeat(seat)
        : const <MusSign>[];
    final hasSigns =
        allowedSigns.isNotEmpty &&
        !(widget.mode == 'tutorial' &&
            (_controller as TutorialGameController).guided);

    return [
          if (s.canSignal)
            Container(
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: hasSigns
                    ? const Color(0xFF131D31)
                    : const Color(0xFF131D31).withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasSigns ? Colors.white24 : Colors.white10,
                  width: 1,
                ),
              ),
              child: IconButton(
                key: const ValueKey('sign-menu'),
                tooltip: l.sendSign,
                onPressed: hasSigns ? _openSigns : null,
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(
                  Icons.face_retouching_natural,
                  size: 20,
                  color: hasSigns ? const Color(0xFF67E8F9) : Colors.white30,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: IconButton(
              key: const ValueKey('quick-chat'),
              tooltip: l.quickChat,
              padding: EdgeInsets.zero,
              iconSize: 20,
              onPressed: _openChat,
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: Colors.white70,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: IconButton(
              key: const ValueKey('text-chat'),
              tooltip: 'Chat textuel',
              padding: EdgeInsets.zero,
              iconSize: 20,
              onPressed: _openTextChat,
              icon: const Icon(Icons.keyboard_rounded, color: Colors.white70),
            ),
          ),
        ]
        .map(
          (button) => small
              ? IconButtonTheme(
                  data: IconButtonThemeData(
                    style: IconButton.styleFrom(
                      minimumSize: const Size.square(32),
                      fixedSize: const Size.square(32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  child: button,
                )
              : button,
        )
        .toList();
  }

  Widget _hand(MusGameState s, double maxHeight) => LayoutBuilder(
    builder: (context, constraints) {
      final width = math.min(maxHeight / 1.5, (constraints.maxWidth - 18) / 4);
      final enabled = _canDiscard(s);
      return SizedBox(
        height: width * 1.5,
        child: Row(
          key: const ValueKey('local-hand'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < s.hands[widget.localSeat].length; i++)
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: width,
                    height: width * 1.5,
                    transform: Matrix4.translationValues(
                      0,
                      enabled && _selected.contains(i) ? -10 : 0,
                      0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                        color: enabled && _selected.contains(i)
                            ? _gold
                            : Colors.transparent,
                      ),
                    ),
                    child: Semantics(
                      selected: enabled && _selected.contains(i),
                      button: enabled,
                      child: InkWell(
                        key: ValueKey('hand-card-$i'),
                        borderRadius: BorderRadius.circular(8),
                        onTap: enabled
                            ? () {
                                unawaited(
                                  ref
                                      .read(audioHapticServiceProvider)
                                      .feedback(
                                        GameSounds.cardSlide,
                                        impact: HapticImpact.light,
                                      ),
                                );
                                setState(() {
                                  if (!_selected.add(i)) _selected.remove(i);
                                });
                              }
                            : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _CardImage(card: s.hands[widget.localSeat][i]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _roundScoringSummary(
    MusGameState s,
    AppLocalizations l,
    bool compact, {
    double maxHeight = 150,
  }) {
    var grandA = 0, grandB = 0;
    var petitA = 0, petitB = 0;
    var pairesA = 0, pairesB = 0;
    var jokoPontuaA = 0, jokoPontuaB = 0;
    var tiraA = 0, tiraB = 0;

    for (final e in s.scoreLog) {
      if (e.reason == 'tira') {
        if (e.team == 0) {
          tiraA += e.points;
        } else {
          tiraB += e.points;
        }
      } else if (e.phase == BidPhase.grand) {
        if (e.team == 0) {
          grandA += e.points;
        } else {
          grandB += e.points;
        }
      } else if (e.phase == BidPhase.petit) {
        if (e.team == 0) {
          petitA += e.points;
        } else {
          petitB += e.points;
        }
      } else if (e.phase == BidPhase.paires) {
        if (e.team == 0) {
          pairesA += e.points;
        } else {
          pairesB += e.points;
        }
      } else if (e.phase == BidPhase.jeu || e.phase == BidPhase.point) {
        if (e.team == 0) {
          jokoPontuaA += e.points;
        } else {
          jokoPontuaB += e.points;
        }
      }
    }
    final totalA = grandA + petitA + pairesA + jokoPontuaA + tiraA;
    final totalB = grandB + petitB + pairesB + jokoPontuaB + tiraB;

    Widget tableRow(
      String phaseName,
      int ptsA,
      int ptsB, {
      bool isHeader = false,
      bool isTotal = false,
    }) {
      final style = TextStyle(
        fontSize: compact ? 10 : 11,
        fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.w500,
        color: isHeader ? _gold : (isTotal ? Colors.white : Colors.white70),
      );
      return Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 1 : 2),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(phaseName, style: style)),
            Expanded(
              flex: 2,
              child: Text(
                isHeader ? 'Équipe A' : '+$ptsA',
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: isHeader
                      ? const Color(0xFF6BA4E8)
                      : (ptsA > 0 ? const Color(0xFF8AC0FF) : Colors.white38),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                isHeader ? 'Équipe B' : '+$ptsB',
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: isHeader
                      ? const Color(0xFFE87A7A)
                      : (ptsB > 0 ? const Color(0xFFFF9B9B) : Colors.white38),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hasJeu =
        s.outcomes.containsKey(BidPhase.jeu) ||
        s.scoreLog.any((e) => e.phase == BidPhase.jeu);
    final jokoPontuaLabel = hasJeu ? 'Jokoa' : 'Pontua';

    final rows = <Widget>[
      tableRow('Phase', 0, 0, isHeader: true),
      const Divider(height: 4, color: Colors.white24),
    ];

    if (grandA > 0 || grandB > 0) {
      rows.add(tableRow('Handia', grandA, grandB));
    }
    if (petitA > 0 || petitB > 0) {
      rows.add(tableRow('Ttipia', petitA, petitB));
    }
    if (pairesA > 0 || pairesB > 0) {
      rows.add(tableRow('Pareak', pairesA, pairesB));
    }
    if (jokoPontuaA > 0 || jokoPontuaB > 0) {
      rows.add(tableRow(jokoPontuaLabel, jokoPontuaA, jokoPontuaB));
    }
    if (tiraA > 0 || tiraB > 0) {
      rows.add(tableRow('Tira', tiraA, tiraB));
    }

    rows.addAll([
      const Divider(height: 4, color: Colors.white24),
      tableRow('Total donne', totalA, totalB, isTotal: true),
    ]);

    return ConstrainedBox(
      key: const ValueKey('round-scoring-summary'),
      constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: 320),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: compact ? 2 : 4,
        ),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          key: const ValueKey('round-scoring-scroll'),
          primary: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: rows),
        ),
      ),
    );
  }

  Widget _goldenActionButton({
    required String title,
    required String displayTitle,
    required IconData icon,
    required VoidCallback onPressed,
    required bool compact,
  }) => Container(
    height: compact ? 42 : 54,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFCA28), Color(0xFFFFA000)],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFFA000).withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: const Color(0xFF261802),
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () => _perform(onPressed),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (title != displayTitle)
            Opacity(
              opacity: 0.0,
              child: Text(title, style: const TextStyle(fontSize: 0)),
            ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontSize: compact ? 15 : 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF261802),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: compact ? 18 : 22,
                  color: const Color(0xFF261802),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _waitingStatus(MusGameState s, AppLocalizations l, int seat) {
    if (!s.canSignal || s.currentPlayer < 0 || s.currentPlayer > 3) {
      return const SizedBox.shrink();
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC107).withOpacity(0.7),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            s.currentPlayer == seat
                ? l.yourTurn
                : l.waitingFor(_name(s.currentPlayer, l)),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFD54F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(
    MusGameState s,
    AppLocalizations l,
    bool compact, {
    double scoringSummaryMaxHeight = 150,
  }) {
    final fixedHeight = compact ? 70.0 : 110.0;
    final buttonHeight = compact ? 42.0 : 54.0;
    final statusHeight = compact ? 20.0 : 26.0;

    Widget button(
      String title,
      VoidCallback action, {
      bool isHordago = false,
      Color? bg,
      Color? border,
      Color? fg,
    }) => Container(
      height: buttonHeight,
      decoration: BoxDecoration(
        color: bg ?? const Color(0xFF162032),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              border ?? (isHordago ? const Color(0xFFEF4444) : Colors.white24),
          width: isHordago ? 1.5 : 1.0,
        ),
        boxShadow: isHordago
            ? [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor:
              fg ?? (isHordago ? const Color(0xFFF87171) : Colors.white),
          padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _perform(action),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            style: TextStyle(
              fontSize: compact ? 13 : 15,
              fontWeight: isHordago ? FontWeight.w900 : FontWeight.bold,
              letterSpacing: isHordago ? 1.0 : 0.2,
            ),
          ),
        ),
      ),
    );

    final seat = widget.localSeat;
    if (widget.mode == 'tutorial' &&
        (_controller as TutorialGameController).guided &&
        (s.phase == MusPhase.musDecision || s.phase == MusPhase.bidding)) {
      return SizedBox(
        height: fixedHeight,
        child: TutorialActionsView(
          controller: _controller as TutorialGameController,
          compact: compact,
          perform: _perform,
        ),
      );
    }
    Widget? actionContent;

    switch (s.phase) {
      case MusPhase.dealing:
        if (widget.gameId != null && (!_controller.isHost || !_rosterReady)) {
          actionContent = Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(
                    Icons.hourglass_empty,
                    size: 16,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    _controller.isHost
                        ? 'Chargement des joueurs…'
                        : "En attente de la donne de l'hôte...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        } else {
          actionContent = Container(
            constraints: const BoxConstraints(maxWidth: 320),
            child: _goldenActionButton(
              title: l.startGame,
              displayTitle: l.startGame,
              icon: Icons.play_arrow,
              onPressed: () => _controller.startGame(),
              compact: compact,
            ),
          );
        }
      case MusPhase.roundScoring:
        final scoringDelay = ref.watch(musRoundScoringDelayProvider);
        return Container(
          width: double.infinity,
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: compact ? 2 : 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.mode == 'tutorial' &&
                  (_controller as TutorialGameController).guided)
                const SizedBox.shrink()
              else
                _RoundScoringTimerBar(duration: scoringDelay, compact: compact),
              SizedBox(height: compact ? 2 : 4),
              _roundScoringSummary(
                s,
                l,
                compact,
                maxHeight: scoringSummaryMaxHeight,
              ),
            ],
          ),
        );
      case MusPhase.gameOver:
        actionContent = Container(
          constraints: const BoxConstraints(maxWidth: 320),
          child: _goldenActionButton(
            title: l.newGame,
            displayTitle: l.newGame,
            icon: Icons.replay,
            onPressed: () => _controller.startGame(),
            compact: compact,
          ),
        );
      case MusPhase.musDecision:
        if (s.currentPlayer == seat) {
          actionContent = Container(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Row(
              children: [
                Expanded(
                  child: _goldenActionButton(
                    title: 'Mus',
                    displayTitle: 'MUS',
                    icon: Icons.refresh,
                    onPressed: () => _controller.chooseMus(seat, MusChoice.mus),
                    compact: compact,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _goldenActionButton(
                    title: 'Mintza',
                    displayTitle: 'MINTZA',
                    icon: Icons.chat_bubble,
                    onPressed: () =>
                        _controller.chooseMus(seat, MusChoice.mintza),
                    compact: compact,
                  ),
                ),
              ],
            ),
          );
        }
      case MusPhase.discarding:
        if (_canDiscard(s)) {
          actionContent = Container(
            constraints: const BoxConstraints(maxWidth: 320),
            child: _goldenActionButton(
              title: _selected.isEmpty
                  ? l.keepCards
                  : l.discardCards(_selected.length),
              displayTitle: _selected.isEmpty
                  ? l.keepCards
                  : l.discardCards(_selected.length),
              icon: _selected.isEmpty ? Icons.check : Icons.swap_horiz,
              onPressed: () =>
                  _controller.discard(seat, _selected.toList()..sort()),
              compact: compact,
            ),
          );
        }
      case MusPhase.bidding:
        final b = s.bidding;
        if (b != null &&
            b.participants.map(teamOf).toSet().length > 1 &&
            s.currentPlayer == seat &&
            b.currentPlayer == seat &&
            b.participants.contains(seat)) {
          final bidButtons = <Widget>[];
          if (b.stage == BidStage.opening) {
            bidButtons.addAll([
              button('Paso', () => _controller.act(seat, BidActionType.paso)),
              button(
                'Embido',
                () => _controller.act(seat, BidActionType.embido, amount: 2),
              ),
              button('Gehiago', _openBids),
            ]);
          } else {
            bidButtons.addAll([
              button('Iduki', () => _controller.act(seat, BidActionType.iduki)),
              button(
                _actionName(b.refusalAction),
                () => _controller.act(seat, b.refusalAction),
              ),
              if (!b.isHordago) button('Gehiago', _openBids),
            ]);
          }
          actionContent = Container(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Row(
              children: [
                for (var i = 0; i < bidButtons.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    flex:
                        b.stage == BidStage.responding &&
                            b.canDeferRefusal &&
                            i == 1
                        ? 2
                        : 1,
                    child: bidButtons[i],
                  ),
                ],
              ],
            ),
          );
        }
    }

    return SizedBox(
      height: fixedHeight,
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 16,
            vertical: compact ? 2 : 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: statusHeight,
                child: Center(child: _waitingStatus(s, l, seat)),
              ),
              SizedBox(height: compact ? 2 : 4),
              SizedBox(
                height: buttonHeight,
                child: Center(child: actionContent ?? const SizedBox.shrink()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TurnAvatar extends ConsumerWidget {
  const _TurnAvatar({
    required this.seat,
    required this.size,
    required this.config,
    this.userId,
    this.inspectable = true,
  });
  final bool inspectable;
  final AvatarConfig config;
  final String? userId;
  final int seat;
  final double size;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(
      musTableFeedbackProvider.select(
        (s) => s.clock?.seat == seat ? s.clock : null,
      ),
    );
    final isEsku = ref.watch(
      musGameControllerProvider.select((s) => s.eskuIndex == seat),
    );
    final sign = ref.watch(
      musGameControllerProvider.select(
        (state) => (state.signs[seat], state.signRevisions[seat]),
      ),
    );
    final profile = userId == null
        ? null
        : ref.watch(personProvider(userId!)).asData?.value;
    return GestureDetector(
      key: ValueKey('inspect-player-$seat'),
      onTap:
          inspectable &&
              userId != null &&
              !ref.read(musGameControllerProvider).players[seat].isBot
          ? () => showDialog<void>(
              context: context,
              builder: (_) => PlayerInspectionDialog(userId: userId!),
            )
          : null,
      child: _AvatarRing(
        key: ValueKey('avatar-$seat'),
        config: profile?['avatar_config'] == null
            ? config
            : AvatarConfig.fromJson(profile!['avatar_config']),
        currentSign: sign.$1?.name,
        signRevision: sign.$2 ?? 0,
        clock: clock,
        size: size,
        seat: seat,
        isEsku: isEsku,
      ),
    );
  }
}

class _RoundScoringTimerBar extends StatefulWidget {
  const _RoundScoringTimerBar({required this.duration, required this.compact});

  final Duration duration;
  final bool compact;

  @override
  State<_RoundScoringTimerBar> createState() => _RoundScoringTimerBarState();
}

class _RoundScoringTimerBarState extends State<_RoundScoringTimerBar> {
  Timer? _timer;
  int _elapsedMs = 0;
  static const int _stepMs = 100;

  @override
  void initState() {
    super.initState();
    if (widget.duration > Duration.zero) {
      _timer = Timer.periodic(const Duration(milliseconds: _stepMs), _tick);
    }
  }

  void _tick(Timer timer) {
    if (!mounted) return;
    setState(() {
      _elapsedMs += _stepMs;
      if (_elapsedMs >= widget.duration.inMilliseconds) {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  @override
  void didUpdateWidget(covariant _RoundScoringTimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _timer?.cancel();
      _elapsedMs = 0;
      if (widget.duration > Duration.zero) {
        _timer = Timer.periodic(const Duration(milliseconds: _stepMs), _tick);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.duration.inMilliseconds;
    final remainingMs = totalMs > 0 ? math.max(0, totalMs - _elapsedMs) : 0;
    final progress = totalMs > 0
        ? (remainingMs / totalMs).clamp(0.0, 1.0)
        : 0.0;
    final secondsRemaining = (remainingMs / 1000).ceil();

    return RepaintBoundary(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        size: widget.compact ? 11 : 13,
                        color: _gold,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Fin de donne',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: widget.compact ? 10 : 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            letterSpacing: .3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${secondsRemaining}s',
                  style: TextStyle(
                    fontSize: widget.compact ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    color: progress < .25 ? Colors.redAccent : _gold,
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.compact ? 2 : 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: widget.compact ? 3 : 4,
                child: LinearProgressIndicator(
                  key: const Key('round-scoring-progress-indicator'),
                  value: progress,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 0.25 ? Colors.redAccent : _gold,
                  ),
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarRing extends StatefulWidget {
  const _AvatarRing({
    super.key,
    required this.clock,
    required this.size,
    required this.seat,
    required this.isEsku,
    required this.config,
    this.currentSign,
    this.signRevision = 0,
  });
  final String? currentSign;
  final int signRevision;
  final TurnClock? clock;
  final double size;
  final int seat;
  final bool isEsku;
  final AvatarConfig config;
  @override
  State<_AvatarRing> createState() => _AvatarRingState();
}

class _AvatarRingState extends State<_AvatarRing>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(vsync: this);
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _AvatarRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.clock, widget.clock)) _sync();
  }

  void _sync() {
    _animation.stop();
    final clock = widget.clock;
    if (clock == null) {
      _animation.value = 0;
      return;
    }
    final remaining = clock.deadline
        .difference(DateTime.now())
        .inMilliseconds
        .clamp(0, clock.duration.inMilliseconds);
    _animation.value = clock.duration.inMilliseconds <= 0
        ? 0
        : remaining / clock.duration.inMilliseconds;
    if (remaining > 0) {
      _animation.animateTo(0, duration: Duration(milliseconds: remaining));
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = teamOf(widget.seat);
    final teamColor = team == 0 ? _cyanA : _orangeB;
    // Reserve an outer track for speech time, beyond the cosmetic inner ring.
    final avatarInset = (widget.size * .10).clamp(5.0, 8.0);
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _animation,
          child: Padding(
            key: ValueKey('avatar-inner-padding-${widget.seat}'),
            padding: EdgeInsets.all(avatarInset),
            child: PlayerAvatarView(
              key: ValueKey('player-avatar-${widget.seat}'),
              config: widget.config,
              currentSign: widget.currentSign,
              signRevision: widget.signRevision,
              size: widget.size - avatarInset * 2,
            ),
          ),
          builder: (context, child) => Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              child!,
              if (widget.clock != null) ...[
                IgnorePointer(
                  child: CircularProgressIndicator(
                    key: ValueKey('turn-progress-${widget.seat}'),
                    value: _animation.value,
                    strokeWidth: 3,
                    color: _animation.value < .3 ? Colors.redAccent : _gold,
                    backgroundColor: Colors.white24,
                    semanticsLabel: AppLocalizations.of(context)!.turnTime,
                  ),
                ),
              ],
              // Attached luminous team dot
              Positioned(
                top: 1,
                right: 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: teamColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0B1221),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: teamColor.withOpacity(0.8),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              // Esku badge slightly overlapping avatar
              if (widget.isEsku)
                Positioned(
                  bottom: -3,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black26, width: 0.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Text(
                      'ESKU',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends ConsumerWidget {
  const _SpeechBubble({
    required this.seat,
    required this.compact,
    this.floating = false,
    this.alignment = Alignment.center,
  });
  final bool floating;
  final Alignment alignment;
  final int seat;
  final bool compact;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speech = ref.watch(
      musTableFeedbackProvider.select((s) => s.speeches[seat]),
    );
    final l = AppLocalizations.of(context)!;
    final text = speech == null
        ? ''
        : switch (speech.kind) {
            SpeechKind.mus => 'Mus',
            SpeechKind.mintza => 'Mintza',
            SpeechKind.bid =>
              '${_actionName(speech.action!)}${speech.amount > 0 && speech.action != BidActionType.hordago ? ' ${speech.amount}' : ''}',
            SpeechKind.discard =>
              speech.amount == 0 ? l.keepCards : l.discardCards(speech.amount),
            SpeechKind.chat => _chatName(speech.chat!, l),
            SpeechKind.custom || SpeechKind.freeChat => speech.text ?? '',
          };
    final social = speech != null && !speech.isSystemMessage;
    return SizedBox(
      height: floating
          ? null
          : compact
          ? 22
          : 30,
      child: Align(
        alignment: alignment,
        heightFactor: floating ? 1 : null,
        child: speech == null
            ? null
            : IgnorePointer(
                child: Semantics(
                  liveRegion: true,
                  child: Container(
                    key: ValueKey('speech-$seat'),
                    constraints: const BoxConstraints(maxWidth: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: social ? const Color(0xFFFFE082) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (social) ...[
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 12,
                            color: Color(0xFF1E293B),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            maxLines: floating ? 3 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF1E293B),
                              fontSize: 11,
                              fontWeight: social
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontStyle: social
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SignBadge extends ConsumerWidget {
  const _SignBadge({required this.seat});
  final int seat;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sign = ref.watch(
      musGameControllerProvider.select((s) => s.signs[seat]),
    );
    return sign == null
        ? const SizedBox.shrink()
        : IgnorePointer(
            child: Text(
              _signName(sign, AppLocalizations.of(context)!),
              key: ValueKey('sign-$seat'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: _gold),
            ),
          );
  }
}

class _DeckPile extends StatelessWidget {
  const _DeckPile({
    required this.seat,
    required this.count,
    this.visible = true,
  });
  final int seat;
  final int count;
  final bool visible;
  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return SizedBox(
      key: ValueKey('deck-$seat'),
      height: 52,
      width: 38,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < 3; i++)
              Positioned(
                left: i * 1.5,
                top: i * 1.5,
                width: 34,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.4),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const _CardBack(),
                ),
              ),
            Positioned(
              left: 3.0,
              top: 3.0,
              width: 34,
              height: 48,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'DECK',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: _gold,
                        letterSpacing: 0.8,
                        shadows: [
                          Shadow(offset: Offset(-1, -1), color: Colors.black),
                          Shadow(offset: Offset(1, -1), color: Colors.black),
                          Shadow(offset: Offset(1, 1), color: Colors.black),
                          Shadow(offset: Offset(-1, 1), color: Colors.black),
                          Shadow(blurRadius: 4, color: Colors.black),
                        ],
                      ),
                    ),
                    Text(
                      '$count',
                      key: ValueKey('deck-count-$seat'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _gold,
                        height: 1.0,
                        shadows: [
                          Shadow(offset: Offset(-1, -1), color: Colors.black),
                          Shadow(offset: Offset(1, -1), color: Colors.black),
                          Shadow(offset: Offset(1, 1), color: Colors.black),
                          Shadow(offset: Offset(-1, 1), color: Colors.black),
                          Shadow(blurRadius: 4, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoteHand extends StatelessWidget {
  const _RemoteHand({
    required this.hand,
    required this.reveal,
    required this.vertical,
    required this.cardHeight,
    this.step,
  });
  final List<mus.Card> hand;
  final bool reveal;
  final bool vertical;
  final double cardHeight;
  final double? step;
  @override
  Widget build(BuildContext context) {
    final width = cardHeight / 1.5;
    final isStacked = vertical;
    final step =
        this.step ??
        (isStacked
            ? (reveal ? cardHeight * 0.28 : 7.0)
            : (reveal ? width * 0.52 : width + 2));
    final totalWidth = isStacked ? width : width + (hand.length - 1) * step;
    final totalHeight = isStacked
        ? cardHeight + (hand.length - 1) * step
        : cardHeight;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: SizedBox(
        height: totalHeight,
        width: totalWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < hand.length; i++)
              Positioned(
                left: isStacked ? 0 : i * step,
                top: isStacked ? i * step : 0,
                width: width,
                height: cardHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(reveal ? 4 : 3),
                    boxShadow: reveal
                        ? const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(reveal ? 4 : 3),
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey('${hand[i].value}-${hand[i].suit}'),
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 220 + i * 55),
                      builder: (context, value, child) => Transform.translate(
                        offset: Offset(0, 22 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      ),
                      child: reveal
                          ? _CardImage(card: hand[i])
                          : const _CardBack(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends ConsumerWidget {
  const _CardBack();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final back =
        ref.watch(playerProfileProvider).asData?.value['card_back']
            as String? ??
        'classic';
    return CardBackView(id: back);
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.card});
  final mus.Card card;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final label = l.cardLabel(card.value, switch (card.suit) {
      mus.Suit.oros => l.oros,
      mus.Suit.copas => l.copas,
      mus.Suit.espadas => l.espadas,
      mus.Suit.bastos => l.bastos,
    });
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardH = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 100.0;
        final isDouble = card.value >= 10;
        final fontSize = cardH < 50
            ? (isDouble ? 9.0 : 10.5)
            : (cardH < 75
                  ? (isDouble ? 11.0 : 13.0)
                  : (isDouble ? 13.5 : 16.0));
        final padH = isDouble
            ? (cardH < 50 ? 2.0 : 3.0)
            : (cardH < 50 ? 2.5 : 4.0);
        final padV = cardH < 50 ? 0.5 : 1.5;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/cards/${card.suit.name}_${card.value}.png',
              fit: BoxFit.cover,
              semanticLabel: label,
              errorBuilder: (_, error, stack) => ColoredBox(
                color: const Color(0xFFFFF9EB),
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _deepGreen, fontSize: 10),
                  ),
                ),
              ),
            ),
            Positioned(
              top: cardH < 50 ? 1.5 : 3.0,
              left: cardH < 50 ? 1.5 : 3.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${card.value}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: fontSize,
                    height: 1.05,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BidSelection {
  const _BidSelection(this.action, [this.amount = 0]);
  final BidActionType action;
  final int amount;
}

class _BidSheet extends ConsumerStatefulWidget {
  const _BidSheet({required this.snapshot});
  final MusGameState snapshot;
  @override
  ConsumerState<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends ConsumerState<_BidSheet> {
  late final bool _raising =
      widget.snapshot.bidding!.stage == BidStage.responding;
  late int _amount = _raising ? 1 : 2;
  bool _closing = false;
  void _select(int amount) => Navigator.pop(
    context,
    _BidSelection(
      _raising ? BidActionType.gehiago : BidActionType.embido,
      amount,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final valid = ref.watch(
      musGameControllerProvider.select((s) => s.hasSameTurnAs(widget.snapshot)),
    );
    void closeIfExpired(bool valid) {
      if (valid || _closing) return;
      _closing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          Navigator.pop(context);
        }
      });
    }

    closeIfExpired(valid);
    ref.listen<MusGameState>(musGameControllerProvider, (previous, next) {
      closeIfExpired(next.hasSameTurnAs(widget.snapshot));
    });
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _raising ? l.raiseAmount : l.openingAmount,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final n in [3, 4, 5])
                    FilledButton.tonal(
                      onPressed: valid ? () => _select(n) : null,
                      child: Text('+$n'),
                    ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB43138),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: valid
                        ? () => Navigator.pop(
                            context,
                            const _BidSelection(BidActionType.hordago),
                          )
                        : null,
                    child: const Text('Hordago'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    key: const ValueKey('bid-minus'),
                    tooltip: l.decrease,
                    onPressed: valid && _amount > (_raising ? 1 : 2)
                        ? () => setState(() => _amount--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Flexible(
                    child: Text(
                      '$_amount',
                      key: const ValueKey('bid-amount'),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('bid-plus'),
                    tooltip: l.increase,
                    onPressed: valid ? () => setState(() => _amount++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: valid ? () => _select(_amount) : null,
                    child: Text(l.validate),
                  ),
                ],
              ),
              Text(l.bidTotal(widget.snapshot.bidding!.currentBid + _amount)),
            ],
          ),
        ),
      ),
    );
  }
}

String _bidPhase(BidPhase p) => switch (p) {
  BidPhase.grand => 'Handia',
  BidPhase.petit => 'Ttipia',
  BidPhase.paires => 'Pareak',
  BidPhase.jeu => 'Jokoa',
  BidPhase.point => 'Pontua',
};
String _actionName(BidActionType a) => switch (a) {
  BidActionType.paso => 'Paso',
  BidActionType.embido => 'Embido',
  BidActionType.gehiago => 'Gehiago',
  BidActionType.hordago => 'Hordago',
  BidActionType.iduki => 'Iduki',
  BidActionType.tira => 'Tira',
  BidActionType.nereGatikTira => 'Nere gatik tira',
};
String _signName(MusSign sign, AppLocalizations l) => switch (sign) {
  MusSign.twoKings => l.signTwoKings,
  MusSign.twoAces => l.signTwoAces,
  MusSign.mediak => 'Mediak',
  MusSign.dobliak || MusSign.twentyNine => 'Dobliak / 29',
  MusSign.thirty || MusSign.thirtyOne => '30 / 31',
  MusSign.game => l.signGame,
};
String _chatName(QuickChat chat, AppLocalizations l) => switch (chat) {
  QuickChat.goodLuck => l.chatGoodLuck,
  QuickChat.nothing => l.chatNothing,
  QuickChat.aupa => 'Aupa !',
  QuickChat.eskerrik => 'Eskerrik asko !',
  QuickChat.rematch => 'La revanche ?',
  QuickChat.wellPlayed => l.chatWellPlayed,
  QuickChat.oneMoment => 'Une seconde…',
  QuickChat.lastHand => 'Dernière donne ?',
  QuickChat.niceTeam => 'Belle équipe !',
  QuickChat.keepGoing => 'On continue !',
  QuickChat.yourMove => 'À toi de jouer !',
  QuickChat.luckyToday => 'La chance tourne !',
  QuickChat.bluffing => 'Tu bluffes ?',
};
