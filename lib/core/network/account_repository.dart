import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

final accountRepositoryProvider = Provider(
  (ref) => AccountRepository(auth: ref.read(authRepositoryProvider)),
);

/// Account settings intentionally expose only identity, sign-out and deletion.
class AccountRepository {
  AccountRepository({AuthRepository? auth}) : _auth = auth ?? AuthRepository();
  final AuthRepository _auth;
  User? get user => _auth.currentUser;
  Stream<AuthState> get changes => _auth.authStateChanges;
  Future<void> signOut() => _auth.signOut();
  Future<void> deleteAccount() => _auth.deleteAccount();
}
