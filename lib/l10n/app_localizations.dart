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
