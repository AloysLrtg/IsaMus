import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/auth_repository.dart';

void main() {
  group('AuthRepository & UUID validation', () {
    test('isValidUuid valide les UUIDs RFC 4122 valides et rejette les chaînes invalides', () {
      expect(AuthRepository.isValidUuid('123e4567-e89b-12d3-a456-426614174000'), isTrue);
      expect(AuthRepository.isValidUuid('c8d23e3e-4318-490b-9df0-b2f567085732'), isTrue);
      expect(AuthRepository.isValidUuid('00000000-0000-0000-0000-000000000000'), isTrue);

      // Rejette les chaînes invalides comme les identifiants locaux arbitraires
      expect(AuthRepository.isValidUuid('anonymous_local_user'), isFalse);
      expect(AuthRepository.isValidUuid('mock-user-uuid-456'), isFalse);
      expect(AuthRepository.isValidUuid(''), isFalse);
      expect(AuthRepository.isValidUuid(null), isFalse);
      expect(AuthRepository.isValidUuid('123e4567-e89b-12d3-a456-42661417400'), isFalse); // trop court
      expect(AuthRepository.isValidUuid('123e4567-e89b-12d3-a456-4266141740000'), isFalse); // trop long
    });

    test('getProfile retourne null immédiatement si l\'UUID est invalide (évite erreur Postgrest 22P02)', () async {
      final repo = AuthRepository();
      final result = await repo.getProfile('anonymous_local_user');
      expect(result, isNull);
    });

    test('createProfile lance une Exception si l\'UUID est invalide', () async {
      final repo = AuthRepository();
      expect(
        () => repo.createProfile('anonymous_local_user', 'Patxi'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Échec de la récupération de l\'UUID Supabase.'),
          ),
        ),
      );
    });

    test('updateMatchResult lance une Exception si l\'UUID est invalide', () async {
      final repo = AuthRepository();
      expect(
        () => repo.updateMatchResult('anonymous_local_user', true, newElo: 1200),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Échec de la mise à jour des statistiques : UUID invalide.'),
          ),
        ),
      );
    });

    test('authRepositoryProvider est accessible', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);
      expect(repo, isA<AuthRepository>());
    });
  });
}
