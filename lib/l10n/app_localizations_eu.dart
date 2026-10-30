// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get appTitle => 'IsaMus';

  @override
  String get you => 'Zu';

  @override
  String get partner => 'Bikotekidea';

  @override
  String team(String name) {
    return '$name taldea';
  }

  @override
  String rounds(int count) {
    return 'Mankak: $count / 3';
  }

  @override
  String get startGame => 'Kartak banatu';

  @override
  String get nextHand => 'Hurrengo eskua';

  @override
  String get newGame => 'Partida berria';

  @override
  String get dealing => 'Banaketa';

  @override
  String get discarding => 'Mus trukea';

  @override
  String get roundScoring => 'Zenbaketa';

  @override
  String get gameOver => 'Partida amaitu da';

  @override
  String get yourTurn => 'Zure txanda';

  @override
  String waitingFor(String name) {
    return '$name: zure txanda';
  }

  @override
  String discardCards(int count) {
    return '$count karta trukatu';
  }

  @override
  String get keepCards => 'Kartak atxiki';

  @override
  String currentBid(int amount) {
    return 'Apustua: $amount Tantto';
  }

  @override
  String roundWinner(String team) {
    return '$team: manka irabazi du';
  }

  @override
  String gameWinner(String team) {
    return '$team: partida irabazi du';
  }

  @override
  String get actionFailed => 'Ezin da ekintza egin: egoera aldatu da.';

  @override
  String cardLabel(int value, String suit) {
    return '$value $suit';
  }

  @override
  String get oros => 'Urrea';

  @override
  String get copas => 'Kopa';

  @override
  String get espadas => 'Ezpata';

  @override
  String get bastos => 'Bastoia';

  @override
  String get hasPairs => 'Pariak dut';

  @override
  String get hasGame => 'Jokoa dut';

  @override
  String get hasNeither => 'Ez dut';

  @override
  String get sendSign => 'Bikotekideari keinua egin';

  @override
  String get signTwoKings => '2 Errege';

  @override
  String get signTwoAces => '2 Bateko';

  @override
  String get signGame => 'Jokoa';

  @override
  String opponentShort(int number) {
    return '$number. aurk.';
  }

  @override
  String scoreTotal(int total, int hamarreko, int tantto) {
    return 'Puntuazioa: $total pt ($hamarreko Hamarreko, $tantto Tantto)';
  }

  @override
  String get quickChat => 'Mezu azkarrak';

  @override
  String get chatGoodLuck => 'Zorte on';

  @override
  String get chatNothing => 'Ez dut ezer';

  @override
  String get chatWellPlayed => 'Ongi jokatua!';

  @override
  String get turnTime => 'Jokatzeko denbora';

  @override
  String get raiseAmount => 'Apustua igo…';

  @override
  String get openingAmount => 'Apustua egin…';

  @override
  String get increase => 'Handitu';

  @override
  String get decrease => 'Txikitu';

  @override
  String get validate => 'Baieztatu';

  @override
  String bidTotal(int amount) {
    return 'Apustua guztira: $amount Tantto';
  }

  @override
  String get playTitle => 'Jokatu';

  @override
  String get leaderboardTitle => 'Top 100';

  @override
  String get shopTitle => 'Denda';

  @override
  String get friendsTitle => 'Lagunak';

  @override
  String get profileTitle => 'Profila';

  @override
  String get seasonPassTitle => 'Denboraldiko pasea';

  @override
  String get tutorialTitle => 'Tutoriala';

  @override
  String get settingsTitle => 'Ezarpenak';

  @override
  String get languageTitle => 'Hizkuntza';

  @override
  String get menuUnableToCompleteThisActionCheckYourConnectionAnd =>
      'Ezin izan da ekintza burutu. Egiaztatu konexioa eta saiatu berriro.';

  @override
  String get menuDocumentUnavailableTryAgain =>
      'Dokumentua ez dago erabilgarri. Saiatu berriro.';

  @override
  String get menuSoundEffects => 'Soinu-efektuak';

  @override
  String get menuPreferenceUnavailable => 'Hobespena ez dago erabilgarri';

  @override
  String get menuTryAgain => 'Saiatu berriro';

  @override
  String get menuAccountSecurity => 'Kontua eta segurtasuna';

  @override
  String get menuAdPrivacyChoices => 'Iragarkien pribatutasun-aukerak';

  @override
  String get menuTermsOfUse => 'Erabilera-baldintzak';

  @override
  String get menuPrivacyPolicy => 'Pribatutasun-politika';

  @override
  String get menuLastDay => 'Azken eguna';

  @override
  String menuOnlyArg0DLeft(String arg0) {
    return '$arg0 egun besterik ez';
  }

  @override
  String get menuSeasonInProgress => 'Denboraldia abian';

  @override
  String get menuPlayer => 'Jokalaria';

  @override
  String get menuUnableToCompleteThisActionTheRoomMayHave =>
      'Ezin izan da ekintza burutu. Baliteke gela aldatu izana. Saiatu berriro.';

  @override
  String menuCodeArg0CopiedToClipboard(String arg0) {
    return '$arg0 kodea arbelean kopiatu da!';
  }

  @override
  String get menuWAITINGROOM => 'ITXARONGELA';

  @override
  String get menuSyncErrorTryAgain => 'Sinkronizazio-errorea. Saiatu berriro';

  @override
  String get menuThisRoomIsReservedForPublicMatchmaking =>
      'Gela hau parekatze publikorako gordeta dago.';

  @override
  String get menuINVITATIONCODE => 'GONBIDAPEN-KODEA';

  @override
  String get menuCopyCode => 'Kopiatu kodea';

  @override
  String get menuStartGame => 'Hasi partida';

  @override
  String get menuFillWithAIPlayers => 'Bete AArekin';

  @override
  String get menuTwoPlayersPerTeamAreRequired =>
      'Talde bakoitzean bi jokalari behar dira.';

  @override
  String get menuWaitingForTheHost => 'Ostalariaren zain...';

  @override
  String get menuTheRoomHasBeenClosed => 'Gela itxi da.';

  @override
  String menuTeamArg0Arg12(String arg0, String arg1) {
    return '$arg0. taldea · $arg1/2';
  }

  @override
  String get menuYourTeam => 'Zure taldea';

  @override
  String get menuJoin => 'Sartu';

  @override
  String get menuYOU => 'ZU';

  @override
  String get menuOpenSeat => 'Leku librea';

  @override
  String get menuWaiting => 'Zain…';

  @override
  String get menuHost => 'Ostalaria';

  @override
  String get menuAI => 'AA';

  @override
  String get menuInviteMyFriends => 'Gonbidatu lagunak';

  @override
  String get menuAddFriendsFromTheFriendsTab =>
      'Gehitu lagunak Lagunak fitxatik.';

  @override
  String get menuFriend => 'Laguna';

  @override
  String menuInvitationSentToArg0(String arg0) {
    return 'Gonbidapena bidali zaio $arg0 jokalariari.';
  }

  @override
  String get menuUnableToSendTheInvitation =>
      'Ezin izan da gonbidapena bidali.';

  @override
  String get menuInvite => 'Gonbidatu';

  @override
  String get menuSignInToPlay => 'Hasi saioa jokatzeko.';

  @override
  String get menuPleaseEnterYourNickname => 'Sartu zure ezizena.';

  @override
  String get menuSignInToCreateYourProfile =>
      'Hasi saioa zure profila sortzeko.';

  @override
  String get menuTheCodeMustContainExactly5Characters =>
      'Kodeak 5 karaktere izan behar ditu zehazki.';

  @override
  String get menuIAlreadyHaveAnAccount => 'Badut kontua';

  @override
  String menuArg0Coins(String arg0) {
    return '$arg0 txanpon';
  }

  @override
  String get menuWeeklyQuests => 'Asteko erronkak';

  @override
  String get menuGAMEMODES => 'JOKO-MODUAK';

  @override
  String get menuATYOUROWNPACE => 'ZURE ERRITMOAN';

  @override
  String get menuTakeASeatAndLearnMusFromYourFirst =>
      'Eseri mahaian eta ikasi Mus jokatzen, lehen erabakietatik puntuen zenbaketara.';

  @override
  String get menuNoTimerGuidedThenFreePlay =>
      'Kronometrorik gabe · Gidatua, gero librea';

  @override
  String get menuLearnMus => 'Ikasi Mus';

  @override
  String get menuOfficialRules => 'Arau ofizialak';

  @override
  String get menuQUICKMULTIPLAYER => 'JOKALARI ANITZEKO PARTIDA AZKARRA';

  @override
  String get menuONLINECASUAL => 'SAREAN (KLASIKOA)';

  @override
  String get menuChallengePlayersOnlineInRelaxedFriendlyGamesWithNo =>
      'Jokatu sarean lagunarteko partida lasaiak, Elo arriskuan jarri gabe. Mus une atsegin bat partekatzeko aproposa.';

  @override
  String get menuOfficial4KingsAnd4AcesRulesNoPressure =>
      '4 Errege eta 4 Bateko arau ofizialak • Presiorik gabe';

  @override
  String get menuOFFICIALCOMPETITION => 'LEHIAKETA OFIZIALA';

  @override
  String get menuONLINERANKED => 'SAREAN (SAILKATUA)';

  @override
  String menuYourCurrentEloArg0(String arg0) {
    return 'Zure uneko Elo: $arg0';
  }

  @override
  String get menuSeasonRewards => 'Denboraldiko sariak';

  @override
  String get menuClimbTheCompetitiveRankingsEveryWinRaisesYourElo =>
      'Igo sailkapen lehiakorrean. Garaipen bakoitzak Elo igotzen du eta porrot bakoitzak jaisten. Lortu Top 100ean sartzea!';

  @override
  String get menuPlayRanked => 'Jokatu (Sailkatua)';

  @override
  String get menuSOLOPRACTICE => 'BAKARKAKO ENTRENAMENDUA';

  @override
  String get menuSOLOVSAI => 'BAKARKA AAREN AURKA';

  @override
  String get menuPlayAgainst3LocalAIPlayersWithoutWaitingFor =>
      'Jokatu tokiko 3 AAren aurka, beste jokalarien zain egon gabe. Arauak, taktikak eta euskal keinuak berrikusteko aproposa.';

  @override
  String get menuInstantStart3IndependentBots =>
      'Berehala hasi • 3 bot autonomo';

  @override
  String get menuPlayAgainstAI => 'Jokatu AAren aurka';

  @override
  String get menuPRIVATEROOM => 'GELA PRIBATUA';

  @override
  String get menuPLAYWITHFRIENDS => 'JOKATU LAGUNEKIN';

  @override
  String get menuCreateAPrivateRoom => 'Sortu gela pribatu bat';

  @override
  String get menuORJOINWITHACODE => 'EDO SARTU KODE BATEKIN';

  @override
  String get menuConfirmAndJoin => 'Berretsi eta sartu';

  @override
  String get menuBASQUECARDGAMEMULTIPLAYER =>
      'EUSKAL KARTA-JOKOA • JOKALARI ANITZEKOA';

  @override
  String get menuCONNECTING => 'KONEKTATZEN...';

  @override
  String get menuCREATEYOURPROFILE => 'SORTU ZURE PROFILA';

  @override
  String get menuYourNicknameEGPatxiAmaia =>
      'Zure ezizena (adib.: Patxi, Amaia…)';

  @override
  String get menuCreateMyProfile => 'Sortu nire profila';

  @override
  String get menuTop100Players => '100 jokalari onenak';

  @override
  String get menuRefreshRankings => 'Eguneratu sailkapena';

  @override
  String get menuLoadingRankings => 'Sailkapena kargatzen';

  @override
  String get menuUnableToLoadRankingsCheckYourConnectionAndTry =>
      'Ezin izan da sailkapena kargatu. Egiaztatu konexioa eta saiatu berriro.';

  @override
  String get menuNoRankedPlayersYet => 'Oraindik ez dago jokalari sailkaturik.';

  @override
  String get menuTheHighestEloRatings => 'Elo puntuaziorik onenak';

  @override
  String menuYourPositionArg0(String arg0) {
    return 'Zure postua: #$arg0';
  }

  @override
  String get menuReachTheTop100ToAppearHere =>
      'Sartu Top 100ean hemen agertzeko!';

  @override
  String get menuRankedByDescendingElo =>
      'Elo handienetik txikienera ordenatuta.';

  @override
  String menuPositionArg0Arg1Arg2EloArg3(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return '$arg0. postua, $arg1, $arg2 Elo$arg3';
  }

  @override
  String menuLevelArg0Arg1500XP(String arg0, String arg1) {
    return '$arg0. maila · $arg1 / 500 XP';
  }

  @override
  String menuLevelArg0Arg1XPOutOf500(String arg0, String arg1) {
    return '$arg0. maila, $arg1 XP / 500';
  }

  @override
  String get menuYouHaveTwoKingsAndAGameTotalOf =>
      'Bi Errege eta 31ko Jokoa dituzu. Gorde eskua: esan Mintza.';

  @override
  String get menuYourOpponentRaisesCallIdukiToCompareCardsAt =>
      'Aurkariak apustua igo du. Berdindu (Iduki), kartak zenbaketan alderatzeko.';

  @override
  String get menuYouHaveTwoKingsBaiAnnouncesYourPairBet =>
      'Bi Errege dituzu: Bai esanez iragartzen da zure parea. Egin 2 harriko apustua!';

  @override
  String get menuYouHave31TheBestGameTotalBet2 =>
      '31 duzu, Jokorik onena. Egin 2 harriko apustua enkantea irekitzeko.';

  @override
  String get menuThisIsHighHandiaYouHaveStrongCardsBet =>
      'Handia da. Karta sendoak dituzu: egin apustua!';

  @override
  String get menuAtLowYourAceIsFollowedByThreeFace =>
      'Ttipian, zure Batekoaren ondoren hiru figura daude. Eman hitza Paso esanez.';

  @override
  String get menuWatchTheOtherPlayersAnnouncementsAndResponses =>
      'Begiratu beste jokalarien iragarpenak eta erantzunak.';

  @override
  String get menuTheTutorialIsWaitingForMintza => 'Tutoriala Mintza zain dago.';

  @override
  String get menuDiscardingIsNotAvailableAtThisStep =>
      'Ezin da kartarik trukatu urrats honetan.';

  @override
  String get menuThisIsNotTheActionExpectedByTheTutorial =>
      'Hau ez da tutorialak espero duen ekintza.';

  @override
  String get menuTheOtherPlayersAreTakingTheirTurns =>
      'Beste jokalariak jokatzen ari dira…';

  @override
  String get menuIdukiCall => 'Iduki (Berdindu)';

  @override
  String get menuRaise => 'Igo apustua';

  @override
  String get menuBet2 => 'Egin 2ko apustua';

  @override
  String get menuMusOrMintza => 'Mus ala Mintza?';

  @override
  String get menuAtTheStartOfEachHandEachPlayerChooses =>
      'Esku bakoitzaren hasieran, jokalari bakoitzak Mus aukeratzen du kartak trukatzeko. Laurek Mus esaten badute, kartak baztertu eta berriak jaso ditzakete. Mintza aukerak Mus eteten du: eskuak gorde eta apustuak hasten dira. Sakatu Mintza: espero den botoia bakarrik dago aktibo, eta haren ertzak distira egiten du.';

  @override
  String get menuBettingPasoAndEmbido => 'Apustuak: Paso eta Embido';

  @override
  String get menuInEachPhaseYouCanBetStonesForYour =>
      'Fase bakoitzean harriak apustu egin ditzakezu zure taldearentzat. Paso aukerak hitza ematen du apusturik ireki gabe. Embido aukerak apustua proposatzen du; Gehiago aukerak igo egiten du. Taldeak apustuetan blufa egin dezake, baina inoiz ez keinu faltsurik bidali.';

  @override
  String get menuRespondingTiraAndIduki => 'Erantzunak: Tira eta Iduki';

  @override
  String get menuWhenFacingABetIdukiAcceptsTheCardsWill =>
      'Apustu baten aurrean, Iduki aukerak onartzen du: kartek erabakiko dute zenbaketan. Tira aukerak uko egiten dio: fasea amaitu eta aurkariak aurreko apustuen araberako puntuak jasotzen ditu. Igoerak, berriz, apustu handiagoa proposatzen du.';

  @override
  String get menuHordagoTheWholeRound => 'Hordago: manka osoa';

  @override
  String get menuHordagoPutsTheEntireRoundAtStakeIfAccepted =>
      'Hordago aukerak manka osoa jartzen du jokoan. Iduki aukerarekin onartuz gero, fase horretako eskuak berehala alderatu eta irabazleak manka irabazten du. Tira aukerak erronkari uko egin eta ukoaren puntuak bakarrik uzten ditu. Handian eta Pareetan 2 apustu egingo dituzu, eta Jokoan igoera bat berdinduko duzu. Beste aukerak desgaituta egongo dira joko librera arte.';

  @override
  String get menuYourTurnToCall => 'Zure txanda berdintzeko';

  @override
  String get menuYourOpponentRaisesBy8TheBetGoesFrom =>
      'Aurkariak 8 igo du: apustua 2 harritik 10era igaro da. Sakatu Iduki onartzeko. Kartek erabakiko dute irabazlea zenbaketan.';

  @override
  String get menuTheCardsAreRevealedBetsAndPointsForPairs =>
      'Kartak agerian jartzen dira. Apustuak eta Pareetako eta Jokoko puntuak batzen dira. 40 harrira iristen den lehen taldeak manka irabazten du.';

  @override
  String get menuHighHandia => 'Handia';

  @override
  String get menuCompareCardsFromHighestToLowestTheKingIs =>
      'Kartak handienetik txikienera alderatzen dira. Erregea da indartsuena. Sakatu Egin 2ko apustua bi harri proposatzeko. Aurkari batek lehen apustua onartuko du.';

  @override
  String get menuLowTtipia => 'Ttipia';

  @override
  String get menuNowCompareTheLowestCardsTheAceIsBest =>
      'Oraingoan karta txikienak alderatzen dira. Batekoa da onena. Berdinketan hurrengo kartak alderatzen dira; erabateko berdinketa Esku jokalariak erabakitzen du.';

  @override
  String get menuPairsPareak => 'Pareak';

  @override
  String get menuTwoMatchingCardsMakeAPairThreeMakeMediak =>
      'Bi karta berdinek parea osatzen dute; hiruk Mediak; bi parek edo lau karta berdinek Dobliak. Pareak dituzten jokalariek bakarrik parte hartzen dute. Bi Errege dituzu: Bai iragarpenak zure parea iragartzen du. Sakatu Egin 2ko apustua hura defendatzeko.';

  @override
  String get menuGameJoko => 'Joko';

  @override
  String get menuFaceCardsAreWorth10AndOtherCardsTheir =>
      'Figurek 10 balio dute eta beste kartek beren balioa. Gutxienez 31 behar dira. Jokorik onena 31 da, gero 32. Inork Jokorik ez badu, Puntua jokatzen da, 30era ahalik eta gehien hurbilduz. Proposatu 2: aurkari batek igo egingo du eta Iduki aukerarekin berdintzen ikasiko duzu.';

  @override
  String get menuYourTurnToPlay => 'Zure txanda jokatzeko!';

  @override
  String get menuYouHaveLearnedYourWayAroundTheTable =>
      'Mahai osoa ezagutu duzu.';

  @override
  String get menuKeepPlayingAgainstTheBotsAllActionsAreAvailable =>
      'Jarraitu boten aurka: ekintza guztiak erabilgarri daude, kronometrorik eta aholkurik gabe. Menura ere itzul zaitezke.';

  @override
  String get menuReturnToMenu => 'Itzuli menura';

  @override
  String get menuFinishThisGameFreePlay => 'Amaitu partida (Librea)';

  @override
  String get menuGotIt => 'Ulertu dut';

  @override
  String get menuCheckYourEmailToActivateYourAccount =>
      'Begiratu zure posta kontua aktibatzeko.';

  @override
  String get menuAnAccountAlreadyUsesThisEmailAddress =>
      'Helbide elektroniko hori beste kontu batek erabiltzen du.';

  @override
  String get menuChooseAStrongerPassword => 'Aukeratu pasahitz sendoagoa.';

  @override
  String get menuTooManyAttemptsTryAgainShortly =>
      'Saiakera gehiegi. Saiatu berriro une batzuk barru.';

  @override
  String get menuUnableToSignUpTryAnotherNicknameAndCheck =>
      'Ezin izan da kontua sortu. Saiatu beste ezizen batekin eta egiaztatu datuak.';

  @override
  String get menuServiceUnavailableCheckYourConnectionAndTryAgain =>
      'Zerbitzua ez dago erabilgarri. Egiaztatu konexioa eta saiatu berriro.';

  @override
  String get menuSignUp => 'Erregistratu';

  @override
  String get menuJoinIsaMus => 'Batu IsaMusera';

  @override
  String get menuChooseYourNicknameAndJoinTheGame =>
      'Aukeratu ezizena eta sartu partidan.';

  @override
  String get menuNickname => 'Ezizena';

  @override
  String get menuChooseANickname => 'Aukeratu ezizen bat.';

  @override
  String get menu24CharactersMaximum => 'Gehienez 24 karaktere.';

  @override
  String get menuEmail => 'Posta elektronikoa';

  @override
  String get menuEnterAValidEmailAddress =>
      'Sartu baliozko helbide elektroniko bat.';

  @override
  String get menuPassword => 'Pasahitza';

  @override
  String get menuAtLeast8Characters => 'Gutxienez 8 karaktere';

  @override
  String get menuShowPassword => 'Erakutsi pasahitza';

  @override
  String get menuHidePassword => 'Ezkutatu pasahitza';

  @override
  String get menuUseAtLeast8Characters => 'Erabili gutxienez 8 karaktere.';

  @override
  String get menuCreateMyAccount => 'Sortu nire kontua';

  @override
  String get menuAlreadyHaveAnAccountSignIn => 'Baduzu kontua? Hasi saioa';

  @override
  String get menuIncorrectEmailOrPassword =>
      'Posta elektroniko edo pasahitz okerra.';

  @override
  String get menuConfirmYourEmailAddressBeforeSigningIn =>
      'Berretsi zure helbide elektronikoa saioa hasi aurretik.';

  @override
  String get menuUnableToSignInCheckYourDetailsAndTry =>
      'Ezin izan da saioa hasi. Egiaztatu datuak eta saiatu berriro.';

  @override
  String get menuYourTableIsWaiting => 'Zure mahaia zain duzu.';

  @override
  String get menuEnterYourPassword => 'Sartu pasahitza.';

  @override
  String get menuSignIn => 'Hasi saioa';

  @override
  String get menuPlayAsAGuest => 'Jokatu gonbidatu gisa';

  @override
  String get menuNoAccountYetSignUp => 'Ez duzu konturik? Erregistratu';

  @override
  String get menuQuestsUnavailable => 'Erronkak ez daude erabilgarri';

  @override
  String get menuClose => 'Itxi';

  @override
  String get menuANewWeekNewChallenges => 'Aste berria, erronka berriak.';

  @override
  String get menuResetsOnMondayAt0000UTCXPRewards =>
      'Astelehenetan berrabiarazten da, 00:00 UTCn. XP sariak automatikoki ematen dira.';

  @override
  String get menuNewChallengesComingSoon => 'Laster erronka berriak.';

  @override
  String menuArg0XPRewardReceived(String arg0) {
    return '+$arg0 XP · Saria jasota';
  }

  @override
  String get menuRewardReceived => 'Saria jasota';

  @override
  String menuArg0XP(String arg0) {
    return '+$arg0 XP';
  }

  @override
  String get menuXPRewardUnavailable => 'XP saria ez dago erabilgarri';

  @override
  String menuTierArg0Arg1(String arg0, String arg1) {
    return '$arg0. urratsa, $arg1';
  }

  @override
  String get menuNextGoal => 'hurrengo helburua';

  @override
  String get menuLocked => 'blokeatuta';

  @override
  String get menuVIP => 'VIP';

  @override
  String get menuFree => 'Doakoa';

  @override
  String get menuNoReward => 'Saririk ez';

  @override
  String get menuEarned => 'Lortuta';

  @override
  String get menuNextGoal189 => 'Hurrengo helburua';

  @override
  String menuLevelArg0(String arg0) {
    return '$arg0. maila';
  }

  @override
  String get menuVIPRequired => 'VIP behar da';

  @override
  String get menuSeasonEnded => 'Denboraldia amaituta';

  @override
  String get menuPleaseWait => 'Itxaron…';

  @override
  String get menuClaim => 'Jaso';

  @override
  String menuArg0Coins195(String arg0) {
    return ', $arg0 txanpon';
  }

  @override
  String get menuPreviewOnlyCosmeticNotYetDefinedOrAvailable =>
      'Aurrebista soilik: kosmetikoa zehazteke dago eta ez da oraindik banatzen.';

  @override
  String get menuUpcomingCosmetic => 'Datorren kosmetikoa';

  @override
  String get menuGoldCardBack => 'Urrezko karta-atzealdea';

  @override
  String get menuRubyTableFelt => 'Errubizko tapiza';

  @override
  String get menuActionUnavailableTryAgainShortly =>
      'Ekintza ez dago erabilgarri. Saiatu berriro une batzuk barru.';

  @override
  String get menuPassUnavailable => 'Pasea ez dago erabilgarri.';

  @override
  String get menuNoActiveSeason => 'Ez dago denboraldirik abian';

  @override
  String get menuDemoCalendar => 'Erakustaldiko egutegia';

  @override
  String menuArg0Arg1TiersUnlocked(String arg0, String arg1) {
    return '$arg0 / $arg1 urrats desblokeatuta';
  }

  @override
  String get menuAllTiersUnlocked => 'Urrats guztiak desblokeatuta!';

  @override
  String menuNextGoalTierArg0(String arg0) {
    return 'Hurrengo helburua: $arg0. urratsa';
  }

  @override
  String menuArg0XPLeftToReachIt(String arg0) {
    return '$arg0 XP falta dira iristeko.';
  }

  @override
  String get menuTapAnUnlockedRewardToClaimItAFree =>
      'Sakatu desblokeatutako sari bat jasotzeko. Doako sari bat 5 urratsean behin; VIP sari bat urrats bakoitzean.';

  @override
  String get menuRewardPath => 'Sarien ibilbidea';

  @override
  String get menuReached => 'Lortuta';

  @override
  String get menuGoal => 'Helburua';

  @override
  String get menuComingUp => 'Datorrena';

  @override
  String get menuRewardAlreadyReceived => 'Saria dagoeneko jasota';

  @override
  String menuArg0CoinsReceivedArg1(String arg0, String arg1) {
    return '$arg0 txanpon jasota$arg1';
  }

  @override
  String get menuCosmeticUnlocked => ' · Kosmetikoa desblokeatuta';

  @override
  String get menuPREMIUM => 'PREMIUM';

  @override
  String get menuYourVIPPassIsActive => 'Zure VIP pasea aktibo dago';

  @override
  String get menuUnlockTheVIPPass => 'Desblokeatu VIP pasea';

  @override
  String get menuNoAds => 'Iragarkirik gabe';

  @override
  String get menuVIPPassTrack => 'Pasearen VIP ibilbidea';

  @override
  String get menuXP2 => 'XP ×2';

  @override
  String get menuCoinsCanOnlyBeEarnedThroughTheSeasonPass =>
      'Txanponak denboraldiko pasean soilik lortzen dira. XP ×2 partidetan eta erronketan.';

  @override
  String get menuVIPIsTemporarilyUnavailable =>
      'VIP ez dago erabilgarri une honetan.';

  @override
  String get menuVIPActive => 'VIP aktibo';

  @override
  String get menuVIPComingSoon => 'VIP laster erabilgarri';

  @override
  String menuBecomeVIPArg0Month(String arg0) {
    return 'Bihurtu VIP · $arg0/hilean';
  }

  @override
  String get menuMonthlySubscriptionWithAutomaticRenewalCancelThroughYourApp =>
      'Harpidetza hilero berritzen da automatikoki. Utzi bertan behera zure aplikazio-dendan.';

  @override
  String get menuRestorePurchases => 'Berrezarri erosketak';

  @override
  String get menuNotEnoughCoinsForThisItem =>
      'Ez duzu artikulu honetarako nahikoa txanpon.';

  @override
  String get menuThisItemIsAlreadyInYourInventory =>
      'Artikulu hau zure inbentarioan dago jada.';

  @override
  String get menuThePriceHasChangedTheShopHasBeenRefreshed =>
      'Prezioa aldatu da. Denda eguneratu da.';

  @override
  String get menuThisItemIsNoLongerAvailable =>
      'Artikulu hau ez dago jada erabilgarri.';

  @override
  String get menuPurchaseFailedTryAgainShortly =>
      'Ezin izan da erosi. Saiatu berriro une batzuk barru.';

  @override
  String menuArg0AddedToYourInventory(String arg0) {
    return '$arg0 zure inbentariora gehituta';
  }

  @override
  String get menuOutfits => 'Jantziak';

  @override
  String get menuCardBacks => 'Karten atzealdeak';

  @override
  String get menuHeadwear => 'Burukoak';

  @override
  String get menuGlasses => 'Betaurrekoak';

  @override
  String get menuHair => 'Ilea';

  @override
  String get menuQuickChats => 'Mezu azkarrak';

  @override
  String get menuShopUnavailable => 'Denda ez dago erabilgarri.';

  @override
  String get menuNewItemsComingSoon => 'Laster artikulu berriak.';

  @override
  String get menuOwned => 'Jabetzan';

  @override
  String menuBuyArg0Arg1Coins(String arg0, String arg1) {
    return 'Erosi $arg0, $arg1 txanpon';
  }

  @override
  String get menuBuying => 'Erosten…';

  @override
  String get menuBuy => 'Erosi';

  @override
  String get menuUnableToCompleteThisActionCheckYourConnectionOr =>
      'Ezin izan da ekintza burutu. Egiaztatu konexioa edo saiatu berriro.';

  @override
  String get menuYourFriend => 'zure laguna';

  @override
  String menuInvitationSentArg0(String arg0) {
    return 'Gonbidapena bidalita: $arg0';
  }

  @override
  String get menuInAGame => 'Partida batean';

  @override
  String get menuOnline => 'Konektatuta';

  @override
  String get menuOffline => 'Deskonektatuta';

  @override
  String get menuInviteToPlay => 'Gonbidatu jokatzera';

  @override
  String get menuFriendOptions => 'Lagunaren aukerak';

  @override
  String get menuRemoveFriend => 'Kendu lagunetatik';

  @override
  String get menuFriendsPrivateRooms => 'Lagunak eta gela pribatuak';

  @override
  String get menuRequests => 'Eskaerak';

  @override
  String get menuBlocked => 'Blokeatuak';

  @override
  String get menuSearchForANickname => 'Bilatu ezizen bat';

  @override
  String get menuSearch => 'Bilatu';

  @override
  String get menuNoResultsEnterAtLeast2Characters =>
      'Ez dago emaitzarik. Sartu gutxienez 2 karaktere.';

  @override
  String get menuSendFriendRequest => 'Bidali lagun-eskaera';

  @override
  String get menuFriendRequestSent => 'Lagun-eskaera bidalita';

  @override
  String get menuUnableToLoadFriendsTryAgain =>
      'Ezin izan dira lagunak kargatu. Saiatu berriro';

  @override
  String get menuYourListIsEmptySearchForAPlayerTo =>
      'Zure zerrenda hutsik dago. Bilatu jokalari bat eskaera bidaltzeko.';

  @override
  String get menuUnableToLoadRequestsTryAgain =>
      'Ezin izan dira eskaerak kargatu. Saiatu berriro';

  @override
  String get menuNoPendingRequests => 'Ez dago eskaerarik zain.';

  @override
  String get menuReceived => 'Jasotakoak';

  @override
  String get menuSent => 'Bidalitakoak';

  @override
  String get menuRequestReceived => 'Eskaera jasota';

  @override
  String get menuRequestSent => 'Eskaera bidalita';

  @override
  String get menuAccept => 'Onartu';

  @override
  String get menuDecline => 'Baztertu';

  @override
  String get menuCancel => 'Utzi';

  @override
  String get menuUnableToLoadBlockedPlayersTryAgain =>
      'Ezin izan dira blokeoak kargatu. Saiatu berriro';

  @override
  String get menuNoBlockedPlayers => 'Ez dago jokalari blokeaturik.';

  @override
  String get menuBlockedPlayer => 'Jokalaria blokeatuta';

  @override
  String get menuPlayerUnblocked => 'Jokalaria desblokeatuta';

  @override
  String get menuUnblock => 'Desblokeatu';

  @override
  String menuInviteArg0(String arg0) {
    return 'Gonbidatu $arg0';
  }

  @override
  String get menuChooseHowToPlayTogether => 'Aukeratu nola jokatu elkarrekin.';

  @override
  String get menuSameTeamAgainstTwoOtherPlayers =>
      'Talde berean, beste bi jokalariren aurka';

  @override
  String get menuRoomWithACodeAndTeamSelection =>
      'Gela kodearekin eta taldeak aukeratuta';

  @override
  String get menuLeaveYourCurrentGame => 'Irten uneko partidatik';

  @override
  String get menuNavigationUnavailable => 'Nabigazioa ez dago erabilgarri';

  @override
  String get menuInvitationUnavailableLeaveYourCurrentGameOrTryAgain =>
      'Gonbidapena ez dago erabilgarri. Irten uneko partidatik edo saiatu berriro.';

  @override
  String get menuAFriend => 'Lagun bat';

  @override
  String menuArg0InvitesYouToPlayArg1(String arg0, String arg1) {
    return '$arg0 jokalariak $arg1 jokatzera gonbidatzen zaitu';
  }

  @override
  String get menuYouWillPlayOnTheSameTeam => 'Talde berean jokatuko duzue.';

  @override
  String get menuChooseYourTeamsInTheRoom => 'Aukeratu taldeak gelan.';

  @override
  String get menuDecline296 => 'Baztertu';

  @override
  String get menuNewFriendRequestReceived => 'Lagun-eskaera berria jasota';

  @override
  String menuArg0NewFriendRequests(String arg0) {
    return '$arg0 lagun-eskaera berri';
  }

  @override
  String get menuCloseNotification => 'Itxi jakinarazpena';

  @override
  String get menuOverallStatistics => 'Estatistika orokorrak';

  @override
  String get menuCurrentElo => 'Uneko Elo';

  @override
  String get menuPeakElo => 'Elo gorena';

  @override
  String get menuNoCompletedGames => 'Ez dago amaitutako partidarik';

  @override
  String menuArg0Wins(String arg0) {
    return '% $arg0 garaipen';
  }

  @override
  String get menuDetailsByMode => 'Modu bakoitzeko xehetasunak';

  @override
  String menuArg0WinsArg1LossesInArg2Games(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return '$arg0 garaipen, $arg1 porrot, $arg2 partidatan';
  }

  @override
  String get menuNoGames => 'Partidarik ez';

  @override
  String get menuWins => 'garaipen';

  @override
  String get menuWins309 => 'Garaipenak';

  @override
  String get menuLosses => 'Porrotak';

  @override
  String get menuCasual => 'Klasikoa';

  @override
  String get menuRanked => 'Sailkatua';

  @override
  String get menuSolo => 'Bakarka';

  @override
  String get menuPrivateRoomsWithHumanPlayersAreIncludedInCasual =>
      'Giza jokalarien gela pribatuak Klasikoan sartzen dira.';

  @override
  String menuArg0OlderGamesWithoutDetailedHistoryAreNotAssigned(String arg0) {
    return 'Historia zehatzik gabeko $arg0 partida zahar ez daude moduka banatuta.';
  }

  @override
  String get menuUnableToSendTheRequestTryAgain =>
      'Ezin izan da eskaera bidali. Saiatu berriro.';

  @override
  String get menuBlockThisPlayer => 'Jokalari hau blokeatu?';

  @override
  String get menuYourFriendshipWillBeRemovedAndPendingRequestsAnd =>
      'Adiskidetasuna ezabatu eta zain dauden eskaerak eta gonbidapenak bertan behera utziko dira. Jokalari honek ezin izango du zurekin bide horretatik harremanetan jarri. Blokeatuak fitxatik desblokea dezakezu.';

  @override
  String get menuBlock => 'Blokeatu';

  @override
  String get menuUnableToUpdateTheBlockTryAgain =>
      'Ezin izan da blokeoa aldatu. Saiatu berriro.';

  @override
  String get menuProfileUnavailable => 'Profila ez dago erabilgarri.';

  @override
  String get menuPlayerProfile => 'Jokalariaren profila';

  @override
  String get menuWinRate => 'Garaipen-tasa';

  @override
  String get menuGamesPlayed => 'Jokatutako partidak';

  @override
  String menuArg0WinsArg1Losses(String arg0, String arg1) {
    return '$arg0 garaipen · $arg1 porrot';
  }

  @override
  String get menuAddFriend => 'Gehitu laguna';

  @override
  String get menuSignInRequired => 'Saioa hasi behar da';

  @override
  String get menuYourProfile => 'Zure profila';

  @override
  String get menuSending => 'Bidaltzen…';

  @override
  String get menuCheckingFriendship => 'Harremana egiaztatzen…';

  @override
  String get menuAlreadyFriends => 'Lagunak zarete jada';

  @override
  String get menuCheckFriendshipAgain => 'Egiaztatu harremana berriro';

  @override
  String get menuServiceUnavailableTryAgainShortly =>
      'Zerbitzua ez dago erabilgarri. Saiatu berriro une batzuk barru.';

  @override
  String get menuDeleteYourAccount => 'Zure kontua ezabatu?';

  @override
  String get menuYourProfileFriendsAndHistoryWillBePermanentlyDeleted =>
      'Zure profila, lagunak eta historia behin betiko ezabatuko dira. Erosketek denden arauak beteko dituzte. Ekintza hau ezin da desegin.';

  @override
  String get menuDeletePermanently => 'Ezabatu behin betiko';

  @override
  String get menuAccountDeleted => 'Kontua ezabatuta.';

  @override
  String get menuGuestAccount => 'Gonbidatu-kontua';

  @override
  String get menuSignedInAccount => 'Konektatutako kontua';

  @override
  String get menuGuest => 'Gonbidatua';

  @override
  String get menuSignedOut => 'Saioa amaituta.';

  @override
  String get menuSignOut => 'Amaitu saioa';

  @override
  String get menuDeleteMyAccount => 'Ezabatu nire kontua';

  @override
  String menuArg0Arg1XP(String arg0, String arg1) {
    return '$arg0 / $arg1 XP';
  }

  @override
  String menuLevelArg0ProgressArg1XPOutOf500(String arg0, String arg1) {
    return '$arg0. mailaren aurrerapena, $arg1 XP / 500';
  }

  @override
  String menuArg0XPToGoBeforeLevelArg1(String arg0, String arg1) {
    return '$arg0 XP falta dira $arg1. mailarako';
  }

  @override
  String get menuChangeNickname => 'Aldatu ezizena';

  @override
  String get menuSave => 'Gorde';

  @override
  String get menuProfileUnavailableTryAgain =>
      'Profila ez dago erabilgarri. Saiatu berriro';

  @override
  String get menuPlayerProfile352 => 'Jokalariaren profila';

  @override
  String get menuEditMyAvatar => 'Editatu nire avatarra';

  @override
  String get menuCustomisation => 'Karta kolorea';

  @override
  String get menuRecentGames => 'Azken partidak';

  @override
  String get menuReloadHistory => 'Birkargatu historia';

  @override
  String get menuYourNextCompletedGamesWillAppearHere =>
      'Amaitzen dituzun hurrengo partidak hemen agertuko dira.';

  @override
  String get menuWin => 'Garaipena';

  @override
  String get menuLoss => 'Porrota';

  @override
  String get menuPrivate => 'Pribatua';

  @override
  String get menuEquipmentSavedTryLoadingTheInventoryAgain =>
      'Ekipamendua gordeta. Saiatu inbentarioa berriro kargatzen.';

  @override
  String get menuUnableToEquipCheckYourConnectionAndTryAgain =>
      'Ezin izan da ekipatu. Egiaztatu konexioa eta saiatu berriro.';

  @override
  String get menuInventoryUnavailable => 'Inbentarioa ez dago erabilgarri.';

  @override
  String get menuTheOriginalBlueCardBackAlwaysAvailable =>
      'Jatorrizko karta-atzealde urdina, beti erabilgarri.';

  @override
  String get menuEquipped => 'Ekipatuta';

  @override
  String menuArg0Equipped(String arg0) {
    return '$arg0 ekipatuta';
  }

  @override
  String get menuEquip => 'Ekipatu';

  @override
  String menuSeasonArg0Arg1(String arg0, String arg1) {
    return '$arg0/$arg1 denboraldia';
  }

  @override
  String get menuSeasonEnds => 'Denboraldiaren amaiera';

  @override
  String get menuDays => 'Egunak';

  @override
  String get menuHours => 'Orduak';

  @override
  String get menuMinutes => 'Minutuak';

  @override
  String get menuSeconds => 'Segundoak';

  @override
  String menuSeasonEndsInArg0DaysArg1HoursArg2Minutes(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Denboraldia $arg0 egun, $arg1 ordu, $arg2 minutu eta $arg3 segundo barru amaituko da';
  }

  @override
  String get menuYourSeasonsBestEloDeterminesYourRewardsTiersAre =>
      'Denboraldiko zure Elo onenak zehazten ditu sariak. Mailak metagarriak dira.';

  @override
  String get menuBronzeBorder => 'Brontzezko ertza';

  @override
  String get menuSilverBorder => 'Zilarrezko ertza';

  @override
  String get menuGoldBorder => 'Urrezko ertza';

  @override
  String get menuTxapelaBeret => 'Txapela';

  @override
  String get menuAtTheMonthlyCloseEloAndPeakEloReset =>
      'Hilabetea amaitzean, Elo eta Elo gorena 800era itzultzen dira. Kosmetikoak zureak dira: ekipatu Editatu nire avatarra → Ertzak / Garaikurrak atalean.';

  @override
  String get menuSkin => 'Azala';

  @override
  String get menuTop => 'Goiko jantzia';

  @override
  String get menuBackgroundColour => 'Atzeko planoaren kolorea';

  @override
  String get menuHairColour => 'Ilearen kolorea';

  @override
  String get menuBorders => 'Ertzak';

  @override
  String get menuNone => 'Bat ere ez';

  @override
  String get menuBronze => 'Brontzea';

  @override
  String get menuSilver => 'Zilarra';

  @override
  String get menuDiamond => 'Diamantea';

  @override
  String get menuNone391 => 'Bat ere ez';

  @override
  String get menuTxapela => 'Txapela';

  @override
  String get menuCrown => 'Koroa';

  @override
  String get menuCap => 'Bisera';

  @override
  String get menuBeanie => 'Txanoa';

  @override
  String get menuBald => 'Burusoila';

  @override
  String get menuMohawk => 'Gandorra';

  @override
  String get menuGoldFrames => 'Urrezko markoa';

  @override
  String get menuRound => 'Biribilak';

  @override
  String get menuStripedShirt => 'Kamiseta marraduna';

  @override
  String get menuUnableToSaveCheckYourConnectionAndTryAgain =>
      'Ezin izan da gorde. Egiaztatu konexioa eta saiatu berriro.';

  @override
  String get menuSaving => 'Gordetzen…';

  @override
  String get menuSave403 => 'Gorde';

  @override
  String menuAvatarSkinArg0HairArg1GlassesArg2TopArg3(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Avatarra: azala $arg0, ilea $arg1, betaurrekoak $arg2, goiko jantzia $arg3';
  }

  @override
  String get menuBrightRed => 'Gorri bizia';

  @override
  String get menuOrange => 'Laranja';

  @override
  String get menuSunshineYellow => 'Eguzki-horia';

  @override
  String get menuAppleGreen => 'Sagar-berdea';

  @override
  String get menuPineGreen => 'Izei-berdea';

  @override
  String get menuCyan => 'Ziana';

  @override
  String get menuNavyBlue => 'Itsas urdina';

  @override
  String get menuDeepPurple => 'More sakona';

  @override
  String get menuFuchsiaPink => 'Arrosa fuksia';

  @override
  String get menuBrown => 'Marroia';

  @override
  String get menuLightGrey => 'Gris argia';

  @override
  String get menuCharcoal => 'Antrazita';

  @override
  String get menuBrunette => 'Gaztaina';

  @override
  String get menuBlonde => 'Horia';

  @override
  String get menuBlack => 'Beltza';

  @override
  String get menuCopper => 'Kobrea';

  @override
  String get menuPurple => 'Morea';

  @override
  String get menuFrenchMusChampionshipRegulations =>
      'Frantziako Mus Txapelketaren Araudia';

  @override
  String get menuFederationFrancaiseDeMus => 'Fédération Française de Mus';

  @override
  String get menuLastRevisedJanuary2023 => 'Azken aldaketak: 2023ko urtarrila.';

  @override
  String get menuPrinciplesAndRankings => 'Oinarriak eta sailkapena';

  @override
  String get menuMusIsPlayedInTeamsOf2WithA =>
      'Mus bina jokalariko taldeetan jokatzen da, 40 kartako baraja espainiarrarekin, 40 puntuko 3 mankatan (40 tantto edo 8 hamarreko), salbuespenak salbuespen.';

  @override
  String get menuRankingsAreCalculatedAsFollows3RoundsWon1 =>
      'Sailkapena honela egiten da: irabazitako 3 manka = garaipen 1.';

  @override
  String get menuAWinnerOneWinIsCountedRegardlessOfRounds =>
      'a) Irabazlea: garaipen bat zenbatzen da, galdutako mankak eta haietan lortutako puntuak kontuan hartu gabe.';

  @override
  String get menuBLoser0WinsAreCountedAlongWithRounds =>
      'b) Galtzailea: 0 garaipen, irabazitako mankak eta galdutako manketan lortutako puntuak bakarrik zenbatzen dira.';

  @override
  String get menuForTheFirstDealThePlayerWhoDrewThe =>
      'Lehen banaketan, karta txikiena atera duenak ematen du. Kartak nahasi eta ezkerreko aurkariari moztarazi behar dizkio, ebakiaren gainean edo azpian karta bat baino gehiago utzita. Banatzaileak kartak banan-banan ematen ditu goitik, eskuineko aurkaritik hasita; hura izango da Esku. Jokalari bakoitzak jasotako karta kopurua egiaztatu behar du. Banaketa amaitu aurretik begira daitezke kartak.';

  @override
  String get menuIfACardIsTurnedOverDuringTheFirst =>
      'Lehen banaketan karta bat agerian geratzen bada edo beste akatsen bat badago (4 karta baino gehiago edo gutxiago, etab.), denak bildu, nahasi, moztu eta berriro banatzen dira.';

  @override
  String get menuIfTheErrorIsFoundAfterPlayHasBegun =>
      'Akatsa jokoa hasi ondoren antzematen bada, hau da, jokalari batek Mus eten ondoren, lau karta baino gehiago edo gutxiago dituenak ez du parte hartuko, eta haren taldeak lortutako puntuak baliogabetuko dira.';

  @override
  String get menuIfACardIsTurnedOverAfterMusHas =>
      'Behin Mus izan ondoren karta bat agerian geratzen bada, jokoak normaltasunez jarraitzen du.';

  @override
  String get menuEskuAndTheirPartnerDecideWhetherToStopWith =>
      'Esku jokalariak eta haren bikotekideak Mintza esanez eten edo Mus joatea erabakitzen dute, Zuetan edo «Zuei» esanez. Ondoren aurkariek gauza bera egiten dute beren txandan.';

  @override
  String get menuIfThereIsMusAll4PlayersDiscardThe =>
      'Mus badago, 4 jokalariek nahi dituzten kartak batera baztertzen dituzte, ESKU lehena izanik. Banatzaileak jokalari bakoitzari karta berriak aldi bakarrean ematen dizkio.';

  @override
  String get menuPlayBeginsWithESKUFirstHighThenLowPairs =>
      'ESKU hasita jokatzen da beti: lehenik Handia, gero Ttipia, Pareak, Jokoa edo Puntua. Biak Embido eta Biak Hordago apustuak onartzen dira.';

  @override
  String get menuTiraIdukiAndHordagoBindTheTeamTheSpeakers =>
      'Tira, Iduki eta Hordago hitzek taldea lotzen dute: bikotekideak ezin ditu ezeztatu, Esku izanda ere. Nere gatik tira nahiz Tira nere gatik onartzen dira, edo «Niregatik, utzi», bikotekideari igotzeko aukera utziz. Biek apustu egin edo igotzen badute, lehen erabakia nagusitzen da. Hordago Kanta ondoren ez da punturik (tantto) zenbatzen.';

  @override
  String get menuSigns => 'Keinuak';

  @override
  String get menuOnlyTheFollowingOfficialSignsAreAllowed =>
      'Honako keinu ofizial hauek bakarrik onartzen dira:';

  @override
  String get menu2KingsLowerLip => '2 errege: beheko ezpaina.';

  @override
  String get menu2AcesStickOutTheTongue => '2 bateko: mihia atera.';

  @override
  String get menuMediakMoveOneSideOfTheLips =>
      'Mediak: ezpainen alde bat mugitu.';

  @override
  String get menuDobliakMoveBothSidesOfTheLips =>
      'Dobliak: ezpainen bi aldeak mugitu.';

  @override
  String get menu29SameAsMediak => '29: mediak bezala.';

  @override
  String get menu30Or31Wink => '30 edo 31: begi bati keinu egin.';

  @override
  String get menuGameRaiseTheEyebrows => 'Jokoa: bekainak altxatu.';

  @override
  String get menuTheSignFor30Or31MayBeMade =>
      '30 edo 31ren keinua edozein unetan egin daiteke. 29rena Pareak amaitu ondoren bakarrik. 31 edukita debekatuta dago Jokoaren keinua egitea.';

  @override
  String get menuDoublePairs => 'Bi pare';

  @override
  String get menuWhen2OpponentsHaveDoublePairsWithTheSame =>
      'Bi aurkarik goiko pare bera duten bi pare badituzte, beheko pare indartsuena duenak irabazten du beti. Adibidez: bi hamaika + bi zazpi, azken eskua izanda ere, bi hamaika + bi sei baino gehiago dira.';

  @override
  String get menuErrors => 'Akatsak';

  @override
  String get menuAnnouncingPairsWithoutHavingAny =>
      'Parerik izan gabe pareak iragartzea:';

  @override
  String get menuAIfThePartnerHasNoneAllBetsOn =>
      'a) Bikotekideak ez badu parerik, Pareetako apustu guztiak baliogabetzen dira. Aurkariak bere pareen puntuak zenbatzen ditu.';

  @override
  String get menuBIfThePartnerHasPairsAndTheOpponents =>
      'b) Bikotekideak eta aurkariek pareak badituzte, Pareetako apustu guztiak baliogabetzen dira; aurkariak Pareetako TIRA eta bere pareen puntuak zenbatzen ditu.';

  @override
  String get menuFailingToAnnouncePairsWhenHoldingThem =>
      'Pareak edukita ez iragartzea:';

  @override
  String get menuUnannouncedPairsCannotBeUsedToBetCallOr =>
      'Ukatutako pareek ez dute balio apustu egiteko, onartzeko edo gero zenbatzeko.';

  @override
  String get menuIfThePartnerHasNoPairsAnOpponentWith =>
      'Bikotekideak parerik ez badu, pareak dituen aurkariak Tira puntu bat jasotzen du.';

  @override
  String get menuAnnouncingGameWithoutHavingIt =>
      'Jokorik izan gabe Jokoa iragartzea:';

  @override
  String get menuAIfNoneOfTheOther3PlayersHas =>
      'a) Beste 3 jokalariek Jokorik ez badute, aurkariek Puntuko Tira eta Pontua puntua jasotzen dituzte.';

  @override
  String get menuBIfThePartnerHasGameAndTheOpponents =>
      'b) Bikotekideak Jokoa badu eta aurkariek ez, akatsa ez da kontuan hartzen.';

  @override
  String get menuCIfThePartnerHasNoGameButAn =>
      'c) Bikotekideak Jokorik ez badu eta aurkariak bai, Jokoko apustuak baliogabetzen dira eta aurkariak bere Jokoaren puntuak jasotzen ditu.';

  @override
  String get menuDIfThePartnerAndAnOpponentBothHave =>
      'd) Bikotekideak eta aurkari batek Jokoa badute, Jokoko apustuak baliogabetzen dira; aurkariak Jokoko TIRA eta bere Jokoaren puntuak jasotzen ditu.';

  @override
  String get menuFailingToAnnounceGameWhenHoldingIt =>
      'Jokoa edukita ez iragartzea:';

  @override
  String get menuAIfNoneOfTheOther3PlayersHas465 =>
      'a) Beste 3 jokalariek Jokorik ez badute, Puntuko apustuak baliogabetzen dira, eta aurkariak Tira aukeraren ttantto eta Pontua puntua jasotzen ditu. Iragarri gabeko Jokoak ez du balio.';

  @override
  String get menuBIfThePartnerHasGameAndTheOpponents466 =>
      'b) Bikotekideak Jokoa badu eta aurkariek ez, bikotekidearen Jokoa bakarrik zenbatzen da.';

  @override
  String get menuCIfThePartnerHasNoGameAndAn =>
      'c) Bikotekideak Jokorik ez badu eta aurkariak bai, aurkariak Jokoko TIRA eta bere Jokoaren puntuak jasotzen ditu. Parerik edo Jokorik ez duenak ezin du apustu egin edo igo horiek dituen bikotekidearen ordez.';

  @override
  String get menuScoringAndRaises => 'Zenbaketa eta igoerak';

  @override
  String get menuDuringPlayPointsConcededThroughTIRAAreScoredAs =>
      'Jokoan zehar, TIRA bidez utzitako puntuak unean bertan zenbatzen dira. Erabateko berdinketan, ESKU nagusitzen da beti. Esku bakoitzaren amaieran, laurek karta guztiak mahai gainean erakutsi behar dituzte.';

  @override
  String get menuScoreHighThenLowPairsGameOrPointAs =>
      'Handia, gero Ttipia, Pareak, Jokoa edo Puntua honela zenbatzen dira:';

  @override
  String get menuHighIfEveryoneSaidPASOTheBestHighScores =>
      'Handia: PASO bakarrik izan bada, Handi onenak puntu 1 jasotzen du (Haundi Pasa). Embido ondoren Handia utzi bada, ez da ezer zenbatzen. Iduki izan bada, apustuko puntuak bakarrik zenbatzen dira.';

  @override
  String get menuLowTheSameAsHigh => 'Ttipia: Handian bezala.';

  @override
  String get menuPairsAfterPasoTheTeamWithTheBestPair =>
      'Pareak: Paso izan bada, pare onena duen taldeak bere pareak zenbatzen ditu: puntu 1 parearengatik, 2 mediak edo 3 bi parerengatik. Iduki izan bada, apustuko puntuak gehitzen dira.';

  @override
  String get menuGameTheSameAsPairsCounting2PointsFor =>
      'Jokoa: Pareetan bezala, 2 puntu Jokoarengatik edo 3 puntu 31gatik, Jokoa irabazi duen taldeko Joko bakoitzeko.';

  @override
  String get menuPointPontuaAfterPasoTheBestPontuaScores1 =>
      'Puntua (Pontua): Paso izan bada, Pontua onenak puntu 1 jasotzen du. Tira izan bada, Tira irabazi duen taldeak Pontua puntu 1 jasotzen du. Iduki izan bada, apustuko puntuak gehi Pontua puntu 1 zenbatzen dira.';

  @override
  String get menuRaiseExamples => 'Igoeren adibideak:';

  @override
  String get menuEmbido2PointsTira1Point => 'Embido (2 puntu) - Tira = puntu 1';

  @override
  String get menuEmbido2PointsIduki2Points =>
      'Embido (2 puntu) - Iduki = 2 puntu';

  @override
  String get menuHordagoTira1Point => 'Hordago - Tira = puntu 1';

  @override
  String get menuHiruEmbido3PointsTira1Point =>
      'Hiru Embido (3 puntu) - Tira = puntu 1';

  @override
  String get menuHiruEmbido3PointsIduki3Points =>
      'Hiru Embido (3 puntu) – Iduki = 3 puntu';

  @override
  String get menuEmbido2PointsLauGehiago4Tira2Points =>
      'Embido (2 puntu) Lau gehiago (+ 4) - Tira = 2 puntu';

  @override
  String get menuEmbido2PointsBigehiago2HordagoTira4Points =>
      'Embido (2 puntu) – Bigehiago( +2 ) – Hordago - Tira = 4 puntu';

  @override
  String get menuHiruEmbido3PointsLauGehiago4Iduki7 =>
      'Hiru Embido (3 puntu) Lau gehiago (+ 4) Iduki = 7 puntu';

  @override
  String get menuEmbido2PointsBortzGehiago5Bigehiago2Tira =>
      'Embido (2 puntu) Bortz gehiago (+ 5) Bigehiago (+2) Tira = 7 puntu';

  @override
  String get menuNoTtanttoMayBeScoredOnceTheCardsHave =>
      'Kartak bildu ondoren ezin da ttanttorik zenbatu.';

  @override
  String get menuRefereeing => 'Epailetza';

  @override
  String get menuTheRefereeIntervenesOnlyAtAPlayersRequestOr =>
      'Epaileak jokalari batek eskatuta edo irregulartasun bat ikusita bakarrik esku hartzen du.';

  @override
  String get menuAnyDisputeOverTheseRegulationsOrAnySituationNot =>
      'Araudiaren interpretazioko edozein gatazka eta hemen aurreikusi gabeko arazo oro epaileak ebatziko ditu.';

  @override
  String get menuTheRefereeMayImposePenaltiesUpToAndIncluding =>
      'Epaileak kanporatzerainoko zigorrak ezar ditzake.';

  @override
  String menuArticleArg0(String arg0) {
    return '$arg0. artikulua';
  }

  @override
  String get invitationPrivateTitle => 'Sortu gela pribatu bat';

  @override
  String get invitationPrivateLabel => 'Gela pribatua';

  @override
  String get invitationCasualTitle => 'Sarean (Klasikoa) bikotean';

  @override
  String get invitationCasualLabel => 'Klasikoa bikotean';

  @override
  String get invitationRankedTitle => 'Sarean (Sailkatua) bikotean';

  @override
  String get invitationRankedLabel => 'Sailkatua bikotean';

  @override
  String get classicCardBack => 'Karta-atzealde klasikoa';

  @override
  String gamesPlayedCount(String count) {
    return '$count partida';
  }

  @override
  String avatarOption(String name, String number) {
    return '$name: $number. aukera';
  }

  @override
  String get nicknameLengthError =>
      'Ezizenak 1 eta 24 karaktere artean izan behar ditu.';

  @override
  String get deleteAccountError =>
      'Ezin izan da kontua ezabatu. Saiatu berriro.';

  @override
  String get connectionUnavailable =>
      'Konexioa ez dago erabilgarri. Saiatu berriro.';

  @override
  String seasonName(String name) {
    return '$name denboraldia';
  }

  @override
  String questPlay(String count) {
    return 'Amaitu $count partida';
  }

  @override
  String questWin(String count) {
    return 'Irabazi $count partida';
  }

  @override
  String questRanked(String count) {
    return 'Irabazi $count partida sailkatu';
  }

  @override
  String get questGeneric => 'Asteko erronka';

  @override
  String get catalogUnknown => 'Kosmetikoa';

  @override
  String get catalogUnknownDescription => 'Pertsonalizatu zure itxura mahaian.';

  @override
  String get catalogSun => 'Eguzkia';

  @override
  String get catalogMountain => 'Mendia';

  @override
  String get catalogBlue => 'Urdina';

  @override
  String get catalogGreen => 'Berdea';

  @override
  String get catalogOcean => 'Ozeanoa';

  @override
  String get catalogRuby => 'Errubia';

  @override
  String get catalogDiamondBorder => 'Diamantezko ertza';

  @override
  String get catalogLeagueTxapela => 'Ligako Txapela';

  @override
  String get catalogLeagueCrown => 'Ligako koroa';

  @override
  String get catalogEmeraldBorder => 'Esmeraldazko markoa';

  @override
  String get catalogAmethystBorder => 'Ametistazko markoa';

  @override
  String get catalogEmeraldBack => 'Esmeraldazko karta-atzealdea';

  @override
  String get catalogVioletBack => 'Karta-atzealde morea';

  @override
  String get catalogEskerrik => 'Eskerrik asko !';

  @override
  String get catalogRematch => 'Errebantxa?';

  @override
  String get catalogMullet => 'Mulet orrazkera';

  @override
  String get catalogStriped => 'Kamiseta marra urdin eta zuriekin';

  @override
  String get catalogGoldGlasses => 'Urrezko eguzkitako betaurrekoak';

  @override
  String get catalogCap => 'Bisera urdina';

  @override
  String get catalogBeanie => 'Kobrezko txanoa';

  @override
  String get catalogRoundGlasses => 'Betaurreko biribilak';

  @override
  String get catalogOceanBack => 'Ozeano karta-atzealdea';

  @override
  String get catalogCoralBack => 'Koral karta-atzealdea';

  @override
  String get catalogEmeraldBorderDescription =>
      'Esmeraldazko eraztun bat zure avatarraren inguruan.';

  @override
  String get catalogAmethystBorderDescription =>
      'Ertz more bat mahaian erakusteko.';

  @override
  String get catalogEmeraldBackDescription =>
      'Esmeralda-berdeko karta-atzealdea.';

  @override
  String get catalogVioletBackDescription => 'Karta-atzealde morea.';

  @override
  String get catalogEskerrikDescription =>
      'Eskertu beste jokalariak ukitu batekin.';

  @override
  String get catalogRematchDescription =>
      'Proposatu beste partida bat mahaiari.';

  @override
  String get catalogMulletDescription =>
      'Aurrean motza, atzean luzea: nortasun handiko orrazkera.';

  @override
  String get catalogStripedDescription =>
      'Marra urdinak eta zuriak zure jantzirako.';

  @override
  String get catalogGoldGlassesDescription =>
      'Lente ilunak eta urrezko markoa.';

  @override
  String get catalogCapDescription => 'Bisera urdin bat ilearen gainean.';

  @override
  String get catalogBeanieDescription => 'Kobrezko txano bat borlarekin.';

  @override
  String get catalogFineGlassesDescription =>
      'Urrezko marko mehea, begiak agerian uzten dituena.';

  @override
  String get catalogRoundGlassesDescription =>
      'Lente gardenak eta marko biribila.';

  @override
  String get catalogOceanBackDescription => 'Eredu klasiko bat urdin sakonean.';

  @override
  String get catalogCoralBackDescription => 'Eredu klasiko bat koral kolorean.';

  @override
  String get catalogBaldDescription => 'Burua agerian, ile-geruzarik gabe.';

  @override
  String get catalogMohawkDescription => 'Erdiko gandorra, aurretik ikusgai.';

  @override
  String get legalTermsBody =>
      'ISAMUS — CONDITIONS GÉNÉRALES D’UTILISATION\nVersion du 30 octobre 2026\n\nÉditeur : Aloys Lartiguelongue, domicilié à Saint-Palais, France.\nContact et réclamations : aloys.lartiguelongue@etud.univ-pau.fr.\n\n1. Objet et champ d’application\nLes présentes conditions générales d’utilisation (CGU) encadrent l’accès à IsaMus, jeu de cartes Mus, variante 4 Rois / 4 As, disponible sur les plateformes compatibles. Elles régissent les parties avec d’autres joueurs ou des robots, le compte, les classements, les fonctions sociales et les éléments virtuels. La Politique de confidentialité explique séparément les traitements de données ; accepter les CGU ne constitue pas un consentement aux traitements facultatifs.\nIsaMus est un jeu de divertissement : aucune mise d’argent, aucun gain monétaire et aucun échange de points contre de l’argent ne sont proposés. Les règles, modes et fonctionnalités disponibles sont présentés dans le jeu. Certains services dépendent de la plateforme, de la version ou de leur activation.\nLes CGU sont consultables dans Réglages. L’utilisateur doit en prendre connaissance avant de créer un compte ou d’utiliser le service. Elles peuvent être conservées ou demandées par e-mail. Les conditions des boutiques et fournisseurs de connexion s’appliquent à leurs propres prestations, sans diminuer les droits impératifs de l’utilisateur.\n\n2. Conditions d’accès et mineurs\nL’utilisateur dispose d’un appareil compatible et d’une connexion à Internet dont les frais restent à sa charge. Il veille à installer les mises à jour nécessaires à la sécurité et au fonctionnement du jeu.\nLe service est destiné aux personnes de quinze ans et plus. L’utilisateur mineur doit disposer de l’autorisation de son représentant légal lorsque sa capacité juridique ou la nature de l’acte l’exige, notamment pour les achats. Une classification d’âge attribuée par une boutique ne remplace pas ces conditions contractuelles. Si la législation locale impose un âge ou une autorisation plus protecteurs, ces exigences s’appliquent. Toute utilisation par un enfant ne remplissant pas ces conditions peut être signalée au contact indiqué en en-tête afin d’organiser la fermeture du compte et le traitement des données.\n\n3. Création, sécurisation et gestion du compte\nUn compte invité permet de commencer à jouer. Sa récupération peut devenir impossible en cas de perte de la session, de réinstallation ou de changement d’appareil. L’association à une adresse e-mail vérifiée ou à une identité Apple ou Google, lorsque cette possibilité est disponible, permet de sécuriser l’accès. L’utilisateur fournit des informations exactes pour les éléments nécessaires au service et les tient à jour ; l’emploi d’un pseudonyme est autorisé.\nL’utilisateur choisit un pseudo respectueux, sans usurpation ni divulgation de données personnelles de tiers, protège ses identifiants et ne les partage pas. Il signale sans délai un accès suspect. Aucune demande d’assistance ne nécessite la transmission de son mot de passe. L’éditeur reste responsable des défauts de sécurité qui lui sont imputables ; l’utilisation d’un compte ne suffit pas, à elle seule, à établir une faute de son titulaire.\nLa vente, la location et le transfert de comptes ainsi que la création de comptes destinée à contourner une sanction ou manipuler le classement sont interdits.\n\n4. Règles de jeu et comportements interdits\nL’utilisateur respecte les règles affichées et les autres participants. Sont interdits : la triche, la collusion entre joueurs, la manipulation des scores, les logiciels d’automatisation non autorisés, l’exploitation volontaire de failles et toute tentative d’accès aux données ou cartes que les règles ne permettent pas de consulter. Une anomalie peut être signalée par e-mail sans l’exploiter ni divulguer de données de tiers.\nSont également interdits le harcèlement, les insultes, les menaces, les propos discriminatoires ou haineux, les contenus illicites, l’usurpation d’identité, les sollicitations répétées non désirées, le spam et les comportements visant à perturber les parties ou l’infrastructure. Les demandes d’amitié et invitations peuvent être refusées ; les outils de blocage disponibles peuvent être utilisés.\nLes robots sont identifiés comme tels. Les délais de décision, abandons et déconnexions peuvent déclencher des actions automatiques et affecter le résultat ou le classement selon les règles du jeu. Aucun résultat, niveau ou classement particulier n’est garanti.\n\n5. Signalements, modération et sanctions\nUn abus peut être signalé à aloys.lartiguelongue@etud.univ-pau.fr en précisant les faits, la date, le pseudo concerné et les éléments utiles, sans communiquer de données excessives. L’éditeur examine les éléments disponibles et peut prendre des mesures proportionnées à la gravité, à la répétition et au contexte : avertissement, retrait d’un pseudo ou contenu illicite, correction d’un résultat frauduleux, restriction temporaire, suspension ou fermeture du compte.\nSauf urgence de sécurité, obligation légale ou nécessité de préserver une enquête, l’utilisateur reçoit une information sur les motifs et la portée de la mesure et peut présenter ses observations par e-mail. Il peut demander un réexamen humain à la même adresse. Une sanction ne peut supprimer les recours légaux ni justifier la confiscation arbitraire d’un contenu payé. Les droits éventuels à restitution ou remboursement restent appréciés selon la loi et les circonstances.\n\n6. Objets virtuels, achats et abonnements\nLes points, l’expérience, le classement, les récompenses et objets virtuels n’ont aucune valeur monétaire réelle, ne constituent ni une monnaie ni un actif financier et ne peuvent être convertis en argent, revendus ou transférés entre joueurs dans le service. Les cosmétiques modifient l’apparence sans procurer d’avantage sur les cartes ni les scores. Leur acquisition confère un droit personnel d’utilisation dans le jeu, sans transfert de propriété intellectuelle.\nLorsqu’un achat est proposé, ses caractéristiques, son prix total, sa durée et ses conditions sont présentés avant validation. Un abonnement éventuel précise sa périodicité, son renouvellement et ses modalités de résiliation dans le parcours de souscription. Aucune facturation ne résulte de la seule utilisation gratuite du jeu. Apple ou Google traitent les paiements sur leurs boutiques ; RevenueCat peut assurer la validation et la synchronisation des droits. IsaMus ne reçoit pas le numéro complet de carte bancaire. La restauration des achats reste soumise à la vérification des droits et du compte concerné.\nLes droits légaux de rétractation et de remboursement demeurent applicables. Lorsqu’il existe, le délai de rétractation est en principe de quatorze jours à compter de la conclusion du contrat. Pour un contenu numérique sans support matériel, la perte de ce droit suppose que les conditions légales soient réunies, notamment l’accord préalable exprès au commencement de l’exécution, la reconnaissance expresse de la perte du droit et la confirmation requise ; la seule acceptation des CGU n’y suffit pas. L’utilisateur peut adresser sa demande au vendeur identifié lors de l’achat et contacter l’éditeur pour assistance. La suppression d’un compte ne résilie pas automatiquement un abonnement souscrit auprès d’une boutique.\nLes garanties légales applicables aux contenus et services numériques, notamment celles prévues aux articles L. 224-25-12 et suivants du Code de la consommation, sont préservées. Selon les conditions légales, le consommateur peut obtenir la mise en conformité sans frais, puis une réduction du prix ou la résolution du contrat lorsque les conditions sont réunies. Pour une fourniture continue, la conformité est due pendant la période contractuelle de fourniture ; pour une fourniture ponctuelle, les défauts apparaissant dans les deux ans de la fourniture relèvent de la garantie applicable. Les mises à jour nécessaires, notamment de sécurité, sont fournies conformément à la loi. Aucune stipulation des CGU ne réduit ces garanties.\n\n7. Publicité et services tiers\nDes annonces peuvent être proposées lorsque la publicité est activée, notamment dans l’accueil. Les choix applicables sont accessibles dans les réglages de confidentialité publicitaire. Le refus ou le retrait d’un consentement facultatif ne prive pas l’utilisateur du jeu de base. Les annonces non personnalisées peuvent néanmoins impliquer des traitements techniques décrits dans la Politique de confidentialité. L’éditeur n’endosse pas les offres des annonceurs ; il conserve les responsabilités qui lui incombent légalement pour sa propre activité.\n\n8. Propriété intellectuelle et contenus des utilisateurs\nLe logiciel, les textes, les graphismes et les autres éléments protégés demeurent la propriété de leurs titulaires respectifs. L’utilisateur reçoit une autorisation personnelle, non exclusive et non transférable d’utiliser le jeu pour son divertissement dans le respect des CGU. La reproduction, l’exploitation commerciale et le contournement de protections sans autorisation sont interdits, sous réserve des exceptions légales, notamment d’interopérabilité.\nL’utilisateur conserve ses droits sur les contenus qu’il fournit. Il autorise uniquement leur hébergement et leur affichage dans la mesure nécessaire au fonctionnement des fonctions qu’il utilise, pendant leur disponibilité dans le service. Il ne doit fournir que des contenus qu’il est autorisé à utiliser.\n\n9. Disponibilité, évolution et fin du service\nL’éditeur apporte un soin raisonnable au fonctionnement et à la sécurité du jeu. Des maintenances, incidents ou contraintes de réseau peuvent interrompre l’accès. Il informe les utilisateurs des interruptions prévisibles importantes lorsque cela est possible. Les modifications nécessaires à la sécurité, à la conformité ou à l’évolution du jeu ne doivent pas priver les consommateurs de leurs droits.\nUne modification affectant négativement de manière plus que mineure l’accès ou l’utilisation d’un service numérique fourni dans la durée fait l’objet de l’information et des droits de résiliation prévus par la loi. Un arrêt définitif est annoncé dans un délai raisonnable, sauf impossibilité justifiée ; les conséquences sur les achats sont traitées conformément aux obligations légales, sans promesse de disponibilité perpétuelle.\n\n10. Responsabilité\nL’éditeur répond des dommages directement causés par un manquement qui lui est imputable dans les conditions du droit applicable. Sa responsabilité peut être écartée lorsque le dommage résulte exclusivement d’une faute de l’utilisateur, du fait imprévisible et insurmontable d’un tiers ou d’un événement de force majeure au sens de l’article 1218 du Code civil. Une panne d’un prestataire ne constitue pas automatiquement un cas de force majeure.\nDans les seules limites autorisées par la loi, l’éditeur ne répond pas des préjudices indirects qui ne constituent pas une conséquence prévisible de son manquement. Aucun plafond forfaitaire de responsabilité n’est opposé au consommateur par ces CGU. Aucune exclusion ne couvre une atteinte à l’intégrité physique, un dol, une faute lourde, une obligation essentielle privée de sa substance ou une responsabilité que la loi interdit de limiter. Les garanties légales et les droits relatifs aux données personnelles restent pleinement applicables.\n\n11. Durée, fermeture du compte et données\nLes CGU s’appliquent pendant l’utilisation du service. L’utilisateur peut cesser de jouer à tout moment et demander la suppression de son compte dans « Compte & sécurité » ou par e-mail. La suppression entraîne la perte de l’accès au profil et aux éléments qui lui sont rattachés, sous réserve des droits légaux concernant les achats. Le traitement et les délais d’effacement des données sont décrits dans la Politique de confidentialité. Les clauses destinées à produire effet après la fin du compte, notamment sur les litiges et la propriété intellectuelle, subsistent pour leur objet.\n\n12. Modification des CGU\nLa version et la date figurent en tête du document. Les changements substantiels sont portés à la connaissance des utilisateurs avant leur prise d’effet, avec un préavis adapté à leur portée, sauf urgence légale ou de sécurité. Ils ne s’appliquent pas rétroactivement aux droits acquis. Lorsqu’un accord exprès est requis, il est recueilli séparément ; le silence ne vaut pas renonciation à un droit. L’utilisateur peut cesser l’utilisation et demander la fermeture du compte.\n\n13. Droit applicable et règlement des différends\nLes CGU sont régies par le droit français, sans priver le consommateur des dispositions impératives protectrices du pays de sa résidence habituelle. Toute réclamation peut être adressée au contact en en-tête pour rechercher une solution amiable. Le consommateur conserve son droit de recourir gratuitement à un médiateur de la consommation compétent lorsque ce dispositif est applicable, ainsi que son droit de saisir la juridiction compétente selon les règles légales. Aucune compétence exclusive des tribunaux du domicile de l’éditeur n’est imposée au consommateur. Une démarche amiable ne constitue pas un préalable obligatoire à l’exercice des recours légaux. Si une clause est déclarée inapplicable, les autres dispositions restent en vigueur dans la mesure permise par la loi.\n';

  @override
  String get legalPrivacyBody =>
      'ISAMUS — POLITIQUE DE CONFIDENTIALITÉ\nVersion du 30 octobre 2026\n\nResponsable du traitement : Aloys Lartiguelongue, domicilié à Saint-Palais, France.\nContact pour la protection des données et l’exercice des droits : aloys.lartiguelongue@etud.univ-pau.fr.\n\n1. Objet et périmètre\nCette politique décrit les traitements de données personnelles nécessaires au jeu IsaMus, à ses comptes, à ses fonctions sociales et à sa version web, ainsi que ceux liés aux achats et à la publicité lorsqu’ils sont activés. Elle s’applique aux comptes invités comme aux comptes sécurisés. Le responsable du traitement détermine les finalités et moyens de ces traitements conformément au règlement (UE) 2016/679 (RGPD) et à la loi Informatique et Libertés.\n\n2. Origine et catégories de données\nLes données proviennent de vos saisies, de votre activité dans le jeu, des échanges techniques avec votre appareil et, si vous les utilisez, des fournisseurs de connexion et boutiques.\n• Compte et profil : identifiant technique, statut invité, pseudo, avatar, préférences, dates de création et d’activité ; adresse e-mail, identifiant du fournisseur et informations d’authentification nécessaires si vous sécurisez le compte avec une adresse vérifiée, Apple ou Google. Les secrets d’authentification sont gérés par le service dédié ; votre mot de passe ne doit jamais être transmis à l’assistance.\n• Jeu : participants, actions, états de partie, résultats, classement Elo, statistiques, expérience, progression, quêtes et récompenses, selon les fonctions disponibles.\n• Relations sociales : demandes d’amitié, liens acceptés, invitations, blocages, présence et statut de jeu.\n• Achats : identifiant du compte, références de transaction, produits, droits d’accès, état de validation et de restauration. Les coordonnées bancaires complètes sont traitées par les boutiques et ne sont pas reçues par IsaMus.\n• Fonctionnement et sécurité : adresse IP, horodatages, requêtes, caractéristiques techniques du navigateur ou de l’application, erreurs et événements de sécurité nécessaires à l’exploitation.\n• Assistance : adresse de réponse, objet de la demande, échanges et pièces que vous choisissez de fournir. Évitez d’envoyer des données sensibles ou des informations concernant des tiers sans nécessité.\n• Publicité, si activée : informations techniques sur l’appareil et le réseau, événements de diffusion et choix de consentement ; des identifiants publicitaires ou traceurs peuvent être traités dans les conditions permises par vos choix et la réglementation.\nL’application ne demande pas l’accès à vos contacts, à votre microphone ni à votre localisation précise. Une adresse IP peut néanmoins renseigner approximativement sur une zone géographique.\n\n3. Finalités, bases légales et caractère nécessaire\nLa création et la sécurisation du compte, l’authentification, les parties, le classement, la progression et les fonctions sociales demandées reposent sur l’exécution du contrat (article 6, paragraphe 1, b du RGPD). La validation et la restauration des achats reposent sur cette même base. Les identifiants, états de jeu et données techniques indispensables sont nécessaires à ces services ; leur absence empêche leur fonctionnement. L’adresse e-mail ou la connexion à un fournisseur externe n’est pas nécessaire pour commencer comme invité, mais peut être requise pour retrouver et sécuriser le compte. Les fonctions facultatives n’exigent des données que si vous les utilisez.\nLa prévention de la triche, des abus et des accès non autorisés, le diagnostic des incidents et la défense des droits reposent sur l’intérêt légitime de maintenir un jeu équitable, disponible et sûr (article 6, paragraphe 1, f), après prise en compte de vos droits et attentes. Vous pouvez vous y opposer pour des raisons tenant à votre situation particulière.\nLes réponses aux demandes de droits et la conservation de documents légalement exigés reposent sur une obligation légale (article 6, paragraphe 1, c). L’assistance relative au service repose sur l’exécution du contrat ou, pour les autres échanges, sur l’intérêt légitime à répondre à votre demande.\nLes traceurs et traitements publicitaires nécessitant un consentement reposent sur votre choix préalable, libre, spécifique, éclairé et révocable (article 6, paragraphe 1, a et règles applicables aux traceurs). L’acceptation des CGU n’autorise pas ces traitements. Refuser un traitement facultatif n’empêche pas de jouer au jeu de base. Aucun usage de votre adresse de compte pour une prospection nécessitant un consentement n’est autorisé par la seule création du compte.\n\n4. Visibilité et destinataires\nVotre pseudo, avatar et classement peuvent être visibles par les autres joueurs authentifiés ; les participants reçoivent les informations de partie nécessaires au jeu. Dans l’architecture du service, les états et cartes de la partie sont accessibles aux participants : ne les utilisez pas pour transmettre des informations personnelles. Les amis acceptés peuvent connaître votre présence ou votre statut de jeu sans recevoir automatiquement le code de votre salon. Une invitation ou un blocage implique le traitement des identifiants concernés. Votre adresse e-mail et vos secrets d’authentification ne sont pas destinés à être affichés aux autres joueurs.\nL’éditeur et les personnes autorisées à l’assister n’accèdent aux données que pour les finalités décrites et selon leur besoin d’en connaître. Des données peuvent être communiquées aux autorités légalement habilitées sur demande valable ou pour respecter une obligation légale. Elles ne sont pas vendues par l’éditeur.\n\n5. Prestataires techniques\nSupabase assure l’authentification, l’hébergement des profils et de la base de données, les fonctions serveur et les échanges en temps réel nécessaires au jeu. Vercel assure le déploiement et l’hébergement de la version web ainsi que la distribution de ses ressources ; les accès web impliquent notamment le traitement de données de connexion et de requêtes.\nApple et Google interviennent si vous choisissez leurs services de connexion ou leurs boutiques. RevenueCat intervient dans la gestion et la validation des achats lorsque cette fonction est utilisée. Google AdMob et son dispositif de gestion du consentement interviennent lorsque la publicité est activée. Selon les opérations, ces acteurs agissent comme sous-traitants sur instruction ou comme responsables autonomes pour leurs propres services et obligations ; leurs politiques décrivent ces derniers traitements.\nInformations des fournisseurs : https://supabase.com/privacy ; https://vercel.com/legal/privacy-policy ; https://www.revenuecat.com/privacy/ ; https://policies.google.com/privacy ; https://www.apple.com/legal/privacy/.\n\n6. Localisation et transferts internationaux\nL’accès au service peut impliquer des traitements hors de l’Espace économique européen, notamment du fait des infrastructures mondiales et sous-traitants de Supabase, Vercel, Apple, Google et RevenueCat. Le seul recours à un hébergement européen ne garantit pas l’absence d’accès depuis un pays tiers. Cette politique ne promet donc pas une localisation exclusivement française ou européenne.\nTout transfert relevant de la responsabilité de l’éditeur doit être encadré conformément au chapitre V du RGPD : décision d’adéquation applicable au destinataire ou garanties appropriées, notamment clauses contractuelles types de la Commission européenne, avec évaluation du transfert et mesures complémentaires lorsque nécessaires. Une certification au cadre de protection des données UE–États-Unis n’est utilisable que pour un destinataire effectivement certifié et un traitement couvert. Vous pouvez demander au contact indiqué les informations sur les lieux de traitement, les destinataires et une copie des garanties applicables, sous réserve des secrets protégés et des droits des tiers.\n\n7. Durées de conservation\nLes durées suivantes constituent les limites de conservation de référence pour les traitements du jeu sous la responsabilité de l’éditeur :\n• Historique des parties, résultats et événements rattachés : 12 mois à compter de la fin de chaque partie, puis effacement ou anonymisation irréversible. Les statistiques agrégées du profil peuvent subsister pendant la vie du compte ; elles ne doivent pas permettre de reconstituer un historique individuel au-delà de ce délai.\n• Journaux techniques (logs), y compris les traces de connexion et d’erreurs : 90 jours à compter de leur enregistrement, puis suppression ou anonymisation irréversible.\n• Sauvegardes de sécurité : 30 jours au maximum à compter de leur création, par rotation et expiration. Une suppression dans la base active se répercute au plus tard à l’expiration de ces sauvegardes. Celles-ci sont réservées à la reprise après incident ; en cas de restauration, les demandes d’effacement doivent être réappliquées avant une remise en utilisation ordinaire.\nLe profil, les préférences, les droits d’accès aux objets et les relations sociales sont conservés pendant l’existence du compte, puis effacés ou anonymisés lors de sa suppression, sous réserve des exceptions ci-dessous. La présence sert uniquement au fonctionnement de la connexion et n’a pas vocation à constituer un historique durable des déplacements du joueur. La validité fonctionnelle d’une invitation est de dix minutes ; son expiration ne signifie pas à elle seule sa suppression de la base. Les traces techniques associées relèvent de la limite de 90 jours.\nLes échanges d’assistance sont conservés pendant le traitement de la demande, puis au maximum 12 mois après sa clôture, sauf litige. Les preuves nécessaires à une réclamation ou procédure identifiée peuvent être isolées en accès restreint pendant la durée nécessaire à son règlement et aux délais de prescription applicables, en principe cinq ans pour une action personnelle ou contractuelle. Les documents comptables que l’éditeur serait légalement tenu de conserver le sont dix ans à compter de la clôture de l’exercice concerné. Ces exceptions ne justifient pas le maintien de l’ensemble du compte ou de l’historique courant.\nLes fournisseurs agissant comme responsables autonomes appliquent leurs propres délais pour leurs obligations ; la suppression du compte IsaMus ne supprime pas votre compte Apple ou Google ni leurs documents de paiement. Vous pouvez leur adresser une demande distincte.\n\n8. Stockage local, cookies et publicité\nL’application et la version web peuvent conserver des jetons de session et des préférences sur votre appareil pour permettre l’authentification et les réglages. Les éléments strictement nécessaires au service demandé ne requièrent pas le consentement applicable aux traceurs facultatifs. Vous pouvez les effacer via les réglages du navigateur ou de l’appareil ; cela peut déconnecter un compte invité et rendre sa récupération impossible s’il n’est pas sécurisé.\nLorsque les annonces sont activées, l’intégration demande des annonces non personnalisées. Cette qualification ne signifie pas qu’aucune donnée n’est traitée ni qu’aucun consentement n’est requis. Les opérations soumises au consentement doivent attendre le choix correspondant. Le lien « Choix de confidentialité publicitaire » dans les réglages, lorsqu’il est disponible, permet de revoir les choix. Vous pouvez également écrire au contact en en-tête. Le retrait est sans effet sur la licéité des traitements effectués avant celui-ci.\n\n9. Sécurité et incidents\nLa protection des données repose sur des accès limités, l’authentification, les autorisations de la base de données et les mécanismes de sécurité des prestataires. L’éditeur doit adapter ces mesures aux risques, contrôler les accès et traiter les incidents ; aucune technologie ne permet de promettre une sécurité absolue. Protégez votre appareil et vos moyens de connexion et signalez les incidents au contact indiqué sans transmettre de mot de passe.\nEn cas de violation de données, le responsable du traitement évalue les conséquences et procède aux notifications requises : à l’autorité de contrôle, si nécessaire dans les 72 heures après en avoir pris connaissance, et aux personnes concernées sans délai indu lorsque la violation est susceptible d’engendrer un risque élevé, selon les conditions des articles 33 et 34 du RGPD.\n\n10. Vos droits et leurs modalités d’exercice\nVous pouvez demander l’accès à vos données et une copie, la rectification de données inexactes, l’effacement dans les cas prévus par la loi, la limitation du traitement et la portabilité des données fournies lorsque le traitement automatisé repose sur le contrat ou le consentement. Vous pouvez vous opposer aux traitements fondés sur l’intérêt légitime pour des raisons tenant à votre situation particulière ; le responsable doit alors justifier d’éventuels motifs légitimes impérieux ou des besoins liés à la défense de droits en justice. L’opposition à la prospection est possible à tout moment. Vous pouvez retirer un consentement sans effet rétroactif et donner des directives relatives au sort de vos données après votre décès selon la loi française.\nAdressez votre demande à aloys.lartiguelongue@etud.univ-pau.fr, en indiquant le droit souhaité et un identifiant permettant de retrouver votre compte. Ne transmettez pas spontanément de pièce d’identité : une vérification proportionnée n’est demandée qu’en cas de doute raisonnable sur votre identité. Une réponse est apportée au plus tard dans un mois à compter de la réception ; ce délai peut être prolongé de deux mois en raison de la complexité ou du nombre de demandes, avec information et motifs dans le premier mois. La démarche est gratuite, sous réserve des exceptions légales pour les demandes manifestement infondées ou excessives. Tout refus est motivé et accompagné des voies de recours.\nLa suppression peut également être demandée depuis « Compte & sécurité ». Elle entraîne la fermeture du compte et le traitement des données selon les délais du présent document. Certaines données peuvent être conservées en accès restreint pour une obligation légale ou un litige, avec information sur le motif applicable. Les droits d’autrui et les exceptions prévues par le RGPD peuvent limiter une demande ; ils n’autorisent pas un refus général non motivé.\nVous pouvez introduire une réclamation auprès de la CNIL, notamment sur https://www.cnil.fr/fr/plaintes, ou auprès de l’autorité de contrôle de votre résidence habituelle, de votre lieu de travail ou du lieu de la violation alléguée. Contacter préalablement l’éditeur n’est pas une condition obligatoire de ce recours.\n\n11. Mineurs et décisions automatisées\nLe service est destiné aux personnes de quinze ans et plus selon les CGU. Ce seuil d’accès ne dispense pas de respecter la capacité contractuelle des mineurs et les règles locales plus protectrices. En France, lorsqu’un traitement facultatif repose sur le consentement dans le cadre d’un service en ligne directement offert à un enfant de moins de quinze ans, la loi exige le consentement conjoint de l’enfant et du titulaire de l’autorité parentale. Une simple utilisation du jeu ne prouve pas ce consentement. Un parent peut contacter l’éditeur pour signaler un compte créé en méconnaissance de ces conditions ou exercer les droits applicables.\nLe jeu calcule automatiquement les scores, classements et récompenses selon ses règles. Ces calculs ne constituent pas une décision produisant des effets juridiques ou affectant de manière similaire significative au sens de l’article 22 du RGPD. Une contestation concernant une sanction ou une erreur peut être adressée à l’éditeur pour examen humain.\n\n12. Évolution de la politique\nLa date de version figure en tête. Les modifications importantes, notamment de finalité, de destinataires ou de durées, font l’objet d’une information adaptée dans le service. Un nouveau consentement est demandé lorsque la réglementation l’exige ; une mise à jour du texte ne permet pas d’étendre rétroactivement un consentement antérieur. Vous pouvez demander toute précision à aloys.lartiguelongue@etud.univ-pau.fr.\n';

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

  @override
  String get gameMenuTitle => 'Partidaren menua';

  @override
  String get gameQuitTitle => 'Irten partidatik';

  @override
  String get gameQuitConfirm => 'Ziur partidatik irten nahi duzula?';

  @override
  String get gameQuitAction => 'Irten';

  @override
  String get gameQuitFailed =>
      'Ezin izan da gela itxi. Egiaztatu konexioa eta saiatu berriro.';

  @override
  String get leaderboardYouSuffix => ', zu';

  @override
  String get endOfDeal => 'Eskuaren amaiera';

  @override
  String get scoringPhase => 'Fasea';

  @override
  String get dealTotal => 'Eskuko guztizkoa';

  @override
  String get onlyOneTeamHasPairs => 'Talde bakarrak ditu pareak';

  @override
  String get noTeamHasPairs => 'Ez dago parerik';

  @override
  String get noTeamHasGame => 'Ez dago jokorik';

  @override
  String get onlyOneTeamHasGame => 'Talde bakarrak du jokoa';

  @override
  String get victoryTitle => 'GARAIPENA';

  @override
  String get defeatTitle => 'PORROTA';

  @override
  String congratulationsTeam(String teamName) {
    return 'Zorionak! Zure taldeak ($teamName) partida irabazi du!';
  }

  @override
  String defeatTeam(String teamName) {
    return 'Lastima! $teamName taldeak partida irabazi du.';
  }

  @override
  String get finalScores => 'AZKEN PUNTUAZIOAK';

  @override
  String get returnHome => 'Itzuli hasierara';

  @override
  String get savingMatchResult => 'Emaitza gordetzen…';

  @override
  String get matchResultSyncPending =>
      'Emaitza ostalariarekin sinkronizatzeko zain.';

  @override
  String get retrySavingResult => 'Saiatu berriro gordetzen';

  @override
  String get discussMatch => 'Partidari buruz hitz egin';

  @override
  String rankedEloChange(String delta) {
    return 'Sailkapeneko partida • Elo: $delta';
  }
}
