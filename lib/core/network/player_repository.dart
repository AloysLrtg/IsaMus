import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/avatar_config.dart';

final playerRepositoryProvider = Provider((ref) => PlayerRepository());
final playerProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.watch(playerRepositoryProvider).profile(),
);
final matchHistoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref.watch(playerRepositoryProvider).history(),
    );
final cosmeticsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref.watch(playerRepositoryProvider).cosmetics(),
    );
final inventoryProvider = FutureProvider.autoDispose<Set<String>>(
  (ref) => ref.watch(playerRepositoryProvider).inventory(),
);

class PlayerRepository {
  PlayerRepository({this.clientInstance});
  final SupabaseClient? clientInstance;
  SupabaseClient get client => clientInstance ?? Supabase.instance.client;
  String get userId => client.auth.currentUser!.id;
  Future<Map<String, dynamic>> profile() =>
      client.from('profiles').select().eq('id', userId).single();
  Future<Map<String, dynamic>> publicProfile(String id) => client
      .from('profiles')
      .select('username,elo,peak_elo,games_played,games_won,avatar_config')
      .eq('id', id)
      .single();
  Future<List<Map<String, dynamic>>> history() => client
      .from('match_results')
      .select()
      .eq('user_id', userId)
      .order('finished_at', ascending: false)
      .limit(20);
  Future<List<Map<String, dynamic>>> cosmetics() => client
      .from('cosmetics')
      .select()
      .order('free', ascending: false)
      .order('id');
  Future<Set<String>> inventory() async =>
      (await client
              .from('inventory')
              .select('cosmetic_id')
              .eq('user_id', userId))
          .map((r) => r['cosmetic_id'] as String)
          .toSet();
  Future<void> equip(String id) =>
      client.rpc('equip_cosmetic', params: {'item': id});
  Future<void> sound(bool enabled) async {
    await client
        .from('profiles')
        .update({'sound_enabled': enabled})
        .eq('id', userId);
  }

  Future<void> language(String playerId, String code) async {
    if (!const ['fr', 'eu', 'es', 'en'].contains(code)) {
      throw const FormatException('Unsupported language');
    }
    await client
        .from('profiles')
        .update({'language': code})
        .eq('id', playerId)
        .select('id')
        .single();
  }

  Future<void> saveAvatar(AvatarConfig config) async {
    // Returning one row also detects a missing profile or an RLS rejection.
    await client
        .from('profiles')
        .update({'avatar_config': config.toJson()})
        .eq('id', userId)
        .select('id')
        .single();
  }

  Future<void> rename(String name) async {
    final value = name.trim();
    if (value.length < 2 || value.length > 24) {
      throw const FormatException('Le pseudo doit contenir 2 à 24 caractères.');
    }
    await client.from('profiles').update({'username': value}).eq('id', userId);
  }

  Future<Map<String, dynamic>?> finish(String gameId) async {
    await client.rpc('record_game_result', params: {'game': gameId});
    return client
        .from('match_results')
        .select()
        .eq('game_id', gameId)
        .eq('user_id', userId)
        .maybeSingle();
  }
}

final publicPlayerProfileProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, id) => ref.watch(playerRepositoryProvider).publicProfile(id),
    );
