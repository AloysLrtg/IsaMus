import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';
import 'presence_service.dart' show onlineUsersProvider, inGameUsersProvider;

final socialRepositoryProvider = Provider((ref) => SocialRepository());
final friendshipsProvider = StreamProvider.autoDispose(
  (ref) => ref
      .watch(socialRepositoryProvider)
      .friendships()
      .map(deduplicateSocialRows),
);
final blockedUsersProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(socialRepositoryProvider).blockedUsers(),
);
final invitationsProvider = StreamProvider.autoDispose(
  (ref) => ref
      .watch(socialRepositoryProvider)
      .invitations()
      .map(deduplicateSocialRows),
);
final friendPresenceProvider = StreamProvider.autoDispose
    .family<String, String>((ref, id) {
      final online = ref.watch(
        onlineUsersProvider.select((ids) => ids.contains(id)),
      );
      final inGame = ref.watch(
        inGameUsersProvider.select((ids) => ids.contains(id)),
      );
      return Stream.value(
        online ? (inGame ? 'Dans une partie' : 'En ligne') : 'Hors ligne',
      );
    });

/// Realtime INSERT can repeat a row already present in the initial snapshot.
List<Map<String, dynamic>> deduplicateSocialRows(
  List<Map<String, dynamic>> rows,
) {
  final byId = <String, Map<String, dynamic>>{};
  for (final row in rows) {
    final key =
        row['id']?.toString() ??
        '${row['sender_id'] ?? row['user_id_1']}:${row['receiver_id'] ?? row['user_id_2']}';
    final previous = byId[key];
    final before = DateTime.tryParse(previous?['created_at']?.toString() ?? '');
    final after = DateTime.tryParse(row['created_at']?.toString() ?? '');
    // INSERT echoes can remain after UPDATE in the SDK cache. Preserve the
    // terminal status; a renewed invitation has a later created_at instead.
    const rank = {'pending': 0, 'declined': 1, 'accepted': 2};
    final newer = before != null && after != null && after.isAfter(before);
    final sameTime = before == after || before == null || after == null;
    if (previous == null ||
        newer ||
        (sameTime &&
            (rank[row['status']] ?? 0) >= (rank[previous['status']] ?? 0))) {
      byId[key] = Map<String, dynamic>.of(row);
    }
  }
  return List.unmodifiable(byId.values);
}

class SocialRepository {
  SocialRepository({this.clientInstance});
  final SupabaseClient? clientInstance;
  SupabaseClient get client => clientInstance ?? Supabase.instance.client;
  String get userId => client.auth.currentUser!.id;

