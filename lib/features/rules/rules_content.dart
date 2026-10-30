import '../../l10n/app_localizations.dart';

// Complete transcription of the supplied FFM regulation; PDF line wraps repaired.
Map<String, dynamic> officialMusRules(
  AppLocalizations l10n,
) => <String, dynamic>{
  "title": l10n.menuFrenchMusChampionshipRegulations,
  "publisher": l10n.menuFederationFrancaiseDeMus,
  "revision": l10n.menuLastRevisedJanuary2023,
  "contact": l10n.rulesContact,
  "sections": [
    {
      "title": l10n.menuPrinciplesAndRankings,
      "articles": [
        {
          "number": 1,
          "paragraphs": [l10n.menuMusIsPlayedInTeamsOf2WithA],
        },
        {
          "number": 2,
          "paragraphs": [
            l10n.menuRankingsAreCalculatedAsFollows3RoundsWon1,
            l10n.menuAWinnerOneWinIsCountedRegardlessOfRounds,
            l10n.menuBLoser0WinsAreCountedAlongWithRounds,
          ],
        },
      ],
    },
    {
      "title": l10n.dealing,
      "articles": [
        {
          "number": 3,
          "paragraphs": [l10n.menuForTheFirstDealThePlayerWhoDrewThe],
        },
        {
          "number": 4,
          "paragraphs": [l10n.menuIfACardIsTurnedOverDuringTheFirst],
        },
        {
          "number": 5,
          "paragraphs": [l10n.menuIfTheErrorIsFoundAfterPlayHasBegun],
        },
        {
          "number": 6,
          "paragraphs": [l10n.menuIfACardIsTurnedOverAfterMusHas],
        },
        {
          "number": 7,
          "paragraphs": [l10n.menuEskuAndTheirPartnerDecideWhetherToStopWith],
        },
        {
          "number": 8,
          "paragraphs": [l10n.menuIfThereIsMusAll4PlayersDiscardThe],
        },
        {
          "number": 9,
          "paragraphs": [l10n.menuPlayBeginsWithESKUFirstHighThenLowPairs],
        },
        {
          "number": 10,
          "paragraphs": [l10n.menuTiraIdukiAndHordagoBindTheTeamTheSpeakers],
        },
      ],
    },
    {
      "title": l10n.menuSigns,
      "articles": [
        {
          "number": 11,
          "paragraphs": [
            l10n.menuOnlyTheFollowingOfficialSignsAreAllowed,
            l10n.menu2KingsLowerLip,
            l10n.menu2AcesStickOutTheTongue,
            l10n.menuMediakMoveOneSideOfTheLips,
            l10n.menuDobliakMoveBothSidesOfTheLips,
            l10n.menu29SameAsMediak,
            l10n.menu30Or31Wink,
            l10n.menuGameRaiseTheEyebrows,
            l10n.menuTheSignFor30Or31MayBeMade,
          ],
        },
      ],
    },
    {
      "title": l10n.menuDoublePairs,
      "articles": [
        {
          "number": 12,
          "paragraphs": [l10n.menuWhen2OpponentsHaveDoublePairsWithTheSame],
        },
      ],
    },
    {
      "title": l10n.menuErrors,
      "articles": [
        {
          "number": 13,
          "paragraphs": [
            l10n.menuAnnouncingPairsWithoutHavingAny,
            l10n.menuAIfThePartnerHasNoneAllBetsOn,
            l10n.menuBIfThePartnerHasPairsAndTheOpponents,
          ],
        },
        {
          "number": 14,
          "paragraphs": [
            l10n.menuFailingToAnnouncePairsWhenHoldingThem,
            l10n.menuUnannouncedPairsCannotBeUsedToBetCallOr,
            l10n.menuIfThePartnerHasNoPairsAnOpponentWith,
          ],
        },
        {
          "number": 15,
          "paragraphs": [
            l10n.menuAnnouncingGameWithoutHavingIt,
            l10n.menuAIfNoneOfTheOther3PlayersHas,
            l10n.menuBIfThePartnerHasGameAndTheOpponents,
            l10n.menuCIfThePartnerHasNoGameButAn,
            l10n.menuDIfThePartnerAndAnOpponentBothHave,
          ],
        },
        {
          "number": 16,
          "paragraphs": [
            l10n.menuFailingToAnnounceGameWhenHoldingIt,
            l10n.menuAIfNoneOfTheOther3PlayersHas465,
            l10n.menuBIfThePartnerHasGameAndTheOpponents466,
            l10n.menuCIfThePartnerHasNoGameAndAn,
          ],
        },
      ],
    },
    {
      "title": l10n.menuScoringAndRaises,
      "articles": [
        {
          "number": 17,
          "paragraphs": [
            l10n.menuDuringPlayPointsConcededThroughTIRAAreScoredAs,
            l10n.menuScoreHighThenLowPairsGameOrPointAs,
            l10n.menuHighIfEveryoneSaidPASOTheBestHighScores,
            l10n.menuLowTheSameAsHigh,
            l10n.menuPairsAfterPasoTheTeamWithTheBestPair,
            l10n.menuGameTheSameAsPairsCounting2PointsFor,
            l10n.menuPointPontuaAfterPasoTheBestPontuaScores1,
            l10n.menuRaiseExamples,
            l10n.menuEmbido2PointsTira1Point,
            l10n.menuEmbido2PointsIduki2Points,
            l10n.menuHordagoTira1Point,
            l10n.menuHiruEmbido3PointsTira1Point,
            l10n.menuHiruEmbido3PointsIduki3Points,
            l10n.menuEmbido2PointsLauGehiago4Tira2Points,
            l10n.menuEmbido2PointsBigehiago2HordagoTira4Points,
            l10n.menuHiruEmbido3PointsLauGehiago4Iduki7,
            l10n.menuEmbido2PointsBortzGehiago5Bigehiago2Tira,
          ],
        },
        {
          "number": 18,
          "paragraphs": [l10n.menuNoTtanttoMayBeScoredOnceTheCardsHave],
        },
      ],
    },
    {
      "title": l10n.menuRefereeing,
      "articles": [
        {
          "number": 19,
          "paragraphs": [l10n.menuTheRefereeIntervenesOnlyAtAPlayersRequestOr],
        },
        {
          "number": 20,
          "paragraphs": [
            l10n.menuAnyDisputeOverTheseRegulationsOrAnySituationNot,
          ],
        },
        {
          "number": 21,
          "paragraphs": [l10n.menuTheRefereeMayImposePenaltiesUpToAndIncluding],
        },
      ],
    },
  ],
};
