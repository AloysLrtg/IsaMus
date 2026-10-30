import '../shop/shop_screen.dart';
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../core/network/auth_repository.dart';
import '../../core/engine/bot_profile.dart';
import '../../core/engine/mus_game_controller.dart';
import '../../core/network/supabase_repository.dart';
import '../game/game_screen.dart';
import 'lobby_screen.dart';
import 'game_mode_card.dart';
import 'profile_xp_avatar.dart';
import 'season_pass_button.dart';
import '../seasons/season_countdown.dart';
import '../seasons/league_rewards_sheet.dart';
import '../retention/battle_pass_screen.dart';
import 'leaderboard_tab.dart';
import '../social/friends_tab.dart';
import '../profile/profile_tab.dart';
import '../profile/account_screen.dart';
import '../settings/settings_screen.dart';
import '../tutorial/tutorial_screen.dart';
import '../rules/rules_screen.dart';
import '../retention/quests_screen.dart';
import '../../core/network/player_repository.dart';
import '../../core/network/leaderboard_repository.dart';
import '../../core/monetization/ads_banner.dart';

const _scaffoldBg = Color(0xFF0B1221);
const _cardBg = Color(0xFF132238);
const _gold = Color(0xFFFFD54F);
const _goldAccent = Color(0xFFFFA000);
const _cyanA = Color(0xFF38BDF8);

enum _HomeAuthStatus { loading, needsRegistration, authenticated }

/// Écran principal de type Hub Mobile complet (MainDashboardScreen).
///
/// Comprend :
/// 1. Un AppBar persistant avec bandeau joueur & Elo partagé.
/// 2. Une BottomNavigationBar stylisée à 5 onglets (Jouer, Top 100, Boutique, Amis, Profil).
/// 3. Un carrousel de cartes en PageView horizontal pour le choix du mode de jeu (Créer / Rejoindre).
class MainDashboardScreen extends ConsumerStatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  ConsumerState<MainDashboardScreen> createState() =>
      _MainDashboardScreenState();
}

class _MainDashboardScreenState extends ConsumerState<MainDashboardScreen> {
  final _pseudoController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final PageController _pageController;

  _HomeAuthStatus _authStatus = _HomeAuthStatus.loading;
  String? _userId;
  Map<String, dynamic>? _profile;

  int _currentTabIndex = 0;
  int _currentCarouselPage = 0;
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _initAuthAndProfile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pseudoController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _initAuthAndProfile() async {
    setState(() => _authStatus = _HomeAuthStatus.loading);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userId = authRepo.currentUserId;
      if (userId == null) throw StateError('Connectez-vous pour jouer.');
      _userId = userId;
      final profile = await authRepo.getProfile(userId);

      if (!mounted) return;
      if (profile != null) {
        setState(() {
          _profile = profile;
          _authStatus = _HomeAuthStatus.authenticated;
        });
      } else {
        setState(() {
          _profile = null;
          _authStatus = _HomeAuthStatus.needsRegistration;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _authStatus = _HomeAuthStatus.needsRegistration;
      });
    }
  }

