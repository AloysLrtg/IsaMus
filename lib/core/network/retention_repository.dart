import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final retentionRepositoryProvider = Provider((ref) => RetentionRepository());
final retentionStatusProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>(
      (ref) => ref.watch(retentionRepositoryProvider).status(),
    );

class RetentionRepository {
  SupabaseClient get client => Supabase.instance.client;
  Future<Map<String, dynamic>> status() async =>
      Map<String, dynamic>.from(await client.rpc('retention_status'));
  Future<Map<String, dynamic>> claim(
    int tier, {
    required bool vip,
    required String seasonId,
  }) async => Map<String, dynamic>.from(
    await client.rpc(
      'claim_season_pass',
      params: {'season': seasonId, 'tier_number': tier, 'premium': vip},
    ),
  );
}
