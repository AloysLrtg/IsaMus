import 'package:isamus/l10n/app_localizations.dart';
import 'package:isamus/features/shop/shop_screen.dart';
import 'package:isamus/core/network/shop_repository.dart';
import 'package:isamus/features/seasons/countdown_widget.dart';
import 'package:isamus/core/models/game_season.dart';
import 'package:isamus/core/network/season_repository.dart';
import 'package:isamus/core/audio/audio_haptic_service.dart';

import 'helpers/audio_haptic_fakes.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/engine/mus_game_state.dart';
import 'package:isamus/core/network/auth_repository.dart';
import 'package:isamus/core/network/leaderboard_repository.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/retention_repository.dart';
import 'package:isamus/features/home/game_mode_card.dart';
import 'package:isamus/features/retention/battle_pass_screen.dart';
import 'package:isamus/features/retention/quests_screen.dart';
import 'package:isamus/core/network/social_repository.dart';
import 'package:isamus/core/network/supabase_repository.dart';
import 'package:isamus/features/game/game_over_overlay.dart';
import 'package:isamus/features/game/game_screen.dart';
import 'package:isamus/features/home/home_screen.dart';
import 'package:isamus/features/home/lobby_screen.dart';
import 'package:isamus/main.dart';
import 'package:isamus/features/settings/settings_screen.dart';

class _HomeRetention extends RetentionRepository {
  @override
  Future<Map<String, dynamic>> status() async => {
    'coins': 275,
    'quests': [
      {
        'id': 'ranked_wins',
        'title': 'Gagner 2 parties classées',
        'progress': 0,
        'target': 2,
        'reward_xp': 500,
      },
    ],
  };
}

class _MockPlayerRepository extends PlayerRepository {
  bool finished = false;
  @override
  Future<Map<String, dynamic>?> finish(String gameId) async {
    finished = true;
    return {'elo_before': 1000, 'elo_after': 1024};
  }
}

class _MockAuthRepository implements AuthRepository {
  _MockAuthRepository({
    this.userId = '123e4567-e89b-12d3-a456-426614174000',
    Map<String, dynamic>? initialProfile,
    this.getProfileError,
    this.createProfileError,
  }) : _profile = initialProfile;

  final String userId;
  final Exception? getProfileError;
  final Exception? createProfileError;

  Map<String, dynamic>? _profile;
  int anonymousCalls = 0;
  bool createProfileCalled = false;
  String? createdUsername;
  bool updateMatchResultCalled = false;
  String? lastUpdatedUserId;
  bool? lastMatchVictory;
  int? lastNewElo;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  String? get currentUserId => userId;

  @override
  Future<String> signInAnonymously() async {
    anonymousCalls++;
    return userId;
  }

  @override
  Future<Map<String, dynamic>?> getProfile(String uid) async {
    if (getProfileError != null) throw getProfileError!;
    return _profile;
  }

  @override
  Future<void> createProfile(String uid, String username) async {
    if (createProfileError != null) throw createProfileError!;
    createProfileCalled = true;
    createdUsername = username;
    _profile = {'id': uid, 'username': username, 'elo': 1000};
  }

  @override
  Future<void> updateMatchResult(
    String uid,
    bool isVictory, {
    int? newElo,
  }) async {
    updateMatchResultCalled = true;
    lastUpdatedUserId = uid;
    lastMatchVictory = isVictory;
    lastNewElo = newElo;
  }
}

class _MockSupabaseRepository implements SupabaseRepository {
  _MockSupabaseRepository({
    this.createGameError,
    this.joinGameError,
    this.fillWithBotsError,
    Stream<Map<String, dynamic>>? gameStream,
  }) : _stream =
           gameStream ??
           Stream.value({
             'id': 'mock-game-uuid-123',
             'join_code': 'ABCDE',
             'status': 'waiting',
             'mode': 'casual',
             'players': [
               {'name': 'Patxi', 'seat': 0, 'is_host': true},
             ],
           });

  final Exception? createGameError;
  final Exception? joinGameError;
  final Exception? fillWithBotsError;
  final Stream<Map<String, dynamic>> _stream;

  bool fillWithBotsCalled = false;
  String? fillWithBotsGameId;
  List<dynamic>? fillWithBotsPlayers;

  String? lastCreatedHostName;
  String? lastCreatedUserId;
  String? lastCreatedMode;
  String? lastJoinedPlayerName;
  String? lastJoinedUserId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Map<String, dynamic>> findPublicGame(String mode) async {
    if (createGameError != null) throw createGameError!;
    lastCreatedMode = mode;
    return {
      'id': 'mock-game-uuid-123',
      'mode': mode,
      'status': 'waiting',
      'is_public': true,
      'local_seat': 0,
      'players': [
        {
          'id': '999e4567-e89b-12d3-a456-426614174000',
          'seat': 0,
          'name': 'Amaia',
          'is_host': true,
        },
      ],
    };
  }

  @override
  Future<String> createGame(
    String hostName, {
    String? userId,
    String mode = 'casual',
  }) async {
    if (createGameError != null) throw createGameError!;
    lastCreatedHostName = hostName;
    lastCreatedUserId = userId;
    lastCreatedMode = mode;
    return 'mock-game-uuid-123';
  }

