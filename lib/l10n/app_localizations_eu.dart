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
  String get roundScoring => 'Tanttoen zenbaketa';

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
}
