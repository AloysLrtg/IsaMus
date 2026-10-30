// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'IsaMus';

  @override
  String get you => 'Vous';

  @override
  String get partner => 'Partenaire';

  @override
  String team(String name) {
    return 'Équipe $name';
  }

  @override
  String rounds(int count) {
    return 'Manches : $count / 3';
  }

  @override
  String get startGame => 'Distribuer';

  @override
  String get nextHand => 'Donne suivante';

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get dealing => 'Distribution';

  @override
  String get discarding => 'Défausse';

  @override
  String get roundScoring => 'Décompte';

  @override
  String get gameOver => 'Partie terminée';

  @override
  String get yourTurn => 'À vous de parler';

  @override
  String waitingFor(String name) {
    return 'À $name de parler';
  }

  @override
  String discardCards(int count) {
    return 'Échanger $count carte(s)';
  }

  @override
  String get keepCards => 'Garder mes cartes';

  @override
  String currentBid(int amount) {
    return 'Mise : $amount Tantto';
  }

  @override
  String roundWinner(String team) {
    return '$team remporte la manche';
  }

  @override
  String gameWinner(String team) {
    return '$team remporte la partie';
  }

  @override
  String get actionFailed => 'Action impossible : la situation a changé.';

  @override
  String cardLabel(int value, String suit) {
    return '$value de $suit';
  }

  @override
  String get oros => 'Or';

  @override
  String get copas => 'Coupe';

  @override
  String get espadas => 'Épée';

  @override
  String get bastos => 'Bâton';

  @override
  String get hasPairs => 'Pariak dut';

  @override
  String get hasGame => 'Jokoa dut';

  @override
  String get hasNeither => 'Ez dut';

  @override
  String get sendSign => 'Faire un signe au partenaire';

  @override
  String get signTwoKings => '2 Rois';

  @override
  String get signTwoAces => '2 As';

  @override
  String get signGame => 'Jeu';

  @override
  String opponentShort(int number) {
    return 'Adv. $number';
  }

  @override
  String scoreTotal(int total, int hamarreko, int tantto) {
    return 'Score : $total pts ($hamarreko Hamarreko, $tantto Tantto)';
  }

  @override
  String get quickChat => 'Chat rapide';

  @override
  String get chatGoodLuck => 'Bonne chance';

  @override
  String get chatNothing => 'Je n’ai rien';

  @override
  String get chatWellPlayed => 'Bien joué !';

  @override
  String get turnTime => 'Temps pour jouer';

  @override
  String get raiseAmount => 'Relancer de…';

  @override
  String get openingAmount => 'Miser…';

  @override
  String get increase => 'Augmenter';

  @override
  String get decrease => 'Diminuer';

  @override
  String get validate => 'Valider';

  @override
  String bidTotal(int amount) {
    return 'Mise totale : $amount Tantto';
  }

  @override
  String get playTitle => 'Jouer';

  @override
  String get leaderboardTitle => 'Top 100';

  @override
  String get shopTitle => 'Boutique';

  @override
  String get friendsTitle => 'Amis';

  @override
  String get profileTitle => 'Profil';

  @override
  String get seasonPassTitle => 'Pass de Saison';

  @override
  String get tutorialTitle => 'Tutoriel';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get languageTitle => 'Langue';

  @override
  String get menuUnableToCompleteThisActionCheckYourConnectionAnd =>
      'Action impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get menuDocumentUnavailableTryAgain =>
      'Document indisponible. Réessayez.';

  @override
  String get menuSoundEffects => 'Effets sonores';

  @override
  String get menuPreferenceUnavailable => 'Préférence indisponible';

  @override
  String get menuTryAgain => 'Réessayer';

  @override
  String get menuAccountSecurity => 'Compte & sécurité';

  @override
  String get menuAdPrivacyChoices => 'Choix de confidentialité publicitaire';

  @override
  String get menuTermsOfUse => 'Conditions d’utilisation';

  @override
  String get menuPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get menuLastDay => 'Dernier jour';

  @override
  String menuOnlyArg0DLeft(String arg0) {
    return 'Plus que ${arg0}j';
  }

  @override
  String get menuSeasonInProgress => 'Saison en cours';

  @override
  String get menuPlayer => 'Joueur';

  @override
  String get menuUnableToCompleteThisActionTheRoomMayHave =>
      'Action impossible. Le salon a peut-être changé. Réessayez.';

  @override
  String menuCodeArg0CopiedToClipboard(String arg0) {
    return 'Code $arg0 copié dans le presse-papier !';
  }

  @override
  String get menuWAITINGROOM => 'SALON D’ATTENTE';

  @override
  String get menuSyncErrorTryAgain => 'Erreur de synchronisation. Réessayer';

  @override
  String get menuThisRoomIsReservedForPublicMatchmaking =>
      'Ce salon est réservé au matchmaking public.';

  @override
  String get menuINVITATIONCODE => 'CODE D’INVITATION';

  @override
  String get menuCopyCode => 'Copier le code';

  @override
  String get menuStartGame => 'Lancer la partie';

  @override
  String get menuFillWithAIPlayers => 'Compléter avec des IA';

  @override
  String get menuTwoPlayersPerTeamAreRequired =>
      'Deux joueurs par équipe sont requis.';

  @override
  String get menuWaitingForTheHost => 'En attente de l\'hôte...';

  @override
  String get menuTheRoomHasBeenClosed => 'Le salon a été fermé.';

  @override
  String menuTeamArg0Arg12(String arg0, String arg1) {
    return 'Équipe $arg0 · $arg1/2';
  }

  @override
  String get menuYourTeam => 'Votre équipe';

  @override
  String get menuJoin => 'Rejoindre';

  @override
  String get menuYOU => 'VOUS';

  @override
  String get menuOpenSeat => 'Place libre';

  @override
  String get menuWaiting => 'En attente…';

  @override
  String get menuHost => 'Hôte';

  @override
  String get menuAI => 'IA';

  @override
  String get menuInviteMyFriends => 'Inviter mes amis';

  @override
  String get menuAddFriendsFromTheFriendsTab =>
      'Ajoutez des amis depuis l’onglet Amis.';

  @override
  String get menuFriend => 'Ami';

  @override
  String menuInvitationSentToArg0(String arg0) {
    return 'Invitation envoyée à $arg0.';
  }

  @override
  String get menuUnableToSendTheInvitation =>
      'Impossible d’envoyer l’invitation.';

  @override
  String get menuInvite => 'Inviter';

  @override
  String get menuSignInToPlay => 'Connectez-vous pour jouer.';

  @override
  String get menuPleaseEnterYourNickname => 'Veuillez saisir votre pseudo.';

  @override
  String get menuSignInToCreateYourProfile =>
      'Connectez-vous pour créer votre profil.';

  @override
  String get menuTheCodeMustContainExactly5Characters =>
      'Le code doit comporter exactement 5 caractères.';

  @override
  String get menuIAlreadyHaveAnAccount => 'J’ai déjà un compte';

  @override
  String menuArg0Coins(String arg0) {
    return '$arg0 pièces';
  }

  @override
  String get menuWeeklyQuests => 'Quêtes hebdomadaires';

  @override
  String get menuGAMEMODES => 'MODES DE JEU';

  @override
  String get menuATYOUROWNPACE => 'À VOTRE RYTHME';

  @override
  String get menuTakeASeatAndLearnMusFromYourFirst =>
      'Prenez place à la table et apprenez le Mus, des premières décisions au décompte des points.';

  @override
  String get menuNoTimerGuidedThenFreePlay =>
      'Sans chronomètre · Guidé, puis libre';

  @override
  String get menuLearnMus => 'Apprendre le Mus';

  @override
  String get menuOfficialRules => 'Règles officielles';

  @override
  String get menuQUICKMULTIPLAYER => 'MULTIJOUEUR RAPIDE';

  @override
  String get menuONLINECASUAL => 'EN LIGNE (CLASSIQUE)';

  @override
  String get menuChallengePlayersOnlineInRelaxedFriendlyGamesWithNo =>
      'Défiez des joueurs en ligne dans des parties amicales et détendues, sans enjeu d\'Elo. Idéal pour partager un bon moment de Mus.';

  @override
  String get menuOfficial4KingsAnd4AcesRulesNoPressure =>
      'Règles officielles 4 Rois et 4 As • Sans pression';

  @override
  String get menuOFFICIALCOMPETITION => 'COMPÉTITION OFFICIELLE';

  @override
  String get menuONLINERANKED => 'EN LIGNE (CLASSÉ)';

  @override
  String menuYourCurrentEloArg0(String arg0) {
    return 'Votre Elo actuel : $arg0';
  }

  @override
  String get menuSeasonRewards => 'Récompenses de Saison';

  @override
  String get menuClimbTheCompetitiveRankingsEveryWinRaisesYourElo =>
      'Grimpez dans le classement compétitif. Chaque victoire augmente votre cote Elo, chaque défaite en coûte. Visez le Top 100 !';

  @override
  String get menuPlayRanked => 'Lancer (Classé)';

  @override
  String get menuSOLOPRACTICE => 'ENTRAÎNEMENT SOLO';

  @override
  String get menuSOLOVSAI => 'SOLO CONTRE IA';

  @override
  String get menuPlayAgainst3LocalAIPlayersWithoutWaitingFor =>
      'Affrontez 3 intelligences artificielles locales sans attendre d\'autres joueurs. Parfait pour réviser les règles, tactiques et signes basques.';

  @override
  String get menuInstantStart3IndependentBots =>
      'Lancement immédiat • 3 Bots autonomes';

  @override
  String get menuPlayAgainstAI => 'Jouer contre l\'IA';

  @override
  String get menuPRIVATEROOM => 'SALON PRIVÉ';

  @override
  String get menuPLAYWITHFRIENDS => 'JOUER AVEC DES AMIS';

  @override
  String get menuCreateAPrivateRoom => 'Créer un salon privé';

  @override
  String get menuORJOINWITHACODE => 'OU REJOINDRE AVEC UN CODE';

  @override
  String get menuConfirmAndJoin => 'Valider et rejoindre';

  @override
  String get menuBASQUECARDGAMEMULTIPLAYER =>
      'JEU DE CARTES BASQUE • MULTIJOUEUR';

  @override
  String get menuCONNECTING => 'CONNEXION EN COURS...';

  @override
  String get menuCREATEYOURPROFILE => 'CRÉEZ VOTRE PROFIL';

  @override
  String get menuYourNicknameEGPatxiAmaia => 'Votre pseudo (ex: Patxi, Amaia…)';

  @override
  String get menuCreateMyProfile => 'Créer mon profil';

  @override
  String get menuTop100Players => 'Top 100 des Joueurs';

  @override
  String get menuRefreshRankings => 'Actualiser le classement';

  @override
  String get menuLoadingRankings => 'Chargement du classement';

  @override
  String get menuUnableToLoadRankingsCheckYourConnectionAndTry =>
      'Impossible de charger le classement. Vérifiez votre connexion et réessayez.';

  @override
  String get menuNoRankedPlayersYet => 'Aucun joueur classé pour le moment.';

  @override
  String get menuTheHighestEloRatings => 'Les meilleurs scores Elo';

  @override
  String menuYourPositionArg0(String arg0) {
    return 'Votre position : #$arg0';
  }

  @override
  String get menuReachTheTop100ToAppearHere =>
      'Atteignez le Top 100 pour apparaître ici !';

  @override
  String get menuRankedByDescendingElo => 'Classement par Elo décroissant.';

  @override
  String menuPositionArg0Arg1Arg2EloArg3(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Position $arg0, $arg1, $arg2 Elo$arg3';
  }

  @override
  String menuLevelArg0Arg1500XP(String arg0, String arg1) {
    return 'Niveau $arg0 · $arg1 / 500 XP';
  }

  @override
  String menuLevelArg0Arg1XPOutOf500(String arg0, String arg1) {
    return 'Niveau $arg0, $arg1 XP sur 500';
  }

  @override
  String get menuYouHaveTwoKingsAndAGameTotalOf =>
      'Vous avez deux Rois et un Jeu de 31. Gardez cette main : dites Mintza.';

  @override
  String get menuYourOpponentRaisesCallIdukiToCompareCardsAt =>
      'L’adversaire relance. Suivez (Iduki) pour comparer les cartes au décompte.';

  @override
  String get menuYouHaveTwoKingsBaiAnnouncesYourPairBet =>
      'Vous avez deux Rois : votre paire est annoncée avec Bai. Misez 2 pierres !';

  @override
  String get menuYouHave31TheBestGameTotalBet2 =>
      'Vous avez 31, le meilleur Jeu. Misez 2 pierres pour ouvrir les enchères.';

  @override
  String get menuThisIsHighHandiaYouHaveStrongCardsBet =>
      'C’est le Grand (Handia). Vous avez des cartes fortes, misez !';

  @override
  String get menuAtLowYourAceIsFollowedByThreeFace =>
      'Au Petit, votre As est suivi de trois figures. Passez la parole avec Paso.';

  @override
  String get menuWatchTheOtherPlayersAnnouncementsAndResponses =>
      'Observez les annonces et les réponses des autres joueurs.';

  @override
  String get menuTheTutorialIsWaitingForMintza => 'Le tutoriel attend Mintza.';

  @override
  String get menuDiscardingIsNotAvailableAtThisStep =>
      'La défausse n’est pas disponible dans cette étape.';

  @override
  String get menuThisIsNotTheActionExpectedByTheTutorial =>
      'Action différente de celle attendue par le tutoriel.';

  @override
  String get menuTheOtherPlayersAreTakingTheirTurns =>
      'Les autres joueurs jouent…';

  @override
  String get menuIdukiCall => 'Iduki (Suivre)';

  @override
  String get menuRaise => 'Relancer';

  @override
  String get menuBet2 => 'Enchérir de 2';

  @override
  String get menuMusOrMintza => 'Mus ou Mintza ?';

  @override
  String get menuAtTheStartOfEachHandEachPlayerChooses =>
      'Au début de chaque donne, chacun choisit Mus pour demander un échange de cartes. Si les quatre joueurs disent Mus, chacun peut défausser puis recevoir de nouvelles cartes. Mintza coupe le Mus : on garde les mains et on commence les enchères. À vous de cliquer sur Mintza : seul le bouton attendu est actif et son contour brille.';

  @override
  String get menuBettingPasoAndEmbido => 'Miser : Paso et Embido';

  @override
  String get menuInEachPhaseYouCanBetStonesForYour =>
      'Chaque phase permet de miser des pierres pour son équipe. Paso passe la parole sans ouvrir de mise. Embido propose une mise ; Gehiago permet de relancer. Votre équipe peut bluffer sur ses mises, mais jamais envoyer un faux signe.';

  @override
  String get menuRespondingTiraAndIduki => 'Répondre : Tira et Iduki';

  @override
  String get menuWhenFacingABetIdukiAcceptsTheCardsWill =>
      'Face à une mise, Iduki accepte : les cartes départageront les équipes au décompte. Tira refuse : la phase s’arrête et l’adversaire marque le refus selon les mises précédentes. Une relance propose au contraire une mise plus forte.';

  @override
  String get menuHordagoTheWholeRound => 'Hordago : toute la manche';

  @override
  String get menuHordagoPutsTheEntireRoundAtStakeIfAccepted =>
      'Le Hordago met la manche entière en jeu. S’il est accepté avec Iduki, les mains sont comparées immédiatement pour cette phase et le gagnant remporte la manche. Tira refuse le défi et laisse seulement les points de refus. Vous allez miser 2 au Grand et aux Paires, puis suivre une relance au Jeu. Les autres choix restent grisés jusqu’à la partie libre.';

  @override
  String get menuYourTurnToCall => 'À vous de suivre';

  @override
  String get menuYourOpponentRaisesBy8TheBetGoesFrom =>
      'L’adversaire relance de 8 : la mise passe de 2 à 10 pierres. Cliquez sur Iduki pour accepter. Les cartes décideront du gagnant au décompte.';

  @override
  String get menuTheCardsAreRevealedBetsAndPointsForPairs =>
      'Les cartes sont révélées. On additionne les mises et les points de Paires et de Jeu. La première équipe à 40 pierres gagne la manche.';

  @override
  String get menuHighHandia => 'Grand — Handia';

  @override
  String get menuCompareCardsFromHighestToLowestTheKingIs =>
      'On compare les cartes de la plus haute à la plus basse. Le Roi est le plus fort. Cliquez sur Enchérir de 2 : vous proposez deux pierres. Un adversaire acceptera cette première mise.';

  @override
  String get menuLowTtipia => 'Petit — Ttipia';

  @override
  String get menuNowCompareTheLowestCardsTheAceIsBest =>
      'On compare cette fois les cartes les plus basses. L’As est le meilleur. En cas d’égalité, on compare les suivantes ; l’Esku départage une égalité parfaite.';

  @override
  String get menuPairsPareak => 'Paires — Pareak';

  @override
  String get menuTwoMatchingCardsMakeAPairThreeMakeMediak =>
      'Deux cartes identiques font une paire ; trois font Mediak ; deux paires ou quatre cartes identiques font Dobliak. Seuls les joueurs avec des paires participent. Vous avez deux Rois : l’annonce Bai confirme votre paire. Cliquez sur Enchérir de 2 pour la défendre.';

  @override
  String get menuGameJoko => 'Jeu — Joko';

  @override
  String get menuFaceCardsAreWorth10AndOtherCardsTheir =>
      'Les figures valent 10 et les autres cartes leur valeur. Il faut au moins 31. Le meilleur Jeu est 31, puis 32. Si personne n’a le Jeu, on joue le Point, au plus près de 30. Ici, proposez 2 : un adversaire relancera, et vous apprendrez à suivre avec Iduki.';

  @override
  String get menuYourTurnToPlay => 'À vous de jouer !';

  @override
  String get menuYouHaveLearnedYourWayAroundTheTable =>
      'Vous avez fait le tour de la table.';

  @override
  String get menuKeepPlayingAgainstTheBotsAllActionsAreAvailable =>
      'Poursuivez cette partie contre les bots : toutes les actions sont disponibles, sans chronomètre et sans conseils. Vous pouvez aussi revenir au menu.';

  @override
  String get menuReturnToMenu => 'Retourner au menu';

  @override
  String get menuFinishThisGameFreePlay =>
      'Terminer la partie en cours (Libre)';

  @override
  String get menuGotIt => 'J’ai compris';

  @override
  String get menuCheckYourEmailToActivateYourAccount =>
      'Consultez votre boîte e-mail pour activer votre compte.';

  @override
  String get menuAnAccountAlreadyUsesThisEmailAddress =>
      'Un compte utilise déjà cette adresse e-mail.';

  @override
  String get menuChooseAStrongerPassword =>
      'Choisissez un mot de passe plus fort.';

  @override
  String get menuTooManyAttemptsTryAgainShortly =>
      'Trop de tentatives. Réessayez dans quelques instants.';

  @override
  String get menuUnableToSignUpTryAnotherNicknameAndCheck =>
      'Inscription impossible. Essayez un autre pseudo et vérifiez vos informations.';

  @override
  String get menuServiceUnavailableCheckYourConnectionAndTryAgain =>
      'Service indisponible. Vérifiez votre connexion et réessayez.';

  @override
  String get menuSignUp => 'Inscription';

  @override
  String get menuJoinIsaMus => 'Rejoignez IsaMus';

  @override
  String get menuChooseYourNicknameAndJoinTheGame =>
      'Choisissez votre pseudo et entrez dans la partie.';

  @override
  String get menuNickname => 'Pseudo';

  @override
  String get menuChooseANickname => 'Choisissez un pseudo.';

  @override
  String get menu24CharactersMaximum => '24 caractères maximum.';

  @override
  String get menuEmail => 'E-mail';

  @override
  String get menuEnterAValidEmailAddress =>
      'Saisissez une adresse e-mail valide.';

  @override
  String get menuPassword => 'Mot de passe';

  @override
  String get menuAtLeast8Characters => '8 caractères minimum';

  @override
  String get menuShowPassword => 'Afficher le mot de passe';

  @override
  String get menuHidePassword => 'Masquer le mot de passe';

  @override
  String get menuUseAtLeast8Characters => 'Utilisez au moins 8 caractères.';

  @override
  String get menuCreateMyAccount => 'Créer mon compte';

  @override
  String get menuAlreadyHaveAnAccountSignIn => 'Déjà un compte ? Se connecter';

  @override
  String get menuIncorrectEmailOrPassword =>
      'E-mail ou mot de passe incorrect.';

  @override
  String get menuConfirmYourEmailAddressBeforeSigningIn =>
      'Confirmez votre adresse e-mail avant de vous connecter.';

  @override
  String get menuUnableToSignInCheckYourDetailsAndTry =>
      'Connexion impossible. Vérifiez vos informations et réessayez.';

  @override
  String get menuYourTableIsWaiting => 'Votre table vous attend.';

  @override
  String get menuEnterYourPassword => 'Saisissez votre mot de passe.';

  @override
  String get menuSignIn => 'Se connecter';

  @override
  String get menuPlayAsAGuest => 'Jouer en tant qu’invité';

  @override
  String get menuNoAccountYetSignUp => 'Pas encore de compte ? S\'inscrire';

  @override
  String get menuQuestsUnavailable => 'Quêtes indisponibles';

  @override
  String get menuClose => 'Fermer';

  @override
  String get menuANewWeekNewChallenges =>
      'Une nouvelle semaine, de nouveaux défis.';

  @override
  String get menuResetsOnMondayAt0000UTCXPRewards =>
      'Réinitialisation le lundi à 00 h UTC. Les récompenses XP sont attribuées automatiquement.';

  @override
  String get menuNewChallengesComingSoon =>
      'De nouveaux défis arrivent bientôt.';

  @override
  String menuArg0XPRewardReceived(String arg0) {
    return '+$arg0 XP · Récompense reçue';
  }

  @override
  String get menuRewardReceived => 'Récompense reçue';

  @override
  String menuArg0XP(String arg0) {
    return '+$arg0 XP';
  }

  @override
  String get menuXPRewardUnavailable => 'Récompense XP indisponible';

  @override
  String menuTierArg0Arg1(String arg0, String arg1) {
    return 'Palier $arg0, $arg1';
  }

  @override
  String get menuNextGoal => 'prochain objectif';

  @override
  String get menuLocked => 'verrouillé';

  @override
  String get menuVIP => 'VIP';

  @override
  String get menuFree => 'Gratuite';

  @override
  String get menuNoReward => 'Aucune récompense';

  @override
  String get menuEarned => 'Acquis';

  @override
  String get menuNextGoal189 => 'Prochain objectif';

  @override
  String menuLevelArg0(String arg0) {
    return 'Niveau $arg0';
  }

  @override
  String get menuVIPRequired => 'VIP requis';

  @override
  String get menuSeasonEnded => 'Saison terminée';

  @override
  String get menuPleaseWait => 'Patientez…';

  @override
  String get menuClaim => 'Récupérer';

  @override
  String menuArg0Coins195(String arg0) {
    return ', $arg0 pièces';
  }

  @override
  String get menuPreviewOnlyCosmeticNotYetDefinedOrAvailable =>
      'Aperçu uniquement : cosmétique à définir, non distribué actuellement.';

  @override
  String get menuUpcomingCosmetic => 'Cosmétique à venir';

  @override
  String get menuGoldCardBack => 'Dos Or';

  @override
  String get menuRubyTableFelt => 'Tapis Rubis';

  @override
  String get menuActionUnavailableTryAgainShortly =>
      'Action indisponible. Réessayez dans quelques instants.';

  @override
  String get menuPassUnavailable => 'Pass indisponible.';

  @override
  String get menuNoActiveSeason => 'Aucune saison en cours';

  @override
  String get menuDemoCalendar => 'Calendrier de démonstration';

  @override
  String menuArg0Arg1TiersUnlocked(String arg0, String arg1) {
    return '$arg0 / $arg1 paliers débloqués';
  }

  @override
  String get menuAllTiersUnlocked => 'Tous les paliers sont débloqués !';

  @override
  String menuNextGoalTierArg0(String arg0) {
    return 'Prochain objectif : palier $arg0';
  }

  @override
  String menuArg0XPLeftToReachIt(String arg0) {
    return 'Encore $arg0 XP pour l’atteindre.';
  }

  @override
  String get menuTapAnUnlockedRewardToClaimItAFree =>
      'Touchez une récompense débloquée pour la récupérer. Une récompense gratuite tous les 5 paliers ; une récompense VIP à chaque palier.';

  @override
  String get menuRewardPath => 'Route des récompenses';

  @override
  String get menuReached => 'Atteint';

  @override
  String get menuGoal => 'Objectif';

  @override
  String get menuComingUp => 'À venir';

  @override
  String get menuRewardAlreadyReceived => 'Récompense déjà reçue';

  @override
  String menuArg0CoinsReceivedArg1(String arg0, String arg1) {
    return '$arg0 pièces reçues$arg1';
  }

  @override
  String get menuCosmeticUnlocked => ' · Cosmétique débloqué';

  @override
  String get menuPREMIUM => 'PREMIUM';

  @override
  String get menuYourVIPPassIsActive => 'Votre Pass VIP est actif';

  @override
  String get menuUnlockTheVIPPass => 'Débloquez le Pass VIP';

  @override
  String get menuNoAds => 'Sans publicités';

  @override
  String get menuVIPPassTrack => 'Voie VIP du Pass';

  @override
  String get menuXP2 => 'XP ×2';

  @override
  String get menuCoinsCanOnlyBeEarnedThroughTheSeasonPass =>
      'Les pièces se gagnent uniquement dans le Pass de Saison. XP ×2 sur les parties et les quêtes.';

  @override
  String get menuVIPIsTemporarilyUnavailable =>
      'Le VIP est momentanément indisponible.';

  @override
  String get menuVIPActive => 'VIP actif';

  @override
  String get menuVIPComingSoon => 'VIP bientôt disponible';

  @override
  String menuBecomeVIPArg0Month(String arg0) {
    return 'Devenir VIP · $arg0/mois';
  }

  @override
  String get menuMonthlySubscriptionWithAutomaticRenewalCancelThroughYourApp =>
      'Abonnement mensuel renouvelé automatiquement. Annulable depuis votre store.';

  @override
  String get menuRestorePurchases => 'Restaurer mes achats';

  @override
  String get menuNotEnoughCoinsForThisItem =>
      'Fonds insuffisants pour cet article.';

  @override
  String get menuThisItemIsAlreadyInYourInventory =>
      'Cet article est déjà dans votre inventaire.';

  @override
  String get menuThePriceHasChangedTheShopHasBeenRefreshed =>
      'Le prix a changé. La boutique a été actualisée.';

  @override
  String get menuThisItemIsNoLongerAvailable =>
      'Cet article n’est plus disponible.';

  @override
  String get menuPurchaseFailedTryAgainShortly =>
      'Achat impossible. Réessayez dans quelques instants.';

  @override
  String menuArg0AddedToYourInventory(String arg0) {
    return '$arg0 ajouté à votre inventaire';
  }

  @override
  String get menuOutfits => 'Tenues';

  @override
  String get menuCardBacks => 'Dos de cartes';

  @override
  String get menuHeadwear => 'Couvre-chefs';

  @override
  String get menuGlasses => 'Lunettes';

  @override
  String get menuHair => 'Cheveux';

  @override
  String get menuQuickChats => 'Quick Chats';

  @override
  String get menuShopUnavailable => 'Boutique indisponible.';

  @override
  String get menuNewItemsComingSoon => 'De nouveaux articles arrivent bientôt.';

  @override
  String get menuOwned => 'Possédé';

  @override
  String menuBuyArg0Arg1Coins(String arg0, String arg1) {
    return 'Acheter $arg0, $arg1 pièces';
  }

  @override
  String get menuBuying => 'Achat…';

  @override
  String get menuBuy => 'Acheter';

  @override
  String get menuUnableToCompleteThisActionCheckYourConnectionOr =>
      'Action impossible. Vérifiez votre connexion ou réessayez.';

  @override
  String get menuYourFriend => 'votre ami';

  @override
  String menuInvitationSentArg0(String arg0) {
    return 'Invitation envoyée : $arg0';
  }

  @override
  String get menuInAGame => 'Dans une partie';

  @override
  String get menuOnline => 'En ligne';

  @override
  String get menuOffline => 'Hors ligne';

  @override
  String get menuInviteToPlay => 'Inviter à jouer';

  @override
  String get menuFriendOptions => 'Options de l’ami';

  @override
  String get menuRemoveFriend => 'Retirer de mes amis';

  @override
  String get menuFriendsPrivateRooms => 'Amis & Salons Privés';

  @override
  String get menuRequests => 'Demandes';

  @override
  String get menuBlocked => 'Bloqués';

  @override
  String get menuSearchForANickname => 'Rechercher un pseudo';

  @override
  String get menuSearch => 'Rechercher';

  @override
  String get menuNoResultsEnterAtLeast2Characters =>
      'Aucun résultat. Saisissez au moins 2 caractères.';

  @override
  String get menuSendFriendRequest => 'Demander en ami';

  @override
  String get menuFriendRequestSent => 'Demande d’amitié envoyée';

  @override
  String get menuUnableToLoadFriendsTryAgain =>
      'Impossible de charger les amis. Réessayer';

  @override
  String get menuYourListIsEmptySearchForAPlayerTo =>
      'Votre liste est vide. Recherchez un joueur pour lui envoyer une demande.';

  @override
  String get menuUnableToLoadRequestsTryAgain =>
      'Impossible de charger les demandes. Réessayer';

  @override
  String get menuNoPendingRequests => 'Aucune demande en attente.';

  @override
  String get menuReceived => 'Reçues';

  @override
  String get menuSent => 'Envoyées';

  @override
  String get menuRequestReceived => 'Demande reçue';

  @override
  String get menuRequestSent => 'Demande envoyée';

  @override
  String get menuAccept => 'Accepter';

  @override
  String get menuDecline => 'Refuser';

  @override
  String get menuCancel => 'Annuler';

  @override
  String get menuUnableToLoadBlockedPlayersTryAgain =>
      'Impossible de charger les blocages. Réessayer';

  @override
  String get menuNoBlockedPlayers => 'Aucun joueur bloqué.';

  @override
  String get menuBlockedPlayer => 'Joueur bloqué';

  @override
  String get menuPlayerUnblocked => 'Joueur débloqué';

  @override
  String get menuUnblock => 'Débloquer';

  @override
  String menuInviteArg0(String arg0) {
    return 'Inviter $arg0';
  }

  @override
  String get menuChooseHowToPlayTogether =>
      'Choisissez comment jouer ensemble.';

  @override
  String get menuSameTeamAgainstTwoOtherPlayers =>
      'Même équipe, face à deux autres joueurs';

  @override
  String get menuRoomWithACodeAndTeamSelection =>
      'Salon avec code et choix des équipes';

  @override
  String get menuLeaveYourCurrentGame => 'Quittez la partie en cours';

  @override
  String get menuNavigationUnavailable => 'Navigation indisponible';

  @override
  String get menuInvitationUnavailableLeaveYourCurrentGameOrTryAgain =>
      'Invitation indisponible. Quittez votre partie actuelle ou réessayez.';

  @override
  String get menuAFriend => 'Un ami';

  @override
  String menuArg0InvitesYouToPlayArg1(String arg0, String arg1) {
    return '$arg0 vous invite à jouer en $arg1';
  }

  @override
  String get menuYouWillPlayOnTheSameTeam =>
      'Vous jouerez dans la même équipe.';

  @override
  String get menuChooseYourTeamsInTheRoom =>
      'Choisissez vos équipes dans le salon.';

  @override
  String get menuDecline296 => 'Décliner';

  @override
  String get menuNewFriendRequestReceived => 'Nouvelle demande d’amitié reçue';

  @override
  String menuArg0NewFriendRequests(String arg0) {
    return '$arg0 nouvelles demandes d’amitié';
  }

  @override
  String get menuCloseNotification => 'Fermer la notification';

  @override
  String get menuOverallStatistics => 'Statistiques globales';

  @override
  String get menuCurrentElo => 'Elo actuel';

  @override
  String get menuPeakElo => 'Peak Elo';

  @override
  String get menuNoCompletedGames => 'Aucune partie terminée';

  @override
  String menuArg0Wins(String arg0) {
    return '$arg0 % de victoires';
  }

  @override
  String get menuDetailsByMode => 'Détails par mode';

  @override
  String menuArg0WinsArg1LossesInArg2Games(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return '$arg0 victoires, $arg1 défaites sur $arg2 parties';
  }

  @override
  String get menuNoGames => 'Aucune partie';

  @override
  String get menuWins => 'de victoires';

  @override
  String get menuWins309 => 'Victoires';

  @override
  String get menuLosses => 'Défaites';

  @override
  String get menuCasual => 'Classique';

  @override
  String get menuRanked => 'Classé';

  @override
  String get menuSolo => 'Solo';

  @override
  String get menuPrivateRoomsWithHumanPlayersAreIncludedInCasual =>
      'Les salons privés entre humains sont inclus dans Classique.';

  @override
  String menuArg0OlderGamesWithoutDetailedHistoryAreNotAssigned(String arg0) {
    return '$arg0 anciennes parties sans historique détaillé ne sont pas réparties par mode.';
  }

  @override
  String get menuUnableToSendTheRequestTryAgain =>
      'Impossible d’envoyer la demande. Réessayez.';

  @override
  String get menuBlockThisPlayer => 'Bloquer ce joueur ?';

  @override
  String get menuYourFriendshipWillBeRemovedAndPendingRequestsAnd =>
      'Votre amitié sera supprimée et vos demandes et invitations en attente seront annulées. Ce joueur ne pourra plus vous contacter ainsi. Vous pourrez le débloquer depuis l’onglet Bloqués.';

  @override
  String get menuBlock => 'Bloquer';

  @override
  String get menuUnableToUpdateTheBlockTryAgain =>
      'Impossible de modifier le blocage. Réessayez.';

  @override
  String get menuProfileUnavailable => 'Profil indisponible.';

  @override
  String get menuPlayerProfile => 'Profil du joueur';

  @override
  String get menuWinRate => 'Taux de victoire';

  @override
  String get menuGamesPlayed => 'Parties jouées';

  @override
  String menuArg0WinsArg1Losses(String arg0, String arg1) {
    return '$arg0 victoires · $arg1 défaites';
  }

  @override
  String get menuAddFriend => 'Ajouter en ami';

  @override
  String get menuSignInRequired => 'Connexion requise';

  @override
  String get menuYourProfile => 'Votre profil';

  @override
  String get menuSending => 'Envoi en cours…';

  @override
  String get menuCheckingFriendship => 'Vérification de la relation…';

  @override
  String get menuAlreadyFriends => 'Déjà amis';

  @override
  String get menuCheckFriendshipAgain => 'Réessayer la relation';

  @override
  String get menuServiceUnavailableTryAgainShortly =>
      'Service indisponible. Réessayez dans quelques instants.';

  @override
  String get menuDeleteYourAccount => 'Supprimer votre compte ?';

  @override
  String get menuYourProfileFriendsAndHistoryWillBePermanentlyDeleted =>
      'Votre profil, vos amis et votre historique seront supprimés définitivement. Les achats restent soumis aux règles des stores. Cette action est irréversible.';

  @override
  String get menuDeletePermanently => 'Supprimer définitivement';

  @override
  String get menuAccountDeleted => 'Compte supprimé.';

  @override
  String get menuGuestAccount => 'Compte invité';

  @override
  String get menuSignedInAccount => 'Compte connecté';

  @override
  String get menuGuest => 'Invité';

  @override
  String get menuSignedOut => 'Déconnexion effectuée.';

  @override
  String get menuSignOut => 'Se déconnecter';

  @override
  String get menuDeleteMyAccount => 'Supprimer mon compte';

  @override
  String menuArg0Arg1XP(String arg0, String arg1) {
    return '$arg0 / $arg1 XP';
  }

  @override
  String menuLevelArg0ProgressArg1XPOutOf500(String arg0, String arg1) {
    return 'Progression du niveau $arg0, $arg1 XP sur 500';
  }

  @override
  String menuArg0XPToGoBeforeLevelArg1(String arg0, String arg1) {
    return 'Encore $arg0 XP avant le niveau $arg1';
  }

  @override
  String get menuChangeNickname => 'Modifier le pseudo';

  @override
  String get menuSave => 'Enregistrer';

  @override
  String get menuProfileUnavailableTryAgain => 'Profil indisponible. Réessayer';

  @override
  String get menuPlayerProfile352 => 'Profil Joueur';

  @override
  String get menuEditMyAvatar => 'Modifier mon Avatar';

  @override
  String get menuCustomisation => 'Personnalisation';

  @override
  String get menuRecentGames => 'Dernières parties';

  @override
  String get menuReloadHistory => 'Recharger l’historique';

  @override
  String get menuYourNextCompletedGamesWillAppearHere =>
      'Vos prochaines parties terminées apparaîtront ici.';

  @override
  String get menuWin => 'Victoire';

  @override
  String get menuLoss => 'Défaite';

  @override
  String get menuPrivate => 'Privé';

  @override
  String get menuEquipmentSavedTryLoadingTheInventoryAgain =>
      'Équipement enregistré. Réessayez le chargement de l’inventaire.';

  @override
  String get menuUnableToEquipCheckYourConnectionAndTryAgain =>
      'Équipement impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get menuInventoryUnavailable => 'Inventaire indisponible.';

  @override
  String get menuTheOriginalBlueCardBackAlwaysAvailable =>
      'Le dos bleu d’origine, toujours disponible.';

  @override
  String get menuEquipped => 'Équipé';

  @override
  String menuArg0Equipped(String arg0) {
    return '$arg0 équipé';
  }

  @override
  String get menuEquip => 'Équiper';

  @override
  String menuSeasonArg0Arg1(String arg0, String arg1) {
    return 'Saison $arg0/$arg1';
  }

  @override
  String get menuSeasonEnds => 'Fin de saison';

  @override
  String get menuDays => 'Jours';

  @override
  String get menuHours => 'Heures';

  @override
  String get menuMinutes => 'Minutes';

  @override
  String get menuSeconds => 'Secondes';

  @override
  String menuSeasonEndsInArg0DaysArg1HoursArg2Minutes(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Fin de saison dans $arg0 jours, $arg1 heures, $arg2 minutes et $arg3 secondes';
  }

  @override
  String get menuYourSeasonsBestEloDeterminesYourRewardsTiersAre =>
      'Votre meilleur Elo de la saison détermine vos récompenses. Les paliers sont cumulatifs.';

  @override
  String get menuBronzeBorder => 'Bordure Bronze';

  @override
  String get menuSilverBorder => 'Bordure Argent';

  @override
  String get menuGoldBorder => 'Bordure Or';

  @override
  String get menuTxapelaBeret => 'Txapela (béret)';

  @override
  String get menuAtTheMonthlyCloseEloAndPeakEloReset =>
      'À la clôture mensuelle, l’Elo et le Peak Elo reviennent à 800. Vos cosmétiques restent acquis : équipez-les dans Modifier mon Avatar → Bordures / Trophées.';

  @override
  String get menuSkin => 'Peau';

  @override
  String get menuTop => 'Haut';

  @override
  String get menuBackgroundColour => 'Couleur de fond';

  @override
  String get menuHairColour => 'Couleur cheveux';

  @override
  String get menuBorders => 'Bordures';

  @override
  String get menuNone => 'Aucune';

  @override
  String get menuBronze => 'Bronze';

  @override
  String get menuSilver => 'Argent';

  @override
  String get menuDiamond => 'Diamant';

  @override
  String get menuNone391 => 'Aucun';

  @override
  String get menuTxapela => 'Txapela';

  @override
  String get menuCrown => 'Couronne';

  @override
  String get menuCap => 'Casquette';

  @override
  String get menuBeanie => 'Bonnet';

  @override
  String get menuBald => 'Chauve';

  @override
  String get menuMohawk => 'Crête';

  @override
  String get menuGoldFrames => 'Monture dorée';

  @override
  String get menuRound => 'Rondes';

  @override
  String get menuStripedShirt => 'Maillot rayé';

  @override
  String get menuUnableToSaveCheckYourConnectionAndTryAgain =>
      'Sauvegarde impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get menuSaving => 'Sauvegarde…';

  @override
  String get menuSave403 => 'Sauvegarder';

  @override
  String menuAvatarSkinArg0HairArg1GlassesArg2TopArg3(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Avatar : peau $arg0, cheveux $arg1, lunettes $arg2, haut $arg3';
  }

  @override
  String get menuBrightRed => 'Rouge vif';

  @override
  String get menuOrange => 'Orange';

  @override
  String get menuSunshineYellow => 'Jaune soleil';

  @override
  String get menuAppleGreen => 'Vert pomme';

  @override
  String get menuPineGreen => 'Vert sapin';

  @override
  String get menuCyan => 'Cyan';

  @override
  String get menuNavyBlue => 'Bleu marine';

  @override
  String get menuDeepPurple => 'Violet profond';

  @override
  String get menuFuchsiaPink => 'Rose fuchsia';

  @override
  String get menuBrown => 'Marron';

  @override
  String get menuLightGrey => 'Gris clair';

  @override
  String get menuCharcoal => 'Anthracite';

  @override
  String get menuBrunette => 'Brun';

  @override
  String get menuBlonde => 'Blond';

  @override
  String get menuBlack => 'Noir';

  @override
  String get menuCopper => 'Cuivré';

  @override
  String get menuPurple => 'Violet';

  @override
  String get menuFrenchMusChampionshipRegulations =>
      'Règlement du Championnat de France de Mus';

  @override
  String get menuFederationFrancaiseDeMus => 'Fédération Française de Mus';

  @override
  String get menuLastRevisedJanuary2023 =>
      'Dernières modifications : janvier 2023.';

  @override
  String get menuPrinciplesAndRankings => 'Principes et classement';

  @override
  String get menuMusIsPlayedInTeamsOf2WithA =>
      'Le Mus se joue par équipes de 2 joueurs, avec un jeu espagnol de 40 cartes, en 3 manches de 40 Points (40 tantto ou 8 hamarreko), sauf exception.';

  @override
  String get menuRankingsAreCalculatedAsFollows3RoundsWon1 =>
      'Le classement s\'opère comme suit: 3 manches gagnées = 1 victoire.';

  @override
  String get menuAWinnerOneWinIsCountedRegardlessOfRounds =>
      'a) Vainqueur : on compte une victoire, sans tenir compte des manches perdues ni des points réalisés au cours de ces manches.';

  @override
  String get menuBLoser0WinsAreCountedAlongWithRounds =>
      'b) Perdant : on compte 0 victoire, le nombre de manches gagnées et les points réalisés au cours des manches perdues seulement.';

  @override
  String get menuForTheFirstDealThePlayerWhoDrewThe =>
      'Pour la première distribution, le joueur ayant tiré la plus petite carte donne. Il doit mélanger les cartes et les faire couper par son adversaire de gauche qui devra laisser plus d\'une carte en haut ou en bas de sa coupe. Le donneur distribue les cartes une à une, par le dessus, en commençant par son adversaire de droite qui aura la main (Esku), à charge à chaque joueur de vérifier le nombre de cartes qu\'il reçoit. Les joueurs peuvent regarder les cartes avant la fin de la donne.';

  @override
  String get menuIfACardIsTurnedOverDuringTheFirst =>
      'Si au cours de la première distribution une carte est retournée ou si l\'on constate toute autre anomalie (plus ou moins de 4 cartes, etc...), on ramasse tout, on bat, on coupe et on recommence.';

  @override
  String get menuIfTheErrorIsFoundAfterPlayHasBegun =>
      'Si l\'erreur est décelée lorsque le jeu est commencé, c\'est-à-dire après qu\'un joueur soit sorti, le joueur qui a plus ou moins de quatre cartes n\'entrera pas dans le jeu et on annulera les points tirés par son équipe.';

  @override
  String get menuIfACardIsTurnedOverAfterMusHas =>
      'Si après avoir été Mus une fois, une carte est retournée, le jeu continue normalement.';

  @override
  String get menuEskuAndTheirPartnerDecideWhetherToStopWith =>
      'Le « Esku » et son partenaire décident s\'ils sortent « Mintza » ou s\'ils vont « Mus » en disant « Zuetan ou A vous». A leur tour, leurs adversaires en feront autant.';

  @override
  String get menuIfThereIsMusAll4PlayersDiscardThe =>
      'S’il y a Mus les 4 joueurs se débarrasseront du nombre de cartes désiré, d\'un seul coup, et le «ESKU», en premier. Le donneur distribuera alors les nouvelles cartes en une seule fois, à chaque joueur.';

  @override
  String get menuPlayBeginsWithESKUFirstHighThenLowPairs =>
      'Pour démarrer le jeu, et toujours le « ESKU » en premier, on joue d\' abord le Grand, puis le Petit, les Paires, le Jeu ou le Point. Les enchères « Biak Embido » ou « Biak Hordago » étant tolérées.';

  @override
  String get menuTiraIdukiAndHordagoBindTheTeamTheSpeakers =>
      'Les mots Tira, Iduki ou Hordago bloquent le jeu et le partenaire de celui qui les prononce ne peut les désavouer, même s\'il est « Esku ». On admet aussi bien « Nere gatik tira » que « Tira nere gatik » ou « Pour moi tirez » qui laisse au partenaire le droit de surenchérir. Quand les 2 partenaires tapent ou surenchérissent, la décision de celui qui parle en premier est retenue. Après un « Hordago Kanta » aucun point (tantto) ne sera tiré.';

  @override
  String get menuSigns => 'Signes';

  @override
  String get menuOnlyTheFollowingOfficialSignsAreAllowed =>
      'Seuls les signes réglementaires suivants sont admis :';

  @override
  String get menu2KingsLowerLip => '2 rois : lèvre inférieure.';

  @override
  String get menu2AcesStickOutTheTongue => '2 as : tirer la langue.';

  @override
  String get menuMediakMoveOneSideOfTheLips =>
      'Mediak : remuer un côté des lèvres.';

  @override
  String get menuDobliakMoveBothSidesOfTheLips =>
      'Dobliak : remuer les 2 côtés des lèvres.';

  @override
  String get menu29SameAsMediak => '29 : comme les mediak.';

  @override
  String get menu30Or31Wink => '30 ou 31 : cligner d’un œil.';

  @override
  String get menuGameRaiseTheEyebrows => 'Le jeu : lever les sourcils.';

  @override
  String get menuTheSignFor30Or31MayBeMade =>
      'Le signe du 30 ou du 31 peut se faire à tout moment. Le 29 par contre ne peut être passé qu’après en avoir terminé avec les paires. Le signe du jeu est interdit si on a 31.';

  @override
  String get menuDoublePairs => 'Doubles';

  @override
  String get menuWhen2OpponentsHaveDoublePairsWithTheSame =>
      'Lorsque 2 adversaires ont des doubles avec paire supérieure égale, celui qui a la paire inférieure la plus forte l\'emporte dans tous les cas. Exemple : 2 onze + 2 sept même en dernière main sont supérieurs à 2 onze + 2 six';

  @override
  String get menuErrors => 'Erreurs';

  @override
  String get menuAnnouncingPairsWithoutHavingAny =>
      'Annoncer des paires si on n\'en a pas :';

  @override
  String get menuAIfThePartnerHasNoneAllBetsOn =>
      'a) Si le partenaire n\'en a pas, on annule tout pari fait sur les paires. Bien entendu, l\'adversaire compte les points de sa ou de ses paires.';

  @override
  String get menuBIfThePartnerHasPairsAndTheOpponents =>
      'b) Si le partenaire en a, et les adversaires aussi, tout pari aux paires sera annulé, l\'adversaire comptant le « TIRA» des paires et les points de sa ou de ses paires.';

  @override
  String get menuFailingToAnnouncePairsWhenHoldingThem =>
      'Ne pas annoncer de paires si on en a :';

  @override
  String get menuUnannouncedPairsCannotBeUsedToBetCallOr =>
      'Ces paires niées ne valent ni pour taper, ni pour tenir, ni pour les compter ensuite.';

  @override
  String get menuIfThePartnerHasNoPairsAnOpponentWith =>
      'Si le partenaire n\'a pas de paires, l\'adversaire, s\'il a aussi des paires, tirera un point du «Tira».';

  @override
  String get menuAnnouncingGameWithoutHavingIt =>
      'Annoncer le jeu si on ne l\'a pas :';

  @override
  String get menuAIfNoneOfTheOther3PlayersHas =>
      'a) Si aucun des 3 autres joueurs n\'a le jeu, les adversaires tireront le « Tira» du point, et le point du « Pontua ».';

  @override
  String get menuBIfThePartnerHasGameAndTheOpponents =>
      'b) Si le partenaire a le jeu et les adversaires pas, on ne tient pas compte de l\'erreur.';

  @override
  String get menuCIfThePartnerHasNoGameButAn =>
      'c) Si le partenaire n\'a pas le jeu et l\'adversaire oui, on annule les paris fait, au jeu, et l\'adversaire tirera les points correspondants à son jeu.';

  @override
  String get menuDIfThePartnerAndAnOpponentBothHave =>
      'd) Si son partenaire a le jeu et l\'un des adversaires aussi, on annule les paris faits au jeu et l\'adversaire tirera le « TIRA» du jeu et les points correspondants à son jeu.';

  @override
  String get menuFailingToAnnounceGameWhenHoldingIt =>
      'Ne pas annoncer le jeu si on l\'a :';

  @override
  String get menuAIfNoneOfTheOther3PlayersHas465 =>
      'a) Si aucun des 3 autres joueurs n\'a le jeu, on annulera les paris faits au point, et l\'adversaire tirera le ttantto du Tira et le point du Pontua. Le jeu non annoncé ne comptera pas.';

  @override
  String get menuBIfThePartnerHasGameAndTheOpponents466 =>
      'b) Si le partenaire a le jeu et les adversaires pas, seul le jeu du partenaire sera compté.';

  @override
  String get menuCIfThePartnerHasNoGameAndAn =>
      'c) Si le partenaire n\'a pas le jeu et l\'adversaire oui, ce dernier comptera le « TIRA» du jeu et les points du jeu qui lui reviennent. Le joueur qui n\'a pas de paires ou de jeu ne peut pas taper ni surenchérir à la place de son partenaire qui en a.';

  @override
  String get menuScoringAndRaises => 'Décompte et relances';

  @override
  String get menuDuringPlayPointsConcededThroughTIRAAreScoredAs =>
      'En cours de jeu, les points laissés « TIRA » se tirent au fur et à mesure. En cas d\'égalité parfaite, le «ESKU» l\'emporte dans tous les cas de figure. A la fin de chaque tour de jeu, les quatre joueurs doivent étaler toutes leurs cartes sur la table.';

  @override
  String get menuScoreHighThenLowPairsGameOrPointAs =>
      'On compte alors le Grand, puis le Petit, les Paires, le Jeu ou le Point sur les bases suivantes:';

  @override
  String get menuHighIfEveryoneSaidPASOTheBestHighScores =>
      'Grand : S\'il n\'y a eu que PASO, celui qui a le meilleur Grand compte 1 point (Haundi Pasa) Si le Grand a été laissé après un Embido, on ne tire rien. S\'il y a eu Iduki, on compte les points pariés, rien de plus.';

  @override
  String get menuLowTheSameAsHigh => 'Petit : idem que pour le Grand.';

  @override
  String get menuPairsAfterPasoTheTeamWithTheBestPair =>
      'Paires : S\'il y a eu Paso, l\'équipe ayant la meilleure paire comptera sa ou ses paires, en tirant 1 point (paires) 2 points (mediak) ou 3 points (doubles). S\'il y a eu Iduki, on comptera en plus les points pariés.';

  @override
  String get menuGameTheSameAsPairsCounting2PointsFor =>
      'Le Jeu : idem que pour les paires, en comptant 2 points (jeu) ou 3 (pour le 31) pour le ou les jeux de l\'équipe gagnant le jeu.';

  @override
  String get menuPointPontuaAfterPasoTheBestPontuaScores1 =>
      'Le Point : (Pontua) S\'il y a eu Paso, celui qui a le meilleur Pontua tirera 1 point. S\'il y a eu Tira, l\'équipe ayant gagné le Tira comptera 1 point du Pontua. S\'il y a eu Iduki, on compte les point pariés plus 1 point du Pontua.';

  @override
  String get menuRaiseExamples => 'Relances (exemples) :';

  @override
  String get menuEmbido2PointsTira1Point =>
      'Embido (2 points) - Tira = 1 point';

  @override
  String get menuEmbido2PointsIduki2Points =>
      'Embido (2 points) - Iduki = 2 points';

  @override
  String get menuHordagoTira1Point => 'Hordago - Tira = 1 point';

  @override
  String get menuHiruEmbido3PointsTira1Point =>
      'Hiru Embido (3 points) - Tira = 1 point';

  @override
  String get menuHiruEmbido3PointsIduki3Points =>
      'Hiru Embido (3 points) – Iduki = 3 points';

  @override
  String get menuEmbido2PointsLauGehiago4Tira2Points =>
      'Embido (2 points) Lau gehiago (+ 4) - Tira = 2 points';

  @override
  String get menuEmbido2PointsBigehiago2HordagoTira4Points =>
      'Embido (2 points) – Bigehiago( +2 ) – Hordago - Tira = 4 points';

  @override
  String get menuHiruEmbido3PointsLauGehiago4Iduki7 =>
      'Hiru Embido (3 points) Lau gehiago (+ 4) Iduki = 7 points';

  @override
  String get menuEmbido2PointsBortzGehiago5Bigehiago2Tira =>
      'Embido (2 points) Bortz gehiago (+ 5) Bigehiago (+2) Tira = 7 points';

  @override
  String get menuNoTtanttoMayBeScoredOnceTheCardsHave =>
      'Aucun ttantto ne peut être tiré si les cartes sont ramassées.';

  @override
  String get menuRefereeing => 'Arbitrage';

  @override
  String get menuTheRefereeIntervenesOnlyAtAPlayersRequestOr =>
      'Le Juge n\'intervient que sur demande de l\'un des joueurs ou sur le constat d’une irrégularité.';

  @override
  String get menuAnyDisputeOverTheseRegulationsOrAnySituationNot =>
      'Tout litige dans l\'interprétation de ce règlement ainsi que tout problème non évoqué ici sera réglé par le Juge.';

  @override
  String get menuTheRefereeMayImposePenaltiesUpToAndIncluding =>
      'Le Juge a un pouvoir de pénalisations allant jusqu’à l’exclusion.';

  @override
  String menuArticleArg0(String arg0) {
    return 'Article $arg0';
  }

  @override
  String get invitationPrivateTitle => 'Créer un Salon Privé';

  @override
  String get invitationPrivateLabel => 'Salon privé';

  @override
  String get invitationCasualTitle => 'En Ligne (Classique) en Duo';

  @override
  String get invitationCasualLabel => 'Classique en duo';

  @override
  String get invitationRankedTitle => 'En Ligne (Classé) en Duo';

  @override
  String get invitationRankedLabel => 'Classé en duo';

  @override
  String get classicCardBack => 'Dos Classique';

  @override
  String gamesPlayedCount(String count) {
    return '$count parties';
  }

  @override
  String avatarOption(String name, String number) {
    return '$name : option $number';
  }

  @override
  String get nicknameLengthError =>
      'Le pseudo doit contenir de 1 à 24 caractères.';

  @override
  String get deleteAccountError => 'La suppression a échoué. Réessayez.';

  @override
  String get connectionUnavailable => 'Connexion indisponible. Réessayez.';

  @override
  String seasonName(String name) {
    return 'Saison $name';
  }

  @override
  String questPlay(String count) {
    return 'Terminer $count parties';
  }

  @override
  String questWin(String count) {
    return 'Gagner $count parties';
  }

  @override
  String questRanked(String count) {
    return 'Gagner $count parties classées';
  }

  @override
  String get questGeneric => 'Défi hebdomadaire';

  @override
  String get catalogUnknown => 'Cosmétique';

  @override
  String get catalogUnknownDescription =>
      'Personnalisez votre apparence à la table.';

  @override
  String get catalogSun => 'Soleil';

  @override
  String get catalogMountain => 'Montagne';

  @override
  String get catalogBlue => 'Bleu';

  @override
  String get catalogGreen => 'Vert';

  @override
  String get catalogOcean => 'Océan';

  @override
  String get catalogRuby => 'Rubis';

  @override
  String get catalogDiamondBorder => 'Bordure Diamant';

  @override
  String get catalogLeagueTxapela => 'Txapela de ligue';

  @override
  String get catalogLeagueCrown => 'Couronne de ligue';

  @override
  String get catalogEmeraldBorder => 'Cadre Émeraude';

  @override
  String get catalogAmethystBorder => 'Cadre Améthyste';

  @override
  String get catalogEmeraldBack => 'Dos Émeraude';

  @override
  String get catalogVioletBack => 'Dos Violet';

  @override
  String get catalogEskerrik => 'Eskerrik asko !';

  @override
  String get catalogRematch => 'La revanche ?';

  @override
  String get catalogMullet => 'Coupe Mulet';

  @override
  String get catalogStriped => 'Maillot Rayé Bleu et Blanc';

  @override
  String get catalogGoldGlasses => 'Lunettes de Soleil Dorées';

  @override
  String get catalogCap => 'Casquette Bleue';

  @override
  String get catalogBeanie => 'Bonnet Cuivré';

  @override
  String get catalogRoundGlasses => 'Lunettes rondes';

  @override
  String get catalogOceanBack => 'Dos Océan';

  @override
  String get catalogCoralBack => 'Dos Corail';

  @override
  String get catalogEmeraldBorderDescription =>
      'Un anneau émeraude autour de votre avatar.';

  @override
  String get catalogAmethystBorderDescription =>
      'Une bordure violette à afficher à la table.';

  @override
  String get catalogEmeraldBackDescription => 'Un dos de cartes vert émeraude.';

  @override
  String get catalogVioletBackDescription => 'Un dos de cartes violet.';

  @override
  String get catalogEskerrikDescription =>
      'Remerciez les autres joueurs en un clic.';

  @override
  String get catalogRematchDescription =>
      'Proposez une nouvelle partie à la table.';

  @override
  String get catalogMulletDescription =>
      'Court devant, long derrière : une coupe de caractère.';

  @override
  String get catalogStripedDescription =>
      'Des rayures bleues et blanches pour votre tenue.';

  @override
  String get catalogGoldGlassesDescription =>
      'Des verres sombres et une monture dorée.';

  @override
  String get catalogCapDescription =>
      'Une casquette bleue portée au-dessus des cheveux.';

  @override
  String get catalogBeanieDescription => 'Un bonnet cuivré avec son pompon.';

  @override
  String get catalogFineGlassesDescription =>
      'Une monture fine dorée qui laisse les yeux visibles.';

  @override
  String get catalogRoundGlassesDescription =>
      'Des verres transparents et une monture ronde.';

  @override
  String get catalogOceanBackDescription =>
      'Un motif classique dans un bleu profond.';

  @override
  String get catalogCoralBackDescription =>
      'Un motif classique dans une teinte corail.';

  @override
  String get catalogBaldDescription =>
      'Le crâne dégagé, sans couche de cheveux.';

  @override
  String get catalogMohawkDescription => 'Une crête centrée, visible de face.';

  @override
  String get legalTermsBody =>
      'ISAMUS — CONDITIONS D’UTILISATION\nProjet de texte du 26 octobre 2026 — à compléter avant publication\n\nÉditeur : [NOM / RAISON SOCIALE], [ADRESSE], [PAYS]. Contact : [E-MAIL SUPPORT].\n\n1. Le service\nIsaMus permet de jouer au Mus, variante 4 Rois / 4 As, avec des joueurs ou des bots. Les points et le classement n’ont aucune valeur monétaire. Le service ne propose ni mise d’argent, ni gain échangeable contre de l’argent.\n\n2. Compte\nUn compte invité permet de commencer à jouer. Lier une adresse e-mail vérifiée ou une identité Apple/Google permet de retrouver le compte. Sans cette liaison, la perte de la session ou de l’appareil peut rendre la progression irrécupérable. Vous devez protéger vos moyens de connexion et choisir un pseudo respectueux, qui ne divulgue pas de données personnelles.\n\n3. Jeu et relations entre joueurs\nLa triche, l’exploitation de failles, l’usurpation d’identité, le harcèlement et les sollicitations abusives sont interdits. Les demandes d’amitié et invitations peuvent être refusées. Les bots sont identifiés comme tels. Les déconnexions déclenchent des actions automatiques pour permettre à la partie de continuer.\n\n4. Objets numériques\nLes cosmétiques sont des éléments visuels sans avantage sur les cartes ni les scores. Les articles, leurs caractéristiques et leur prix sont présentés avant la confirmation d’achat dans le store. Le paiement est traité par Apple ou Google. IsaMus ne reçoit pas votre numéro de carte bancaire. Les achats doivent être liés à un compte sécurisé. La fonction « Restaurer mes achats » permet de demander leur synchronisation. Un objet numérique n’est pas convertible en argent et ne peut pas être transféré entre joueurs dans l’application.\nLes conditions de remboursement et les droits légaux applicables restent ceux de votre pays et du store. Aucune clause de ce texte ne limite les garanties obligatoires du consommateur. Les informations et consentements éventuellement nécessaires à l’exécution immédiate d’un contenu numérique doivent être fournis dans le parcours d’achat du store.\n\n5. Publicité\nDes espaces publicitaires peuvent apparaître dans l’accueil. Les choix de confidentialité publicitaire sont accessibles dans le profil. Refuser une utilisation optionnelle de vos données ne doit pas empêcher de jouer.\n\n6. Disponibilité et évolution\nLe fonctionnement dépend du réseau et des services tiers. Des interruptions ou opérations de maintenance peuvent survenir. L’éditeur informe les joueurs des changements importants affectant le service ou les objets acquis et respecte les droits impératifs applicables.\n\n7. Suppression et assistance\nLa suppression du compte peut être demandée dans « Compte & sécurité ». Elle efface le profil et les données associées selon la politique de confidentialité. Elle n’annule pas automatiquement une transaction auprès d’un store. Pour toute difficulté, contactez [E-MAIL SUPPORT].\n\n8. Droit applicable et litiges\nLes règles de protection du consommateur de votre lieu de résidence s’appliquent lorsqu’elles sont impératives. Les mentions du droit applicable, de la médiation et de l’autorité compétente doivent être adaptées au pays et au statut réel de l’éditeur avant publication.\n';

  @override
  String get legalPrivacyBody =>
      'ISAMUS — POLITIQUE DE CONFIDENTIALITÉ\nProjet de texte du 26 octobre 2026 — à compléter avant publication\n\nResponsable du traitement : [NOM / RAISON SOCIALE], [ADRESSE], [PAYS]. Contact pour vos droits : [E-MAIL CONFIDENTIALITÉ].\n\nDonnées et usages\nLe compte possède un identifiant technique, un pseudo, un classement Elo et des statistiques. Une adresse e-mail ou une identité Apple/Google est utilisée seulement si vous choisissez de sécuriser votre compte. Les sessions servent à vous authentifier. Les mots de passe sont traités par le service d’authentification et ne sont pas accessibles dans l’application.\nLes parties contiennent les participants, actions et états nécessaires au jeu. L’historique conserve le résultat et les variations d’Elo. Les demandes d’amitié et invitations permettent les fonctions sociales. La présence indique aux amis acceptés si vous êtes en ligne ou dans une partie ; elle ne leur révèle pas le code du salon.\nLe pseudo, l’avatar et l’Elo sont visibles aux autres joueurs authentifiés. Les cartes et états de partie sont accessibles aux participants dans l’architecture actuelle. Ne placez pas de donnée sensible dans votre pseudo.\n\nAchats et publicité\nLes stores Apple/Google et RevenueCat traitent les achats et leur validation. L’identifiant de compte et les droits d’accès aux cosmétiques permettent leur restauration. Nous ne collectons pas vos coordonnées bancaires.\nLorsque la publicité est activée, Google AdMob et son mécanisme de consentement peuvent traiter des données techniques de l’appareil, du réseau, de la diffusion publicitaire et vos choix de confidentialité. L’intégration demande des annonces non personnalisées ; cela n’exclut pas tout traitement de données par le SDK. Les formulaires de consentement applicables et le lien « Choix de confidentialité publicitaire » permettent de gérer les usages optionnels. L’application n’exige pas l’accès à vos contacts, à votre microphone ni à votre localisation précise.\n\nBases des traitements\nLe fonctionnement du compte, du jeu et des achats repose sur l’exécution du service demandé. La protection contre les abus et la sécurité reposent sur l’intérêt légitime de l’éditeur, sous réserve de vos droits. Les traitements optionnels soumis au consentement ne doivent être activés qu’après le choix requis. Les obligations légales applicables peuvent imposer de conserver certaines traces de transactions.\n\nPrestataires et transferts\nSupabase fournit la base de données, l’authentification, les fonctions serveur et le temps réel. Apple, Google et RevenueCat interviennent dans l’authentification, les achats ou la publicité selon les fonctions utilisées. Avant publication, l’éditeur doit préciser les régions effectivement choisies, les destinataires, les éventuels transferts internationaux et les garanties contractuelles applicables ; ces paramètres ne peuvent pas être déduits du code de l’application.\n\nConservation\nLe profil, l’inventaire et les relations sociales sont conservés tant que le compte existe. La présence est liée à la connexion. Les historiques et journaux techniques nécessitent une durée de conservation documentée par l’éditeur : [DURÉE HISTORIQUE], [DURÉE JOURNAUX], [DURÉE SAUVEGARDES]. Les invitations ont une validité fonctionnelle de dix minutes ; leur expiration ne signifie pas leur effacement immédiat de la base. Les prestataires peuvent avoir leurs propres obligations de conservation.\n\nVos droits et suppression\nVous pouvez demander l’accès, la rectification, l’effacement et, selon les conditions légales, la portabilité, la limitation ou l’opposition, à [E-MAIL CONFIDENTIALITÉ]. Le retrait d’un consentement n’affecte pas les traitements antérieurs licites. Le profil propose une suppression de compte. Les demandes concernant un paiement ou un identifiant publicitaire peuvent également relever du store ou du fournisseur concerné. Vous pouvez saisir l’autorité de contrôle compétente ; en France, la CNIL (www.cnil.fr).\n\nMineurs\nL’éditeur doit définir avant publication l’âge minimal, le public visé et le mécanisme de consentement parental éventuellement nécessaire. La configuration publicitaire et la déclaration d’âge des stores doivent correspondre à ce choix.\n\nMises à jour\nLa date et les changements substantiels de cette politique seront communiqués dans l’application. Ce projet doit être complété avec les informations réelles de l’éditeur et des prestataires avant sa mise en ligne.\n';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageBasque => 'Euskara';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get musWord => 'Mus';

  @override
  String get mintzaWord => 'Mintza';

  @override
  String get tiraWord => 'Tira';

  @override
  String get pasoWord => 'Paso';

  @override
  String get hordagoWord => 'Hordago';

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerApple => 'Apple';

  @override
  String get rulesContact =>
      'Centre Départemental Nelson Paillou · 2, allée des Platanes · 64100 Bayonne\n05 59 14 19 12 · mail@federation-mus.fr';
}