  Stream<List<Map<String, dynamic>>> friendships() =>
      client.from('friendships').stream(primaryKey: ['id']).order('created_at');
  static int _invitationChannelId = 0;
  Stream<List<Map<String, dynamic>>> invitations() {
    final recipient = userId;
    late StreamController<List<Map<String, dynamic>>> stream;
    RealtimeChannel? channel;
    var cancelled = false, loaded = false;
    var sequence = 0;
    final knownIds = <String>{};
    Future<void> refresh() async {
      final read = ++sequence;
      try {
        final rows = await client
            .from('game_invitations')
            .select()
            .eq('recipient_id', recipient)
            .order('created_at', ascending: false);
        if (cancelled || read != sequence) return;
        loaded = true;
        knownIds
          ..clear()
          ..addAll(rows.map((r) => r['id'].toString()));
        stream.add(deduplicateSocialRows(rows));
      } catch (error, stack) {
        if (!cancelled && read == sequence) stream.addError(error, stack);
      }
    }

    stream = StreamController<List<Map<String, dynamic>>>(
      onListen: () {
        channel = client
            .channel(
              'invitation-notifications:$recipient:${_invitationChannelId++}',
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'game_invitations',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'recipient_id',
                value: recipient,
              ),
              callback: (payload) {
                if (cancelled) return;
                if (payload.eventType == PostgresChangeEvent.delete) {
                  if (loaded && !knownIds.contains(payload.oldRecord['id'])) {
                    return;
                  }
                } else if (payload.newRecord['recipient_id'] != recipient) {
                  return;
                }
                unawaited(refresh());
              },
            );
        channel!.subscribe((status, error) {
          if (cancelled) return;
          if (status == RealtimeSubscribeStatus.subscribed) {
            unawaited(refresh());
          } else if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut ||
              status == RealtimeSubscribeStatus.closed) {
            stream.addError(error ?? StateError('Notifications indisponibles'));
          }
        });
      },
      onCancel: () async {
        cancelled = true;
        if (channel != null) await client.removeChannel(channel!);
      },
    );
    return stream.stream;
  }

  Stream<List<Map<String, dynamic>>> blockedUsers() => client
      .from('blocked_users')
      .stream(primaryKey: ['blocker_id', 'blocked_id'])
      .eq('blocker_id', userId);
  Future<void> block(String id) async {
    await client.rpc('block_user', params: {'p_user_id': id});
  }

  Future<void> unblock(String id) async {
    await client.rpc('unblock_user', params: {'p_user_id': id});
  }

  Future<void> declineRequest(String id) async {
    await client
        .from('friendships')
        .update({'status': 'declined'})
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final text = query.trim();
    if (text.length < 2) return [];
    return List<Map<String, dynamic>>.from(
      await client.rpc('search_social_players', params: {'p_query': text}),
    );
  }

  Future<Map<String, dynamic>> person(String id) => client
      .from('profiles')
      .select('id, username, avatar, avatar_config, elo')
      .eq('id', id)
      .single();
  Future<Map<String, dynamic>?> relationship(String id) {
    if (!AuthRepository.isValidUuid(id)) {
      throw const FormatException('Identité du joueur invalide');
    }
    final me = userId;
    return client
        .from('friendships')
        .select()
        .or(
          'and(user_id_1.eq.$me,user_id_2.eq.$id),and(user_id_1.eq.$id,user_id_2.eq.$me)',
        )
        .maybeSingle();
  }

  Future<void> request(String id) async {
    if (id == userId) {
      throw const FormatException('Vous ne pouvez pas vous ajouter en ami');
    }
    final existing = await relationship(id);
    if (existing != null && existing['status'] != 'declined') return;
    if (existing != null) {
      await client
          .from('friendships')
          .delete()
          .eq('id', existing['id'])
          .eq('status', 'declined');
    }
    try {
      await client.from('friendships').insert({
        'user_id_1': userId,
        'user_id_2': id,
      });
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        final current = await relationship(id);
        if (current != null && current['status'] != 'declined') return;
      }
      rethrow;
    }
  }

  Future<void> accept(String id) async {
    await client
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('id', id);
  }

  Future<void> remove(String id) async {
    await client.from('friendships').delete().eq('id', id);
  }

  Future<Map<String, dynamic>> createModeInvitation(
    String friend,
    String mode,
  ) async => Map<String, dynamic>.from(
    await client.rpc(
      'create_mode_invitation',
      params: {'p_friend': friend, 'p_mode': mode},
    ),
  );
  Future<Map<String, dynamic>> acceptGameInvitation(String id) async =>
      Map<String, dynamic>.from(
        await client.rpc('accept_game_invitation', params: {'invitation': id}),
      );
  Future<void> invite(String friend, String game) =>
      client.rpc('invite_friend', params: {'friend': friend, 'game': game});
  Future<String> joinInvitation(String id) async =>
      (await client.rpc('accept_invitation', params: {'invitation': id}))
          as String;
  Future<void> decline(String id) async {
    await client.rpc('decline_game_invitation', params: {'invitation': id});
  }

  Stream<String> presence(String id) {
    late RealtimeChannel channel;
    late StreamController<String> stream;
    stream = StreamController<String>(
      onListen: () {
        stream.add('Connexion…');
        channel = client.channel(
          'presence:$id',
          opts: const RealtimeChannelConfig(private: true),
        );
        channel
            .onPresenceSync((_) {
              final peers = channel
                  .presenceState()
                  .expand((state) => state.presences)
                  .toList();
              if (!stream.isClosed) {
                stream.add(
                  peers.isEmpty
                      ? 'Hors ligne'
                      : peers.any((p) => p.payload['in_game'] == true)
                      ? 'Dans une partie'
                      : 'En ligne',
                );
              }
            })
            .subscribe((status, error) {
              if (status == RealtimeSubscribeStatus.channelError &&
                  !stream.isClosed) {
                stream.add('Statut indisponible');
              }
            });
      },
      onCancel: () async {
        await client.removeChannel(channel);
      },
    );
    return stream.stream;
  }
}

final personProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, id) => ref.watch(socialRepositoryProvider).person(id),
    );
