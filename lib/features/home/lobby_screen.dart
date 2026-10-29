// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/supabase_repository.dart';
import '../../core/network/auth_repository.dart';
import '../../core/network/social_repository.dart';
import '../game/game_screen.dart';

const _scaffoldBg = Color(0xFF0B1221);
const _cardBg = Color(0xFF132238);
const _gold = Color(0xFFFFD54F);
const _cyanA = Color(0xFF38BDF8);
const _orangeB = Color(0xFFFB923C);

/// Écran de salon d'attente (Lobby) connecté en temps réel à Supabase Realtime.
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({
    super.key,
    required this.gameId,
    this.playerName,
    this.initialMode,
  });

  final String gameId;
  final String? playerName;
  final String? initialMode;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  bool _hasNavigated = false;
  bool _busy = false;
  late Stream<Map<String, dynamic>> _stream;
  @override
  void initState() {
    super.initState();
    _stream = ref.read(supabaseRepositoryProvider).streamGame(widget.gameId);
  }

  Map? _me(List<dynamic> players) {
    final uid = ref.read(authRepositoryProvider).currentUserId;
    return players
        .whereType<Map>()
        .where(
          (p) => uid != null
              ? p['id'] == uid
              : widget.playerName != null &&
                    p['name']?.toString().trim().toLowerCase() ==
                        widget.playerName!.trim().toLowerCase(),
        )
        .firstOrNull;
  }

  int _teamOf(Map player) => player['team'] is int
      ? player['team'] as int
      : (player['seat'] as int? ?? -1) % 2;
  bool _balanced(List<dynamic> players) =>
      players.length == 4 &&
      [0, 1].every(
        (team) =>
            players.whereType<Map>().where((p) => _teamOf(p) == team).length ==
            2,
      );
  bool _host(List<dynamic> players) {
    final me = _me(players);
    if (me == null || players.isEmpty) return false;
    final host =
        players
            .whereType<Map>()
            .where((p) => p['is_host'] == true)
            .firstOrNull ??
        players.first;
    return identical(me, host) || (me['id'] != null && me['id'] == host['id']);
  }

  void _navigate(Map<String, dynamic> data, List<dynamic> players) {
    if (_hasNavigated ||
        !_balanced(players) ||
        (data['status'] != 'ready' && data['status'] != 'playing')) {
      return;
    }
    final me = _me(players);
    if (me == null) return;
    _hasNavigated = true;
    final names = List<String>.filled(4, 'Joueur');
    for (final p in players.whereType<Map>()) {
      names[p['seat'] as int] = p['name']?.toString() ?? 'Joueur';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => GameScreen(
              gameId: widget.gameId,
              localSeat: me['seat'] as int,
              players: players,
              playerNames: names,
              mode: data['mode']?.toString() ?? widget.initialMode ?? 'private',
              userId: me['id']?.toString(),
              initialGame: data,
            ),
          ),
        );
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Action impossible. Le salon a peut-être changé. Réessayez.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code $code copié dans le presse-papier !')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _scaffoldBg,
    appBar: AppBar(title: const Text('SALON D’ATTENTE'), centerTitle: true),
    body: SafeArea(
      child: StreamBuilder<Map<String, dynamic>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => setState(
                  () => _stream = ref
                      .read(supabaseRepositoryProvider)
                      .streamGame(widget.gameId),
                ),
                child: const Text('Erreur de synchronisation. Réessayer'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          if (data['is_public'] == true) {
            return const Center(
              child: Text('Ce salon est réservé au matchmaking public.'),
            );
          }
          final players = data['players'] is List
              ? List<dynamic>.from(data['players'] as List)
              : <dynamic>[];
          _navigate(data, players);
          final host = _host(players),
              balanced = _balanced(players),
              waiting = data['status'] == 'waiting';
          final code = data['join_code']?.toString() ?? '-----';
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (host && data['mode'] == 'private')
                      _LobbyInvitations(gameId: widget.gameId),
                    Card(
                      color: _cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text("CODE D’INVITATION"),
                            const SizedBox(height: 12),
                            Text(
                              code,
                              key: const ValueKey('lobby-join-code'),
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(color: _gold, letterSpacing: 5),
                            ),
                            TextButton.icon(
                              key: const ValueKey('lobby-copy-code-button'),
                              onPressed: () => _copyCode(code),
                              icon: const Icon(Icons.copy),
                              label: const Text('Copier le code'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${players.length} / 4',
                      key: const ValueKey('lobby-player-count'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    for (final team in [0, 1]) ...[
                      _team(team, players, waiting),
                      const SizedBox(height: 12),
                    ],
                    if (host) ...[
                      FilledButton.icon(
                        key: const ValueKey('private-start-game'),
                        onPressed: waiting && balanced && !_busy
                            ? () => _run(
                                () => ref
                                    .read(supabaseRepositoryProvider)
                                    .startPrivateGame(widget.gameId),
                              )
                            : null,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Lancer la partie'),
                      ),
                      if (waiting && players.length < 4)
                        TextButton.icon(
                          key: const ValueKey('lobby-fill-bots-button'),
                          onPressed: _busy
                              ? null
                              : () => _run(
                                  () => ref
                                      .read(supabaseRepositoryProvider)
                                      .fillWithBotsAndStart(
                                        widget.gameId,
                                        players,
                                      ),
                                ),
                          icon: const Icon(Icons.smart_toy_outlined),
                          label: const Text('Compléter avec des IA'),
                        ),
                      if (!balanced)
                        const Text(
                          'Deux joueurs par équipe sont requis.',
                          textAlign: TextAlign.center,
                        ),
                    ] else
                      const Text(
                        "En attente de l'hôte...",
                        textAlign: TextAlign.center,
                      ),
                    if (data['status'] == 'cancelled')
                      const Text('Le salon a été fermé.'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  Widget _team(int team, List<dynamic> players, bool waiting) {
    final color = team == 0 ? _cyanA : _orangeB;
    final me = _me(players);
    final mine = me != null && _teamOf(me) == team;
    final members = players
        .whereType<Map>()
        .where((p) => _teamOf(p) == team)
        .toList();
    return Container(
      key: ValueKey('lobby-team-$team'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        border: Border.all(color: color.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Équipe ${team == 0 ? 'A' : 'B'} · ${members.length}/2',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: color),
                ),
              ),
              TextButton(
                key: ValueKey('join-private-team-$team'),
                onPressed: !waiting || mine || me == null || _busy
                    ? null
                    : () => _run(
                        () => ref
                            .read(supabaseRepositoryProvider)
                            .choosePrivateTeam(widget.gameId, team),
                      ),
                child: Text(mine ? 'Votre équipe' : 'Rejoindre'),
              ),
            ],
          ),
          for (
            var index = 0;
            index < (members.length < 2 ? 2 : members.length);
            index++
          )
            Builder(
              builder: (_) {
                final p = index < members.length ? members[index] : null;
                final seat = p?['seat'] as int? ?? team + index * 2;
                return ListTile(
                  key: ValueKey('lobby-seat-$seat'),
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: .15),
                    child: Icon(
                      p == null
                          ? Icons.person_add_outlined
                          : p['is_bot'] == true
                          ? Icons.smart_toy_outlined
                          : Icons.person_outline,
                      color: color,
                    ),
                  ),
                  trailing: identical(p, me)
                      ? const Text(
                          'VOUS',
                          style: TextStyle(
                            fontSize: 11,
                            color: _gold,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                  title: Text(
                    p?['name']?.toString() ?? 'Place libre',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    p == null
                        ? 'En attente…'
                        : p['is_host'] == true
                        ? 'Hôte'
                        : p['is_bot'] == true
                        ? 'IA'
                        : identical(p, me)
                        ? 'Vous'
                        : 'Joueur',
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LobbyInvitations extends ConsumerStatefulWidget {
  const _LobbyInvitations({required this.gameId});
  final String gameId;
  @override
  ConsumerState<_LobbyInvitations> createState() => _LobbyInvitationsState();
}

class _LobbyInvitationsState extends ConsumerState<_LobbyInvitations> {
  bool _busy = false;
  String? _message;
  @override
  Widget build(BuildContext context) {
    final friends =
        ref
            .watch(friendshipsProvider)
            .asData
            ?.value
            .where((f) => f['status'] == 'accepted')
            .toList() ??
        [];
    final uid = ref.read(authRepositoryProvider).currentUserId;
    return Column(
      children: [
        ExpansionTile(
          title: const Text('Inviter mes amis'),
          children: [
            if (friends.isEmpty)
              const ListTile(
                title: Text('Ajoutez des amis depuis l’onglet Amis.'),
              ),
            for (final friend in friends)
              Builder(
                builder: (context) {
                  final id =
                      (friend['user_id_1'] == uid
                              ? friend['user_id_2']
                              : friend['user_id_1'])
                          as String;
                  final name =
                      ref.watch(personProvider(id)).asData?.value['username'] ??
                      'Ami';
                  return ListTile(
                    title: Text(name.toString()),
                    trailing: TextButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              setState(() => _busy = true);
                              try {
                                await ref
                                    .read(socialRepositoryProvider)
                                    .invite(id, widget.gameId);
                                if (mounted) {
                                  setState(
                                    () => _message =
                                        'Invitation envoyée à $name.',
                                  );
                                }
                              } catch (_) {
                                if (mounted) {
                                  setState(
                                    () => _message =
                                        'Impossible d’envoyer l’invitation.',
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _busy = false);
                              }
                            },
                      child: const Text('Inviter'),
                    ),
                  );
                },
              ),
          ],
        ),
        if (_message != null) Text(_message!),
      ],
    );
  }
}
