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
}