  Future<void> _refreshProfile() async {
    if (_userId == null) return;
    final profile = await ref.read(authRepositoryProvider).getProfile(_userId!);
    if (!mounted) return;
    if (profile != null) setState(() => _profile = profile);
    ref.invalidate(playerProfileProvider);
    ref.invalidate(matchHistoryProvider);
    ref.invalidate(leaderboardProvider);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateProfile() async {
    final pseudo = _pseudoController.text.trim();
    if (pseudo.isEmpty) {
      _showError('Veuillez saisir votre pseudo.');
      return;
    }

    setState(() => _isLoadingAction = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final uid = _userId ?? authRepo.currentUserId;
      if (uid == null) {
        throw StateError('Connectez-vous pour créer votre profil.');
      }
      _userId = uid;
      await authRepo.createProfile(uid, pseudo);
      final profile =
          await authRepo.getProfile(uid) ??
          {'id': uid, 'username': pseudo, 'elo': 1000};

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _authStatus = _HomeAuthStatus.authenticated;
      });
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoadingAction = false);
        unawaited(_refreshProfile());
      }
    }
  }

  Future<void> _handleCreateGame({String mode = 'casual'}) async {
    final pseudo = _profile?['username']?.toString() ?? 'Joueur';

    setState(() => _isLoadingAction = true);
    try {
      final repository = ref.read(supabaseRepositoryProvider);
      if (mode != 'private') {
        final game = await repository.findPublicGame(mode);
        if (!mounted) return;
        ref.invalidate(musGameControllerProvider);
        final players = List<dynamic>.from(game['players'] as List);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GameScreen(
              gameId: game['id'] as String,
              localSeat: game['local_seat'] as int,
              players: players,
              mode: mode,
              userId: _userId,
              publicMatchmaking: true,
              initialGame: game,
            ),
          ),
        );
        return;
      }
      final gameId = await repository.createGame(
        pseudo,
        userId: _userId,
        mode: mode,
      );

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            gameId: gameId,
            playerName: pseudo,
            initialMode: mode,
          ),
        ),
      );
    } on Exception catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoadingAction = false);
        unawaited(_refreshProfile());
      }
    }
  }

  Future<void> _handlePlaySolo() async {
    final pseudo = _profile?['username']?.toString() ?? 'Joueur';

    setState(() => _isLoadingAction = true);
    try {
      final repository = ref.read(supabaseRepositoryProvider);
      final gameId = await repository.createGame(
        pseudo,
        userId: _userId,
        mode: 'casual',
      );

      final bots = BotProfile.shuffled(ref.read(botLineupRandomProvider));
      final players = [
        {
          'id': _userId ?? 'player_host',
          'name': pseudo,
          'seat': 0,
          'is_host': true,
          'is_bot': false,
        },
        for (var i = 0; i < bots.length; i++)
          {
            'id': 'bot_${i + 1}',
            'seat': i + 1,
            'is_host': false,
            'is_bot': true,
            'name': bots[i].name,
            'bot_personality': bots[i].personality.name,
            'avatar_config': bots[i].avatar.toJson(),
          },
      ];

      await repository.fillWithBotsAndStart(gameId, [players.first]);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameScreen(
            gameId: gameId,
            localSeat: 0,
            playerNames: [pseudo, ...bots.map((p) => p.name)],
            players: players,
            mode: 'casual',
            userId: _userId,
          ),
        ),
      );
    } on Exception catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoadingAction = false);
        unawaited(_refreshProfile());
      }
    }
  }

  Future<void> _handleJoinGame() async {
    final pseudo = _profile?['username']?.toString() ?? 'Joueur';
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 5) {
      _showError('Le code doit comporter exactement 5 caractères.');
      return;
    }

    setState(() => _isLoadingAction = true);
    try {
      final repository = ref.read(supabaseRepositoryProvider);
      final gameId = await repository.joinGame(code, pseudo, userId: _userId);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LobbyScreen(gameId: gameId, playerName: pseudo),
        ),
      );
    } on Exception catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoadingAction = false);
        unawaited(_refreshProfile());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authStatus == _HomeAuthStatus.loading) {
      return Scaffold(
        backgroundColor: _scaffoldBg,
        body: SafeArea(child: Center(child: _buildLoadingCard())),
      );
    }

    if (_authStatus == _HomeAuthStatus.needsRegistration) {
      return Scaffold(
        backgroundColor: _scaffoldBg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLogoHeader(),
                      const SizedBox(height: 32),
                      _buildRegistrationCard(),
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountScreen(),
                            ),
                          );
                          if (mounted) _initAuthAndProfile();
                        },
                        child: const Text('J’ai déjà un compte'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ÉTAT AUTHENTIFIÉ : Navigation Shell avec Custom AppBar, BottomNav et Tabs
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: _buildCustomAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildTabBody()),
            if (_currentTabIndex == 0 && adsEnabled) const DashboardAdBanner(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// AppBar personnalisé affichant le titre de l'application et le bandeau Joueur & Elo persistant.
  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(74),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 16,
          right: 16,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LOGO ISAMUS COMPACT
            if (MediaQuery.sizeOf(context).width >= 420)
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFFF9C4), Color(0xFFFFB300)],
                ).createShader(bounds),
                child: const Text(
                  'IsaMus',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(width: 8),

            // BANDEAU DE PROFIL JOUEUR & ELO (visible sur tous les onglets)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildProfileBanner(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bandeau Joueur & Elo stylisé (partagé entre tous les onglets).
  Widget _buildProfileBanner() {
    final profile = {
      ...?_profile,
      ...?ref.watch(playerProfileProvider).asData?.value,
    };
    final pseudo = profile['username']?.toString() ?? 'Joueur';
    final elo = profile['elo'] ?? 800;
    final coins = profile['coins'] ?? 0;

    return Container(
      key: const ValueKey('home-profile-banner'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF132A46), Color(0xFF0F1E33)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cyanA.withOpacity(0.6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _cyanA.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileXpAvatar(profile: profile),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$pseudo • $elo 🏆',
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: '$coins pièces',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monetization_on_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$coins',
                  key: const ValueKey('home-coins'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('home-quests-button'),
            tooltip: 'Quêtes hebdomadaires',
            icon: const Icon(Icons.assignment_outlined, size: 22),
            onPressed: () => showWeeklyQuests(context),
          ),
          IconButton(
            key: const ValueKey('home-settings-button'),
            tooltip: AppLocalizations.of(context)!.settingsTitle,
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white70,
              size: 22,
            ),
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              if (mounted) await _refreshProfile();
            },
          ),
        ],
      ),
    );
  }

  /// Corps de l'écran affichant l'onglet sélectionné.
  Widget _buildTabBody() {
    switch (_currentTabIndex) {
      case 0:
        return _buildPlayTab();
      case 1:
        return LeaderboardTab(currentUserId: _userId);
      case 2:
        return const ShopScreen(embedded: true);
      case 3:
        return FriendsTab(
          userId: _userId!,
          username: _profile?['username']?.toString() ?? 'Joueur',
        );
      case 4:
        return ProfileTab(onChanged: _refreshProfile);
      default:
        return _buildPlayTab();
    }
  }

  /// Onglet "Jouer" avec le carrousel horizontal des 4 modes de jeu thématiques.
  Widget _buildPlayTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MODES DE JEU',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: [
                  _buildPageIndicatorDot(0),
                  const SizedBox(width: 6),
                  _buildPageIndicatorDot(1),
                  const SizedBox(width: 6),
                  _buildPageIndicatorDot(2),
                  const SizedBox(width: 6),
                  _buildPageIndicatorDot(3),
                  const SizedBox(width: 8),
                  _buildPageIndicatorDot(4),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SeasonPassButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BattlePassScreen()),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // CARROUSEL DE CARTES (PAGEVIEW.BUILDER HORIZONTAL 85% DE LARGEUR)
        Expanded(
          child: SizedBox(
            height: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 5,
              onPageChanged: (page) =>
                  setState(() => _currentCarouselPage = page),
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _buildCasualCard();
                  case 1:
                    return _buildRankedCard();
                  case 2:
                    return _buildSoloCard();
                  case 3:
                    return _buildFriendsCard();
                  case 4:
                    return _buildTutorialCard();
                  default:
                    return _buildCasualCard();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildPageIndicatorDot(int index) {
    final isActive = _currentCarouselPage == index;
    final dotColor = switch (index) {
      0 => _cyanA,
      1 => _gold,
      2 => const Color(0xFF34D399),
      3 => const Color(0xFFC084FC),
      _ => _gold,
    };

    return InkWell(
      key: ValueKey('carousel-dot-$index'),
      borderRadius: BorderRadius.circular(4),
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isActive ? 22 : 8,
        height: 6,
        decoration: BoxDecoration(
          color: isActive ? dotColor : Colors.white24,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isActive
              ? [BoxShadow(color: dotColor.withOpacity(0.4), blurRadius: 8)]
              : null,
        ),
      ),
    );
  }

  /// Carte 1 : "En ligne (Classique)" (Dégradé Cyan/Bleu, cartes en filigrane)
  Widget _buildCyanModeAction({
    Key? key,
    required String label,
    required VoidCallback onPressed,
  }) => Container(
    height: 54,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0284C7).withValues(alpha: .45),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: FilledButton.icon(
      key: key,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.play_arrow_rounded, size: 24),
      label: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: .5,
          color: Colors.white,
        ),
      ),
    ),
  );

  Widget _buildTutorialCard() {
    final theme = Theme.of(context);
    const amber = Color(0xFFFFB74D);
    const ink = Color(0xFF2B1405);
    return GameModeCard(
      key: const ValueKey('tutorial-card'),
      colors: const [Color(0xFF6B2D0B), Color(0xFF452008), Color(0xFF241207)],
      accent: amber,
      borderOpacity: .65,
      glow: amber.withValues(alpha: .2),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            right: -25,
            bottom: -25,
            child: IgnorePointer(
              child: Opacity(
                opacity: .1,
                child: Icon(
                  Icons.school_rounded,
                  size: 180,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: amber.withValues(alpha: .12),
                          border: Border.all(
                            color: amber.withValues(alpha: .45),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: amber,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: amber.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: amber.withValues(alpha: .3),
                                ),
                              ),
                              child: Text(
                                'À VOTRE RYTHME',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: amber,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.tutorialTitle
                                  .toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Prenez place à la table et apprenez le Mus, des premières décisions au décompte des points.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFFFE0B2),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: amber,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sans chronomètre · Guidé, puis libre',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: const Color(0xFFFFE0B2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: amber,
                      foregroundColor: ink,
                      minimumSize: const Size(0, 54),
                    ),
                    icon: const Icon(Icons.school_rounded),
                    label: const Text('Apprendre le Mus'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TutorialScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: const ValueKey('home-official-rules-button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ink,
                      backgroundColor: const Color(0xFFFFE0B2),
                      side: const BorderSide(color: amber),
                      minimumSize: const Size(0, 48),
                    ),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Règles officielles'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RulesScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCasualCard() {
    return GameModeCard(
      colors: const [Color(0xFF0C4A6E), Color(0xFF082F49), Color(0xFF031424)],
      accent: _cyanA,
      borderOpacity: .65,
      glow: _cyanA.withValues(alpha: .28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Filigrane icône cartes en bas à droite
            Positioned(
              right: -25,
              bottom: -25,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.1,
                  child: const Icon(
                    Icons.style_rounded,
                    size: 180,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _cyanA.withOpacity(0.18),
                            border: Border.all(
                              color: _cyanA.withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.style_rounded,
                            color: _cyanA,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _cyanA.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _cyanA.withOpacity(0.4),
                                  ),
                                ),
                                child: const Text(
                                  'MULTIJOUEUR RAPIDE',
                                  style: TextStyle(
                                    color: _cyanA,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'EN LIGNE (CLASSIQUE)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Défiez des joueurs en ligne dans des parties amicales et détendues, sans enjeu d\'Elo. Idéal pour partager un bon moment de Mus.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: _cyanA,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Règles officielles 4 Rois et 4 As • Sans pression',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoadingAction)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: _cyanA),
                        ),
                      )
                    else
                      _buildCyanModeAction(
                        key: const ValueKey('home-create-button'),
                        label: 'Lancer la partie',
                        onPressed: () => _handleCreateGame(mode: 'casual'),
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

  /// Carte 2 : "En ligne (Classé)" (Dégradé Or/Rouge sombre, trophée en filigrane, rappel Elo)
  Widget _buildRankedCard() {
    final elo = _profile?['elo'] ?? 800;

    return GameModeCard(
      colors: const [Color(0xFF581515), Color(0xFF3A0D0D), Color(0xFF1E0707)],
      accent: _gold,
      glow: _goldAccent.withValues(alpha: .35),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Filigrane trophée en bas à droite
            Positioned(
              right: -25,
              bottom: -25,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.1,
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 180,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold.withOpacity(0.18),
                            border: Border.all(
                              color: _gold.withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: _gold,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _gold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _gold.withOpacity(0.4),
                                  ),
                                ),
                                child: const Text(
                                  'COMPÉTITION OFFICIELLE',
                                  style: TextStyle(
                                    color: _gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'EN LIGNE (CLASSÉ)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // RAPPEL DE L'ELO ACTUEL DU JOUEUR
                    Container(
                      key: const ValueKey('card-ranked-elo-badge'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF280C0C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _gold.withOpacity(0.5),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _goldAccent.withOpacity(0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            color: _gold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Votre Elo actuel : $elo',
                              style: const TextStyle(
                                color: _gold,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SeasonCountdown(showName: true),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const ValueKey('ranked-season-rewards'),
                      onPressed: () => showLeagueRewards(context),
                      icon: const Icon(Icons.workspace_premium),
                      label: const Text('Récompenses de Saison'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Grimpez dans le classement compétitif. Chaque victoire augmente votre cote Elo, chaque défaite en coûte. Visez le Top 100 !',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoadingAction)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: _gold),
                        ),
                      )
                    else
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFCA28), Color(0xFFFFA000)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFA000).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FilledButton.icon(
                          key: const ValueKey('home-launch-ranked-button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: const Color(0xFF261802),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => _handleCreateGame(mode: 'ranked'),
                          icon: const Icon(
                            Icons.emoji_events_rounded,
                            size: 22,
                            color: Color(0xFF261802),
                          ),
                          label: const Text(
                            'Lancer (Classé)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: Color(0xFF261802),
                            ),
                          ),
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

  /// Carte 3 : "Solo contre IA" (Dégradé Vert émeraude/Gris sombre, robot IA en filigrane)
  Widget _buildSoloCard() {
    return GameModeCard(
      colors: const [Color(0xFF064E3B), Color(0xFF043327), Color(0xFF031913)],
      accent: const Color(0xFF34D399),
      glow: const Color(0xFF10B981).withValues(alpha: .28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Filigrane robot en bas à droite
            Positioned(
              right: -25,
              bottom: -25,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.1,
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    size: 180,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF34D399).withOpacity(0.18),
                            border: Border.all(
                              color: const Color(0xFF34D399).withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: Color(0xFF34D399),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF34D399)
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: const Text(
                                  'ENTRAÎNEMENT SOLO',
                                  style: TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'SOLO CONTRE IA',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Affrontez 3 intelligences artificielles locales sans attendre d\'autres joueurs. Parfait pour réviser les règles, tactiques et signes basques.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFF34D399),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lancement immédiat • 3 Bots autonomes',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoadingAction)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: Color(0xFF34D399),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF34D399), Color(0xFF059669)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF059669).withOpacity(0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FilledButton.icon(
                          key: const ValueKey('home-launch-solo-button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: const Color(0xFF032219),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _handlePlaySolo,
                          icon: const Icon(
                            Icons.smart_toy_rounded,
                            size: 22,
                            color: Color(0xFF032219),
                          ),
                          label: const Text(
                            'Jouer contre l\'IA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: Color(0xFF032219),
                            ),
                          ),
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

  /// Carte 4 : "Jouer avec des amis" (Dégradé Violet/Magenta, groupe en filigrane, créer + rejoindre)
  Widget _buildFriendsCard() {
    return GameModeCard(
      colors: const [Color(0xFF4A044E), Color(0xFF350646), Color(0xFF180320)],
      accent: const Color(0xFFC084FC),
      glow: const Color(0xFFC084FC).withValues(alpha: .3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Filigrane groupe en bas à droite
            Positioned(
              right: -25,
              bottom: -25,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.1,
                  child: const Icon(
                    Icons.groups_rounded,
                    size: 180,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFC084FC).withOpacity(0.18),
                            border: Border.all(
                              color: const Color(0xFFC084FC).withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            color: Color(0xFFE879F9),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC084FC)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFC084FC)
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: const Text(
                                  'SALON PRIVÉ',
                                  style: TextStyle(
                                    color: Color(0xFFE879F9),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'JOUER AVEC DES AMIS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ACTION 1 : CRÉER UN SALON PRIVÉ
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFC084FC), Color(0xFF9333EA)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9333EA).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        key: const ValueKey('home-create-private-button'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _handleCreateGame(mode: 'private'),
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Créer un salon privé',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // SÉPARATEUR
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.white24, thickness: 1),
                        ),
                        Flexible(
                          flex: 4,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'OU REJOINDRE AVEC UN CODE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.white24, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // ACTION 2 : CODE ET BOUTON REJOINDRE
                    TextField(
                      key: const ValueKey('home-code-input'),
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 5,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE879F9),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFF1E072B),
                        hintText: '•••••',
                        hintStyle: const TextStyle(
                          color: Colors.white24,
                          fontSize: 20,
                          letterSpacing: 6,
                        ),
                        prefixIcon: const Icon(
                          Icons.vpn_key_outlined,
                          color: Color(0xFFE879F9),
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: const Color(0xFFC084FC).withOpacity(0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: const Color(0xFFC084FC).withOpacity(0.4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE879F9),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingAction)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            color: Color(0xFFE879F9),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF280738),
                          border: Border.all(
                            color: const Color(0xFFC084FC).withOpacity(0.7),
                            width: 1.3,
                          ),
                        ),
                        child: FilledButton.icon(
                          key: const ValueKey('home-join-button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: const Color(0xFFE879F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _handleJoinGame,
                          icon: const Icon(
                            Icons.login_rounded,
                            size: 20,
                            color: Color(0xFFE879F9),
                          ),
                          label: const Text(
                            'Valider et rejoindre',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: Color(0xFFE879F9),
                            ),
                          ),
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

  /// Barre de navigation inférieure stylisée Dark Mode avec 4 onglets.
  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1221),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        backgroundColor: const Color(0xFF0B1221),
        selectedItemColor: _currentTabIndex < 3 ? _gold : _cyanA,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.style_rounded,
              key: ValueKey('nav-tab-play'),
            ),
            activeIcon: const Icon(Icons.style_rounded, color: _gold),
            label: l10n.playTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.emoji_events_rounded,
              key: ValueKey('nav-tab-leaderboard'),
            ),
            activeIcon: const Icon(Icons.emoji_events_rounded, color: _gold),
            label: l10n.leaderboardTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.storefront_rounded,
              key: ValueKey('nav-tab-shop'),
            ),
            activeIcon: const Icon(Icons.storefront_rounded, color: _gold),
            label: l10n.shopTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.people_alt_rounded,
              key: ValueKey('nav-tab-friends'),
            ),
            activeIcon: const Icon(Icons.people_alt_rounded, color: _cyanA),
            label: l10n.friendsTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.person_rounded,
              key: ValueKey('nav-tab-profile'),
            ),
            activeIcon: const Icon(Icons.person_rounded, color: _cyanA),
            label: l10n.profileTitle,
          ),
        ],
      ),
    );
  }

  /// En-tête avec logo IsaMus (Stroke + ShaderMask) pour l'étape de connexion / inscription.
  Widget _buildLogoHeader() {
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'IsaMus',
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.5,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3
                    ..color = const Color(0xFFFFA000).withOpacity(0.4),
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withOpacity(0.5),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF9C4), Color(0xFFFFB300)],
                ).createShader(bounds),
                child: const Text(
                  'IsaMus',
                  style: TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF132238).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: const Text(
              'JEU DE CARTES BASQUE • MULTIJOUEUR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: _gold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Écran d'attente lors de l'authentification silencieuse.
  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_gold),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'CONNEXION EN COURS...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// Carte d'inscription affichée lorsqu'aucun profil n'existe encore.
  Widget _buildRegistrationCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardBg, Color(0xFF0D1726)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withOpacity(0.4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 25,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'CRÉEZ VOTRE PROFIL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            key: const ValueKey('home-pseudo-input'),
            controller: _pseudoController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0A1422),
              hintText: 'Votre pseudo (ex: Patxi, Amaia…)',
              hintStyle: const TextStyle(
                color: Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: const Icon(Icons.person_outline, color: _cyanA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _cyanA, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (_isLoadingAction)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(color: _gold),
              ),
            )
          else
            Container(
              height: 54,
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
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FilledButton.icon(
                key: const ValueKey('home-create-profile-button'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: const Color(0xFF261802),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _handleCreateProfile,
                icon: const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 22,
                  color: Color(0xFF261802),
                ),
                label: const Text(
                  'Créer mon profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF261802),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget générique pour les onglets en construction (Top 100, Amis, Profil).
