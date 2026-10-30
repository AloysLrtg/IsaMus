import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_eu.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
    Locale('es'),
    Locale('eu'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'IsaMus'**
  String get appTitle;

  /// No description provided for @you.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get you;

  /// No description provided for @partner.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire'**
  String get partner;

  /// No description provided for @team.
  ///
  /// In fr, this message translates to:
  /// **'Équipe {name}'**
  String team(String name);

  /// No description provided for @rounds.
  ///
  /// In fr, this message translates to:
  /// **'Manches : {count} / 3'**
  String rounds(int count);

  /// No description provided for @startGame.
  ///
  /// In fr, this message translates to:
  /// **'Distribuer'**
  String get startGame;

  /// No description provided for @nextHand.
  ///
  /// In fr, this message translates to:
  /// **'Donne suivante'**
  String get nextHand;

  /// No description provided for @newGame.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle partie'**
  String get newGame;

  /// No description provided for @dealing.
  ///
  /// In fr, this message translates to:
  /// **'Distribution'**
  String get dealing;

  /// No description provided for @discarding.
  ///
  /// In fr, this message translates to:
  /// **'Défausse'**
  String get discarding;

  /// No description provided for @roundScoring.
  ///
  /// In fr, this message translates to:
  /// **'Décompte'**
  String get roundScoring;

  /// No description provided for @gameOver.
  ///
  /// In fr, this message translates to:
  /// **'Partie terminée'**
  String get gameOver;

  /// No description provided for @yourTurn.
  ///
  /// In fr, this message translates to:
  /// **'À vous de parler'**
  String get yourTurn;

  /// No description provided for @waitingFor.
  ///
  /// In fr, this message translates to:
  /// **'À {name} de parler'**
  String waitingFor(String name);

  /// No description provided for @discardCards.
  ///
  /// In fr, this message translates to:
  /// **'Échanger {count} carte(s)'**
  String discardCards(int count);

  /// No description provided for @keepCards.
  ///
  /// In fr, this message translates to:
  /// **'Garder mes cartes'**
  String get keepCards;

  /// No description provided for @currentBid.
  ///
  /// In fr, this message translates to:
  /// **'Mise : {amount} Tantto'**
  String currentBid(int amount);

  /// No description provided for @roundWinner.
  ///
  /// In fr, this message translates to:
  /// **'{team} remporte la manche'**
  String roundWinner(String team);

  /// No description provided for @gameWinner.
  ///
  /// In fr, this message translates to:
  /// **'{team} remporte la partie'**
  String gameWinner(String team);

  /// No description provided for @actionFailed.
  ///
  /// In fr, this message translates to:
  /// **'Action impossible : la situation a changé.'**
  String get actionFailed;

  /// No description provided for @cardLabel.
  ///
  /// In fr, this message translates to:
  /// **'{value} de {suit}'**
  String cardLabel(int value, String suit);

  /// No description provided for @oros.
  ///
  /// In fr, this message translates to:
  /// **'Or'**
  String get oros;

  /// No description provided for @copas.
  ///
  /// In fr, this message translates to:
  /// **'Coupe'**
  String get copas;

  /// No description provided for @espadas.
  ///
  /// In fr, this message translates to:
  /// **'Épée'**
  String get espadas;

  /// No description provided for @bastos.
  ///
  /// In fr, this message translates to:
  /// **'Bâton'**
  String get bastos;

  /// No description provided for @hasPairs.
  ///
  /// In fr, this message translates to:
  /// **'Pariak dut'**
  String get hasPairs;

  /// No description provided for @hasGame.
  ///
  /// In fr, this message translates to:
  /// **'Jokoa dut'**
  String get hasGame;

  /// No description provided for @hasNeither.
  ///
  /// In fr, this message translates to:
  /// **'Ez dut'**
  String get hasNeither;

  /// No description provided for @sendSign.
  ///
  /// In fr, this message translates to:
  /// **'Faire un signe au partenaire'**
  String get sendSign;

  /// No description provided for @signTwoKings.
  ///
  /// In fr, this message translates to:
  /// **'2 Rois'**
  String get signTwoKings;

  /// No description provided for @signTwoAces.
  ///
  /// In fr, this message translates to:
  /// **'2 As'**
  String get signTwoAces;

  /// No description provided for @signGame.
  ///
  /// In fr, this message translates to:
  /// **'Jeu'**
  String get signGame;

  /// No description provided for @opponentShort.
  ///
  /// In fr, this message translates to:
  /// **'Adv. {number}'**
  String opponentShort(int number);

  /// No description provided for @scoreTotal.
  ///
  /// In fr, this message translates to:
  /// **'Score : {total} pts ({hamarreko} Hamarreko, {tantto} Tantto)'**
  String scoreTotal(int total, int hamarreko, int tantto);

  /// No description provided for @quickChat.
  ///
  /// In fr, this message translates to:
  /// **'Chat rapide'**
  String get quickChat;

  /// No description provided for @chatGoodLuck.
  ///
  /// In fr, this message translates to:
  /// **'Bonne chance'**
  String get chatGoodLuck;

  /// No description provided for @chatNothing.
  ///
  /// In fr, this message translates to:
  /// **'Je n’ai rien'**
  String get chatNothing;

  /// No description provided for @chatWellPlayed.
  ///
  /// In fr, this message translates to:
  /// **'Bien joué !'**
  String get chatWellPlayed;

  /// No description provided for @turnTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps pour jouer'**
  String get turnTime;

  /// No description provided for @raiseAmount.
  ///
  /// In fr, this message translates to:
  /// **'Relancer de…'**
  String get raiseAmount;

  /// No description provided for @openingAmount.
  ///
  /// In fr, this message translates to:
  /// **'Miser…'**
  String get openingAmount;

  /// No description provided for @increase.
  ///
  /// In fr, this message translates to:
  /// **'Augmenter'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In fr, this message translates to:
  /// **'Diminuer'**
  String get decrease;

  /// No description provided for @validate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// No description provided for @bidTotal.
  ///
  /// In fr, this message translates to:
  /// **'Mise totale : {amount} Tantto'**
  String bidTotal(int amount);

  /// No description provided for @playTitle.
  ///
  /// In fr, this message translates to:
  /// **'Jouer'**
  String get playTitle;

  /// No description provided for @leaderboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Top 100'**
  String get leaderboardTitle;

  /// No description provided for @shopTitle.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get shopTitle;

  /// No description provided for @friendsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get friendsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @seasonPassTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pass de Saison'**
  String get seasonPassTitle;

  /// No description provided for @tutorialTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tutoriel'**
  String get tutorialTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageTitle;

  /// No description provided for @menuUnableToCompleteThisActionCheckYourConnectionAnd.
  ///
  /// In fr, this message translates to:
  /// **'Action impossible. Vérifiez votre connexion et réessayez.'**
  String get menuUnableToCompleteThisActionCheckYourConnectionAnd;

  /// No description provided for @menuDocumentUnavailableTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Document indisponible. Réessayez.'**
  String get menuDocumentUnavailableTryAgain;

  /// No description provided for @menuSoundEffects.
  ///
  /// In fr, this message translates to:
  /// **'Effets sonores'**
  String get menuSoundEffects;

  /// No description provided for @menuPreferenceUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Préférence indisponible'**
  String get menuPreferenceUnavailable;

  /// No description provided for @menuTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get menuTryAgain;

  /// No description provided for @menuAccountSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Compte & sécurité'**
  String get menuAccountSecurity;

  /// No description provided for @menuAdPrivacyChoices.
  ///
  /// In fr, this message translates to:
  /// **'Choix de confidentialité publicitaire'**
  String get menuAdPrivacyChoices;

  /// No description provided for @menuTermsOfUse.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d’utilisation'**
  String get menuTermsOfUse;

  /// No description provided for @menuPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get menuPrivacyPolicy;

  /// No description provided for @menuLastDay.
  ///
  /// In fr, this message translates to:
  /// **'Dernier jour'**
  String get menuLastDay;

  /// No description provided for @menuOnlyArg0DLeft.
  ///
  /// In fr, this message translates to:
  /// **'Plus que {arg0}j'**
  String menuOnlyArg0DLeft(String arg0);

  /// No description provided for @menuSeasonInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Saison en cours'**
  String get menuSeasonInProgress;

  /// No description provided for @menuPlayer.
  ///
  /// In fr, this message translates to:
  /// **'Joueur'**
  String get menuPlayer;

  /// No description provided for @menuUnableToCompleteThisActionTheRoomMayHave.
  ///
  /// In fr, this message translates to:
  /// **'Action impossible. Le salon a peut-être changé. Réessayez.'**
  String get menuUnableToCompleteThisActionTheRoomMayHave;

  /// No description provided for @menuCodeArg0CopiedToClipboard.
  ///
  /// In fr, this message translates to:
  /// **'Code {arg0} copié dans le presse-papier !'**
  String menuCodeArg0CopiedToClipboard(String arg0);

  /// No description provided for @menuWAITINGROOM.
  ///
  /// In fr, this message translates to:
  /// **'SALON D’ATTENTE'**
  String get menuWAITINGROOM;

  /// No description provided for @menuSyncErrorTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de synchronisation. Réessayer'**
  String get menuSyncErrorTryAgain;

  /// No description provided for @menuThisRoomIsReservedForPublicMatchmaking.
  ///
  /// In fr, this message translates to:
  /// **'Ce salon est réservé au matchmaking public.'**
  String get menuThisRoomIsReservedForPublicMatchmaking;

  /// No description provided for @menuINVITATIONCODE.
  ///
  /// In fr, this message translates to:
  /// **'CODE D’INVITATION'**
  String get menuINVITATIONCODE;

  /// No description provided for @menuCopyCode.
  ///
  /// In fr, this message translates to:
  /// **'Copier le code'**
  String get menuCopyCode;

  /// No description provided for @menuStartGame.
  ///
  /// In fr, this message translates to:
  /// **'Lancer la partie'**
  String get menuStartGame;

  /// No description provided for @menuFillWithAIPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Compléter avec des IA'**
  String get menuFillWithAIPlayers;

  /// No description provided for @menuTwoPlayersPerTeamAreRequired.
  ///
  /// In fr, this message translates to:
  /// **'Deux joueurs par équipe sont requis.'**
  String get menuTwoPlayersPerTeamAreRequired;

  /// No description provided for @menuWaitingForTheHost.
  ///
  /// In fr, this message translates to:
  /// **'En attente de l\'hôte...'**
  String get menuWaitingForTheHost;

  /// No description provided for @menuTheRoomHasBeenClosed.
  ///
  /// In fr, this message translates to:
  /// **'Le salon a été fermé.'**
  String get menuTheRoomHasBeenClosed;

  /// No description provided for @menuTeamArg0Arg12.
  ///
  /// In fr, this message translates to:
  /// **'Équipe {arg0} · {arg1}/2'**
  String menuTeamArg0Arg12(String arg0, String arg1);

  /// No description provided for @menuYourTeam.
  ///
  /// In fr, this message translates to:
  /// **'Votre équipe'**
  String get menuYourTeam;

  /// No description provided for @menuJoin.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get menuJoin;

  /// No description provided for @menuYOU.
  ///
  /// In fr, this message translates to:
  /// **'VOUS'**
  String get menuYOU;

  /// No description provided for @menuOpenSeat.
  ///
  /// In fr, this message translates to:
  /// **'Place libre'**
  String get menuOpenSeat;

  /// No description provided for @menuWaiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente…'**
  String get menuWaiting;

  /// No description provided for @menuHost.
  ///
  /// In fr, this message translates to:
  /// **'Hôte'**
  String get menuHost;

  /// No description provided for @menuAI.
  ///
  /// In fr, this message translates to:
  /// **'IA'**
  String get menuAI;

  /// No description provided for @menuInviteMyFriends.
  ///
  /// In fr, this message translates to:
  /// **'Inviter mes amis'**
  String get menuInviteMyFriends;

  /// No description provided for @menuAddFriendsFromTheFriendsTab.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des amis depuis l’onglet Amis.'**
  String get menuAddFriendsFromTheFriendsTab;

  /// No description provided for @menuFriend.
  ///
  /// In fr, this message translates to:
  /// **'Ami'**
  String get menuFriend;

  /// No description provided for @menuInvitationSentToArg0.
  ///
  /// In fr, this message translates to:
  /// **'Invitation envoyée à {arg0}.'**
  String menuInvitationSentToArg0(String arg0);

  /// No description provided for @menuUnableToSendTheInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’envoyer l’invitation.'**
  String get menuUnableToSendTheInvitation;

  /// No description provided for @menuInvite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get menuInvite;

  /// No description provided for @menuSignInToPlay.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour jouer.'**
  String get menuSignInToPlay;

  /// No description provided for @menuPleaseEnterYourNickname.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre pseudo.'**
  String get menuPleaseEnterYourNickname;

  /// No description provided for @menuSignInToCreateYourProfile.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour créer votre profil.'**
  String get menuSignInToCreateYourProfile;

  /// No description provided for @menuTheCodeMustContainExactly5Characters.
  ///
  /// In fr, this message translates to:
  /// **'Le code doit comporter exactement 5 caractères.'**
  String get menuTheCodeMustContainExactly5Characters;

  /// No description provided for @menuIAlreadyHaveAnAccount.
  ///
  /// In fr, this message translates to:
  /// **'J’ai déjà un compte'**
  String get menuIAlreadyHaveAnAccount;

  /// No description provided for @menuArg0Coins.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} pièces'**
  String menuArg0Coins(String arg0);

  /// No description provided for @menuWeeklyQuests.
  ///
  /// In fr, this message translates to:
  /// **'Quêtes hebdomadaires'**
  String get menuWeeklyQuests;

  /// No description provided for @menuGAMEMODES.
  ///
  /// In fr, this message translates to:
  /// **'MODES DE JEU'**
  String get menuGAMEMODES;

  /// No description provided for @menuATYOUROWNPACE.
  ///
  /// In fr, this message translates to:
  /// **'À VOTRE RYTHME'**
  String get menuATYOUROWNPACE;

  /// No description provided for @menuTakeASeatAndLearnMusFromYourFirst.
  ///
  /// In fr, this message translates to:
  /// **'Prenez place à la table et apprenez le Mus, des premières décisions au décompte des points.'**
  String get menuTakeASeatAndLearnMusFromYourFirst;

  /// No description provided for @menuNoTimerGuidedThenFreePlay.
  ///
  /// In fr, this message translates to:
  /// **'Sans chronomètre · Guidé, puis libre'**
  String get menuNoTimerGuidedThenFreePlay;

  /// No description provided for @menuLearnMus.
  ///
  /// In fr, this message translates to:
  /// **'Apprendre le Mus'**
  String get menuLearnMus;

  /// No description provided for @menuOfficialRules.
  ///
  /// In fr, this message translates to:
  /// **'Règles officielles'**
  String get menuOfficialRules;

  /// No description provided for @menuQUICKMULTIPLAYER.
  ///
  /// In fr, this message translates to:
  /// **'MULTIJOUEUR RAPIDE'**
  String get menuQUICKMULTIPLAYER;

  /// No description provided for @menuONLINECASUAL.
  ///
  /// In fr, this message translates to:
  /// **'EN LIGNE (CLASSIQUE)'**
  String get menuONLINECASUAL;

  /// No description provided for @menuChallengePlayersOnlineInRelaxedFriendlyGamesWithNo.
  ///
  /// In fr, this message translates to:
  /// **'Défiez des joueurs en ligne dans des parties amicales et détendues, sans enjeu d\'Elo. Idéal pour partager un bon moment de Mus.'**
  String get menuChallengePlayersOnlineInRelaxedFriendlyGamesWithNo;

  /// No description provided for @menuOfficial4KingsAnd4AcesRulesNoPressure.
  ///
  /// In fr, this message translates to:
  /// **'Règles officielles 4 Rois et 4 As • Sans pression'**
  String get menuOfficial4KingsAnd4AcesRulesNoPressure;

  /// No description provided for @menuOFFICIALCOMPETITION.
  ///
  /// In fr, this message translates to:
  /// **'COMPÉTITION OFFICIELLE'**
  String get menuOFFICIALCOMPETITION;

  /// No description provided for @menuONLINERANKED.
  ///
  /// In fr, this message translates to:
  /// **'EN LIGNE (CLASSÉ)'**
  String get menuONLINERANKED;

  /// No description provided for @menuYourCurrentEloArg0.
  ///
  /// In fr, this message translates to:
  /// **'Votre Elo actuel : {arg0}'**
  String menuYourCurrentEloArg0(String arg0);

  /// No description provided for @menuSeasonRewards.
  ///
  /// In fr, this message translates to:
  /// **'Récompenses de Saison'**
  String get menuSeasonRewards;

  /// No description provided for @menuClimbTheCompetitiveRankingsEveryWinRaisesYourElo.
  ///
  /// In fr, this message translates to:
  /// **'Grimpez dans le classement compétitif. Chaque victoire augmente votre cote Elo, chaque défaite en coûte. Visez le Top 100 !'**
  String get menuClimbTheCompetitiveRankingsEveryWinRaisesYourElo;

  /// No description provided for @menuPlayRanked.
  ///
  /// In fr, this message translates to:
  /// **'Lancer (Classé)'**
  String get menuPlayRanked;

  /// No description provided for @menuSOLOPRACTICE.
  ///
  /// In fr, this message translates to:
  /// **'ENTRAÎNEMENT SOLO'**
  String get menuSOLOPRACTICE;

  /// No description provided for @menuSOLOVSAI.
  ///
  /// In fr, this message translates to:
  /// **'SOLO CONTRE IA'**
  String get menuSOLOVSAI;

  /// No description provided for @menuPlayAgainst3LocalAIPlayersWithoutWaitingFor.
  ///
  /// In fr, this message translates to:
  /// **'Affrontez 3 intelligences artificielles locales sans attendre d\'autres joueurs. Parfait pour réviser les règles, tactiques et signes basques.'**
  String get menuPlayAgainst3LocalAIPlayersWithoutWaitingFor;

  /// No description provided for @menuInstantStart3IndependentBots.
  ///
  /// In fr, this message translates to:
  /// **'Lancement immédiat • 3 Bots autonomes'**
  String get menuInstantStart3IndependentBots;

  /// No description provided for @menuPlayAgainstAI.
  ///
  /// In fr, this message translates to:
  /// **'Jouer contre l\'IA'**
  String get menuPlayAgainstAI;

  /// No description provided for @menuPRIVATEROOM.
  ///
  /// In fr, this message translates to:
  /// **'SALON PRIVÉ'**
  String get menuPRIVATEROOM;

  /// No description provided for @menuPLAYWITHFRIENDS.
  ///
  /// In fr, this message translates to:
  /// **'JOUER AVEC DES AMIS'**
  String get menuPLAYWITHFRIENDS;

  /// No description provided for @menuCreateAPrivateRoom.
  ///
  /// In fr, this message translates to:
  /// **'Créer un salon privé'**
  String get menuCreateAPrivateRoom;

  /// No description provided for @menuORJOINWITHACODE.
  ///
  /// In fr, this message translates to:
  /// **'OU REJOINDRE AVEC UN CODE'**
  String get menuORJOINWITHACODE;

  /// No description provided for @menuConfirmAndJoin.
  ///
  /// In fr, this message translates to:
  /// **'Valider et rejoindre'**
  String get menuConfirmAndJoin;

  /// No description provided for @menuBASQUECARDGAMEMULTIPLAYER.
  ///
  /// In fr, this message translates to:
  /// **'JEU DE CARTES BASQUE • MULTIJOUEUR'**
  String get menuBASQUECARDGAMEMULTIPLAYER;

  /// No description provided for @menuCONNECTING.
  ///
  /// In fr, this message translates to:
  /// **'CONNEXION EN COURS...'**
  String get menuCONNECTING;

  /// No description provided for @menuCREATEYOURPROFILE.
  ///
  /// In fr, this message translates to:
  /// **'CRÉEZ VOTRE PROFIL'**
  String get menuCREATEYOURPROFILE;

  /// No description provided for @menuYourNicknameEGPatxiAmaia.
  ///
  /// In fr, this message translates to:
  /// **'Votre pseudo (ex: Patxi, Amaia…)'**
  String get menuYourNicknameEGPatxiAmaia;

  /// No description provided for @menuCreateMyProfile.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon profil'**
  String get menuCreateMyProfile;

  /// No description provided for @menuTop100Players.
  ///
  /// In fr, this message translates to:
  /// **'Top 100 des Joueurs'**
  String get menuTop100Players;

  /// No description provided for @menuRefreshRankings.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser le classement'**
  String get menuRefreshRankings;

  /// No description provided for @menuLoadingRankings.
  ///
  /// In fr, this message translates to:
  /// **'Chargement du classement'**
  String get menuLoadingRankings;

  /// No description provided for @menuUnableToLoadRankingsCheckYourConnectionAndTry.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le classement. Vérifiez votre connexion et réessayez.'**
  String get menuUnableToLoadRankingsCheckYourConnectionAndTry;

  /// No description provided for @menuNoRankedPlayersYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun joueur classé pour le moment.'**
  String get menuNoRankedPlayersYet;

  /// No description provided for @menuTheHighestEloRatings.
  ///
  /// In fr, this message translates to:
  /// **'Les meilleurs scores Elo'**
  String get menuTheHighestEloRatings;

  /// No description provided for @menuYourPositionArg0.
  ///
  /// In fr, this message translates to:
  /// **'Votre position : #{arg0}'**
  String menuYourPositionArg0(String arg0);

  /// No description provided for @menuReachTheTop100ToAppearHere.
  ///
  /// In fr, this message translates to:
  /// **'Atteignez le Top 100 pour apparaître ici !'**
  String get menuReachTheTop100ToAppearHere;

  /// No description provided for @menuRankedByDescendingElo.
  ///
  /// In fr, this message translates to:
  /// **'Classement par Elo décroissant.'**
  String get menuRankedByDescendingElo;

  /// No description provided for @menuPositionArg0Arg1Arg2EloArg3.
  ///
  /// In fr, this message translates to:
  /// **'Position {arg0}, {arg1}, {arg2} Elo{arg3}'**
  String menuPositionArg0Arg1Arg2EloArg3(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  );

  /// No description provided for @menuLevelArg0Arg1500XP.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {arg0} · {arg1} / 500 XP'**
  String menuLevelArg0Arg1500XP(String arg0, String arg1);

  /// No description provided for @menuLevelArg0Arg1XPOutOf500.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {arg0}, {arg1} XP sur 500'**
  String menuLevelArg0Arg1XPOutOf500(String arg0, String arg1);

  /// No description provided for @menuYouHaveTwoKingsAndAGameTotalOf.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez deux Rois et un Jeu de 31. Gardez cette main : dites Mintza.'**
  String get menuYouHaveTwoKingsAndAGameTotalOf;

  /// No description provided for @menuYourOpponentRaisesCallIdukiToCompareCardsAt.
  ///
  /// In fr, this message translates to:
  /// **'L’adversaire relance. Suivez (Iduki) pour comparer les cartes au décompte.'**
  String get menuYourOpponentRaisesCallIdukiToCompareCardsAt;

  /// No description provided for @menuYouHaveTwoKingsBaiAnnouncesYourPairBet.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez deux Rois : votre paire est annoncée avec Bai. Misez 2 pierres !'**
  String get menuYouHaveTwoKingsBaiAnnouncesYourPairBet;

  /// No description provided for @menuYouHave31TheBestGameTotalBet2.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez 31, le meilleur Jeu. Misez 2 pierres pour ouvrir les enchères.'**
  String get menuYouHave31TheBestGameTotalBet2;

  /// No description provided for @menuThisIsHighHandiaYouHaveStrongCardsBet.
  ///
  /// In fr, this message translates to:
  /// **'C’est le Grand (Handia). Vous avez des cartes fortes, misez !'**
  String get menuThisIsHighHandiaYouHaveStrongCardsBet;

  /// No description provided for @menuAtLowYourAceIsFollowedByThreeFace.
  ///
  /// In fr, this message translates to:
  /// **'Au Petit, votre As est suivi de trois figures. Passez la parole avec Paso.'**
  String get menuAtLowYourAceIsFollowedByThreeFace;

  /// No description provided for @menuWatchTheOtherPlayersAnnouncementsAndResponses.
  ///
  /// In fr, this message translates to:
  /// **'Observez les annonces et les réponses des autres joueurs.'**
  String get menuWatchTheOtherPlayersAnnouncementsAndResponses;

  /// No description provided for @menuTheTutorialIsWaitingForMintza.
  ///
  /// In fr, this message translates to:
  /// **'Le tutoriel attend Mintza.'**
  String get menuTheTutorialIsWaitingForMintza;

  /// No description provided for @menuDiscardingIsNotAvailableAtThisStep.
  ///
  /// In fr, this message translates to:
  /// **'La défausse n’est pas disponible dans cette étape.'**
  String get menuDiscardingIsNotAvailableAtThisStep;

  /// No description provided for @menuThisIsNotTheActionExpectedByTheTutorial.
  ///
  /// In fr, this message translates to:
  /// **'Action différente de celle attendue par le tutoriel.'**
  String get menuThisIsNotTheActionExpectedByTheTutorial;

  /// No description provided for @menuTheOtherPlayersAreTakingTheirTurns.
  ///
  /// In fr, this message translates to:
  /// **'Les autres joueurs jouent…'**
  String get menuTheOtherPlayersAreTakingTheirTurns;

  /// No description provided for @menuIdukiCall.
  ///
  /// In fr, this message translates to:
  /// **'Iduki (Suivre)'**
  String get menuIdukiCall;

  /// No description provided for @menuRaise.
  ///
  /// In fr, this message translates to:
  /// **'Relancer'**
  String get menuRaise;

  /// No description provided for @menuBet2.
  ///
  /// In fr, this message translates to:
  /// **'Enchérir de 2'**
  String get menuBet2;

  /// No description provided for @menuMusOrMintza.
  ///
  /// In fr, this message translates to:
  /// **'Mus ou Mintza ?'**
  String get menuMusOrMintza;

  /// No description provided for @menuAtTheStartOfEachHandEachPlayerChooses.
  ///
  /// In fr, this message translates to:
  /// **'Au début de chaque donne, chacun choisit Mus pour demander un échange de cartes. Si les quatre joueurs disent Mus, chacun peut défausser puis recevoir de nouvelles cartes. Mintza coupe le Mus : on garde les mains et on commence les enchères. À vous de cliquer sur Mintza : seul le bouton attendu est actif et son contour brille.'**
  String get menuAtTheStartOfEachHandEachPlayerChooses;

  /// No description provided for @menuBettingPasoAndEmbido.
  ///
  /// In fr, this message translates to:
  /// **'Miser : Paso et Embido'**
  String get menuBettingPasoAndEmbido;

  /// No description provided for @menuInEachPhaseYouCanBetStonesForYour.
  ///
  /// In fr, this message translates to:
  /// **'Chaque phase permet de miser des pierres pour son équipe. Paso passe la parole sans ouvrir de mise. Embido propose une mise ; Gehiago permet de relancer. Votre équipe peut bluffer sur ses mises, mais jamais envoyer un faux signe.'**
  String get menuInEachPhaseYouCanBetStonesForYour;

  /// No description provided for @menuRespondingTiraAndIduki.
  ///
  /// In fr, this message translates to:
  /// **'Répondre : Tira et Iduki'**
  String get menuRespondingTiraAndIduki;

  /// No description provided for @menuWhenFacingABetIdukiAcceptsTheCardsWill.
  ///
  /// In fr, this message translates to:
  /// **'Face à une mise, Iduki accepte : les cartes départageront les équipes au décompte. Tira refuse : la phase s’arrête et l’adversaire marque le refus selon les mises précédentes. Une relance propose au contraire une mise plus forte.'**
  String get menuWhenFacingABetIdukiAcceptsTheCardsWill;

  /// No description provided for @menuHordagoTheWholeRound.
  ///
  /// In fr, this message translates to:
  /// **'Hordago : toute la manche'**
  String get menuHordagoTheWholeRound;

  /// No description provided for @menuHordagoPutsTheEntireRoundAtStakeIfAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Le Hordago met la manche entière en jeu. S’il est accepté avec Iduki, les mains sont comparées immédiatement pour cette phase et le gagnant remporte la manche. Tira refuse le défi et laisse seulement les points de refus. Vous allez miser 2 au Grand et aux Paires, puis suivre une relance au Jeu. Les autres choix restent grisés jusqu’à la partie libre.'**
  String get menuHordagoPutsTheEntireRoundAtStakeIfAccepted;

  /// No description provided for @menuYourTurnToCall.
  ///
  /// In fr, this message translates to:
  /// **'À vous de suivre'**
  String get menuYourTurnToCall;

  /// No description provided for @menuYourOpponentRaisesBy8TheBetGoesFrom.
  ///
  /// In fr, this message translates to:
  /// **'L’adversaire relance de 8 : la mise passe de 2 à 10 pierres. Cliquez sur Iduki pour accepter. Les cartes décideront du gagnant au décompte.'**
  String get menuYourOpponentRaisesBy8TheBetGoesFrom;

  /// No description provided for @menuTheCardsAreRevealedBetsAndPointsForPairs.
  ///
  /// In fr, this message translates to:
  /// **'Les cartes sont révélées. On additionne les mises et les points de Paires et de Jeu. La première équipe à 40 pierres gagne la manche.'**
  String get menuTheCardsAreRevealedBetsAndPointsForPairs;

  /// No description provided for @menuHighHandia.
  ///
  /// In fr, this message translates to:
  /// **'Grand — Handia'**
  String get menuHighHandia;

  /// No description provided for @menuCompareCardsFromHighestToLowestTheKingIs.
  ///
  /// In fr, this message translates to:
  /// **'On compare les cartes de la plus haute à la plus basse. Le Roi est le plus fort. Cliquez sur Enchérir de 2 : vous proposez deux pierres. Un adversaire acceptera cette première mise.'**
  String get menuCompareCardsFromHighestToLowestTheKingIs;

  /// No description provided for @menuLowTtipia.
  ///
  /// In fr, this message translates to:
  /// **'Petit — Ttipia'**
  String get menuLowTtipia;

  /// No description provided for @menuNowCompareTheLowestCardsTheAceIsBest.
  ///
  /// In fr, this message translates to:
  /// **'On compare cette fois les cartes les plus basses. L’As est le meilleur. En cas d’égalité, on compare les suivantes ; l’Esku départage une égalité parfaite.'**
  String get menuNowCompareTheLowestCardsTheAceIsBest;

  /// No description provided for @menuPairsPareak.
  ///
  /// In fr, this message translates to:
  /// **'Paires — Pareak'**
  String get menuPairsPareak;

  /// No description provided for @menuTwoMatchingCardsMakeAPairThreeMakeMediak.
  ///
  /// In fr, this message translates to:
  /// **'Deux cartes identiques font une paire ; trois font Mediak ; deux paires ou quatre cartes identiques font Dobliak. Seuls les joueurs avec des paires participent. Vous avez deux Rois : l’annonce Bai confirme votre paire. Cliquez sur Enchérir de 2 pour la défendre.'**
  String get menuTwoMatchingCardsMakeAPairThreeMakeMediak;

  /// No description provided for @menuGameJoko.
  ///
  /// In fr, this message translates to:
  /// **'Jeu — Joko'**
  String get menuGameJoko;

  /// No description provided for @menuFaceCardsAreWorth10AndOtherCardsTheir.
  ///
  /// In fr, this message translates to:
  /// **'Les figures valent 10 et les autres cartes leur valeur. Il faut au moins 31. Le meilleur Jeu est 31, puis 32. Si personne n’a le Jeu, on joue le Point, au plus près de 30. Ici, proposez 2 : un adversaire relancera, et vous apprendrez à suivre avec Iduki.'**
  String get menuFaceCardsAreWorth10AndOtherCardsTheir;

  /// No description provided for @menuYourTurnToPlay.
  ///
  /// In fr, this message translates to:
  /// **'À vous de jouer !'**
  String get menuYourTurnToPlay;

  /// No description provided for @menuYouHaveLearnedYourWayAroundTheTable.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez fait le tour de la table.'**
  String get menuYouHaveLearnedYourWayAroundTheTable;

  /// No description provided for @menuKeepPlayingAgainstTheBotsAllActionsAreAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Poursuivez cette partie contre les bots : toutes les actions sont disponibles, sans chronomètre et sans conseils. Vous pouvez aussi revenir au menu.'**
  String get menuKeepPlayingAgainstTheBotsAllActionsAreAvailable;

  /// No description provided for @menuReturnToMenu.
  ///
  /// In fr, this message translates to:
  /// **'Retourner au menu'**
  String get menuReturnToMenu;

  /// No description provided for @menuFinishThisGameFreePlay.
  ///
  /// In fr, this message translates to:
  /// **'Terminer la partie en cours (Libre)'**
  String get menuFinishThisGameFreePlay;

  /// No description provided for @menuGotIt.
  ///
  /// In fr, this message translates to:
  /// **'J’ai compris'**
  String get menuGotIt;

  /// No description provided for @menuCheckYourEmailToActivateYourAccount.
  ///
  /// In fr, this message translates to:
  /// **'Consultez votre boîte e-mail pour activer votre compte.'**
  String get menuCheckYourEmailToActivateYourAccount;

  /// No description provided for @menuAnAccountAlreadyUsesThisEmailAddress.
  ///
  /// In fr, this message translates to:
  /// **'Un compte utilise déjà cette adresse e-mail.'**
  String get menuAnAccountAlreadyUsesThisEmailAddress;

  /// No description provided for @menuChooseAStrongerPassword.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un mot de passe plus fort.'**
  String get menuChooseAStrongerPassword;

  /// No description provided for @menuTooManyAttemptsTryAgainShortly.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez dans quelques instants.'**
  String get menuTooManyAttemptsTryAgainShortly;

  /// No description provided for @menuUnableToSignUpTryAnotherNicknameAndCheck.
  ///
  /// In fr, this message translates to:
  /// **'Inscription impossible. Essayez un autre pseudo et vérifiez vos informations.'**
  String get menuUnableToSignUpTryAnotherNicknameAndCheck;

  /// No description provided for @menuServiceUnavailableCheckYourConnectionAndTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Service indisponible. Vérifiez votre connexion et réessayez.'**
  String get menuServiceUnavailableCheckYourConnectionAndTryAgain;

  /// No description provided for @menuSignUp.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get menuSignUp;

  /// No description provided for @menuJoinIsaMus.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez IsaMus'**
  String get menuJoinIsaMus;

  /// No description provided for @menuChooseYourNicknameAndJoinTheGame.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre pseudo et entrez dans la partie.'**
  String get menuChooseYourNicknameAndJoinTheGame;

  /// No description provided for @menuNickname.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo'**
  String get menuNickname;

  /// No description provided for @menuChooseANickname.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un pseudo.'**
  String get menuChooseANickname;

  /// No description provided for @menu24CharactersMaximum.
  ///
  /// In fr, this message translates to:
  /// **'24 caractères maximum.'**
  String get menu24CharactersMaximum;

  /// No description provided for @menuEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get menuEmail;

  /// No description provided for @menuEnterAValidEmailAddress.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez une adresse e-mail valide.'**
  String get menuEnterAValidEmailAddress;

  /// No description provided for @menuPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get menuPassword;

  /// No description provided for @menuAtLeast8Characters.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum'**
  String get menuAtLeast8Characters;

  /// No description provided for @menuShowPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get menuShowPassword;

  /// No description provided for @menuHidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get menuHidePassword;

  /// No description provided for @menuUseAtLeast8Characters.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez au moins 8 caractères.'**
  String get menuUseAtLeast8Characters;

  /// No description provided for @menuCreateMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get menuCreateMyAccount;

  /// No description provided for @menuAlreadyHaveAnAccountSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get menuAlreadyHaveAnAccountSignIn;

  /// No description provided for @menuIncorrectEmailOrPassword.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect.'**
  String get menuIncorrectEmailOrPassword;

  /// No description provided for @menuConfirmYourEmailAddressBeforeSigningIn.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre adresse e-mail avant de vous connecter.'**
  String get menuConfirmYourEmailAddressBeforeSigningIn;

  /// No description provided for @menuUnableToSignInCheckYourDetailsAndTry.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible. Vérifiez vos informations et réessayez.'**
  String get menuUnableToSignInCheckYourDetailsAndTry;

  /// No description provided for @menuYourTableIsWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Votre table vous attend.'**
  String get menuYourTableIsWaiting;

  /// No description provided for @menuEnterYourPassword.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre mot de passe.'**
  String get menuEnterYourPassword;

  /// No description provided for @menuSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get menuSignIn;

  /// No description provided for @menuPlayAsAGuest.
  ///
  /// In fr, this message translates to:
  /// **'Jouer en tant qu’invité'**
  String get menuPlayAsAGuest;

  /// No description provided for @menuNoAccountYetSignUp.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? S\'inscrire'**
  String get menuNoAccountYetSignUp;

  /// No description provided for @menuQuestsUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Quêtes indisponibles'**
  String get menuQuestsUnavailable;

  /// No description provided for @menuClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get menuClose;

  /// No description provided for @menuANewWeekNewChallenges.
  ///
  /// In fr, this message translates to:
  /// **'Une nouvelle semaine, de nouveaux défis.'**
  String get menuANewWeekNewChallenges;

  /// No description provided for @menuResetsOnMondayAt0000UTCXPRewards.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialisation le lundi à 00 h UTC. Les récompenses XP sont attribuées automatiquement.'**
  String get menuResetsOnMondayAt0000UTCXPRewards;

  /// No description provided for @menuNewChallengesComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'De nouveaux défis arrivent bientôt.'**
  String get menuNewChallengesComingSoon;

  /// No description provided for @menuArg0XPRewardReceived.
  ///
  /// In fr, this message translates to:
  /// **'+{arg0} XP · Récompense reçue'**
  String menuArg0XPRewardReceived(String arg0);

  /// No description provided for @menuRewardReceived.
  ///
  /// In fr, this message translates to:
  /// **'Récompense reçue'**
  String get menuRewardReceived;

  /// No description provided for @menuArg0XP.
  ///
  /// In fr, this message translates to:
  /// **'+{arg0} XP'**
  String menuArg0XP(String arg0);

  /// No description provided for @menuXPRewardUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Récompense XP indisponible'**
  String get menuXPRewardUnavailable;

  /// No description provided for @menuTierArg0Arg1.
  ///
  /// In fr, this message translates to:
  /// **'Palier {arg0}, {arg1}'**
  String menuTierArg0Arg1(String arg0, String arg1);

  /// No description provided for @menuNextGoal.
  ///
  /// In fr, this message translates to:
  /// **'prochain objectif'**
  String get menuNextGoal;

  /// No description provided for @menuLocked.
  ///
  /// In fr, this message translates to:
  /// **'verrouillé'**
  String get menuLocked;

  /// No description provided for @menuVIP.
  ///
  /// In fr, this message translates to:
  /// **'VIP'**
  String get menuVIP;

  /// No description provided for @menuFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuite'**
  String get menuFree;

  /// No description provided for @menuNoReward.
  ///
  /// In fr, this message translates to:
  /// **'Aucune récompense'**
  String get menuNoReward;

  /// No description provided for @menuEarned.
  ///
  /// In fr, this message translates to:
  /// **'Acquis'**
  String get menuEarned;

  /// No description provided for @menuNextGoal189.
  ///
  /// In fr, this message translates to:
  /// **'Prochain objectif'**
  String get menuNextGoal189;

  /// No description provided for @menuLevelArg0.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {arg0}'**
  String menuLevelArg0(String arg0);

  /// No description provided for @menuVIPRequired.
  ///
  /// In fr, this message translates to:
  /// **'VIP requis'**
  String get menuVIPRequired;

  /// No description provided for @menuSeasonEnded.
  ///
  /// In fr, this message translates to:
  /// **'Saison terminée'**
  String get menuSeasonEnded;

  /// No description provided for @menuPleaseWait.
  ///
  /// In fr, this message translates to:
  /// **'Patientez…'**
  String get menuPleaseWait;

  /// No description provided for @menuClaim.
  ///
  /// In fr, this message translates to:
  /// **'Récupérer'**
  String get menuClaim;

  /// No description provided for @menuArg0Coins195.
  ///
  /// In fr, this message translates to:
  /// **', {arg0} pièces'**
  String menuArg0Coins195(String arg0);

  /// No description provided for @menuPreviewOnlyCosmeticNotYetDefinedOrAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu uniquement : cosmétique à définir, non distribué actuellement.'**
  String get menuPreviewOnlyCosmeticNotYetDefinedOrAvailable;

  /// No description provided for @menuUpcomingCosmetic.
  ///
  /// In fr, this message translates to:
  /// **'Cosmétique à venir'**
  String get menuUpcomingCosmetic;

  /// No description provided for @menuGoldCardBack.
  ///
  /// In fr, this message translates to:
  /// **'Dos Or'**
  String get menuGoldCardBack;

  /// No description provided for @menuRubyTableFelt.
  ///
  /// In fr, this message translates to:
  /// **'Tapis Rubis'**
  String get menuRubyTableFelt;

  /// No description provided for @menuActionUnavailableTryAgainShortly.
  ///
  /// In fr, this message translates to:
  /// **'Action indisponible. Réessayez dans quelques instants.'**
  String get menuActionUnavailableTryAgainShortly;

  /// No description provided for @menuPassUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Pass indisponible.'**
  String get menuPassUnavailable;

  /// No description provided for @menuNoActiveSeason.
  ///
  /// In fr, this message translates to:
  /// **'Aucune saison en cours'**
  String get menuNoActiveSeason;

  /// No description provided for @menuDemoCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier de démonstration'**
  String get menuDemoCalendar;

  /// No description provided for @menuArg0Arg1TiersUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} / {arg1} paliers débloqués'**
  String menuArg0Arg1TiersUnlocked(String arg0, String arg1);

  /// No description provided for @menuAllTiersUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'Tous les paliers sont débloqués !'**
  String get menuAllTiersUnlocked;

  /// No description provided for @menuNextGoalTierArg0.
  ///
  /// In fr, this message translates to:
  /// **'Prochain objectif : palier {arg0}'**
  String menuNextGoalTierArg0(String arg0);

  /// No description provided for @menuArg0XPLeftToReachIt.
  ///
  /// In fr, this message translates to:
  /// **'Encore {arg0} XP pour l’atteindre.'**
  String menuArg0XPLeftToReachIt(String arg0);

  /// No description provided for @menuTapAnUnlockedRewardToClaimItAFree.
  ///
  /// In fr, this message translates to:
  /// **'Touchez une récompense débloquée pour la récupérer. Une récompense gratuite tous les 5 paliers ; une récompense VIP à chaque palier.'**
  String get menuTapAnUnlockedRewardToClaimItAFree;

  /// No description provided for @menuRewardPath.
  ///
  /// In fr, this message translates to:
  /// **'Route des récompenses'**
  String get menuRewardPath;

  /// No description provided for @menuReached.
  ///
  /// In fr, this message translates to:
  /// **'Atteint'**
  String get menuReached;

  /// No description provided for @menuGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get menuGoal;

  /// No description provided for @menuComingUp.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get menuComingUp;

  /// No description provided for @menuRewardAlreadyReceived.
  ///
  /// In fr, this message translates to:
  /// **'Récompense déjà reçue'**
  String get menuRewardAlreadyReceived;

  /// No description provided for @menuArg0CoinsReceivedArg1.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} pièces reçues{arg1}'**
  String menuArg0CoinsReceivedArg1(String arg0, String arg1);

  /// No description provided for @menuCosmeticUnlocked.
  ///
  /// In fr, this message translates to:
  /// **' · Cosmétique débloqué'**
  String get menuCosmeticUnlocked;

  /// No description provided for @menuPREMIUM.
  ///
  /// In fr, this message translates to:
  /// **'PREMIUM'**
  String get menuPREMIUM;

  /// No description provided for @menuYourVIPPassIsActive.
  ///
  /// In fr, this message translates to:
  /// **'Votre Pass VIP est actif'**
  String get menuYourVIPPassIsActive;

  /// No description provided for @menuUnlockTheVIPPass.
  ///
  /// In fr, this message translates to:
  /// **'Débloquez le Pass VIP'**
  String get menuUnlockTheVIPPass;

  /// No description provided for @menuNoAds.
  ///
  /// In fr, this message translates to:
  /// **'Sans publicités'**
  String get menuNoAds;

  /// No description provided for @menuVIPPassTrack.
  ///
  /// In fr, this message translates to:
  /// **'Voie VIP du Pass'**
  String get menuVIPPassTrack;

  /// No description provided for @menuXP2.
  ///
  /// In fr, this message translates to:
  /// **'XP ×2'**
  String get menuXP2;

  /// No description provided for @menuCoinsCanOnlyBeEarnedThroughTheSeasonPass.
  ///
  /// In fr, this message translates to:
  /// **'Les pièces se gagnent uniquement dans le Pass de Saison. XP ×2 sur les parties et les quêtes.'**
  String get menuCoinsCanOnlyBeEarnedThroughTheSeasonPass;

  /// No description provided for @menuVIPIsTemporarilyUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Le VIP est momentanément indisponible.'**
  String get menuVIPIsTemporarilyUnavailable;

  /// No description provided for @menuVIPActive.
  ///
  /// In fr, this message translates to:
  /// **'VIP actif'**
  String get menuVIPActive;

  /// No description provided for @menuVIPComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'VIP bientôt disponible'**
  String get menuVIPComingSoon;

  /// No description provided for @menuBecomeVIPArg0Month.
  ///
  /// In fr, this message translates to:
  /// **'Devenir VIP · {arg0}/mois'**
  String menuBecomeVIPArg0Month(String arg0);

  /// No description provided for @menuMonthlySubscriptionWithAutomaticRenewalCancelThroughYourApp.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement mensuel renouvelé automatiquement. Annulable depuis votre store.'**
  String get menuMonthlySubscriptionWithAutomaticRenewalCancelThroughYourApp;

  /// No description provided for @menuRestorePurchases.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer mes achats'**
  String get menuRestorePurchases;

  /// No description provided for @menuNotEnoughCoinsForThisItem.
  ///
  /// In fr, this message translates to:
  /// **'Fonds insuffisants pour cet article.'**
  String get menuNotEnoughCoinsForThisItem;

  /// No description provided for @menuThisItemIsAlreadyInYourInventory.
  ///
  /// In fr, this message translates to:
  /// **'Cet article est déjà dans votre inventaire.'**
  String get menuThisItemIsAlreadyInYourInventory;

  /// No description provided for @menuThePriceHasChangedTheShopHasBeenRefreshed.
  ///
  /// In fr, this message translates to:
  /// **'Le prix a changé. La boutique a été actualisée.'**
  String get menuThePriceHasChangedTheShopHasBeenRefreshed;

  /// No description provided for @menuThisItemIsNoLongerAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Cet article n’est plus disponible.'**
  String get menuThisItemIsNoLongerAvailable;

  /// No description provided for @menuPurchaseFailedTryAgainShortly.
  ///
  /// In fr, this message translates to:
  /// **'Achat impossible. Réessayez dans quelques instants.'**
  String get menuPurchaseFailedTryAgainShortly;

  /// No description provided for @menuArg0AddedToYourInventory.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} ajouté à votre inventaire'**
  String menuArg0AddedToYourInventory(String arg0);

  /// No description provided for @menuOutfits.
  ///
  /// In fr, this message translates to:
  /// **'Tenues'**
  String get menuOutfits;

  /// No description provided for @menuCardBacks.
  ///
  /// In fr, this message translates to:
  /// **'Dos de cartes'**
  String get menuCardBacks;

  /// No description provided for @menuHeadwear.
  ///
  /// In fr, this message translates to:
  /// **'Couvre-chefs'**
  String get menuHeadwear;

  /// No description provided for @menuGlasses.
  ///
  /// In fr, this message translates to:
  /// **'Lunettes'**
  String get menuGlasses;

  /// No description provided for @menuHair.
  ///
  /// In fr, this message translates to:
  /// **'Cheveux'**
  String get menuHair;

  /// No description provided for @menuQuickChats.
  ///
  /// In fr, this message translates to:
  /// **'Quick Chats'**
  String get menuQuickChats;

  /// No description provided for @menuShopUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Boutique indisponible.'**
  String get menuShopUnavailable;

  /// No description provided for @menuNewItemsComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'De nouveaux articles arrivent bientôt.'**
  String get menuNewItemsComingSoon;

  /// No description provided for @menuOwned.
  ///
  /// In fr, this message translates to:
  /// **'Possédé'**
  String get menuOwned;

  /// No description provided for @menuBuyArg0Arg1Coins.
  ///
  /// In fr, this message translates to:
  /// **'Acheter {arg0}, {arg1} pièces'**
  String menuBuyArg0Arg1Coins(String arg0, String arg1);

  /// No description provided for @menuBuying.
  ///
  /// In fr, this message translates to:
  /// **'Achat…'**
  String get menuBuying;

  /// No description provided for @menuBuy.
  ///
  /// In fr, this message translates to:
  /// **'Acheter'**
  String get menuBuy;

  /// No description provided for @menuUnableToCompleteThisActionCheckYourConnectionOr.
  ///
  /// In fr, this message translates to:
  /// **'Action impossible. Vérifiez votre connexion ou réessayez.'**
  String get menuUnableToCompleteThisActionCheckYourConnectionOr;

  /// No description provided for @menuYourFriend.
  ///
  /// In fr, this message translates to:
  /// **'votre ami'**
  String get menuYourFriend;

  /// No description provided for @menuInvitationSentArg0.
  ///
  /// In fr, this message translates to:
  /// **'Invitation envoyée : {arg0}'**
  String menuInvitationSentArg0(String arg0);

  /// No description provided for @menuInAGame.
  ///
  /// In fr, this message translates to:
  /// **'Dans une partie'**
  String get menuInAGame;

  /// No description provided for @menuOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get menuOnline;

  /// No description provided for @menuOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get menuOffline;

  /// No description provided for @menuInviteToPlay.
  ///
  /// In fr, this message translates to:
  /// **'Inviter à jouer'**
  String get menuInviteToPlay;

  /// No description provided for @menuFriendOptions.
  ///
  /// In fr, this message translates to:
  /// **'Options de l’ami'**
  String get menuFriendOptions;

  /// No description provided for @menuRemoveFriend.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de mes amis'**
  String get menuRemoveFriend;

  /// No description provided for @menuFriendsPrivateRooms.
  ///
  /// In fr, this message translates to:
  /// **'Amis & Salons Privés'**
  String get menuFriendsPrivateRooms;

  /// No description provided for @menuRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get menuRequests;

  /// No description provided for @menuBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Bloqués'**
  String get menuBlocked;

  /// No description provided for @menuSearchForANickname.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un pseudo'**
  String get menuSearchForANickname;

  /// No description provided for @menuSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get menuSearch;

  /// No description provided for @menuNoResultsEnterAtLeast2Characters.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat. Saisissez au moins 2 caractères.'**
  String get menuNoResultsEnterAtLeast2Characters;

  /// No description provided for @menuSendFriendRequest.
  ///
  /// In fr, this message translates to:
  /// **'Demander en ami'**
  String get menuSendFriendRequest;

  /// No description provided for @menuFriendRequestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande d’amitié envoyée'**
  String get menuFriendRequestSent;

  /// No description provided for @menuUnableToLoadFriendsTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les amis. Réessayer'**
  String get menuUnableToLoadFriendsTryAgain;

  /// No description provided for @menuYourListIsEmptySearchForAPlayerTo.
  ///
  /// In fr, this message translates to:
  /// **'Votre liste est vide. Recherchez un joueur pour lui envoyer une demande.'**
  String get menuYourListIsEmptySearchForAPlayerTo;

  /// No description provided for @menuUnableToLoadRequestsTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les demandes. Réessayer'**
  String get menuUnableToLoadRequestsTryAgain;

  /// No description provided for @menuNoPendingRequests.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande en attente.'**
  String get menuNoPendingRequests;

  /// No description provided for @menuReceived.
  ///
  /// In fr, this message translates to:
  /// **'Reçues'**
  String get menuReceived;

  /// No description provided for @menuSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyées'**
  String get menuSent;

  /// No description provided for @menuRequestReceived.
  ///
  /// In fr, this message translates to:
  /// **'Demande reçue'**
  String get menuRequestReceived;

  /// No description provided for @menuRequestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get menuRequestSent;

  /// No description provided for @menuAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get menuAccept;

  /// No description provided for @menuDecline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get menuDecline;

  /// No description provided for @menuCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get menuCancel;

  /// No description provided for @menuUnableToLoadBlockedPlayersTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les blocages. Réessayer'**
  String get menuUnableToLoadBlockedPlayersTryAgain;

  /// No description provided for @menuNoBlockedPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun joueur bloqué.'**
  String get menuNoBlockedPlayers;

  /// No description provided for @menuBlockedPlayer.
  ///
  /// In fr, this message translates to:
  /// **'Joueur bloqué'**
  String get menuBlockedPlayer;

  /// No description provided for @menuPlayerUnblocked.
  ///
  /// In fr, this message translates to:
  /// **'Joueur débloqué'**
  String get menuPlayerUnblocked;

  /// No description provided for @menuUnblock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get menuUnblock;

  /// No description provided for @menuInviteArg0.
  ///
  /// In fr, this message translates to:
  /// **'Inviter {arg0}'**
  String menuInviteArg0(String arg0);

  /// No description provided for @menuChooseHowToPlayTogether.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez comment jouer ensemble.'**
  String get menuChooseHowToPlayTogether;

  /// No description provided for @menuSameTeamAgainstTwoOtherPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Même équipe, face à deux autres joueurs'**
  String get menuSameTeamAgainstTwoOtherPlayers;

  /// No description provided for @menuRoomWithACodeAndTeamSelection.
  ///
  /// In fr, this message translates to:
  /// **'Salon avec code et choix des équipes'**
  String get menuRoomWithACodeAndTeamSelection;

  /// No description provided for @menuLeaveYourCurrentGame.
  ///
  /// In fr, this message translates to:
  /// **'Quittez la partie en cours'**
  String get menuLeaveYourCurrentGame;

  /// No description provided for @menuNavigationUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Navigation indisponible'**
  String get menuNavigationUnavailable;

  /// No description provided for @menuInvitationUnavailableLeaveYourCurrentGameOrTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Invitation indisponible. Quittez votre partie actuelle ou réessayez.'**
  String get menuInvitationUnavailableLeaveYourCurrentGameOrTryAgain;

  /// No description provided for @menuAFriend.
  ///
  /// In fr, this message translates to:
  /// **'Un ami'**
  String get menuAFriend;

  /// No description provided for @menuArg0InvitesYouToPlayArg1.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} vous invite à jouer en {arg1}'**
  String menuArg0InvitesYouToPlayArg1(String arg0, String arg1);

  /// No description provided for @menuYouWillPlayOnTheSameTeam.
  ///
  /// In fr, this message translates to:
  /// **'Vous jouerez dans la même équipe.'**
  String get menuYouWillPlayOnTheSameTeam;

  /// No description provided for @menuChooseYourTeamsInTheRoom.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez vos équipes dans le salon.'**
  String get menuChooseYourTeamsInTheRoom;

  /// No description provided for @menuDecline296.
  ///
  /// In fr, this message translates to:
  /// **'Décliner'**
  String get menuDecline296;

  /// No description provided for @menuNewFriendRequestReceived.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle demande d’amitié reçue'**
  String get menuNewFriendRequestReceived;

  /// No description provided for @menuArg0NewFriendRequests.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} nouvelles demandes d’amitié'**
  String menuArg0NewFriendRequests(String arg0);

  /// No description provided for @menuCloseNotification.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la notification'**
  String get menuCloseNotification;

  /// No description provided for @menuOverallStatistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques globales'**
  String get menuOverallStatistics;

  /// No description provided for @menuCurrentElo.
  ///
  /// In fr, this message translates to:
  /// **'Elo actuel'**
  String get menuCurrentElo;

  /// No description provided for @menuPeakElo.
  ///
  /// In fr, this message translates to:
  /// **'Peak Elo'**
  String get menuPeakElo;

  /// No description provided for @menuNoCompletedGames.
  ///
  /// In fr, this message translates to:
  /// **'Aucune partie terminée'**
  String get menuNoCompletedGames;

  /// No description provided for @menuArg0Wins.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} % de victoires'**
  String menuArg0Wins(String arg0);

  /// No description provided for @menuDetailsByMode.
  ///
  /// In fr, this message translates to:
  /// **'Détails par mode'**
  String get menuDetailsByMode;

  /// No description provided for @menuArg0WinsArg1LossesInArg2Games.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} victoires, {arg1} défaites sur {arg2} parties'**
  String menuArg0WinsArg1LossesInArg2Games(
    String arg0,
    String arg1,
    String arg2,
  );

  /// No description provided for @menuNoGames.
  ///
  /// In fr, this message translates to:
  /// **'Aucune partie'**
  String get menuNoGames;

  /// No description provided for @menuWins.
  ///
  /// In fr, this message translates to:
  /// **'de victoires'**
  String get menuWins;

  /// No description provided for @menuWins309.
  ///
  /// In fr, this message translates to:
  /// **'Victoires'**
  String get menuWins309;

  /// No description provided for @menuLosses.
  ///
  /// In fr, this message translates to:
  /// **'Défaites'**
  String get menuLosses;

  /// No description provided for @menuCasual.
  ///
  /// In fr, this message translates to:
  /// **'Classique'**
  String get menuCasual;

  /// No description provided for @menuRanked.
  ///
  /// In fr, this message translates to:
  /// **'Classé'**
  String get menuRanked;

  /// No description provided for @menuSolo.
  ///
  /// In fr, this message translates to:
  /// **'Solo'**
  String get menuSolo;

  /// No description provided for @menuPrivateRoomsWithHumanPlayersAreIncludedInCasual.
  ///
  /// In fr, this message translates to:
  /// **'Les salons privés entre humains sont inclus dans Classique.'**
  String get menuPrivateRoomsWithHumanPlayersAreIncludedInCasual;

  /// No description provided for @menuArg0OlderGamesWithoutDetailedHistoryAreNotAssigned.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} anciennes parties sans historique détaillé ne sont pas réparties par mode.'**
  String menuArg0OlderGamesWithoutDetailedHistoryAreNotAssigned(String arg0);

  /// No description provided for @menuUnableToSendTheRequestTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’envoyer la demande. Réessayez.'**
  String get menuUnableToSendTheRequestTryAgain;

  /// No description provided for @menuBlockThisPlayer.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer ce joueur ?'**
  String get menuBlockThisPlayer;

  /// No description provided for @menuYourFriendshipWillBeRemovedAndPendingRequestsAnd.
  ///
  /// In fr, this message translates to:
  /// **'Votre amitié sera supprimée et vos demandes et invitations en attente seront annulées. Ce joueur ne pourra plus vous contacter ainsi. Vous pourrez le débloquer depuis l’onglet Bloqués.'**
  String get menuYourFriendshipWillBeRemovedAndPendingRequestsAnd;

  /// No description provided for @menuBlock.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer'**
  String get menuBlock;

  /// No description provided for @menuUnableToUpdateTheBlockTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de modifier le blocage. Réessayez.'**
  String get menuUnableToUpdateTheBlockTryAgain;

  /// No description provided for @menuProfileUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Profil indisponible.'**
  String get menuProfileUnavailable;

  /// No description provided for @menuPlayerProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil du joueur'**
  String get menuPlayerProfile;

  /// No description provided for @menuWinRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux de victoire'**
  String get menuWinRate;

  /// No description provided for @menuGamesPlayed.
  ///
  /// In fr, this message translates to:
  /// **'Parties jouées'**
  String get menuGamesPlayed;

  /// No description provided for @menuArg0WinsArg1Losses.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} victoires · {arg1} défaites'**
  String menuArg0WinsArg1Losses(String arg0, String arg1);

  /// No description provided for @menuAddFriend.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter en ami'**
  String get menuAddFriend;

  /// No description provided for @menuSignInRequired.
  ///
  /// In fr, this message translates to:
  /// **'Connexion requise'**
  String get menuSignInRequired;

  /// No description provided for @menuYourProfile.
  ///
  /// In fr, this message translates to:
  /// **'Votre profil'**
  String get menuYourProfile;

  /// No description provided for @menuSending.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours…'**
  String get menuSending;

  /// No description provided for @menuCheckingFriendship.
  ///
  /// In fr, this message translates to:
  /// **'Vérification de la relation…'**
  String get menuCheckingFriendship;

  /// No description provided for @menuAlreadyFriends.
  ///
  /// In fr, this message translates to:
  /// **'Déjà amis'**
  String get menuAlreadyFriends;

  /// No description provided for @menuCheckFriendshipAgain.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer la relation'**
  String get menuCheckFriendshipAgain;

  /// No description provided for @menuServiceUnavailableTryAgainShortly.
  ///
  /// In fr, this message translates to:
  /// **'Service indisponible. Réessayez dans quelques instants.'**
  String get menuServiceUnavailableTryAgainShortly;

  /// No description provided for @menuDeleteYourAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer votre compte ?'**
  String get menuDeleteYourAccount;

  /// No description provided for @menuYourProfileFriendsAndHistoryWillBePermanentlyDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Votre profil, vos amis et votre historique seront supprimés définitivement. Les achats restent soumis aux règles des stores. Cette action est irréversible.'**
  String get menuYourProfileFriendsAndHistoryWillBePermanentlyDeleted;

  /// No description provided for @menuDeletePermanently.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get menuDeletePermanently;

  /// No description provided for @menuAccountDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé.'**
  String get menuAccountDeleted;

  /// No description provided for @menuGuestAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte invité'**
  String get menuGuestAccount;

  /// No description provided for @menuSignedInAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte connecté'**
  String get menuSignedInAccount;

  /// No description provided for @menuGuest.
  ///
  /// In fr, this message translates to:
  /// **'Invité'**
  String get menuGuest;

  /// No description provided for @menuSignedOut.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion effectuée.'**
  String get menuSignedOut;

  /// No description provided for @menuSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get menuSignOut;

  /// No description provided for @menuDeleteMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get menuDeleteMyAccount;

  /// No description provided for @menuArg0Arg1XP.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} / {arg1} XP'**
  String menuArg0Arg1XP(String arg0, String arg1);

  /// No description provided for @menuLevelArg0ProgressArg1XPOutOf500.
  ///
  /// In fr, this message translates to:
  /// **'Progression du niveau {arg0}, {arg1} XP sur 500'**
  String menuLevelArg0ProgressArg1XPOutOf500(String arg0, String arg1);

  /// No description provided for @menuArg0XPToGoBeforeLevelArg1.
  ///
  /// In fr, this message translates to:
  /// **'Encore {arg0} XP avant le niveau {arg1}'**
  String menuArg0XPToGoBeforeLevelArg1(String arg0, String arg1);

  /// No description provided for @menuChangeNickname.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le pseudo'**
  String get menuChangeNickname;

  /// No description provided for @menuSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get menuSave;

  /// No description provided for @menuProfileUnavailableTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Profil indisponible. Réessayer'**
  String get menuProfileUnavailableTryAgain;

  /// No description provided for @menuPlayerProfile352.
  ///
  /// In fr, this message translates to:
  /// **'Profil Joueur'**
  String get menuPlayerProfile352;

  /// No description provided for @menuEditMyAvatar.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon Avatar'**
  String get menuEditMyAvatar;

  /// No description provided for @menuCustomisation.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisation'**
  String get menuCustomisation;

  /// No description provided for @menuRecentGames.
  ///
  /// In fr, this message translates to:
  /// **'Dernières parties'**
  String get menuRecentGames;

  /// No description provided for @menuReloadHistory.
  ///
  /// In fr, this message translates to:
  /// **'Recharger l’historique'**
  String get menuReloadHistory;

  /// No description provided for @menuYourNextCompletedGamesWillAppearHere.
  ///
  /// In fr, this message translates to:
  /// **'Vos prochaines parties terminées apparaîtront ici.'**
  String get menuYourNextCompletedGamesWillAppearHere;

  /// No description provided for @menuWin.
  ///
  /// In fr, this message translates to:
  /// **'Victoire'**
  String get menuWin;

  /// No description provided for @menuLoss.
  ///
  /// In fr, this message translates to:
  /// **'Défaite'**
  String get menuLoss;

  /// No description provided for @menuPrivate.
  ///
  /// In fr, this message translates to:
  /// **'Privé'**
  String get menuPrivate;

  /// No description provided for @menuEquipmentSavedTryLoadingTheInventoryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Équipement enregistré. Réessayez le chargement de l’inventaire.'**
  String get menuEquipmentSavedTryLoadingTheInventoryAgain;

  /// No description provided for @menuUnableToEquipCheckYourConnectionAndTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Équipement impossible. Vérifiez votre connexion et réessayez.'**
  String get menuUnableToEquipCheckYourConnectionAndTryAgain;

  /// No description provided for @menuInventoryUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire indisponible.'**
  String get menuInventoryUnavailable;

  /// No description provided for @menuTheOriginalBlueCardBackAlwaysAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Le dos bleu d’origine, toujours disponible.'**
  String get menuTheOriginalBlueCardBackAlwaysAvailable;

  /// No description provided for @menuEquipped.
  ///
  /// In fr, this message translates to:
  /// **'Équipé'**
  String get menuEquipped;

  /// No description provided for @menuArg0Equipped.
  ///
  /// In fr, this message translates to:
  /// **'{arg0} équipé'**
  String menuArg0Equipped(String arg0);

  /// No description provided for @menuEquip.
  ///
  /// In fr, this message translates to:
  /// **'Équiper'**
  String get menuEquip;

  /// No description provided for @menuSeasonArg0Arg1.
  ///
  /// In fr, this message translates to:
  /// **'Saison {arg0}/{arg1}'**
  String menuSeasonArg0Arg1(String arg0, String arg1);

  /// No description provided for @menuSeasonEnds.
  ///
  /// In fr, this message translates to:
  /// **'Fin de saison'**
  String get menuSeasonEnds;

  /// No description provided for @menuDays.
  ///
  /// In fr, this message translates to:
  /// **'Jours'**
  String get menuDays;

  /// No description provided for @menuHours.
  ///
  /// In fr, this message translates to:
  /// **'Heures'**
  String get menuHours;

  /// No description provided for @menuMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Minutes'**
  String get menuMinutes;

  /// No description provided for @menuSeconds.
  ///
  /// In fr, this message translates to:
  /// **'Secondes'**
  String get menuSeconds;

  /// No description provided for @menuSeasonEndsInArg0DaysArg1HoursArg2Minutes.
  ///
  /// In fr, this message translates to:
  /// **'Fin de saison dans {arg0} jours, {arg1} heures, {arg2} minutes et {arg3} secondes'**
  String menuSeasonEndsInArg0DaysArg1HoursArg2Minutes(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  );

  /// No description provided for @menuYourSeasonsBestEloDeterminesYourRewardsTiersAre.
  ///
  /// In fr, this message translates to:
  /// **'Votre meilleur Elo de la saison détermine vos récompenses. Les paliers sont cumulatifs.'**
  String get menuYourSeasonsBestEloDeterminesYourRewardsTiersAre;

  /// No description provided for @menuBronzeBorder.
  ///
  /// In fr, this message translates to:
  /// **'Bordure Bronze'**
  String get menuBronzeBorder;

  /// No description provided for @menuSilverBorder.
  ///
  /// In fr, this message translates to:
  /// **'Bordure Argent'**
  String get menuSilverBorder;

  /// No description provided for @menuGoldBorder.
  ///
  /// In fr, this message translates to:
  /// **'Bordure Or'**
  String get menuGoldBorder;

  /// No description provided for @menuTxapelaBeret.
  ///
  /// In fr, this message translates to:
  /// **'Txapela (béret)'**
  String get menuTxapelaBeret;

  /// No description provided for @menuAtTheMonthlyCloseEloAndPeakEloReset.
  ///
  /// In fr, this message translates to:
  /// **'À la clôture mensuelle, l’Elo et le Peak Elo reviennent à 800. Vos cosmétiques restent acquis : équipez-les dans Modifier mon Avatar → Bordures / Trophées.'**
  String get menuAtTheMonthlyCloseEloAndPeakEloReset;

  /// No description provided for @menuSkin.
  ///
  /// In fr, this message translates to:
  /// **'Peau'**
  String get menuSkin;

  /// No description provided for @menuTop.
  ///
  /// In fr, this message translates to:
  /// **'Haut'**
  String get menuTop;

  /// No description provided for @menuBackgroundColour.
  ///
  /// In fr, this message translates to:
  /// **'Couleur de fond'**
  String get menuBackgroundColour;

  /// No description provided for @menuHairColour.
  ///
  /// In fr, this message translates to:
  /// **'Couleur cheveux'**
  String get menuHairColour;

  /// No description provided for @menuBorders.
  ///
  /// In fr, this message translates to:
  /// **'Bordures'**
  String get menuBorders;

  /// No description provided for @menuNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get menuNone;

  /// No description provided for @menuBronze.
  ///
  /// In fr, this message translates to:
  /// **'Bronze'**
  String get menuBronze;

  /// No description provided for @menuSilver.
  ///
  /// In fr, this message translates to:
  /// **'Argent'**
  String get menuSilver;

  /// No description provided for @menuDiamond.
  ///
  /// In fr, this message translates to:
  /// **'Diamant'**
  String get menuDiamond;

  /// No description provided for @menuNone391.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get menuNone391;

  /// No description provided for @menuTxapela.
  ///
  /// In fr, this message translates to:
  /// **'Txapela'**
  String get menuTxapela;

  /// No description provided for @menuCrown.
  ///
  /// In fr, this message translates to:
  /// **'Couronne'**
  String get menuCrown;

  /// No description provided for @menuCap.
  ///
  /// In fr, this message translates to:
  /// **'Casquette'**
  String get menuCap;

  /// No description provided for @menuBeanie.
  ///
  /// In fr, this message translates to:
  /// **'Bonnet'**
  String get menuBeanie;

  /// No description provided for @menuBald.
  ///
  /// In fr, this message translates to:
  /// **'Chauve'**
  String get menuBald;

  /// No description provided for @menuMohawk.
  ///
  /// In fr, this message translates to:
  /// **'Crête'**
  String get menuMohawk;

  /// No description provided for @menuGoldFrames.
  ///
  /// In fr, this message translates to:
  /// **'Monture dorée'**
  String get menuGoldFrames;

  /// No description provided for @menuRound.
  ///
  /// In fr, this message translates to:
  /// **'Rondes'**
  String get menuRound;

  /// No description provided for @menuStripedShirt.
  ///
  /// In fr, this message translates to:
  /// **'Maillot rayé'**
  String get menuStripedShirt;

  /// No description provided for @menuUnableToSaveCheckYourConnectionAndTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde impossible. Vérifiez votre connexion et réessayez.'**
  String get menuUnableToSaveCheckYourConnectionAndTryAgain;

  /// No description provided for @menuSaving.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde…'**
  String get menuSaving;

  /// No description provided for @menuSave403.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get menuSave403;

  /// No description provided for @menuAvatarSkinArg0HairArg1GlassesArg2TopArg3.
  ///
  /// In fr, this message translates to:
  /// **'Avatar : peau {arg0}, cheveux {arg1}, lunettes {arg2}, haut {arg3}'**
  String menuAvatarSkinArg0HairArg1GlassesArg2TopArg3(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  );

  /// No description provided for @menuBrightRed.
  ///
  /// In fr, this message translates to:
  /// **'Rouge vif'**
  String get menuBrightRed;

  /// No description provided for @menuOrange.
  ///
  /// In fr, this message translates to:
  /// **'Orange'**
  String get menuOrange;

  /// No description provided for @menuSunshineYellow.
  ///
  /// In fr, this message translates to:
  /// **'Jaune soleil'**
  String get menuSunshineYellow;

  /// No description provided for @menuAppleGreen.
  ///
  /// In fr, this message translates to:
  /// **'Vert pomme'**
  String get menuAppleGreen;

  /// No description provided for @menuPineGreen.
  ///
  /// In fr, this message translates to:
  /// **'Vert sapin'**
  String get menuPineGreen;

  /// No description provided for @menuCyan.
  ///
  /// In fr, this message translates to:
  /// **'Cyan'**
  String get menuCyan;

  /// No description provided for @menuNavyBlue.
  ///
  /// In fr, this message translates to:
  /// **'Bleu marine'**
  String get menuNavyBlue;

  /// No description provided for @menuDeepPurple.
  ///
  /// In fr, this message translates to:
  /// **'Violet profond'**
  String get menuDeepPurple;

  /// No description provided for @menuFuchsiaPink.
  ///
  /// In fr, this message translates to:
  /// **'Rose fuchsia'**
  String get menuFuchsiaPink;

  /// No description provided for @menuBrown.
  ///
  /// In fr, this message translates to:
  /// **'Marron'**
  String get menuBrown;

  /// No description provided for @menuLightGrey.
  ///
  /// In fr, this message translates to:
  /// **'Gris clair'**
  String get menuLightGrey;

  /// No description provided for @menuCharcoal.
  ///
  /// In fr, this message translates to:
  /// **'Anthracite'**
  String get menuCharcoal;

  /// No description provided for @menuBrunette.
  ///
  /// In fr, this message translates to:
  /// **'Brun'**
  String get menuBrunette;

  /// No description provided for @menuBlonde.
  ///
  /// In fr, this message translates to:
  /// **'Blond'**
  String get menuBlonde;

  /// No description provided for @menuBlack.
  ///
  /// In fr, this message translates to:
  /// **'Noir'**
  String get menuBlack;

  /// No description provided for @menuCopper.
  ///
  /// In fr, this message translates to:
  /// **'Cuivré'**
  String get menuCopper;

  /// No description provided for @menuPurple.
  ///
  /// In fr, this message translates to:
  /// **'Violet'**
  String get menuPurple;

  /// No description provided for @menuFrenchMusChampionshipRegulations.
  ///
  /// In fr, this message translates to:
  /// **'Règlement du Championnat de France de Mus'**
  String get menuFrenchMusChampionshipRegulations;

  /// No description provided for @menuFederationFrancaiseDeMus.
  ///
  /// In fr, this message translates to:
  /// **'Fédération Française de Mus'**
  String get menuFederationFrancaiseDeMus;

  /// No description provided for @menuLastRevisedJanuary2023.
  ///
  /// In fr, this message translates to:
  /// **'Dernières modifications : janvier 2023.'**
  String get menuLastRevisedJanuary2023;

  /// No description provided for @menuPrinciplesAndRankings.
  ///
  /// In fr, this message translates to:
  /// **'Principes et classement'**
  String get menuPrinciplesAndRankings;

  /// No description provided for @menuMusIsPlayedInTeamsOf2WithA.
  ///
  /// In fr, this message translates to:
  /// **'Le Mus se joue par équipes de 2 joueurs, avec un jeu espagnol de 40 cartes, en 3 manches de 40 Points (40 tantto ou 8 hamarreko), sauf exception.'**
  String get menuMusIsPlayedInTeamsOf2WithA;

  /// No description provided for @menuRankingsAreCalculatedAsFollows3RoundsWon1.
  ///
  /// In fr, this message translates to:
  /// **'Le classement s\'opère comme suit: 3 manches gagnées = 1 victoire.'**
  String get menuRankingsAreCalculatedAsFollows3RoundsWon1;

  /// No description provided for @menuAWinnerOneWinIsCountedRegardlessOfRounds.
  ///
  /// In fr, this message translates to:
  /// **'a) Vainqueur : on compte une victoire, sans tenir compte des manches perdues ni des points réalisés au cours de ces manches.'**
  String get menuAWinnerOneWinIsCountedRegardlessOfRounds;

  /// No description provided for @menuBLoser0WinsAreCountedAlongWithRounds.
  ///
  /// In fr, this message translates to:
  /// **'b) Perdant : on compte 0 victoire, le nombre de manches gagnées et les points réalisés au cours des manches perdues seulement.'**
  String get menuBLoser0WinsAreCountedAlongWithRounds;

  /// No description provided for @menuForTheFirstDealThePlayerWhoDrewThe.
  ///
  /// In fr, this message translates to:
  /// **'Pour la première distribution, le joueur ayant tiré la plus petite carte donne. Il doit mélanger les cartes et les faire couper par son adversaire de gauche qui devra laisser plus d\'une carte en haut ou en bas de sa coupe. Le donneur distribue les cartes une à une, par le dessus, en commençant par son adversaire de droite qui aura la main (Esku), à charge à chaque joueur de vérifier le nombre de cartes qu\'il reçoit. Les joueurs peuvent regarder les cartes avant la fin de la donne.'**
  String get menuForTheFirstDealThePlayerWhoDrewThe;

  /// No description provided for @menuIfACardIsTurnedOverDuringTheFirst.
  ///
  /// In fr, this message translates to:
  /// **'Si au cours de la première distribution une carte est retournée ou si l\'on constate toute autre anomalie (plus ou moins de 4 cartes, etc...), on ramasse tout, on bat, on coupe et on recommence.'**
  String get menuIfACardIsTurnedOverDuringTheFirst;

  /// No description provided for @menuIfTheErrorIsFoundAfterPlayHasBegun.
  ///
  /// In fr, this message translates to:
  /// **'Si l\'erreur est décelée lorsque le jeu est commencé, c\'est-à-dire après qu\'un joueur soit sorti, le joueur qui a plus ou moins de quatre cartes n\'entrera pas dans le jeu et on annulera les points tirés par son équipe.'**
  String get menuIfTheErrorIsFoundAfterPlayHasBegun;

  /// No description provided for @menuIfACardIsTurnedOverAfterMusHas.
  ///
  /// In fr, this message translates to:
  /// **'Si après avoir été Mus une fois, une carte est retournée, le jeu continue normalement.'**
  String get menuIfACardIsTurnedOverAfterMusHas;

  /// No description provided for @menuEskuAndTheirPartnerDecideWhetherToStopWith.
  ///
  /// In fr, this message translates to:
  /// **'Le « Esku » et son partenaire décident s\'ils sortent « Mintza » ou s\'ils vont « Mus » en disant « Zuetan ou A vous». A leur tour, leurs adversaires en feront autant.'**
  String get menuEskuAndTheirPartnerDecideWhetherToStopWith;

  /// No description provided for @menuIfThereIsMusAll4PlayersDiscardThe.
  ///
  /// In fr, this message translates to:
  /// **'S’il y a Mus les 4 joueurs se débarrasseront du nombre de cartes désiré, d\'un seul coup, et le «ESKU», en premier. Le donneur distribuera alors les nouvelles cartes en une seule fois, à chaque joueur.'**
  String get menuIfThereIsMusAll4PlayersDiscardThe;

  /// No description provided for @menuPlayBeginsWithESKUFirstHighThenLowPairs.
  ///
  /// In fr, this message translates to:
  /// **'Pour démarrer le jeu, et toujours le « ESKU » en premier, on joue d\' abord le Grand, puis le Petit, les Paires, le Jeu ou le Point. Les enchères « Biak Embido » ou « Biak Hordago » étant tolérées.'**
  String get menuPlayBeginsWithESKUFirstHighThenLowPairs;

  /// No description provided for @menuTiraIdukiAndHordagoBindTheTeamTheSpeakers.
  ///
  /// In fr, this message translates to:
  /// **'Les mots Tira, Iduki ou Hordago bloquent le jeu et le partenaire de celui qui les prononce ne peut les désavouer, même s\'il est « Esku ». On admet aussi bien « Nere gatik tira » que « Tira nere gatik » ou « Pour moi tirez » qui laisse au partenaire le droit de surenchérir. Quand les 2 partenaires tapent ou surenchérissent, la décision de celui qui parle en premier est retenue. Après un « Hordago Kanta » aucun point (tantto) ne sera tiré.'**
  String get menuTiraIdukiAndHordagoBindTheTeamTheSpeakers;

  /// No description provided for @menuSigns.
  ///
  /// In fr, this message translates to:
  /// **'Signes'**
  String get menuSigns;

  /// No description provided for @menuOnlyTheFollowingOfficialSignsAreAllowed.
  ///
  /// In fr, this message translates to:
  /// **'Seuls les signes réglementaires suivants sont admis :'**
  String get menuOnlyTheFollowingOfficialSignsAreAllowed;

  /// No description provided for @menu2KingsLowerLip.
  ///
  /// In fr, this message translates to:
  /// **'2 rois : lèvre inférieure.'**
  String get menu2KingsLowerLip;

  /// No description provided for @menu2AcesStickOutTheTongue.
  ///
  /// In fr, this message translates to:
  /// **'2 as : tirer la langue.'**
  String get menu2AcesStickOutTheTongue;

  /// No description provided for @menuMediakMoveOneSideOfTheLips.
  ///
  /// In fr, this message translates to:
  /// **'Mediak : remuer un côté des lèvres.'**
  String get menuMediakMoveOneSideOfTheLips;

  /// No description provided for @menuDobliakMoveBothSidesOfTheLips.
  ///
  /// In fr, this message translates to:
  /// **'Dobliak : remuer les 2 côtés des lèvres.'**
  String get menuDobliakMoveBothSidesOfTheLips;

  /// No description provided for @menu29SameAsMediak.
  ///
  /// In fr, this message translates to:
  /// **'29 : comme les mediak.'**
  String get menu29SameAsMediak;

  /// No description provided for @menu30Or31Wink.
  ///
  /// In fr, this message translates to:
  /// **'30 ou 31 : cligner d’un œil.'**
  String get menu30Or31Wink;

  /// No description provided for @menuGameRaiseTheEyebrows.
  ///
  /// In fr, this message translates to:
  /// **'Le jeu : lever les sourcils.'**
  String get menuGameRaiseTheEyebrows;

  /// No description provided for @menuTheSignFor30Or31MayBeMade.
  ///
  /// In fr, this message translates to:
  /// **'Le signe du 30 ou du 31 peut se faire à tout moment. Le 29 par contre ne peut être passé qu’après en avoir terminé avec les paires. Le signe du jeu est interdit si on a 31.'**
  String get menuTheSignFor30Or31MayBeMade;

  /// No description provided for @menuDoublePairs.
  ///
  /// In fr, this message translates to:
  /// **'Doubles'**
  String get menuDoublePairs;

  /// No description provided for @menuWhen2OpponentsHaveDoublePairsWithTheSame.
  ///
  /// In fr, this message translates to:
  /// **'Lorsque 2 adversaires ont des doubles avec paire supérieure égale, celui qui a la paire inférieure la plus forte l\'emporte dans tous les cas. Exemple : 2 onze + 2 sept même en dernière main sont supérieurs à 2 onze + 2 six'**
  String get menuWhen2OpponentsHaveDoublePairsWithTheSame;

  /// No description provided for @menuErrors.
  ///
  /// In fr, this message translates to:
  /// **'Erreurs'**
  String get menuErrors;

  /// No description provided for @menuAnnouncingPairsWithoutHavingAny.
  ///
  /// In fr, this message translates to:
  /// **'Annoncer des paires si on n\'en a pas :'**
  String get menuAnnouncingPairsWithoutHavingAny;

  /// No description provided for @menuAIfThePartnerHasNoneAllBetsOn.
  ///
  /// In fr, this message translates to:
  /// **'a) Si le partenaire n\'en a pas, on annule tout pari fait sur les paires. Bien entendu, l\'adversaire compte les points de sa ou de ses paires.'**
  String get menuAIfThePartnerHasNoneAllBetsOn;

  /// No description provided for @menuBIfThePartnerHasPairsAndTheOpponents.
  ///
  /// In fr, this message translates to:
  /// **'b) Si le partenaire en a, et les adversaires aussi, tout pari aux paires sera annulé, l\'adversaire comptant le « TIRA» des paires et les points de sa ou de ses paires.'**
  String get menuBIfThePartnerHasPairsAndTheOpponents;

  /// No description provided for @menuFailingToAnnouncePairsWhenHoldingThem.
  ///
  /// In fr, this message translates to:
  /// **'Ne pas annoncer de paires si on en a :'**
  String get menuFailingToAnnouncePairsWhenHoldingThem;

  /// No description provided for @menuUnannouncedPairsCannotBeUsedToBetCallOr.
  ///
  /// In fr, this message translates to:
  /// **'Ces paires niées ne valent ni pour taper, ni pour tenir, ni pour les compter ensuite.'**
  String get menuUnannouncedPairsCannotBeUsedToBetCallOr;

  /// No description provided for @menuIfThePartnerHasNoPairsAnOpponentWith.
  ///
  /// In fr, this message translates to:
  /// **'Si le partenaire n\'a pas de paires, l\'adversaire, s\'il a aussi des paires, tirera un point du «Tira».'**
  String get menuIfThePartnerHasNoPairsAnOpponentWith;

  /// No description provided for @menuAnnouncingGameWithoutHavingIt.
  ///
  /// In fr, this message translates to:
  /// **'Annoncer le jeu si on ne l\'a pas :'**
  String get menuAnnouncingGameWithoutHavingIt;

  /// No description provided for @menuAIfNoneOfTheOther3PlayersHas.
  ///
  /// In fr, this message translates to:
  /// **'a) Si aucun des 3 autres joueurs n\'a le jeu, les adversaires tireront le « Tira» du point, et le point du « Pontua ».'**
  String get menuAIfNoneOfTheOther3PlayersHas;

  /// No description provided for @menuBIfThePartnerHasGameAndTheOpponents.
  ///
  /// In fr, this message translates to:
  /// **'b) Si le partenaire a le jeu et les adversaires pas, on ne tient pas compte de l\'erreur.'**
  String get menuBIfThePartnerHasGameAndTheOpponents;

  /// No description provided for @menuCIfThePartnerHasNoGameButAn.
  ///
  /// In fr, this message translates to:
  /// **'c) Si le partenaire n\'a pas le jeu et l\'adversaire oui, on annule les paris fait, au jeu, et l\'adversaire tirera les points correspondants à son jeu.'**
  String get menuCIfThePartnerHasNoGameButAn;

  /// No description provided for @menuDIfThePartnerAndAnOpponentBothHave.
  ///
  /// In fr, this message translates to:
  /// **'d) Si son partenaire a le jeu et l\'un des adversaires aussi, on annule les paris faits au jeu et l\'adversaire tirera le « TIRA» du jeu et les points correspondants à son jeu.'**
  String get menuDIfThePartnerAndAnOpponentBothHave;

  /// No description provided for @menuFailingToAnnounceGameWhenHoldingIt.
  ///
  /// In fr, this message translates to:
  /// **'Ne pas annoncer le jeu si on l\'a :'**
  String get menuFailingToAnnounceGameWhenHoldingIt;

  /// No description provided for @menuAIfNoneOfTheOther3PlayersHas465.
  ///
  /// In fr, this message translates to:
  /// **'a) Si aucun des 3 autres joueurs n\'a le jeu, on annulera les paris faits au point, et l\'adversaire tirera le ttantto du Tira et le point du Pontua. Le jeu non annoncé ne comptera pas.'**
  String get menuAIfNoneOfTheOther3PlayersHas465;

  /// No description provided for @menuBIfThePartnerHasGameAndTheOpponents466.
  ///
  /// In fr, this message translates to:
  /// **'b) Si le partenaire a le jeu et les adversaires pas, seul le jeu du partenaire sera compté.'**
  String get menuBIfThePartnerHasGameAndTheOpponents466;

  /// No description provided for @menuCIfThePartnerHasNoGameAndAn.
  ///
  /// In fr, this message translates to:
  /// **'c) Si le partenaire n\'a pas le jeu et l\'adversaire oui, ce dernier comptera le « TIRA» du jeu et les points du jeu qui lui reviennent. Le joueur qui n\'a pas de paires ou de jeu ne peut pas taper ni surenchérir à la place de son partenaire qui en a.'**
  String get menuCIfThePartnerHasNoGameAndAn;

  /// No description provided for @menuScoringAndRaises.
  ///
  /// In fr, this message translates to:
  /// **'Décompte et relances'**
  String get menuScoringAndRaises;

  /// No description provided for @menuDuringPlayPointsConcededThroughTIRAAreScoredAs.
  ///
  /// In fr, this message translates to:
  /// **'En cours de jeu, les points laissés « TIRA » se tirent au fur et à mesure. En cas d\'égalité parfaite, le «ESKU» l\'emporte dans tous les cas de figure. A la fin de chaque tour de jeu, les quatre joueurs doivent étaler toutes leurs cartes sur la table.'**
  String get menuDuringPlayPointsConcededThroughTIRAAreScoredAs;

  /// No description provided for @menuScoreHighThenLowPairsGameOrPointAs.
  ///
  /// In fr, this message translates to:
  /// **'On compte alors le Grand, puis le Petit, les Paires, le Jeu ou le Point sur les bases suivantes:'**
  String get menuScoreHighThenLowPairsGameOrPointAs;

  /// No description provided for @menuHighIfEveryoneSaidPASOTheBestHighScores.
  ///
  /// In fr, this message translates to:
  /// **'Grand : S\'il n\'y a eu que PASO, celui qui a le meilleur Grand compte 1 point (Haundi Pasa) Si le Grand a été laissé après un Embido, on ne tire rien. S\'il y a eu Iduki, on compte les points pariés, rien de plus.'**
  String get menuHighIfEveryoneSaidPASOTheBestHighScores;

  /// No description provided for @menuLowTheSameAsHigh.
  ///
  /// In fr, this message translates to:
  /// **'Petit : idem que pour le Grand.'**
  String get menuLowTheSameAsHigh;

  /// No description provided for @menuPairsAfterPasoTheTeamWithTheBestPair.
  ///
  /// In fr, this message translates to:
  /// **'Paires : S\'il y a eu Paso, l\'équipe ayant la meilleure paire comptera sa ou ses paires, en tirant 1 point (paires) 2 points (mediak) ou 3 points (doubles). S\'il y a eu Iduki, on comptera en plus les points pariés.'**
  String get menuPairsAfterPasoTheTeamWithTheBestPair;

  /// No description provided for @menuGameTheSameAsPairsCounting2PointsFor.
  ///
  /// In fr, this message translates to:
  /// **'Le Jeu : idem que pour les paires, en comptant 2 points (jeu) ou 3 (pour le 31) pour le ou les jeux de l\'équipe gagnant le jeu.'**
  String get menuGameTheSameAsPairsCounting2PointsFor;

  /// No description provided for @menuPointPontuaAfterPasoTheBestPontuaScores1.
  ///
  /// In fr, this message translates to:
  /// **'Le Point : (Pontua) S\'il y a eu Paso, celui qui a le meilleur Pontua tirera 1 point. S\'il y a eu Tira, l\'équipe ayant gagné le Tira comptera 1 point du Pontua. S\'il y a eu Iduki, on compte les point pariés plus 1 point du Pontua.'**
  String get menuPointPontuaAfterPasoTheBestPontuaScores1;

  /// No description provided for @menuRaiseExamples.
  ///
  /// In fr, this message translates to:
  /// **'Relances (exemples) :'**
  String get menuRaiseExamples;

  /// No description provided for @menuEmbido2PointsTira1Point.
  ///
  /// In fr, this message translates to:
  /// **'Embido (2 points) - Tira = 1 point'**
  String get menuEmbido2PointsTira1Point;

  /// No description provided for @menuEmbido2PointsIduki2Points.
  ///
  /// In fr, this message translates to:
  /// **'Embido (2 points) - Iduki = 2 points'**
  String get menuEmbido2PointsIduki2Points;

  /// No description provided for @menuHordagoTira1Point.
  ///
  /// In fr, this message translates to:
  /// **'Hordago - Tira = 1 point'**
  String get menuHordagoTira1Point;

  /// No description provided for @menuHiruEmbido3PointsTira1Point.
  ///
  /// In fr, this message translates to:
  /// **'Hiru Embido (3 points) - Tira = 1 point'**
  String get menuHiruEmbido3PointsTira1Point;

  /// No description provided for @menuHiruEmbido3PointsIduki3Points.
  ///
  /// In fr, this message translates to:
  /// **'Hiru Embido (3 points) – Iduki = 3 points'**
  String get menuHiruEmbido3PointsIduki3Points;

  /// No description provided for @menuEmbido2PointsLauGehiago4Tira2Points.
  ///
  /// In fr, this message translates to:
  /// **'Embido (2 points) Lau gehiago (+ 4) - Tira = 2 points'**
  String get menuEmbido2PointsLauGehiago4Tira2Points;

  /// No description provided for @menuEmbido2PointsBigehiago2HordagoTira4Points.
  ///
  /// In fr, this message translates to:
  /// **'Embido (2 points) – Bigehiago( +2 ) – Hordago - Tira = 4 points'**
  String get menuEmbido2PointsBigehiago2HordagoTira4Points;

  /// No description provided for @menuHiruEmbido3PointsLauGehiago4Iduki7.
  ///
  /// In fr, this message translates to:
  /// **'Hiru Embido (3 points) Lau gehiago (+ 4) Iduki = 7 points'**
  String get menuHiruEmbido3PointsLauGehiago4Iduki7;

  /// No description provided for @menuEmbido2PointsBortzGehiago5Bigehiago2Tira.
  ///
  /// In fr, this message translates to:
  /// **'Embido (2 points) Bortz gehiago (+ 5) Bigehiago (+2) Tira = 7 points'**
  String get menuEmbido2PointsBortzGehiago5Bigehiago2Tira;

  /// No description provided for @menuNoTtanttoMayBeScoredOnceTheCardsHave.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ttantto ne peut être tiré si les cartes sont ramassées.'**
  String get menuNoTtanttoMayBeScoredOnceTheCardsHave;

  /// No description provided for @menuRefereeing.
  ///
  /// In fr, this message translates to:
  /// **'Arbitrage'**
  String get menuRefereeing;

  /// No description provided for @menuTheRefereeIntervenesOnlyAtAPlayersRequestOr.
  ///
  /// In fr, this message translates to:
  /// **'Le Juge n\'intervient que sur demande de l\'un des joueurs ou sur le constat d’une irrégularité.'**
  String get menuTheRefereeIntervenesOnlyAtAPlayersRequestOr;

  /// No description provided for @menuAnyDisputeOverTheseRegulationsOrAnySituationNot.
  ///
  /// In fr, this message translates to:
  /// **'Tout litige dans l\'interprétation de ce règlement ainsi que tout problème non évoqué ici sera réglé par le Juge.'**
  String get menuAnyDisputeOverTheseRegulationsOrAnySituationNot;

  /// No description provided for @menuTheRefereeMayImposePenaltiesUpToAndIncluding.
  ///
  /// In fr, this message translates to:
  /// **'Le Juge a un pouvoir de pénalisations allant jusqu’à l’exclusion.'**
  String get menuTheRefereeMayImposePenaltiesUpToAndIncluding;

  /// No description provided for @menuArticleArg0.
  ///
  /// In fr, this message translates to:
  /// **'Article {arg0}'**
  String menuArticleArg0(String arg0);

  /// No description provided for @invitationPrivateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un Salon Privé'**
  String get invitationPrivateTitle;

  /// No description provided for @invitationPrivateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Salon privé'**
  String get invitationPrivateLabel;

  /// No description provided for @invitationCasualTitle.
  ///
  /// In fr, this message translates to:
  /// **'En Ligne (Classique) en Duo'**
  String get invitationCasualTitle;

  /// No description provided for @invitationCasualLabel.
  ///
  /// In fr, this message translates to:
  /// **'Classique en duo'**
  String get invitationCasualLabel;

  /// No description provided for @invitationRankedTitle.
  ///
  /// In fr, this message translates to:
  /// **'En Ligne (Classé) en Duo'**
  String get invitationRankedTitle;

  /// No description provided for @invitationRankedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Classé en duo'**
  String get invitationRankedLabel;

  /// No description provided for @classicCardBack.
  ///
  /// In fr, this message translates to:
  /// **'Dos Classique'**
  String get classicCardBack;

  /// No description provided for @gamesPlayedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} parties'**
  String gamesPlayedCount(String count);

  /// No description provided for @avatarOption.
  ///
  /// In fr, this message translates to:
  /// **'{name} : option {number}'**
  String avatarOption(String name, String number);

  /// No description provided for @nicknameLengthError.
  ///
  /// In fr, this message translates to:
  /// **'Le pseudo doit contenir de 1 à 24 caractères.'**
  String get nicknameLengthError;

  /// No description provided for @deleteAccountError.
  ///
  /// In fr, this message translates to:
  /// **'La suppression a échoué. Réessayez.'**
  String get deleteAccountError;

  /// No description provided for @connectionUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Connexion indisponible. Réessayez.'**
  String get connectionUnavailable;

  /// No description provided for @seasonName.
  ///
  /// In fr, this message translates to:
  /// **'Saison {name}'**
  String seasonName(String name);

  /// No description provided for @questPlay.
  ///
  /// In fr, this message translates to:
  /// **'Terminer {count} parties'**
  String questPlay(String count);

  /// No description provided for @questWin.
  ///
  /// In fr, this message translates to:
  /// **'Gagner {count} parties'**
  String questWin(String count);

  /// No description provided for @questRanked.
  ///
  /// In fr, this message translates to:
  /// **'Gagner {count} parties classées'**
  String questRanked(String count);

  /// No description provided for @questGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Défi hebdomadaire'**
  String get questGeneric;

  /// No description provided for @catalogUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Cosmétique'**
  String get catalogUnknown;

  /// No description provided for @catalogUnknownDescription.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisez votre apparence à la table.'**
  String get catalogUnknownDescription;

  /// No description provided for @catalogSun.
  ///
  /// In fr, this message translates to:
  /// **'Soleil'**
  String get catalogSun;

  /// No description provided for @catalogMountain.
  ///
  /// In fr, this message translates to:
  /// **'Montagne'**
  String get catalogMountain;

  /// No description provided for @catalogBlue.
  ///
  /// In fr, this message translates to:
  /// **'Bleu'**
  String get catalogBlue;

  /// No description provided for @catalogGreen.
  ///
  /// In fr, this message translates to:
  /// **'Vert'**
  String get catalogGreen;

  /// No description provided for @catalogOcean.
  ///
  /// In fr, this message translates to:
  /// **'Océan'**
  String get catalogOcean;

  /// No description provided for @catalogRuby.
  ///
  /// In fr, this message translates to:
  /// **'Rubis'**
  String get catalogRuby;

  /// No description provided for @catalogDiamondBorder.
  ///
  /// In fr, this message translates to:
  /// **'Bordure Diamant'**
  String get catalogDiamondBorder;

  /// No description provided for @catalogLeagueTxapela.
  ///
  /// In fr, this message translates to:
  /// **'Txapela de ligue'**
  String get catalogLeagueTxapela;

  /// No description provided for @catalogLeagueCrown.
  ///
  /// In fr, this message translates to:
  /// **'Couronne de ligue'**
  String get catalogLeagueCrown;

  /// No description provided for @catalogEmeraldBorder.
  ///
  /// In fr, this message translates to:
  /// **'Cadre Émeraude'**
  String get catalogEmeraldBorder;

  /// No description provided for @catalogAmethystBorder.
  ///
  /// In fr, this message translates to:
  /// **'Cadre Améthyste'**
  String get catalogAmethystBorder;

  /// No description provided for @catalogEmeraldBack.
  ///
  /// In fr, this message translates to:
  /// **'Dos Émeraude'**
  String get catalogEmeraldBack;

  /// No description provided for @catalogVioletBack.
  ///
  /// In fr, this message translates to:
  /// **'Dos Violet'**
  String get catalogVioletBack;

  /// No description provided for @catalogEskerrik.
  ///
  /// In fr, this message translates to:
  /// **'Eskerrik asko !'**
  String get catalogEskerrik;

  /// No description provided for @catalogRematch.
  ///
  /// In fr, this message translates to:
  /// **'La revanche ?'**
  String get catalogRematch;

  /// No description provided for @catalogMullet.
  ///
  /// In fr, this message translates to:
  /// **'Coupe Mulet'**
  String get catalogMullet;

  /// No description provided for @catalogStriped.
  ///
  /// In fr, this message translates to:
  /// **'Maillot Rayé Bleu et Blanc'**
  String get catalogStriped;

  /// No description provided for @catalogGoldGlasses.
  ///
  /// In fr, this message translates to:
  /// **'Lunettes de Soleil Dorées'**
  String get catalogGoldGlasses;

  /// No description provided for @catalogCap.
  ///
  /// In fr, this message translates to:
  /// **'Casquette Bleue'**
  String get catalogCap;

  /// No description provided for @catalogBeanie.
  ///
  /// In fr, this message translates to:
  /// **'Bonnet Cuivré'**
  String get catalogBeanie;

  /// No description provided for @catalogRoundGlasses.
  ///
  /// In fr, this message translates to:
  /// **'Lunettes rondes'**
  String get catalogRoundGlasses;

  /// No description provided for @catalogOceanBack.
  ///
  /// In fr, this message translates to:
  /// **'Dos Océan'**
  String get catalogOceanBack;

  /// No description provided for @catalogCoralBack.
  ///
  /// In fr, this message translates to:
  /// **'Dos Corail'**
  String get catalogCoralBack;

  /// No description provided for @catalogEmeraldBorderDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un anneau émeraude autour de votre avatar.'**
  String get catalogEmeraldBorderDescription;

  /// No description provided for @catalogAmethystBorderDescription.
  ///
  /// In fr, this message translates to:
  /// **'Une bordure violette à afficher à la table.'**
  String get catalogAmethystBorderDescription;

  /// No description provided for @catalogEmeraldBackDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un dos de cartes vert émeraude.'**
  String get catalogEmeraldBackDescription;

  /// No description provided for @catalogVioletBackDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un dos de cartes violet.'**
  String get catalogVioletBackDescription;

  /// No description provided for @catalogEskerrikDescription.
  ///
  /// In fr, this message translates to:
  /// **'Remerciez les autres joueurs en un clic.'**
  String get catalogEskerrikDescription;

  /// No description provided for @catalogRematchDescription.
  ///
  /// In fr, this message translates to:
  /// **'Proposez une nouvelle partie à la table.'**
  String get catalogRematchDescription;

  /// No description provided for @catalogMulletDescription.
  ///
  /// In fr, this message translates to:
  /// **'Court devant, long derrière : une coupe de caractère.'**
  String get catalogMulletDescription;

  /// No description provided for @catalogStripedDescription.
  ///
  /// In fr, this message translates to:
  /// **'Des rayures bleues et blanches pour votre tenue.'**
  String get catalogStripedDescription;

  /// No description provided for @catalogGoldGlassesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Des verres sombres et une monture dorée.'**
  String get catalogGoldGlassesDescription;

  /// No description provided for @catalogCapDescription.
  ///
  /// In fr, this message translates to:
  /// **'Une casquette bleue portée au-dessus des cheveux.'**
  String get catalogCapDescription;

  /// No description provided for @catalogBeanieDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un bonnet cuivré avec son pompon.'**
  String get catalogBeanieDescription;

  /// No description provided for @catalogFineGlassesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Une monture fine dorée qui laisse les yeux visibles.'**
  String get catalogFineGlassesDescription;

  /// No description provided for @catalogRoundGlassesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Des verres transparents et une monture ronde.'**
  String get catalogRoundGlassesDescription;

  /// No description provided for @catalogOceanBackDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un motif classique dans un bleu profond.'**
  String get catalogOceanBackDescription;

  /// No description provided for @catalogCoralBackDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un motif classique dans une teinte corail.'**
  String get catalogCoralBackDescription;

  /// No description provided for @catalogBaldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Le crâne dégagé, sans couche de cheveux.'**
  String get catalogBaldDescription;

  /// No description provided for @catalogMohawkDescription.
  ///
  /// In fr, this message translates to:
  /// **'Une crête centrée, visible de face.'**
  String get catalogMohawkDescription;

  /// No description provided for @legalTermsBody.
  ///
  /// In fr, this message translates to:
  /// **'ISAMUS — CONDITIONS D’UTILISATION\nProjet de texte du 26 octobre 2026 — à compléter avant publication\n\nÉditeur : [NOM / RAISON SOCIALE], [ADRESSE], [PAYS]. Contact : [E-MAIL SUPPORT].\n\n1. Le service\nIsaMus permet de jouer au Mus, variante 4 Rois / 4 As, avec des joueurs ou des bots. Les points et le classement n’ont aucune valeur monétaire. Le service ne propose ni mise d’argent, ni gain échangeable contre de l’argent.\n\n2. Compte\nUn compte invité permet de commencer à jouer. Lier une adresse e-mail vérifiée ou une identité Apple/Google permet de retrouver le compte. Sans cette liaison, la perte de la session ou de l’appareil peut rendre la progression irrécupérable. Vous devez protéger vos moyens de connexion et choisir un pseudo respectueux, qui ne divulgue pas de données personnelles.\n\n3. Jeu et relations entre joueurs\nLa triche, l’exploitation de failles, l’usurpation d’identité, le harcèlement et les sollicitations abusives sont interdits. Les demandes d’amitié et invitations peuvent être refusées. Les bots sont identifiés comme tels. Les déconnexions déclenchent des actions automatiques pour permettre à la partie de continuer.\n\n4. Objets numériques\nLes cosmétiques sont des éléments visuels sans avantage sur les cartes ni les scores. Les articles, leurs caractéristiques et leur prix sont présentés avant la confirmation d’achat dans le store. Le paiement est traité par Apple ou Google. IsaMus ne reçoit pas votre numéro de carte bancaire. Les achats doivent être liés à un compte sécurisé. La fonction « Restaurer mes achats » permet de demander leur synchronisation. Un objet numérique n’est pas convertible en argent et ne peut pas être transféré entre joueurs dans l’application.\nLes conditions de remboursement et les droits légaux applicables restent ceux de votre pays et du store. Aucune clause de ce texte ne limite les garanties obligatoires du consommateur. Les informations et consentements éventuellement nécessaires à l’exécution immédiate d’un contenu numérique doivent être fournis dans le parcours d’achat du store.\n\n5. Publicité\nDes espaces publicitaires peuvent apparaître dans l’accueil. Les choix de confidentialité publicitaire sont accessibles dans le profil. Refuser une utilisation optionnelle de vos données ne doit pas empêcher de jouer.\n\n6. Disponibilité et évolution\nLe fonctionnement dépend du réseau et des services tiers. Des interruptions ou opérations de maintenance peuvent survenir. L’éditeur informe les joueurs des changements importants affectant le service ou les objets acquis et respecte les droits impératifs applicables.\n\n7. Suppression et assistance\nLa suppression du compte peut être demandée dans « Compte & sécurité ». Elle efface le profil et les données associées selon la politique de confidentialité. Elle n’annule pas automatiquement une transaction auprès d’un store. Pour toute difficulté, contactez [E-MAIL SUPPORT].\n\n8. Droit applicable et litiges\nLes règles de protection du consommateur de votre lieu de résidence s’appliquent lorsqu’elles sont impératives. Les mentions du droit applicable, de la médiation et de l’autorité compétente doivent être adaptées au pays et au statut réel de l’éditeur avant publication.\n'**
  String get legalTermsBody;

  /// No description provided for @legalPrivacyBody.
  ///
  /// In fr, this message translates to:
  /// **'ISAMUS — POLITIQUE DE CONFIDENTIALITÉ\nProjet de texte du 26 octobre 2026 — à compléter avant publication\n\nResponsable du traitement : [NOM / RAISON SOCIALE], [ADRESSE], [PAYS]. Contact pour vos droits : [E-MAIL CONFIDENTIALITÉ].\n\nDonnées et usages\nLe compte possède un identifiant technique, un pseudo, un classement Elo et des statistiques. Une adresse e-mail ou une identité Apple/Google est utilisée seulement si vous choisissez de sécuriser votre compte. Les sessions servent à vous authentifier. Les mots de passe sont traités par le service d’authentification et ne sont pas accessibles dans l’application.\nLes parties contiennent les participants, actions et états nécessaires au jeu. L’historique conserve le résultat et les variations d’Elo. Les demandes d’amitié et invitations permettent les fonctions sociales. La présence indique aux amis acceptés si vous êtes en ligne ou dans une partie ; elle ne leur révèle pas le code du salon.\nLe pseudo, l’avatar et l’Elo sont visibles aux autres joueurs authentifiés. Les cartes et états de partie sont accessibles aux participants dans l’architecture actuelle. Ne placez pas de donnée sensible dans votre pseudo.\n\nAchats et publicité\nLes stores Apple/Google et RevenueCat traitent les achats et leur validation. L’identifiant de compte et les droits d’accès aux cosmétiques permettent leur restauration. Nous ne collectons pas vos coordonnées bancaires.\nLorsque la publicité est activée, Google AdMob et son mécanisme de consentement peuvent traiter des données techniques de l’appareil, du réseau, de la diffusion publicitaire et vos choix de confidentialité. L’intégration demande des annonces non personnalisées ; cela n’exclut pas tout traitement de données par le SDK. Les formulaires de consentement applicables et le lien « Choix de confidentialité publicitaire » permettent de gérer les usages optionnels. L’application n’exige pas l’accès à vos contacts, à votre microphone ni à votre localisation précise.\n\nBases des traitements\nLe fonctionnement du compte, du jeu et des achats repose sur l’exécution du service demandé. La protection contre les abus et la sécurité reposent sur l’intérêt légitime de l’éditeur, sous réserve de vos droits. Les traitements optionnels soumis au consentement ne doivent être activés qu’après le choix requis. Les obligations légales applicables peuvent imposer de conserver certaines traces de transactions.\n\nPrestataires et transferts\nSupabase fournit la base de données, l’authentification, les fonctions serveur et le temps réel. Apple, Google et RevenueCat interviennent dans l’authentification, les achats ou la publicité selon les fonctions utilisées. Avant publication, l’éditeur doit préciser les régions effectivement choisies, les destinataires, les éventuels transferts internationaux et les garanties contractuelles applicables ; ces paramètres ne peuvent pas être déduits du code de l’application.\n\nConservation\nLe profil, l’inventaire et les relations sociales sont conservés tant que le compte existe. La présence est liée à la connexion. Les historiques et journaux techniques nécessitent une durée de conservation documentée par l’éditeur : [DURÉE HISTORIQUE], [DURÉE JOURNAUX], [DURÉE SAUVEGARDES]. Les invitations ont une validité fonctionnelle de dix minutes ; leur expiration ne signifie pas leur effacement immédiat de la base. Les prestataires peuvent avoir leurs propres obligations de conservation.\n\nVos droits et suppression\nVous pouvez demander l’accès, la rectification, l’effacement et, selon les conditions légales, la portabilité, la limitation ou l’opposition, à [E-MAIL CONFIDENTIALITÉ]. Le retrait d’un consentement n’affecte pas les traitements antérieurs licites. Le profil propose une suppression de compte. Les demandes concernant un paiement ou un identifiant publicitaire peuvent également relever du store ou du fournisseur concerné. Vous pouvez saisir l’autorité de contrôle compétente ; en France, la CNIL (www.cnil.fr).\n\nMineurs\nL’éditeur doit définir avant publication l’âge minimal, le public visé et le mécanisme de consentement parental éventuellement nécessaire. La configuration publicitaire et la déclaration d’âge des stores doivent correspondre à ce choix.\n\nMises à jour\nLa date et les changements substantiels de cette politique seront communiqués dans l’application. Ce projet doit être complété avec les informations réelles de l’éditeur et des prestataires avant sa mise en ligne.\n'**
  String get legalPrivacyBody;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageBasque.
  ///
  /// In fr, this message translates to:
  /// **'Euskara'**
  String get languageBasque;

  /// No description provided for @languageSpanish.
  ///
  /// In fr, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @musWord.
  ///
  /// In fr, this message translates to:
  /// **'Mus'**
  String get musWord;

  /// No description provided for @mintzaWord.
  ///
  /// In fr, this message translates to:
  /// **'Mintza'**
  String get mintzaWord;

  /// No description provided for @tiraWord.
  ///
  /// In fr, this message translates to:
  /// **'Tira'**
  String get tiraWord;

  /// No description provided for @pasoWord.
  ///
  /// In fr, this message translates to:
  /// **'Paso'**
  String get pasoWord;

  /// No description provided for @hordagoWord.
  ///
  /// In fr, this message translates to:
  /// **'Hordago'**
  String get hordagoWord;

  /// No description provided for @providerGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Google'**
  String get providerGoogle;

  /// No description provided for @providerApple.
  ///
  /// In fr, this message translates to:
  /// **'Apple'**
  String get providerApple;

  /// No description provided for @rulesContact.
  ///
  /// In fr, this message translates to:
  /// **'Centre Départemental Nelson Paillou · 2, allée des Platanes · 64100 Bayonne\n05 59 14 19 12 · mail@federation-mus.fr'**
  String get rulesContact;

  /// No description provided for @gameMenuTitle.
  ///
  /// In fr, this message translates to:
  /// **'Menu de la partie'**
  String get gameMenuTitle;

  /// No description provided for @gameQuitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter la partie'**
  String get gameQuitTitle;

  /// No description provided for @gameQuitConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment quitter la partie ?'**
  String get gameQuitConfirm;

  /// No description provided for @gameQuitAction.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get gameQuitAction;

  /// No description provided for @gameQuitFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de fermer le salon. Vérifiez votre connexion et réessayez.'**
  String get gameQuitFailed;

  /// No description provided for @leaderboardYouSuffix.
  ///
  /// In fr, this message translates to:
  /// **', vous'**
  String get leaderboardYouSuffix;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'eu', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'eu':
      return AppLocalizationsEu();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
