import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Service d'authentification et de gestion des profils utilisateurs sur Supabase.
class AuthRepository {
  final SupabaseClient? clientInstance;

  AuthRepository({this.clientInstance});

  SupabaseClient get client => clientInstance ?? Supabase.instance.client;

  String get redirect => kIsWeb ? Uri.base.origin : 'isamus://auth/callback';
  User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<AuthState> get authStateChanges {
    try {
      return client.auth.onAuthStateChange;
    } catch (_) {
      return const Stream.empty();
    }
  }

  Stream<User?> get userChanges => Stream<User?>.multi((sink) {
    final subscription = authStateChanges.listen(
      (event) => sink.add(event.session?.user),
      onError: sink.addError,
    );
    sink.add(currentUser);
    sink.onCancel = subscription.cancel;
  });

  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// A null session means the confirmation email must be opened first.
  Future<bool> signUp(
    String email,
    String password, {
    required String username,
  }) async {
    final pseudo = username.trim();
    if (pseudo.isEmpty || pseudo.length > 24) {
      throw const AuthException(
        'Le pseudo doit contenir de 1 à 24 caractères.',
      );
    }
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: redirect,
      data: {'username': pseudo},
    );
    return response.session != null;
  }

  /// Supabase removes the local session before attempting remote revocation.
  Future<void> signOut() => client.auth.signOut(scope: SignOutScope.local);

  Future<void> deleteAccount() async {
    final response = await client.functions.invoke('delete-account');
    if (response.status < 200 || response.status >= 300) {
      throw const AuthException('La suppression a échoué. Réessayez.');
    }
    await signOut();
  }

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Vérifie si une chaîne correspond à un format UUID standard RFC 4122.
  static bool isValidUuid(String? id) {
    if (id == null || id.isEmpty) return false;
    return _uuidRegex.hasMatch(id);
  }

  /// ID de l'utilisateur actuellement connecté, le cas échéant.
  String? get currentUserId {
    try {
      final id = client.auth.currentUser?.id;
      return isValidUuid(id) ? id : null;
    } catch (_) {
      return null;
    }
  }

  /// Connexion anonyme via Supabase Auth.
  /// Si un utilisateur valide est déjà connecté, retourne son UUID existant.
  /// Sinon, effectue un appel à `signInAnonymously()` et retourne le nouvel UUID généré.
  /// Lance une [Exception] si `response.user` est null ou si son ID n'est pas un UUID valide.
  Future<String> signInAnonymously() async {
    try {
      final existingUser = client.auth.currentUser;
      if (existingUser != null && isValidUuid(existingUser.id)) {
        return existingUser.id;
      }
    } catch (_) {
      // Ignoré si Supabase n'est pas encore initialisé ou inaccessible
    }

    final response = await client.auth.signInAnonymously();
    final userId = response.user?.id;
    if (userId == null || !isValidUuid(userId)) {
      throw Exception('Échec de la récupération de l\'UUID Supabase.');
    }
    return userId;
  }

  /// Récupère le profil associé à [userId] depuis la table `profiles`.
  /// Retourne `null` si aucun profil n'existe pour cet identifiant ou si l'UUID est invalide.
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    if (!isValidUuid(userId)) return null;
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  /// Crée un nouveau profil dans la table `profiles` avec son [userId] et son [username].
  Future<void> createProfile(String userId, String username) async {
    if (!isValidUuid(userId)) {
      throw Exception('Échec de la récupération de l\'UUID Supabase.');
    }
    await client.from('profiles').insert({
      'id': userId,
      'username': username.trim(),
    });
  }

  /// Met à jour les statistiques de match d'un profil suite à une fin de partie.
  /// Incrémente `games_played`, incrémente `games_won` (si victoire),
  /// et met à jour `elo` si [newElo] est fourni.
  Future<void> updateMatchResult(
    String userId,
    bool isVictory, {
    int? newElo,
  }) async {
    if (!isValidUuid(userId)) {
      throw Exception(
        'Échec de la mise à jour des statistiques : UUID invalide.',
      );
    }

    throw UnsupportedError(
      'Les résultats sont enregistrés par record_game_result, jamais par le client.',
    );
  }
}

/// Provider Riverpod global fournissant l'instance de [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthSessionSnapshot {
  const AuthSessionSnapshot(this.user, this.generation);
  final User? user;
  final int generation;
}

/// The generation also resets state on a sign-out/sign-in batched in one frame.
final authSessionProvider = StreamProvider<AuthSessionSnapshot>((ref) {
  var generation = 0;
  String? previousId;
  var first = true;
  return ref.watch(authRepositoryProvider).userChanges.map((user) {
    if (first || user?.id != previousId) generation++;
    first = false;
    previousId = user?.id;
    return AuthSessionSnapshot(user, generation);
  });
});