  @override
  Future<String> joinGame(
    String joinCode,
    String playerName, {
    String? userId,
  }) async {
    if (joinGameError != null) throw joinGameError!;
    lastJoinedPlayerName = playerName;
    lastJoinedUserId = userId;
    return 'mock-game-uuid-123';
  }

  @override
  Future<void> fillWithBotsAndStart(
    String gameId,
    List<dynamic> currentPlayers,
  ) async {
    if (fillWithBotsError != null) throw fillWithBotsError!;
    fillWithBotsCalled = true;
    fillWithBotsGameId = gameId;
    fillWithBotsPlayers = currentPlayers;
  }

  @override
  Future<void> updateGameState(
    String gameId,
    Map<String, dynamic> gameState,
  ) async {}

  @override
  Stream<Map<String, dynamic>> streamGame(String gameId) => _stream;
}

void main() {
  group('HomeScreen UI & Interactions', () {
    testWidgets(
      'Étape B - Inscription : Aucun profil existant -> Champ pseudo et bouton Créer mon profil',
      (tester) async {
        final mockAuth = _MockAuthRepository(initialProfile: null);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(
                _MockSupabaseRepository(),
              ),
            ],
            child: const MyApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('IsaMus'), findsNWidgets(2)); // Stroke + ShaderMask
        expect(mockAuth.anonymousCalls, 0);
        expect(find.text(testL10n.menuCREATEYOURPROFILE), findsOneWidget);
        expect(find.byKey(const ValueKey('home-pseudo-input')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-create-profile-button')),
          findsOneWidget,
        );
        expect(find.text(testL10n.menuCreateMyProfile), findsOneWidget);

        // Les boutons de partie ne sont pas affichés tant qu'il n'y a pas de profil
        expect(find.byKey(const ValueKey('home-create-button')), findsNothing);
        expect(find.byKey(const ValueKey('home-join-button')), findsNothing);
        expect(find.byKey(const ValueKey('home-profile-banner')), findsNothing);
      },
    );

    testWidgets('Clic Créer mon profil sans pseudo -> SnackBar erreur', (
      tester,
    ) async {
      final mockAuth = _MockAuthRepository(initialProfile: null);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioHapticServiceProvider.overrideWithValue(
              FakeAudioHapticService(),
            ),
            authRepositoryProvider.overrideWithValue(mockAuth),
            supabaseRepositoryProvider.overrideWithValue(
              _MockSupabaseRepository(),
            ),
          ],
          child: const MyApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('home-create-profile-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text(testL10n.menuPleaseEnterYourNickname), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(mockAuth.createProfileCalled, isFalse);
    });

    testWidgets(
      'Créer mon profil avec succès -> Bascule vers l\'état Connecté avec bandeau Joueur/Elo',
      (tester) async {
        final mockAuth = _MockAuthRepository(initialProfile: null);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(
                _MockSupabaseRepository(),
              ),
            ],
            child: const MyApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('home-pseudo-input')),
          'Amaia',
        );
        await tester.tap(
          find.byKey(const ValueKey('home-create-profile-button')),
        );
        await tester.pumpAndSettle();

        expect(mockAuth.createProfileCalled, isTrue);
        expect(mockAuth.createdUsername, 'Amaia');

        // Maintenant connecté : bandeau présent et bouton de lancement de partie visible
        expect(
          find.byKey(const ValueKey('home-profile-banner')),
          findsOneWidget,
        );
        expect(find.text('Amaia • 1000 🏆'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-create-button')),
          findsOneWidget,
        );

        // Le champ pseudo a disparu car le profil est désormais chargé
        expect(find.byKey(const ValueKey('home-pseudo-input')), findsNothing);
      },
    );

    testWidgets(
      'Étape C - Connecté avec profil existant : Bandeau Joueur/Elo direct et aucun champ pseudo',
      (tester) async {
        final mockAuth = _MockAuthRepository(
          initialProfile: {
            'id': '123e4567-e89b-12d3-a456-426614174000',
            'username': 'Patxi',
            'elo': 1250,
          },
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(
                _MockSupabaseRepository(),
              ),
            ],
            child: const MyApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Bandeau de joueur avec Elo
        expect(
          find.byKey(const ValueKey('home-profile-banner')),
          findsOneWidget,
        );
        expect(find.text('Patxi • 1250 🏆'), findsOneWidget);

        // Bouton d'action du premier mode
        expect(
          find.byKey(const ValueKey('home-create-button')),
          findsOneWidget,
        );

        // Aucun champ pseudo dans les formulaires
        expect(find.byKey(const ValueKey('home-pseudo-input')), findsNothing);
      },
    );

    testWidgets(
      'Créer une partie en étant connecté -> Matchmaking public et navigation vers GameScreen',
      (tester) async {
        final mockAuth = _MockAuthRepository(
          userId: '999e4567-e89b-12d3-a456-426614174000',
          initialProfile: {
            'id': '999e4567-e89b-12d3-a456-426614174000',
            'username': 'Amaia',
            'elo': 1100,
          },
        );
        final mockRepo = _MockSupabaseRepository();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Clic direct sur "Lancer la partie" sur Carte 1 (Classique)
        await tester.tap(find.byKey(const ValueKey('home-create-button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        expect(mockRepo.lastCreatedHostName, isNull);
        expect(mockRepo.lastCreatedUserId, isNull);
        expect(mockRepo.lastCreatedMode, 'casual');
        expect(find.byType(LobbyScreen), findsNothing);
        expect(find.byType(GameScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey('public-queue-overlay')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Créer une partie en Mode Classé -> Matchmaking ranked vers GameScreen',
      (tester) async {
        final mockAuth = _MockAuthRepository(
          userId: '999e4567-e89b-12d3-a456-426614174000',
          initialProfile: {
            'id': '999e4567-e89b-12d3-a456-426614174000',
            'username': 'Amaia',
            'elo': 1100,
          },
        );
        final mockRepo = _MockSupabaseRepository();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Navigation vers la Carte 2 (En ligne Classé) via le dot 1
        await tester.tap(find.byKey(const ValueKey('carousel-dot-1')));
        await tester.pumpAndSettle();

        // Vérification des éléments de la carte classée
        expect(find.text(testL10n.menuONLINERANKED), findsOneWidget);
        expect(find.text('Votre Elo actuel : 1100'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-launch-ranked-button')),
          findsOneWidget,
        );

        // Clic sur Lancer (Classé) après défilement du contenu pédagogique.
        await tester.ensureVisible(
          find.byKey(const ValueKey('home-launch-ranked-button')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();
        await tester.tap(
          find.byKey(const ValueKey('home-launch-ranked-button')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        expect(mockRepo.lastCreatedHostName, isNull);
        expect(mockRepo.lastCreatedUserId, isNull);
        expect(mockRepo.lastCreatedMode, 'ranked');
        expect(find.byType(LobbyScreen), findsNothing);
        expect(find.byType(GameScreen), findsOneWidget);
      },
    );

    testWidgets(
      'GameOverOverlay en Mode Classé -> affiche le résultat validé par le serveur',
      (tester) async {
        final mockPlayer = _MockPlayerRepository();
        final mockAuth = _MockAuthRepository(
          userId: '123e4567-e89b-12d3-a456-426614174000',
          initialProfile: {
            'id': '123e4567-e89b-12d3-a456-426614174000',
            'username': 'Patxi',
            'elo': 1000,
          },
        );
        final testState = MusGameState.initial().copyWith(
          phase: MusPhase.gameOver,
          tantto: const [40, 20],
          mancheWinner: 0,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              playerRepositoryProvider.overrideWithValue(mockPlayer),
              authRepositoryProvider.overrideWithValue(mockAuth),
            ],
            child: MaterialApp(
              locale: const Locale('fr'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,

              home: Scaffold(
                body: Stack(
                  children: [
                    GameOverOverlay(
                      state: testState,
                      localSeat: 0, // Victoire équipe A
                      mode: 'ranked',
                      gameId: 'validated-game',
                      userId: '123e4567-e89b-12d3-a456-426614174000',
                      playerElo: 1000,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Badge Elo visible en mode classé
        expect(find.byKey(const Key('game-over-elo-badge')), findsOneWidget);
        // Espérance contre 1200 : 32 * (1 - 0.24) = +24
        expect(find.textContaining('+24'), findsOneWidget);
        expect(mockAuth.updateMatchResultCalled, isFalse);
        expect(mockPlayer.finished, isTrue);
      },
    );

    testWidgets(
      'GameOverOverlay en Mode Classique -> N\'affiche PAS le badge Elo et n\'appelle pas updateMatchResult',
      (tester) async {
        final mockAuth = _MockAuthRepository(
          userId: '123e4567-e89b-12d3-a456-426614174000',
          initialProfile: {
            'id': '123e4567-e89b-12d3-a456-426614174000',
            'username': 'Patxi',
            'elo': 1000,
          },
        );
        final testState = MusGameState.initial().copyWith(
          phase: MusPhase.gameOver,
          tantto: const [40, 20],
          mancheWinner: 0,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
            ],
            child: MaterialApp(
              locale: const Locale('fr'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,

              home: Scaffold(
                body: Stack(
                  children: [
                    GameOverOverlay(
                      state: testState,
                      localSeat: 0,
                      mode: 'casual',
                      userId: '123e4567-e89b-12d3-a456-426614174000',
                      playerElo: 1000,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('game-over-elo-badge')), findsNothing);
        expect(mockAuth.updateMatchResultCalled, isFalse);
      },
    );

    testWidgets('Créer un salon Amis conserve LobbyScreen et le mode privé', (
      tester,
    ) async {
      final auth = _MockAuthRepository(
        userId: '999e4567-e89b-12d3-a456-426614174000',
        initialProfile: {
          'id': '999e4567-e89b-12d3-a456-426614174000',
          'username': 'Amaia',
          'elo': 1100,
        },
      );
      final repo = _MockSupabaseRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            supabaseRepositoryProvider.overrideWithValue(repo),
            audioHapticServiceProvider.overrideWithValue(
              FakeAudioHapticService(),
            ),
          ],
          child: const MyApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('carousel-dot-3')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('home-create-private-button')),
      );
      await tester.tap(
        find.byKey(const ValueKey('home-create-private-button')),
      );
      await tester.pumpAndSettle();
      expect(repo.lastCreatedMode, 'private');
      expect(repo.lastCreatedHostName, 'Amaia');
      expect(find.byType(LobbyScreen), findsOneWidget);
      expect(find.byType(GameScreen), findsNothing);
    });
    testWidgets(
      'Rejoindre une partie en étant connecté -> Saisie code uniquement et navigation vers LobbyScreen',
      (tester) async {
        final mockAuth = _MockAuthRepository(
          userId: '888e4567-e89b-12d3-a456-426614174000',
          initialProfile: {
            'id': '888e4567-e89b-12d3-a456-426614174000',
            'username': 'Gorka',
            'elo': 950,
          },
        );
        final mockRepo = _MockSupabaseRepository();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Navigation vers la Carte 4 (Jouer avec des amis) via l'indicateur dot 3
        await tester.tap(find.byKey(const ValueKey('carousel-dot-3')));
        await tester.pumpAndSettle();

        expect(find.text(testL10n.menuPLAYWITHFRIENDS), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-create-private-button')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('home-code-input')), findsOneWidget);
        expect(find.byKey(const ValueKey('home-pseudo-input')), findsNothing);
        expect(find.text(testL10n.menuConfirmAndJoin), findsOneWidget);

        await tester.enterText(
          find.byKey(const ValueKey('home-code-input')),
          'ABCDE',
        );
        await tester.tap(find.byKey(const ValueKey('home-join-button')));
        await tester.pumpAndSettle();

        expect(mockRepo.lastJoinedPlayerName, 'Gorka');
        expect(
          mockRepo.lastJoinedUserId,
          '888e4567-e89b-12d3-a456-426614174000',
        );
        expect(find.byType(LobbyScreen), findsOneWidget);
      },
    );

    testWidgets('Erreur lors de la création de partie -> SnackBar rouge', (
      tester,
    ) async {
      final mockAuth = _MockAuthRepository(
        initialProfile: {
          'id': '111e4567-e89b-12d3-a456-426614174000',
          'username': 'Amaia',
          'elo': 1000,
        },
      );
      final mockRepo = _MockSupabaseRepository(
        createGameError: Exception('Erreur réseau création'),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioHapticServiceProvider.overrideWithValue(
              FakeAudioHapticService(),
            ),
            authRepositoryProvider.overrideWithValue(mockAuth),
            supabaseRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MyApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('home-create-button')));
      await tester.pumpAndSettle();

      expect(find.text(testL10n.menuUnableToCompleteThisActionCheckYourConnectionAnd), findsOneWidget);
      expect(find.byType(LobbyScreen), findsNothing);
    });

    testWidgets('Erreur de connexion (Partie introuvable) -> SnackBar rouge', (
      tester,
    ) async {
      final mockAuth = _MockAuthRepository(
        initialProfile: {
          'id': '222e4567-e89b-12d3-a456-426614174000',
          'username': 'Gorka',
          'elo': 1000,
        },
      );
      final mockRepo = _MockSupabaseRepository(
        joinGameError: const GameNotFoundException('Code introuvable'),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioHapticServiceProvider.overrideWithValue(
              FakeAudioHapticService(),
            ),
            authRepositoryProvider.overrideWithValue(mockAuth),
            supabaseRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MyApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Navigation vers la Carte 4 (Jouer avec des amis) via l'indicateur dot 3
      await tester.tap(find.byKey(const ValueKey('carousel-dot-3')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('home-code-input')),
        'ZZZZZ',
      );
      await tester.tap(find.byKey(const ValueKey('home-join-button')));
      await tester.pumpAndSettle();

      expect(find.text(testL10n.menuUnableToCompleteThisActionCheckYourConnectionAnd), findsOneWidget);
      expect(find.byType(LobbyScreen), findsNothing);
    });

    testWidgets(
      'Erreur lors de la création de profil -> Affiche un SnackBar d\'erreur',
      (tester) async {
        final mockAuth = _MockAuthRepository(
          createProfileError: Exception('Erreur serveur profil'),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(
                _MockSupabaseRepository(),
              ),
            ],
            child: const MyApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('home-pseudo-input')),
          'Amaia',
        );
        await tester.tap(
          find.byKey(const ValueKey('home-create-profile-button')),
        );
        await tester.pumpAndSettle();

        expect(find.text(testL10n.menuUnableToCompleteThisActionCheckYourConnectionAnd), findsOneWidget);
        expect(find.byKey(const ValueKey('home-pseudo-input')), findsOneWidget);
      },
    );

    testWidgets(
      'Erreur de chargement du profil sans connexion anonyme automatique',
      (tester) async {
        final mockAuth = _MockAuthRepository(
          getProfileError: Exception('Erreur get profile'),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(
                _MockSupabaseRepository(),
              ),
            ],
            child: const MyApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(mockAuth.anonymousCalls, 0);
        expect(find.text(testL10n.menuCREATEYOURPROFILE), findsOneWidget);
        expect(find.byKey(const ValueKey('home-pseudo-input')), findsOneWidget);
      },
    );

    testWidgets(
      'Rouage visible et utilisable dans le bandeau sur écran étroit',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final auth = _MockAuthRepository(
          initialProfile: {
            'username': 'PseudoLongDeVingtCaracter',
            'elo': 1320,
          },
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(auth),
              playerProfileProvider.overrideWith(
                (ref) async => {'sound_enabled': true},
              ),
            ],
            child: const MyApp(home: MainDashboardScreen()),
          ),
        );
        await tester.pumpAndSettle();
        final button = find.byKey(const ValueKey('home-settings-button'));
        expect(tester.getRect(button).right, lessThanOrEqualTo(320));
        expect(tester.getSize(button).width, greaterThanOrEqualTo(44));
        expect(tester.takeException(), isNull);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'MainDashboardScreen : Navigation par onglets avec bandeau persistant',
      (tester) async {
        final mockAuth = _MockAuthRepository(
          userId: '123e4567-e89b-12d3-a456-426614174000',
          initialProfile: {
            'id': '123e4567-e89b-12d3-a456-426614174000',
            'username': 'Maddi',
            'elo': 1320,
          },
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              friendshipsProvider.overrideWith((ref) => Stream.value([])),
              playerProfileProvider.overrideWith(
                (ref) async => {
                  'username': 'Maddi',
                  'elo': 1320,
                  'games_played': 0,
                  'games_won': 0,
                },
              ),
              cosmeticsProvider.overrideWith((ref) async => []),
              inventoryProvider.overrideWith((ref) async => <String>{}),
              matchHistoryProvider.overrideWith((ref) async => []),
              leaderboardProvider.overrideWith((ref) async => []),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(
                _MockSupabaseRepository(),
              ),
            ],
            child: const MyApp(home: MainDashboardScreen()),
          ),
        );
        await tester.pumpAndSettle();

        Future<void> checkSettings() async {
          expect(
            find.descendant(
              of: find.byKey(const ValueKey('home-profile-banner')),
              matching: find.byKey(const ValueKey('home-settings-button')),
            ),
            findsOneWidget,
          );
          await tester.tap(find.byKey(const ValueKey('home-settings-button')));
          await tester.pumpAndSettle();
          expect(find.byType(SettingsScreen), findsOneWidget);
          expect(find.text(testL10n.menuSoundEffects), findsOneWidget);
          expect(find.text(testL10n.menuAccountSecurity), findsOneWidget);
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
          expect(find.byType(SettingsScreen), findsNothing);
        }

        await checkSettings();

        // Switch via the real settings route: the navigator and dashboard state
        // must survive each locale change, including the return to French.
        final dashboardState = tester.state(find.byType(MainDashboardScreen));
        for (final entry in [
          ('Euskara', 'eu', 'Jokatu', 'Denda', 'Profila', 'Ezarpenak'),
          ('Español', 'es', 'Jugar', 'Tienda', 'Perfil', 'Ajustes'),
          ('English', 'en', 'Play', 'Shop', 'Profile', 'Settings'),
          ('Français', 'fr', 'Jouer', 'Boutique', 'Profil', 'Réglages'),
        ]) {
          await tester.tap(find.byKey(const ValueKey('home-settings-button')));
          await tester.pumpAndSettle();
          final settingsState = tester.state(find.byType(SettingsScreen));
          await tester.tap(
            find.byKey(const ValueKey('settings-language-selector')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text(entry.$1).last);
          await tester.pumpAndSettle();
          expect(
            tester.state(find.byType(SettingsScreen)),
            same(settingsState),
          );
          expect(find.text(entry.$6), findsOneWidget);
          expect(
            Localizations.localeOf(tester.element(find.byType(SettingsScreen))),
            Locale(entry.$2),
          );
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
          expect(
            tester.state(find.byType(MainDashboardScreen)),
            same(dashboardState),
          );
          final nav = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(nav.currentIndex, 0);
          expect(nav.items[0].label, entry.$3);
          expect(nav.items[2].label, entry.$4);
          expect(nav.items[4].label, entry.$5);
          expect(tester.takeException(), isNull);
        }

        // Vérification des 4 onglets dans la barre de navigation
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.text('Jouer'), findsOneWidget);
        expect(find.text('Top 100'), findsOneWidget);
        expect(find.text(testL10n.friendsTitle), findsOneWidget);
        expect(find.text('Profil'), findsOneWidget);

        // Onglet 0 ("Jouer") actif par défaut
        expect(find.text(testL10n.menuGAMEMODES), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-profile-banner')),
          findsOneWidget,
        );
        expect(find.text('Maddi • 1320 🏆'), findsOneWidget);

        // Clic sur l'onglet 1 ("Top 100")
        await tester.tap(find.byKey(const ValueKey('nav-tab-leaderboard')));
        await tester.pumpAndSettle();

        expect(find.text(testL10n.menuTop100Players), findsOneWidget);
        expect(find.text(testL10n.menuNoRankedPlayersYet), findsOneWidget);
        // Le bandeau Joueur & Elo dans l'AppBar reste persistant et visible
        expect(
          find.byKey(const ValueKey('home-profile-banner')),
          findsOneWidget,
        );
        expect(find.text('Maddi • 1320 🏆'), findsOneWidget);
        await checkSettings();

        // Clic sur l'onglet 3 ("Amis")
        await tester.tap(find.byKey(const ValueKey('nav-tab-friends')));
        await tester.pumpAndSettle();

        await checkSettings();
        expect(find.text(testL10n.menuFriendsPrivateRooms), findsOneWidget);
        expect(find.text('En construction...'), findsNothing);
        expect(
          find.byKey(const ValueKey('home-profile-banner')),
          findsOneWidget,
        );

        // Clic sur l'onglet 4 ("Profil")
        await tester.tap(find.byKey(const ValueKey('nav-tab-profile')));
        await tester.pumpAndSettle();

        await checkSettings();
        expect(find.text(testL10n.menuPlayerProfile352), findsOneWidget);
        expect(find.text('En construction...'), findsNothing);
        expect(
          find.byKey(const ValueKey('home-profile-banner')),
          findsOneWidget,
        );

        // Retour à l'onglet "Jouer"
        await tester.tap(find.byKey(const ValueKey('nav-tab-play')));
        await tester.pumpAndSettle();

        expect(find.text(testL10n.menuGAMEMODES), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-create-button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'MainDashboardScreen : Navigation fluide dans le carrousel (Carte 1 -> Carte 2 -> Carte 1)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final mockAuth = _MockAuthRepository(
          userId: '123e4567-e89b-12d3-a456-426614174000',
          initialProfile: {
            'id': '123e4567-e89b-12d3-a456-426614174000',
            'username': 'Maddi',
            'elo': 1320,
          },
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              shopStateProvider.overrideWith(
                (ref) async => const ShopState(
                  items: [],
                  profile: {'coins': 275},
                  owned: {},
                ),
              ),
              activeSeasonProvider.overrideWith(
                (ref) async => GameSeason(
                  id: 'season_1',
                  name: 'Saison 1',
                  startDate: DateTime.utc(2026, 10, 1),
                  endDate: DateTime.utc(2026, 10, 31, 23),
                ),
              ),
              seasonClockProvider.overrideWithValue(
                () => DateTime.utc(2026, 10, 28, 12),
              ),
              playerProfileProvider.overrideWith(
                (ref) async => {'coins': 275, 'level': 7, 'xp': 250},
              ),
              retentionRepositoryProvider.overrideWithValue(_HomeRetention()),
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              authRepositoryProvider.overrideWithValue(mockAuth),
              supabaseRepositoryProvider.overrideWithValue(
                _MockSupabaseRepository(),
              ),
            ],
            child: const MyApp(home: MainDashboardScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('275'), findsOneWidget);
        expect(find.byKey(const ValueKey('home-level-badge')), findsOneWidget);
        expect(
          tester
              .widget<CircularProgressIndicator>(
                find.byKey(const ValueKey('home-xp-progress')),
              )
              .value,
          .5,
        );
        expect(find.byTooltip('Niveau 7 · 250 / 500 XP'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-quests-button')),
          findsOneWidget,
        );
        expect(find.text('Quêtes & Pass'), findsNothing);
        expect(tester.takeException(), isNull);
        final classicFrame = tester
            .widgetList<GameModeCard>(find.byType(GameModeCard))
            .first;
        await tester.tap(find.byKey(const ValueKey('home-quests-button')));
        await tester.pumpAndSettle();
        expect(find.byType(WeeklyQuestsSheet), findsOneWidget);
        expect(find.byType(BattlePassScreen), findsNothing);
        await tester.tap(find.byTooltip(testL10n.menuClose));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('open-battle-pass')));
        await tester.pumpAndSettle();
        expect(find.byType(BattlePassScreen), findsOneWidget);
        expect(find.byType(CountdownWidget), findsOneWidget);
        expect(find.byKey(const ValueKey('countdown-days-3')), findsOneWidget);
        expect(find.byType(WeeklyQuestsSheet), findsNothing);
        Navigator.of(tester.element(find.byType(BattlePassScreen))).pop();
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('open-shop')), findsNothing);
        final tabs = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(tabs.items.map((item) => item.label), [
          'Jouer',
          'Top 100',
          'Boutique',
          'Amis',
          'Profil',
        ]);
        await tester.tap(find.byKey(const ValueKey('nav-tab-shop')));
        await tester.pumpAndSettle();
        expect(find.byType(ShopScreen), findsOneWidget);
        expect(find.text('275 pièces'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-profile-banner')),
          findsOneWidget,
        );
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          2,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('nav-tab-play')));
        await tester.pumpAndSettle();

        // Au départ, sur la Carte 1 (En ligne Classique)
        expect(find.text(testL10n.menuONLINECASUAL), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-create-button')),
          findsOneWidget,
        );

        // Clic sur l'indicateur dot 1 -> Carte 2 (En ligne Classé)
        await tester.tap(find.byKey(const ValueKey('carousel-dot-1')));
        await tester.pumpAndSettle();

        expect(find.text(testL10n.menuONLINERANKED), findsOneWidget);
        expect(find.byType(CountdownWidget), findsOneWidget);
        expect(find.byKey(const ValueKey('countdown-days-3')), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const ValueKey('ranked-season-rewards')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('ranked-season-rewards')));
        await tester.pumpAndSettle();
        for (final elo in [1000, 1200, 1400, 1600]) {
          expect(find.text('$elo Elo'), findsOneWidget);
        }
        expect(find.text(testL10n.menuTxapelaBeret), findsOneWidget);
        await tester.tap(find.byTooltip(testL10n.menuClose));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('home-launch-ranked-button')),
          findsOneWidget,
        );
        expect(find.text('Votre Elo actuel : 1320'), findsOneWidget);

        // Clic sur l'indicateur dot 2 -> Carte 3 (Hors ligne Solo)
        await tester.tap(find.byKey(const ValueKey('carousel-dot-2')));
        await tester.pumpAndSettle();

        expect(find.text(testL10n.menuSOLOVSAI), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-launch-solo-button')),
          findsOneWidget,
        );

        // Clic sur l'indicateur dot 3 -> Carte 4 (Jouer avec des amis)
        await tester.tap(find.byKey(const ValueKey('carousel-dot-3')));
        await tester.pumpAndSettle();

        expect(find.text(testL10n.menuPLAYWITHFRIENDS), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-create-private-button')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('home-code-input')), findsOneWidget);
        expect(find.byKey(const ValueKey('home-join-button')), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('carousel-dot-4')));
        await tester.pumpAndSettle();
        final tutorialFrame = tester.widget<GameModeCard>(
          find.byKey(const ValueKey('tutorial-card')),
        );
        expect(tutorialFrame.colors, isNot(classicFrame.colors));
        expect(tutorialFrame.accent, isNot(classicFrame.accent));
        expect(find.text('TUTORIEL'), findsOneWidget);
        final rulesButton = find.byKey(
          const ValueKey('home-official-rules-button'),
        );
        await tester.ensureVisible(rulesButton);
        await tester.tap(rulesButton);
        await tester.pumpAndSettle();
        expect(find.text(testL10n.menuOfficialRules), findsOneWidget);
        expect(find.text('Article 21'), findsOneWidget);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Revenir sur Carte 1 via dot 0
        await tester.tap(find.byKey(const ValueKey('carousel-dot-0')));
        await tester.pumpAndSettle();

        expect(find.text(testL10n.menuONLINECASUAL), findsOneWidget);
        expect(
          find.byKey(const ValueKey('home-create-button')),
          findsOneWidget,
        );
      },
    );

    testWidgets('Carte 3 : Solo contre IA -> Lancement immédiat contre 3 IA', (
      tester,
    ) async {
      final mockAuth = _MockAuthRepository(
        userId: '123e4567-e89b-12d3-a456-426614174000',
        initialProfile: {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'username': 'Maddi',
          'elo': 1320,
        },
      );
      final mockRepo = _MockSupabaseRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioHapticServiceProvider.overrideWithValue(
              FakeAudioHapticService(),
            ),
            authRepositoryProvider.overrideWithValue(mockAuth),
            supabaseRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MyApp(home: MainDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Navigation vers la Carte 3 (Hors ligne Solo)
      await tester.tap(find.byKey(const ValueKey('carousel-dot-2')));
      await tester.pumpAndSettle();

      expect(find.text(testL10n.menuSOLOVSAI), findsOneWidget);
      expect(
        find.byKey(const ValueKey('home-launch-solo-button')),
        findsOneWidget,
      );

      // Clic sur "Jouer contre l'IA"
      await tester.tap(find.byKey(const ValueKey('home-launch-solo-button')));
      await tester.pumpAndSettle();

      // Vérifie que la partie a été créée et remplie immédiatement avec les 3 bots
      expect(mockRepo.lastCreatedHostName, 'Maddi');
      expect(mockRepo.fillWithBotsCalled, isTrue);
      expect(mockRepo.fillWithBotsPlayers, hasLength(1));
      expect(find.byType(GameScreen), findsOneWidget);
    });
  });

  group('LobbyScreen UI & Realtime transitions', () {
    testWidgets(
      'Affichage du code d\'invitation, compte 1/4 et copie presse-papier',
      (tester) async {
        final mockRepo = _MockSupabaseRepository();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              supabaseRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyApp(
              home: LobbyScreen(
                gameId: 'mock-game-uuid-123',
                playerName: 'Patxi',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('lobby-join-code')), findsOneWidget);
        expect(find.text('ABCDE'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('lobby-player-count')),
          findsOneWidget,
        );
        expect(find.text('1 / 4'), findsOneWidget);
        expect(find.text(testL10n.menuYOU), findsOneWidget);
        expect(
          find.byKey(const ValueKey('lobby-fill-bots-button')),
          findsOneWidget,
        );
        expect(find.text(testL10n.menuFillWithAIPlayers), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('lobby-copy-code-button')));
        await tester.pumpAndSettle();
        expect(
          find.text('Code ABCDE copié dans le presse-papier !'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Hôte clique sur "Compléter avec des IA" -> Déclenche fillWithBotsAndStart',
      (tester) async {
        final mockRepo = _MockSupabaseRepository();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              supabaseRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyApp(
              home: LobbyScreen(
                gameId: 'mock-game-uuid-123',
                playerName: 'Patxi',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(mockRepo.fillWithBotsCalled, isFalse);
        final fillButton = find.byKey(const ValueKey('lobby-fill-bots-button'));
        await tester.ensureVisible(fillButton);
        await tester.tap(fillButton);
        await tester.pump();

        expect(mockRepo.fillWithBotsCalled, isTrue);
        expect(mockRepo.fillWithBotsGameId, 'mock-game-uuid-123');
        expect(mockRepo.fillWithBotsPlayers?.length, 1);
      },
    );

    testWidgets(
      'Joueur non-hôte ne voit pas le bouton IA mais "En attente de l\'hôte..."',
      (tester) async {
        final mockRepo = _MockSupabaseRepository(
          gameStream: Stream.value({
            'id': 'mock-game-uuid-123',
            'join_code': 'ABCDE',
            'status': 'waiting',
            'players': [
              {'name': 'Patxi', 'seat': 0, 'is_host': true},
              {'name': 'Amaia', 'seat': 1, 'is_host': false},
            ],
          }),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              supabaseRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyApp(
              home: LobbyScreen(
                gameId: 'mock-game-uuid-123',
                playerName: 'Amaia',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Amaia est au siège 1 (pas l'hôte)
        expect(
          find.byKey(const ValueKey('lobby-fill-bots-button')),
          findsNothing,
        );
        expect(find.text(testL10n.menuWaitingForTheHost), findsOneWidget);
      },
    );

    testWidgets(
      'Arrivée des bots via Realtime -> Transition vers GameScreen avec les pseudos des bots',
      (tester) async {
        final streamController =
            StreamController<Map<String, dynamic>>.broadcast();
        addTearDown(streamController.close);

        final mockRepo = _MockSupabaseRepository(
          gameStream: streamController.stream,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              supabaseRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyApp(
              home: LobbyScreen(
                gameId: 'mock-game-uuid-123',
                playerName: 'Patxi',
              ),
            ),
          ),
        );

        // 1. Initial : 1 joueur (Hôte)
        streamController.add({
          'id': 'mock-game-uuid-123',
          'join_code': 'K9X2M',
          'status': 'waiting',
          'players': [
            {'name': 'Patxi', 'seat': 0, 'is_host': true},
          ],
        });
        await tester.pumpAndSettle();
        expect(find.text('1 / 4'), findsOneWidget);
        expect(find.text(testL10n.menuFillWithAIPlayers), findsOneWidget);
        expect(find.byType(GameScreen), findsNothing);

        // 2. Événement Realtime : L'hôte a complété avec 3 bots
        streamController.add({
          'id': 'mock-game-uuid-123',
          'join_code': 'K9X2M',
          'status': 'ready',
          'players': [
            {'name': 'Patxi', 'seat': 0, 'is_host': true},
            {'name': 'Bot 1', 'seat': 1, 'is_host': false, 'is_bot': true},
            {'name': 'Bot 2', 'seat': 2, 'is_host': false, 'is_bot': true},
            {'name': 'Bot 3', 'seat': 3, 'is_host': false, 'is_bot': true},
          ],
        });
        await tester.pumpAndSettle();

        // Navigation vers GameScreen
        expect(find.byType(GameScreen), findsOneWidget);
        expect(find.byType(LobbyScreen), findsNothing);
        // Vérification que les noms des bots sont présents à la table
        expect(find.text('Patxi'), findsWidgets);
        expect(find.text('Mikel'), findsOneWidget);
        expect(find.text('Txomin'), findsOneWidget);
      },
    );

    testWidgets(
      'Arrivée du 4e joueur (status ready) -> Transition automatique vers GameScreen',
      (tester) async {
        final streamController =
            StreamController<Map<String, dynamic>>.broadcast();
        addTearDown(streamController.close);

        final mockRepo = _MockSupabaseRepository(
          gameStream: streamController.stream,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              supabaseRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyApp(
              home: LobbyScreen(
                gameId: 'mock-game-uuid-123',
                playerName: 'Patxi',
              ),
            ),
          ),
        );

        // 1. État initial : 2 joueurs
        streamController.add({
          'id': 'mock-game-uuid-123',
          'join_code': 'K9X2M',
          'status': 'waiting',
          'players': [
            {'name': 'Patxi', 'seat': 0, 'is_host': true},
            {'name': 'Amaia', 'seat': 1, 'is_host': false},
          ],
        });
        await tester.pumpAndSettle();
        expect(find.text('2 / 4'), findsOneWidget);
        expect(find.byType(GameScreen), findsNothing);

        // 2. Événement Realtime : 4 joueurs et statut ready
        streamController.add({
          'id': 'mock-game-uuid-123',
          'join_code': 'K9X2M',
          'status': 'ready',
          'players': [
            {'name': 'Patxi', 'seat': 0, 'is_host': true},
            {'name': 'Amaia', 'seat': 1, 'is_host': false},
            {'name': 'Mikel', 'seat': 2, 'is_host': false},
            {'name': 'Leire', 'seat': 3, 'is_host': false},
          ],
        });
        await tester.pumpAndSettle();

        // Navigation automatique vers GameScreen
        expect(find.byType(GameScreen), findsOneWidget);
        expect(find.byType(LobbyScreen), findsNothing);
      },
    );

    testWidgets(
      'Erreur lors de fillWithBotsAndStart -> Affiche un SnackBar d\'erreur',
      (tester) async {
        final mockRepo = _MockSupabaseRepository(
          fillWithBotsError: Exception('Connexion perdue avec Supabase'),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioHapticServiceProvider.overrideWithValue(
                FakeAudioHapticService(),
              ),
              supabaseRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyApp(
              home: LobbyScreen(
                gameId: 'mock-game-uuid-123',
                playerName: 'Patxi',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final fillButton = find.byKey(const ValueKey('lobby-fill-bots-button'));
        await tester.ensureVisible(fillButton);
        await tester.tap(fillButton);
        await tester.pumpAndSettle();

        expect(find.textContaining('Action impossible.'), findsOneWidget);
      },
    );
  });
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
