import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception levée lorsqu'une partie n'est pas trouvée par son code d'accès.
class GameNotFoundException implements Exception {
  final String message;
  const GameNotFoundException(this.message);

  @override
  String toString() => message;
}

/// Exception levée lorsqu'une tentative de rejoindre une partie échoue car celle-ci est complète.
class GameFullException implements Exception {
  final String message;
  const GameFullException(this.message);

  @override
  String toString() => message;
}

/// Service réseau responsable des interactions avec la table `games` dans Supabase.
class SupabaseRepository {
  final SupabaseClient _client;

  SupabaseRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  SupabaseClient get client => _client;

  /// Génère un code alphanumérique aléatoire à 5 caractères majuscules.
  static String generateJoinCode([Random? random]) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = random ?? Random();
    return List.generate(5, (_) => chars[r.nextInt(chars.length)]).join();
  }

  /// Crée une nouvelle partie avec [hostName] comme premier joueur.
  ///
  /// Génère un code alphanumérique unique à 5 caractères majuscules,
  /// insère une nouvelle ligne dans la table `games` avec `join_code: code`,
  /// `status: 'waiting'` et un tableau JSON `players` contenant l'hôte.
  ///
  /// Retourne l'UUID (String) de la ligne créée.
  Future<String> createGame(
    String hostName, {
    String? userId,
    String mode = 'casual',
  }) async {
    final code = generateJoinCode();
    final uid =
        userId ??
        _client.auth.currentUser?.id ??
        'player_${DateTime.now().millisecondsSinceEpoch}_0';
    final host = {
      'id': uid,
      'name': hostName.trim(),
      'seat': 0,
      'team': 0,
      'is_host': true,
      'joined_at': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _client
        .from('games')
        .insert({
          'join_code': code,
          'status': 'waiting',
          'mode': mode,
          'players': [host],
        })
        .select('id')
        .single();

    return response['id'].toString();
  }

  /// Rejoint une partie existante identifiée par [joinCode] pour le joueur [playerName].
  ///
  /// Si la partie existe et compte moins de 4 joueurs, ajoute le nouveau joueur
  /// au tableau JSON `players`, met à jour la ligne dans Supabase et retourne son UUID.
  ///
  /// Lance [GameNotFoundException] si le code n'existe pas,
  /// ou [GameFullException] si la partie contient déjà 4 joueurs.
  Future<String> joinGame(
    String joinCode,
    String playerName, {
    String? userId,
  }) async {
    final sanitizedCode = joinCode.trim().toUpperCase();
    if (sanitizedCode.isEmpty) {
      throw const FormatException(
        'Le code de la partie ne peut pas être vide.',
      );
    }

    try {
      return await _client.rpc('join_game', params: {'code': sanitizedCode})
          as String;
    } on PostgrestException catch (error) {
      if (error.message.contains('introuvable')) {
        throw GameNotFoundException(error.message);
      }
      if (error.message.contains('complète')) {
        throw GameFullException(error.message);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> findPublicGame(String mode) async =>
      Map<String, dynamic>.from(
        await _client.rpc('find_public_game', params: {'p_mode': mode}),
      );

  Future<void> leavePublicQueue(String gameId) async {
    await _client.rpc('leave_public_queue', params: {'game': gameId});
  }

  Future<void> choosePrivateTeam(String gameId, int team) async {
    await _client.rpc(
      'choose_private_team',
      params: {'game': gameId, 'p_team': team},
    );
  }

  Future<void> startPrivateGame(String gameId) async {
    await _client.rpc('start_private_game', params: {'game': gameId});
  }

  static int _roomChannelId = 0;

  /// One subscription per consumer. Refresh AFTER joining Realtime to cover
  /// changes between the routing snapshot and channel activation/reconnection.
  Stream<Map<String, dynamic>> streamGame(String gameId) {
    late StreamController<Map<String, dynamic>> controller;
    RealtimeChannel? channel;
    var cancelled = false;
    var eventRevision = 0;
    var readSequence = 0;
    Future<void> refresh() async {
      final sequence = ++readSequence;
      final revision = eventRevision;
      try {
        final row = await _client
            .from('games')
            .select()
            .eq('id', gameId)
            .maybeSingle();
        if (!cancelled &&
            sequence == readSequence &&
            revision == eventRevision &&
            row != null) {
          controller.add(row);
        }
      } catch (error, stack) {
        if (!cancelled &&
            sequence == readSequence &&
            revision == eventRevision) {
          controller.addError(error, stack);
        }
      }
    }

    controller = StreamController<Map<String, dynamic>>(
      onListen: () {
        channel = _client
            .channel('game-row:$gameId:${_roomChannelId++}')
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'games',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'id',
                value: gameId,
              ),
              callback: (payload) {
                if (cancelled || payload.newRecord['id'] != gameId) return;
                eventRevision++;
                controller.add(Map<String, dynamic>.from(payload.newRecord));
              },
            );
        channel!.subscribe((status, error) {
          if (cancelled) return;
          if (status == RealtimeSubscribeStatus.subscribed) {
            unawaited(refresh());
          } else if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut ||
              status == RealtimeSubscribeStatus.closed) {
            controller.addError(
              error ?? StateError('Connexion au salon interrompue'),
            );
          }
        });
      },
      onCancel: () async {
        cancelled = true;
        if (channel != null) await _client.removeChannel(channel!);
      },
    );
    return controller.stream;
  }

  /// Complète les places manquantes avec des bots IA jusqu'à 4 joueurs
  /// Le solo démarre aussitôt ; le privé attend le lancement explicite à 2 contre 2.
  Future<void> fillWithBotsAndStart(
    String gameId,
    List<dynamic> currentPlayers,
  ) async {
    if (currentPlayers.length >= 4) return;
    await _client.rpc('start_with_bots', params: {'game': gameId});
  }

  /// Ferme le salon. Le serveur vérifie que l'appelant est l'hôte.
  Future<void> closeGame(String gameId) async {
    await _client.rpc('close_game', params: {'game': gameId});
  }

  /// Met à jour l'état de jeu JSONB dans la colonne `game_state` de la partie [gameId].
  Future<void> updateGameState(
    String gameId,
    Map<String, dynamic> gameState,
  ) async {
    await _client.rpc(
      'publish_game_state',
      params: {'game': gameId, 'payload': gameState},
    );
  }
}

/// Provider Riverpod global fournissant l'instance de [SupabaseRepository].
final supabaseRepositoryProvider = Provider<SupabaseRepository>((ref) {
  return SupabaseRepository();
});
