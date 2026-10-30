// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IsaMus';

  @override
  String get you => 'You';

  @override
  String get partner => 'Partner';

  @override
  String team(String name) {
    return 'Team $name';
  }

  @override
  String rounds(int count) {
    return 'Rounds: $count / 3';
  }

  @override
  String get startGame => 'Deal';

  @override
  String get nextHand => 'Next hand';

  @override
  String get newGame => 'New game';

  @override
  String get dealing => 'Dealing';

  @override
  String get discarding => 'Discarding';

  @override
  String get roundScoring => 'Scoring';

  @override
  String get gameOver => 'Game over';

  @override
  String get yourTurn => 'Your turn';

  @override
  String waitingFor(String name) {
    return '$name’s turn';
  }

  @override
  String discardCards(int count) {
    return 'Exchange $count card(s)';
  }

  @override
  String get keepCards => 'Keep my cards';

  @override
  String currentBid(int amount) {
    return 'Bet: $amount Tantto';
  }

  @override
  String roundWinner(String team) {
    return '$team wins the round';
  }

  @override
  String gameWinner(String team) {
    return '$team wins the game';
  }

  @override
  String get actionFailed => 'Action unavailable: the situation has changed.';

  @override
  String cardLabel(int value, String suit) {
    return '$value of $suit';
  }

  @override
  String get oros => 'Gold';

  @override
  String get copas => 'Cups';

  @override
  String get espadas => 'Swords';

  @override
  String get bastos => 'Clubs';

  @override
  String get hasPairs => 'Pariak dut';

  @override
  String get hasGame => 'Jokoa dut';

  @override
  String get hasNeither => 'Ez dut';

  @override
  String get sendSign => 'Send a sign to your partner';

  @override
  String get signTwoKings => '2 Kings';

  @override
  String get signTwoAces => '2 Aces';

  @override
  String get signGame => 'Game';

  @override
  String opponentShort(int number) {
    return 'Opp. $number';
  }

  @override
  String scoreTotal(int total, int hamarreko, int tantto) {
    return 'Score: $total pts ($hamarreko Hamarreko, $tantto Tantto)';
  }

  @override
  String get quickChat => 'Quick chat';

  @override
  String get chatGoodLuck => 'Good luck';

  @override
  String get chatNothing => 'I have nothing';

  @override
  String get chatWellPlayed => 'Well played!';

  @override
  String get turnTime => 'Time to play';

  @override
  String get raiseAmount => 'Raise by…';

  @override
  String get openingAmount => 'Bet…';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get validate => 'Confirm';

  @override
  String bidTotal(int amount) {
    return 'Total bet: $amount Tantto';
  }

  @override
  String get playTitle => 'Play';

  @override
  String get leaderboardTitle => 'Top 100';

  @override
  String get shopTitle => 'Shop';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get profileTitle => 'Profile';

  @override
  String get seasonPassTitle => 'Season Pass';

  @override
  String get tutorialTitle => 'Tutorial';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get menuUnableToCompleteThisActionCheckYourConnectionAnd =>
      'Unable to complete this action. Check your connection and try again.';

  @override
  String get menuDocumentUnavailableTryAgain =>
      'Document unavailable. Try again.';

  @override
  String get menuSoundEffects => 'Sound effects';

  @override
  String get menuPreferenceUnavailable => 'Preference unavailable';

  @override
  String get menuTryAgain => 'Try again';

  @override
  String get menuAccountSecurity => 'Account & security';

  @override
  String get menuAdPrivacyChoices => 'Ad privacy choices';

  @override
  String get menuTermsOfUse => 'Terms of use';

  @override
  String get menuPrivacyPolicy => 'Privacy policy';

  @override
  String get menuLastDay => 'Last day';

  @override
  String menuOnlyArg0DLeft(String arg0) {
    return 'Only ${arg0}d left';
  }

  @override
  String get menuSeasonInProgress => 'Season in progress';

  @override
  String get menuPlayer => 'Player';

  @override
  String get menuUnableToCompleteThisActionTheRoomMayHave =>
      'Unable to complete this action. The room may have changed. Try again.';

  @override
  String menuCodeArg0CopiedToClipboard(String arg0) {
    return 'Code $arg0 copied to clipboard!';
  }

  @override
  String get menuWAITINGROOM => 'WAITING ROOM';

  @override
  String get menuSyncErrorTryAgain => 'Sync error. Try again';

  @override
  String get menuThisRoomIsReservedForPublicMatchmaking =>
      'This room is reserved for public matchmaking.';

  @override
  String get menuINVITATIONCODE => 'INVITATION CODE';

  @override
  String get menuCopyCode => 'Copy code';

  @override
  String get menuStartGame => 'Start game';

  @override
  String get menuFillWithAIPlayers => 'Fill with AI players';

  @override
  String get menuTwoPlayersPerTeamAreRequired =>
      'Two players per team are required.';

  @override
  String get menuWaitingForTheHost => 'Waiting for the host...';

  @override
  String get menuTheRoomHasBeenClosed => 'The room has been closed.';

  @override
  String menuTeamArg0Arg12(String arg0, String arg1) {
    return 'Team $arg0 · $arg1/2';
  }

  @override
  String get menuYourTeam => 'Your team';

  @override
  String get menuJoin => 'Join';

  @override
  String get menuYOU => 'YOU';

  @override
  String get menuOpenSeat => 'Open seat';

  @override
  String get menuWaiting => 'Waiting…';

  @override
  String get menuHost => 'Host';

  @override
  String get menuAI => 'AI';

  @override
  String get menuInviteMyFriends => 'Invite my friends';

  @override
  String get menuAddFriendsFromTheFriendsTab =>
      'Add friends from the Friends tab.';

  @override
  String get menuFriend => 'Friend';

  @override
  String menuInvitationSentToArg0(String arg0) {
    return 'Invitation sent to $arg0.';
  }

  @override
  String get menuUnableToSendTheInvitation => 'Unable to send the invitation.';

  @override
  String get menuInvite => 'Invite';

  @override
  String get menuSignInToPlay => 'Sign in to play.';

  @override
  String get menuPleaseEnterYourNickname => 'Please enter your nickname.';

  @override
  String get menuSignInToCreateYourProfile => 'Sign in to create your profile.';

  @override
  String get menuTheCodeMustContainExactly5Characters =>
      'The code must contain exactly 5 characters.';

  @override
  String get menuIAlreadyHaveAnAccount => 'I already have an account';

  @override
  String menuArg0Coins(String arg0) {
    return '$arg0 coins';
  }

  @override
  String get menuWeeklyQuests => 'Weekly quests';

  @override
  String get menuGAMEMODES => 'GAME MODES';

  @override
  String get menuATYOUROWNPACE => 'AT YOUR OWN PACE';

  @override
  String get menuTakeASeatAndLearnMusFromYourFirst =>
      'Take a seat and learn Mus, from your first decisions to scoring.';

  @override
  String get menuNoTimerGuidedThenFreePlay =>
      'No timer · Guided, then free play';

  @override
  String get menuLearnMus => 'Learn Mus';

  @override
  String get menuOfficialRules => 'Official rules';

  @override
  String get menuQUICKMULTIPLAYER => 'QUICK MULTIPLAYER';

  @override
  String get menuONLINECASUAL => 'ONLINE (CASUAL)';

  @override
  String get menuChallengePlayersOnlineInRelaxedFriendlyGamesWithNo =>
      'Challenge players online in relaxed, friendly games with no Elo at stake. Enjoy a good game of Mus.';

  @override
  String get menuOfficial4KingsAnd4AcesRulesNoPressure =>
      'Official 4 Kings and 4 Aces rules • No pressure';

  @override
  String get menuOFFICIALCOMPETITION => 'OFFICIAL COMPETITION';

  @override
  String get menuONLINERANKED => 'ONLINE (RANKED)';

  @override
  String menuYourCurrentEloArg0(String arg0) {
    return 'Your current Elo: $arg0';
  }

  @override
  String get menuSeasonRewards => 'Season rewards';

  @override
  String get menuClimbTheCompetitiveRankingsEveryWinRaisesYourElo =>
      'Climb the competitive rankings. Every win raises your Elo and every loss lowers it. Aim for the Top 100!';

  @override
  String get menuPlayRanked => 'Play (Ranked)';

  @override
  String get menuSOLOPRACTICE => 'SOLO PRACTICE';

  @override
  String get menuSOLOVSAI => 'SOLO VS AI';

  @override
  String get menuPlayAgainst3LocalAIPlayersWithoutWaitingFor =>
      'Play against 3 local AI players without waiting for others. Practise the rules, tactics and Basque signs.';

  @override
  String get menuInstantStart3IndependentBots =>
      'Instant start • 3 independent bots';

  @override
  String get menuPlayAgainstAI => 'Play against AI';

  @override
  String get menuPRIVATEROOM => 'PRIVATE ROOM';

  @override
  String get menuPLAYWITHFRIENDS => 'PLAY WITH FRIENDS';

  @override
  String get menuCreateAPrivateRoom => 'Create a private room';

  @override
  String get menuORJOINWITHACODE => 'OR JOIN WITH A CODE';

  @override
  String get menuConfirmAndJoin => 'Confirm and join';

  @override
  String get menuBASQUECARDGAMEMULTIPLAYER => 'BASQUE CARD GAME • MULTIPLAYER';

  @override
  String get menuCONNECTING => 'CONNECTING...';

  @override
  String get menuCREATEYOURPROFILE => 'CREATE YOUR PROFILE';

  @override
  String get menuYourNicknameEGPatxiAmaia =>
      'Your nickname (e.g. Patxi, Amaia…)';

  @override
  String get menuCreateMyProfile => 'Create my profile';

  @override
  String get menuTop100Players => 'Top 100 players';

  @override
  String get menuRefreshRankings => 'Refresh rankings';

  @override
  String get menuLoadingRankings => 'Loading rankings';

  @override
  String get menuUnableToLoadRankingsCheckYourConnectionAndTry =>
      'Unable to load rankings. Check your connection and try again.';

  @override
  String get menuNoRankedPlayersYet => 'No ranked players yet.';

  @override
  String get menuTheHighestEloRatings => 'The highest Elo ratings';

  @override
  String menuYourPositionArg0(String arg0) {
    return 'Your position: #$arg0';
  }

  @override
  String get menuReachTheTop100ToAppearHere =>
      'Reach the Top 100 to appear here!';

  @override
  String get menuRankedByDescendingElo => 'Ranked by descending Elo.';

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
    return 'Level $arg0 · $arg1 / 500 XP';
  }

  @override
  String menuLevelArg0Arg1XPOutOf500(String arg0, String arg1) {
    return 'Level $arg0, $arg1 XP out of 500';
  }

  @override
  String get menuYouHaveTwoKingsAndAGameTotalOf =>
      'You have two Kings and a game total of 31. Keep this hand: say Mintza.';

  @override
  String get menuYourOpponentRaisesCallIdukiToCompareCardsAt =>
      'Your opponent raises. Call (Iduki) to compare cards at scoring.';

  @override
  String get menuYouHaveTwoKingsBaiAnnouncesYourPairBet =>
      'You have two Kings: Bai announces your pair. Bet 2 stones!';

  @override
  String get menuYouHave31TheBestGameTotalBet2 =>
      'You have 31, the best game total. Bet 2 stones to open the bidding.';

  @override
  String get menuThisIsHighHandiaYouHaveStrongCardsBet =>
      'This is High (Handia). You have strong cards: bet!';

  @override
  String get menuAtLowYourAceIsFollowedByThreeFace =>
      'At Low, your Ace is followed by three face cards. Pass with Paso.';

  @override
  String get menuWatchTheOtherPlayersAnnouncementsAndResponses =>
      'Watch the other players’ announcements and responses.';

  @override
  String get menuTheTutorialIsWaitingForMintza =>
      'The tutorial is waiting for Mintza.';

  @override
  String get menuDiscardingIsNotAvailableAtThisStep =>
      'Discarding is not available at this step.';

  @override
  String get menuThisIsNotTheActionExpectedByTheTutorial =>
      'This is not the action expected by the tutorial.';

  @override
  String get menuTheOtherPlayersAreTakingTheirTurns =>
      'The other players are taking their turns…';

  @override
  String get menuIdukiCall => 'Iduki (Call)';

  @override
  String get menuRaise => 'Raise';

  @override
  String get menuBet2 => 'Bet 2';

  @override
  String get menuMusOrMintza => 'Mus or Mintza?';

  @override
  String get menuAtTheStartOfEachHandEachPlayerChooses =>
      'At the start of each hand, each player chooses Mus to request a card exchange. If all four say Mus, everyone can discard and receive new cards. Mintza stops the Mus: you keep your hands and start bidding. Click Mintza now: only the expected button is enabled and its outline glows.';

  @override
  String get menuBettingPasoAndEmbido => 'Betting: Paso and Embido';

  @override
  String get menuInEachPhaseYouCanBetStonesForYour =>
      'In each phase you can bet stones for your team. Paso passes the turn without opening a bet. Embido proposes a bet; Gehiago raises it. Your team can bluff with its bets, but must never send a false sign.';

  @override
  String get menuRespondingTiraAndIduki => 'Responding: Tira and Iduki';

  @override
  String get menuWhenFacingABetIdukiAcceptsTheCardsWill =>
      'When facing a bet, Iduki accepts: the cards will decide the winner at scoring. Tira refuses: the phase ends and the opponent scores the refusal points based on previous bets. A raise proposes a higher bet instead.';

  @override
  String get menuHordagoTheWholeRound => 'Hordago: the whole round';

  @override
  String get menuHordagoPutsTheEntireRoundAtStakeIfAccepted =>
      'Hordago puts the entire round at stake. If accepted with Iduki, hands are compared immediately for this phase and the winner takes the round. Tira refuses the challenge and concedes only refusal points. You will bet 2 at High and Pairs, then call a raise at Game. Other choices stay disabled until free play.';

  @override
  String get menuYourTurnToCall => 'Your turn to call';

  @override
  String get menuYourOpponentRaisesBy8TheBetGoesFrom =>
      'Your opponent raises by 8: the bet goes from 2 to 10 stones. Click Iduki to accept. The cards will decide the winner at scoring.';

  @override
  String get menuTheCardsAreRevealedBetsAndPointsForPairs =>
      'The cards are revealed. Bets and points for Pairs and Game are added up. The first team to reach 40 stones wins the round.';

  @override
  String get menuHighHandia => 'High — Handia';

  @override
  String get menuCompareCardsFromHighestToLowestTheKingIs =>
      'Compare cards from highest to lowest. The King is strongest. Click Bet 2 to propose two stones. An opponent will accept this first bet.';

  @override
  String get menuLowTtipia => 'Low — Ttipia';

  @override
  String get menuNowCompareTheLowestCardsTheAceIsBest =>
      'Now compare the lowest cards. The Ace is best. If tied, compare the next cards; Esku breaks a perfect tie.';

  @override
  String get menuPairsPareak => 'Pairs — Pareak';

  @override
  String get menuTwoMatchingCardsMakeAPairThreeMakeMediak =>
      'Two matching cards make a pair; three make Mediak; two pairs or four matching cards make Dobliak. Only players with pairs take part. You have two Kings: Bai announces your pair. Click Bet 2 to defend it.';

  @override
  String get menuGameJoko => 'Game — Joko';

  @override
  String get menuFaceCardsAreWorth10AndOtherCardsTheir =>
      'Face cards are worth 10 and other cards their face value. You need at least 31. The best Game total is 31, then 32. If nobody has Game, play Point, aiming closest to 30. Bet 2 here: an opponent will raise and you will learn to call with Iduki.';

  @override
  String get menuYourTurnToPlay => 'Your turn to play!';

  @override
  String get menuYouHaveLearnedYourWayAroundTheTable =>
      'You have learned your way around the table.';

  @override
  String get menuKeepPlayingAgainstTheBotsAllActionsAreAvailable =>
      'Keep playing against the bots: all actions are available, with no timer or hints. You can also return to the menu.';

  @override
  String get menuReturnToMenu => 'Return to menu';

  @override
  String get menuFinishThisGameFreePlay => 'Finish this game (Free play)';

  @override
  String get menuGotIt => 'Got it';

  @override
  String get menuCheckYourEmailToActivateYourAccount =>
      'Check your email to activate your account.';

  @override
  String get menuAnAccountAlreadyUsesThisEmailAddress =>
      'An account already uses this email address.';

  @override
  String get menuChooseAStrongerPassword => 'Choose a stronger password.';

  @override
  String get menuTooManyAttemptsTryAgainShortly =>
      'Too many attempts. Try again shortly.';

  @override
  String get menuUnableToSignUpTryAnotherNicknameAndCheck =>
      'Unable to sign up. Try another nickname and check your details.';

  @override
  String get menuServiceUnavailableCheckYourConnectionAndTryAgain =>
      'Service unavailable. Check your connection and try again.';

  @override
  String get menuSignUp => 'Sign up';

  @override
  String get menuJoinIsaMus => 'Join IsaMus';

  @override
  String get menuChooseYourNicknameAndJoinTheGame =>
      'Choose your nickname and join the game.';

  @override
  String get menuNickname => 'Nickname';

  @override
  String get menuChooseANickname => 'Choose a nickname.';

  @override
  String get menu24CharactersMaximum => '24 characters maximum.';

  @override
  String get menuEmail => 'Email';

  @override
  String get menuEnterAValidEmailAddress => 'Enter a valid email address.';

  @override
  String get menuPassword => 'Password';

  @override
  String get menuAtLeast8Characters => 'At least 8 characters';

  @override
  String get menuShowPassword => 'Show password';

  @override
  String get menuHidePassword => 'Hide password';

  @override
  String get menuUseAtLeast8Characters => 'Use at least 8 characters.';

  @override
  String get menuCreateMyAccount => 'Create my account';

  @override
  String get menuAlreadyHaveAnAccountSignIn =>
      'Already have an account? Sign in';

  @override
  String get menuIncorrectEmailOrPassword => 'Incorrect email or password.';

  @override
  String get menuConfirmYourEmailAddressBeforeSigningIn =>
      'Confirm your email address before signing in.';

  @override
  String get menuUnableToSignInCheckYourDetailsAndTry =>
      'Unable to sign in. Check your details and try again.';

  @override
  String get menuYourTableIsWaiting => 'Your table is waiting.';

  @override
  String get menuEnterYourPassword => 'Enter your password.';

  @override
  String get menuSignIn => 'Sign in';

  @override
  String get menuPlayAsAGuest => 'Play as a guest';

  @override
  String get menuNoAccountYetSignUp => 'No account yet? Sign up';

  @override
  String get menuQuestsUnavailable => 'Quests unavailable';

  @override
  String get menuClose => 'Close';

  @override
  String get menuANewWeekNewChallenges => 'A new week, new challenges.';

  @override
  String get menuResetsOnMondayAt0000UTCXPRewards =>
      'Resets on Monday at 00:00 UTC. XP rewards are granted automatically.';

  @override
  String get menuNewChallengesComingSoon => 'New challenges coming soon.';

  @override
  String menuArg0XPRewardReceived(String arg0) {
    return '+$arg0 XP · Reward received';
  }

  @override
  String get menuRewardReceived => 'Reward received';

  @override
  String menuArg0XP(String arg0) {
    return '+$arg0 XP';
  }

  @override
  String get menuXPRewardUnavailable => 'XP reward unavailable';

  @override
  String menuTierArg0Arg1(String arg0, String arg1) {
    return 'Tier $arg0, $arg1';
  }

  @override
  String get menuNextGoal => 'next goal';

  @override
  String get menuLocked => 'locked';

  @override
  String get menuVIP => 'VIP';

  @override
  String get menuFree => 'Free';

  @override
  String get menuNoReward => 'No reward';

  @override
  String get menuEarned => 'Earned';

  @override
  String get menuNextGoal189 => 'Next goal';

  @override
  String menuLevelArg0(String arg0) {
    return 'Level $arg0';
  }

  @override
  String get menuVIPRequired => 'VIP required';

  @override
  String get menuSeasonEnded => 'Season ended';

  @override
  String get menuPleaseWait => 'Please wait…';

  @override
  String get menuClaim => 'Claim';

  @override
  String menuArg0Coins195(String arg0) {
    return ', $arg0 coins';
  }

  @override
  String get menuPreviewOnlyCosmeticNotYetDefinedOrAvailable =>
      'Preview only: cosmetic not yet defined or available.';

  @override
  String get menuUpcomingCosmetic => 'Upcoming cosmetic';

  @override
  String get menuGoldCardBack => 'Gold card back';

  @override
  String get menuRubyTableFelt => 'Ruby table felt';

  @override
  String get menuActionUnavailableTryAgainShortly =>
      'Action unavailable. Try again shortly.';

  @override
  String get menuPassUnavailable => 'Pass unavailable.';

  @override
  String get menuNoActiveSeason => 'No active season';

  @override
  String get menuDemoCalendar => 'Demo calendar';

  @override
  String menuArg0Arg1TiersUnlocked(String arg0, String arg1) {
    return '$arg0 / $arg1 tiers unlocked';
  }

  @override
  String get menuAllTiersUnlocked => 'All tiers unlocked!';

  @override
  String menuNextGoalTierArg0(String arg0) {
    return 'Next goal: tier $arg0';
  }

  @override
  String menuArg0XPLeftToReachIt(String arg0) {
    return '$arg0 XP left to reach it.';
  }

  @override
  String get menuTapAnUnlockedRewardToClaimItAFree =>
      'Tap an unlocked reward to claim it. A free reward every 5 tiers; a VIP reward at every tier.';

  @override
  String get menuRewardPath => 'Reward path';

  @override
  String get menuReached => 'Reached';

  @override
  String get menuGoal => 'Goal';

  @override
  String get menuComingUp => 'Coming up';

  @override
  String get menuRewardAlreadyReceived => 'Reward already received';

  @override
  String menuArg0CoinsReceivedArg1(String arg0, String arg1) {
    return '$arg0 coins received$arg1';
  }

  @override
  String get menuCosmeticUnlocked => ' · Cosmetic unlocked';

  @override
  String get menuPREMIUM => 'PREMIUM';

  @override
  String get menuYourVIPPassIsActive => 'Your VIP Pass is active';

  @override
  String get menuUnlockTheVIPPass => 'Unlock the VIP Pass';

  @override
  String get menuNoAds => 'No ads';

  @override
  String get menuVIPPassTrack => 'VIP Pass track';

  @override
  String get menuXP2 => 'XP ×2';

  @override
  String get menuCoinsCanOnlyBeEarnedThroughTheSeasonPass =>
      'Coins can only be earned through the Season Pass. Double XP from games and quests.';

  @override
  String get menuVIPIsTemporarilyUnavailable =>
      'VIP is temporarily unavailable.';

  @override
  String get menuVIPActive => 'VIP active';

  @override
  String get menuVIPComingSoon => 'VIP coming soon';

  @override
  String menuBecomeVIPArg0Month(String arg0) {
    return 'Become VIP · $arg0/month';
  }

  @override
  String get menuMonthlySubscriptionWithAutomaticRenewalCancelThroughYourApp =>
      'Monthly subscription with automatic renewal. Cancel through your app store.';

  @override
  String get menuRestorePurchases => 'Restore purchases';

  @override
  String get menuNotEnoughCoinsForThisItem => 'Not enough coins for this item.';

  @override
  String get menuThisItemIsAlreadyInYourInventory =>
      'This item is already in your inventory.';

  @override
  String get menuThePriceHasChangedTheShopHasBeenRefreshed =>
      'The price has changed. The shop has been refreshed.';

  @override
  String get menuThisItemIsNoLongerAvailable =>
      'This item is no longer available.';

  @override
  String get menuPurchaseFailedTryAgainShortly =>
      'Purchase failed. Try again shortly.';

  @override
  String menuArg0AddedToYourInventory(String arg0) {
    return '$arg0 added to your inventory';
  }

  @override
  String get menuOutfits => 'Outfits';

  @override
  String get menuCardBacks => 'Card backs';

  @override
  String get menuHeadwear => 'Headwear';

  @override
  String get menuGlasses => 'Glasses';

  @override
  String get menuHair => 'Hair';

  @override
  String get menuQuickChats => 'Quick chats';

  @override
  String get menuShopUnavailable => 'Shop unavailable.';

  @override
  String get menuNewItemsComingSoon => 'New items coming soon.';

  @override
  String get menuOwned => 'Owned';

  @override
  String menuBuyArg0Arg1Coins(String arg0, String arg1) {
    return 'Buy $arg0, $arg1 coins';
  }

  @override
  String get menuBuying => 'Buying…';

  @override
  String get menuBuy => 'Buy';

  @override
  String get menuUnableToCompleteThisActionCheckYourConnectionOr =>
      'Unable to complete this action. Check your connection or try again.';

  @override
  String get menuYourFriend => 'your friend';

  @override
  String menuInvitationSentArg0(String arg0) {
    return 'Invitation sent: $arg0';
  }

  @override
  String get menuInAGame => 'In a game';

  @override
  String get menuOnline => 'Online';

  @override
  String get menuOffline => 'Offline';

  @override
  String get menuInviteToPlay => 'Invite to play';

  @override
  String get menuFriendOptions => 'Friend options';

  @override
  String get menuRemoveFriend => 'Remove friend';

  @override
  String get menuFriendsPrivateRooms => 'Friends & private rooms';

  @override
  String get menuRequests => 'Requests';

  @override
  String get menuBlocked => 'Blocked';

  @override
  String get menuSearchForANickname => 'Search for a nickname';

  @override
  String get menuSearch => 'Search';

  @override
  String get menuNoResultsEnterAtLeast2Characters =>
      'No results. Enter at least 2 characters.';

  @override
  String get menuSendFriendRequest => 'Send friend request';

  @override
  String get menuFriendRequestSent => 'Friend request sent';

  @override
  String get menuUnableToLoadFriendsTryAgain =>
      'Unable to load friends. Try again';

  @override
  String get menuYourListIsEmptySearchForAPlayerTo =>
      'Your list is empty. Search for a player to send a request.';

  @override
  String get menuUnableToLoadRequestsTryAgain =>
      'Unable to load requests. Try again';

  @override
  String get menuNoPendingRequests => 'No pending requests.';

  @override
  String get menuReceived => 'Received';

  @override
  String get menuSent => 'Sent';

  @override
  String get menuRequestReceived => 'Request received';

  @override
  String get menuRequestSent => 'Request sent';

  @override
  String get menuAccept => 'Accept';

  @override
  String get menuDecline => 'Decline';

  @override
  String get menuCancel => 'Cancel';

  @override
  String get menuUnableToLoadBlockedPlayersTryAgain =>
      'Unable to load blocked players. Try again';

  @override
  String get menuNoBlockedPlayers => 'No blocked players.';

  @override
  String get menuBlockedPlayer => 'Blocked player';

  @override
  String get menuPlayerUnblocked => 'Player unblocked';

  @override
  String get menuUnblock => 'Unblock';

  @override
  String menuInviteArg0(String arg0) {
    return 'Invite $arg0';
  }

  @override
  String get menuChooseHowToPlayTogether => 'Choose how to play together.';

  @override
  String get menuSameTeamAgainstTwoOtherPlayers =>
      'Same team, against two other players';

  @override
  String get menuRoomWithACodeAndTeamSelection =>
      'Room with a code and team selection';

  @override
  String get menuLeaveYourCurrentGame => 'Leave your current game';

  @override
  String get menuNavigationUnavailable => 'Navigation unavailable';

  @override
  String get menuInvitationUnavailableLeaveYourCurrentGameOrTryAgain =>
      'Invitation unavailable. Leave your current game or try again.';

  @override
  String get menuAFriend => 'A friend';

  @override
  String menuArg0InvitesYouToPlayArg1(String arg0, String arg1) {
    return '$arg0 invites you to play $arg1';
  }

  @override
  String get menuYouWillPlayOnTheSameTeam => 'You will play on the same team.';

  @override
  String get menuChooseYourTeamsInTheRoom => 'Choose your teams in the room.';

  @override
  String get menuDecline296 => 'Decline';

  @override
  String get menuNewFriendRequestReceived => 'New friend request received';

  @override
  String menuArg0NewFriendRequests(String arg0) {
    return '$arg0 new friend requests';
  }

  @override
  String get menuCloseNotification => 'Close notification';

  @override
  String get menuOverallStatistics => 'Overall statistics';

  @override
  String get menuCurrentElo => 'Current Elo';

  @override
  String get menuPeakElo => 'Peak Elo';

  @override
  String get menuNoCompletedGames => 'No completed games';

  @override
  String menuArg0Wins(String arg0) {
    return '$arg0% wins';
  }

  @override
  String get menuDetailsByMode => 'Details by mode';

  @override
  String menuArg0WinsArg1LossesInArg2Games(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return '$arg0 wins, $arg1 losses in $arg2 games';
  }

  @override
  String get menuNoGames => 'No games';

  @override
  String get menuWins => 'wins';

  @override
  String get menuWins309 => 'Wins';

  @override
  String get menuLosses => 'Losses';

  @override
  String get menuCasual => 'Casual';

  @override
  String get menuRanked => 'Ranked';

  @override
  String get menuSolo => 'Solo';

  @override
  String get menuPrivateRoomsWithHumanPlayersAreIncludedInCasual =>
      'Private rooms with human players are included in Casual.';

  @override
  String menuArg0OlderGamesWithoutDetailedHistoryAreNotAssigned(String arg0) {
    return '$arg0 older games without detailed history are not assigned to a mode.';
  }

  @override
  String get menuUnableToSendTheRequestTryAgain =>
      'Unable to send the request. Try again.';

  @override
  String get menuBlockThisPlayer => 'Block this player?';

  @override
  String get menuYourFriendshipWillBeRemovedAndPendingRequestsAnd =>
      'Your friendship will be removed and pending requests and invitations will be cancelled. This player will no longer be able to contact you this way. You can unblock them from the Blocked tab.';

  @override
  String get menuBlock => 'Block';

  @override
  String get menuUnableToUpdateTheBlockTryAgain =>
      'Unable to update the block. Try again.';

  @override
  String get menuProfileUnavailable => 'Profile unavailable.';

  @override
  String get menuPlayerProfile => 'Player profile';

  @override
  String get menuWinRate => 'Win rate';

  @override
  String get menuGamesPlayed => 'Games played';

  @override
  String menuArg0WinsArg1Losses(String arg0, String arg1) {
    return '$arg0 wins · $arg1 losses';
  }

  @override
  String get menuAddFriend => 'Add friend';

  @override
  String get menuSignInRequired => 'Sign-in required';

  @override
  String get menuYourProfile => 'Your profile';

  @override
  String get menuSending => 'Sending…';

  @override
  String get menuCheckingFriendship => 'Checking friendship…';

  @override
  String get menuAlreadyFriends => 'Already friends';

  @override
  String get menuCheckFriendshipAgain => 'Check friendship again';

  @override
  String get menuServiceUnavailableTryAgainShortly =>
      'Service unavailable. Try again shortly.';

  @override
  String get menuDeleteYourAccount => 'Delete your account?';

  @override
  String get menuYourProfileFriendsAndHistoryWillBePermanentlyDeleted =>
      'Your profile, friends and history will be permanently deleted. Purchases remain subject to app store rules. This cannot be undone.';

  @override
  String get menuDeletePermanently => 'Delete permanently';

  @override
  String get menuAccountDeleted => 'Account deleted.';

  @override
  String get menuGuestAccount => 'Guest account';

  @override
  String get menuSignedInAccount => 'Signed-in account';

  @override
  String get menuGuest => 'Guest';

  @override
  String get menuSignedOut => 'Signed out.';

  @override
  String get menuSignOut => 'Sign out';

  @override
  String get menuDeleteMyAccount => 'Delete my account';

  @override
  String menuArg0Arg1XP(String arg0, String arg1) {
    return '$arg0 / $arg1 XP';
  }

  @override
  String menuLevelArg0ProgressArg1XPOutOf500(String arg0, String arg1) {
    return 'Level $arg0 progress, $arg1 XP out of 500';
  }

  @override
  String menuArg0XPToGoBeforeLevelArg1(String arg0, String arg1) {
    return '$arg0 XP to go before level $arg1';
  }

  @override
  String get menuChangeNickname => 'Change nickname';

  @override
  String get menuSave => 'Save';

  @override
  String get menuProfileUnavailableTryAgain => 'Profile unavailable. Try again';

  @override
  String get menuPlayerProfile352 => 'Player profile';

  @override
  String get menuEditMyAvatar => 'Edit my avatar';

  @override
  String get menuCustomisation => 'Customisation';

  @override
  String get menuRecentGames => 'Recent games';

  @override
  String get menuReloadHistory => 'Reload history';

  @override
  String get menuYourNextCompletedGamesWillAppearHere =>
      'Your next completed games will appear here.';

  @override
  String get menuWin => 'Win';

  @override
  String get menuLoss => 'Loss';

  @override
  String get menuPrivate => 'Private';

  @override
  String get menuEquipmentSavedTryLoadingTheInventoryAgain =>
      'Equipment saved. Try loading the inventory again.';

  @override
  String get menuUnableToEquipCheckYourConnectionAndTryAgain =>
      'Unable to equip. Check your connection and try again.';

  @override
  String get menuInventoryUnavailable => 'Inventory unavailable.';

  @override
  String get menuTheOriginalBlueCardBackAlwaysAvailable =>
      'The original blue card back, always available.';

  @override
  String get menuEquipped => 'Equipped';

  @override
  String menuArg0Equipped(String arg0) {
    return '$arg0 equipped';
  }

  @override
  String get menuEquip => 'Equip';

  @override
  String menuSeasonArg0Arg1(String arg0, String arg1) {
    return 'Season $arg0/$arg1';
  }

  @override
  String get menuSeasonEnds => 'Season ends';

  @override
  String get menuDays => 'Days';

  @override
  String get menuHours => 'Hours';

  @override
  String get menuMinutes => 'Minutes';

  @override
  String get menuSeconds => 'Seconds';

  @override
  String menuSeasonEndsInArg0DaysArg1HoursArg2Minutes(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Season ends in $arg0 days, $arg1 hours, $arg2 minutes and $arg3 seconds';
  }

  @override
  String get menuYourSeasonsBestEloDeterminesYourRewardsTiersAre =>
      'Your season’s best Elo determines your rewards. Tiers are cumulative.';

  @override
  String get menuBronzeBorder => 'Bronze border';

  @override
  String get menuSilverBorder => 'Silver border';

  @override
  String get menuGoldBorder => 'Gold border';

  @override
  String get menuTxapelaBeret => 'Txapela (beret)';

  @override
  String get menuAtTheMonthlyCloseEloAndPeakEloReset =>
      'At the monthly close, Elo and Peak Elo reset to 800. You keep your cosmetics: equip them in Edit my avatar → Borders / Trophies.';

  @override
  String get menuSkin => 'Skin';

  @override
  String get menuTop => 'Top';

  @override
  String get menuBackgroundColour => 'Background colour';

  @override
  String get menuHairColour => 'Hair colour';

  @override
  String get menuBorders => 'Borders';

  @override
  String get menuNone => 'None';

  @override
  String get menuBronze => 'Bronze';

  @override
  String get menuSilver => 'Silver';

  @override
  String get menuDiamond => 'Diamond';

  @override
  String get menuNone391 => 'None';

  @override
  String get menuTxapela => 'Txapela';

  @override
  String get menuCrown => 'Crown';

  @override
  String get menuCap => 'Cap';

  @override
  String get menuBeanie => 'Beanie';

  @override
  String get menuBald => 'Bald';

  @override
  String get menuMohawk => 'Mohawk';

  @override
  String get menuGoldFrames => 'Gold frames';

  @override
  String get menuRound => 'Round';

  @override
  String get menuStripedShirt => 'Striped shirt';

  @override
  String get menuUnableToSaveCheckYourConnectionAndTryAgain =>
      'Unable to save. Check your connection and try again.';

  @override
  String get menuSaving => 'Saving…';

  @override
  String get menuSave403 => 'Save';

  @override
  String menuAvatarSkinArg0HairArg1GlassesArg2TopArg3(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Avatar: skin $arg0, hair $arg1, glasses $arg2, top $arg3';
  }

  @override
  String get menuBrightRed => 'Bright red';

  @override
  String get menuOrange => 'Orange';

  @override
  String get menuSunshineYellow => 'Sunshine yellow';

  @override
  String get menuAppleGreen => 'Apple green';

  @override
  String get menuPineGreen => 'Pine green';

  @override
  String get menuCyan => 'Cyan';

  @override
  String get menuNavyBlue => 'Navy blue';

  @override
  String get menuDeepPurple => 'Deep purple';

  @override
  String get menuFuchsiaPink => 'Fuchsia pink';

  @override
  String get menuBrown => 'Brown';

  @override
  String get menuLightGrey => 'Light grey';

  @override
  String get menuCharcoal => 'Charcoal';

  @override
  String get menuBrunette => 'Brunette';

  @override
  String get menuBlonde => 'Blonde';

  @override
  String get menuBlack => 'Black';

  @override
  String get menuCopper => 'Copper';

  @override
  String get menuPurple => 'Purple';

  @override
  String get menuFrenchMusChampionshipRegulations =>
      'French Mus Championship Regulations';

  @override
  String get menuFederationFrancaiseDeMus => 'Fédération Française de Mus';

  @override
  String get menuLastRevisedJanuary2023 => 'Last revised: January 2023.';

  @override
  String get menuPrinciplesAndRankings => 'Principles and rankings';

  @override
  String get menuMusIsPlayedInTeamsOf2WithA =>
      'Mus is played in teams of 2, with a Spanish deck of 40 cards, over 3 rounds of 40 points (40 tantto or 8 hamarreko), unless an exception applies.';

  @override
  String get menuRankingsAreCalculatedAsFollows3RoundsWon1 =>
      'Rankings are calculated as follows: 3 rounds won = 1 win.';

  @override
  String get menuAWinnerOneWinIsCountedRegardlessOfRounds =>
      'a) Winner: one win is counted, regardless of rounds lost or points scored during those rounds.';

  @override
  String get menuBLoser0WinsAreCountedAlongWithRounds =>
      'b) Loser: 0 wins are counted, along with rounds won and points scored only in lost rounds.';

  @override
  String get menuForTheFirstDealThePlayerWhoDrewThe =>
      'For the first deal, the player who drew the lowest card deals. They shuffle and have the opponent to their left cut, leaving more than one card above or below the cut. The dealer deals one card at a time from the top, starting with the opponent to their right, who has the lead (Esku). Each player must check how many cards they receive. Players may look at their cards before the deal is complete.';

  @override
  String get menuIfACardIsTurnedOverDuringTheFirst =>
      'If a card is turned over during the first deal, or any other irregularity occurs (more or fewer than 4 cards, etc.), collect all cards, shuffle, cut and deal again.';

  @override
  String get menuIfTheErrorIsFoundAfterPlayHasBegun =>
      'If the error is found after play has begun, meaning after a player has stopped the Mus, the player with more or fewer than four cards does not take part and their team’s points are cancelled.';

  @override
  String get menuIfACardIsTurnedOverAfterMusHas =>
      'If a card is turned over after Mus has been agreed once, play continues normally.';

  @override
  String get menuEskuAndTheirPartnerDecideWhetherToStopWith =>
      'Esku and their partner decide whether to stop with Mintza or choose Mus by saying Zuetan or “Over to you”. Their opponents then do the same in turn.';

  @override
  String get menuIfThereIsMusAll4PlayersDiscardThe =>
      'If there is Mus, all 4 players discard the desired number of cards at once, with ESKU first. The dealer then gives each player their replacement cards in one batch.';

  @override
  String get menuPlayBeginsWithESKUFirstHighThenLowPairs =>
      'Play begins with ESKU first: High, then Low, Pairs, Game or Point. Biak Embido and Biak Hordago bids are permitted.';

  @override
  String get menuTiraIdukiAndHordagoBindTheTeamTheSpeakers =>
      'Tira, Iduki and Hordago bind the team: the speaker’s partner cannot overrule them, even as Esku. Both Nere gatik tira and Tira nere gatik, or “For me, fold”, leave the partner free to raise. When both partners bet or raise, the first decision stands. After Hordago Kanta, no points (tantto) are scored.';

  @override
  String get menuSigns => 'Signs';

  @override
  String get menuOnlyTheFollowingOfficialSignsAreAllowed =>
      'Only the following official signs are allowed:';

  @override
  String get menu2KingsLowerLip => '2 Kings: lower lip.';

  @override
  String get menu2AcesStickOutTheTongue => '2 Aces: stick out the tongue.';

  @override
  String get menuMediakMoveOneSideOfTheLips =>
      'Mediak: move one side of the lips.';

  @override
  String get menuDobliakMoveBothSidesOfTheLips =>
      'Dobliak: move both sides of the lips.';

  @override
  String get menu29SameAsMediak => '29: same as mediak.';

  @override
  String get menu30Or31Wink => '30 or 31: wink.';

  @override
  String get menuGameRaiseTheEyebrows => 'Game: raise the eyebrows.';

  @override
  String get menuTheSignFor30Or31MayBeMade =>
      'The sign for 30 or 31 may be made at any time. The sign for 29 may only be sent after Pairs is over. The Game sign is forbidden with 31.';

  @override
  String get menuDoublePairs => 'Double pairs';

  @override
  String get menuWhen2OpponentsHaveDoublePairsWithTheSame =>
      'When 2 opponents have double pairs with the same higher pair, the one with the stronger lower pair always wins. Example: two elevens + two sevens beat two elevens + two sixes, even in last position.';

  @override
  String get menuErrors => 'Errors';

  @override
  String get menuAnnouncingPairsWithoutHavingAny =>
      'Announcing pairs without having any:';

  @override
  String get menuAIfThePartnerHasNoneAllBetsOn =>
      'a) If the partner has none, all bets on Pairs are cancelled. The opponent still scores the points for their pair or pairs.';

  @override
  String get menuBIfThePartnerHasPairsAndTheOpponents =>
      'b) If the partner has pairs and the opponents do too, all bets on Pairs are cancelled; the opponent scores the TIRA for Pairs and the points for their pair or pairs.';

  @override
  String get menuFailingToAnnouncePairsWhenHoldingThem =>
      'Failing to announce pairs when holding them:';

  @override
  String get menuUnannouncedPairsCannotBeUsedToBetCallOr =>
      'Unannounced pairs cannot be used to bet, call or score later.';

  @override
  String get menuIfThePartnerHasNoPairsAnOpponentWith =>
      'If the partner has no pairs, an opponent with pairs scores one Tira point.';

  @override
  String get menuAnnouncingGameWithoutHavingIt =>
      'Announcing Game without having it:';

  @override
  String get menuAIfNoneOfTheOther3PlayersHas =>
      'a) If none of the other 3 players has Game, the opponents score the Tira for Point and the Pontua point.';

  @override
  String get menuBIfThePartnerHasGameAndTheOpponents =>
      'b) If the partner has Game and the opponents do not, the error is ignored.';

  @override
  String get menuCIfThePartnerHasNoGameButAn =>
      'c) If the partner has no Game but an opponent does, Game bets are cancelled and the opponent scores their Game points.';

  @override
  String get menuDIfThePartnerAndAnOpponentBothHave =>
      'd) If the partner and an opponent both have Game, Game bets are cancelled; the opponent scores the TIRA for Game and their Game points.';

  @override
  String get menuFailingToAnnounceGameWhenHoldingIt =>
      'Failing to announce Game when holding it:';

  @override
  String get menuAIfNoneOfTheOther3PlayersHas465 =>
      'a) If none of the other 3 players has Game, Point bets are cancelled and the opponent scores the ttantto for Tira and the Pontua point. The unannounced Game does not count.';

  @override
  String get menuBIfThePartnerHasGameAndTheOpponents466 =>
      'b) If the partner has Game and the opponents do not, only the partner’s Game is counted.';

  @override
  String get menuCIfThePartnerHasNoGameAndAn =>
      'c) If the partner has no Game and an opponent does, that opponent scores the TIRA for Game and their Game points. A player with no pairs or Game cannot bet or raise on behalf of a partner who has them.';

  @override
  String get menuScoringAndRaises => 'Scoring and raises';

  @override
  String get menuDuringPlayPointsConcededThroughTIRAAreScoredAs =>
      'During play, points conceded through TIRA are scored as they occur. In a perfect tie, ESKU always wins. At the end of each hand, all four players must lay all their cards face up on the table.';

  @override
  String get menuScoreHighThenLowPairsGameOrPointAs =>
      'Score High, then Low, Pairs, Game or Point as follows:';

  @override
  String get menuHighIfEveryoneSaidPASOTheBestHighScores =>
      'High: if everyone said PASO, the best High scores 1 point (Haundi Pasa). If High was declined after Embido, nothing is scored. If there was Iduki, only the points bet are scored.';

  @override
  String get menuLowTheSameAsHigh => 'Low: the same as High.';

  @override
  String get menuPairsAfterPasoTheTeamWithTheBestPair =>
      'Pairs: after Paso, the team with the best pair scores its pairs: 1 point for a pair, 2 for mediak or 3 for double pairs. After Iduki, the bet is added.';

  @override
  String get menuGameTheSameAsPairsCounting2PointsFor =>
      'Game: the same as Pairs, counting 2 points for Game or 3 for 31, for each Game held by the team that wins Game.';

  @override
  String get menuPointPontuaAfterPasoTheBestPontuaScores1 =>
      'Point (Pontua): after Paso, the best Pontua scores 1 point. After Tira, the team that won the Tira scores 1 Pontua point. After Iduki, the points bet plus 1 Pontua point are scored.';

  @override
  String get menuRaiseExamples => 'Raise examples:';

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
      'No ttantto may be scored once the cards have been gathered.';

  @override
  String get menuRefereeing => 'Refereeing';

  @override
  String get menuTheRefereeIntervenesOnlyAtAPlayersRequestOr =>
      'The referee intervenes only at a player’s request or upon observing an irregularity.';

  @override
  String get menuAnyDisputeOverTheseRegulationsOrAnySituationNot =>
      'Any dispute over these regulations, or any situation not covered here, will be settled by the referee.';

  @override
  String get menuTheRefereeMayImposePenaltiesUpToAndIncluding =>
      'The referee may impose penalties up to and including exclusion.';

  @override
  String menuArticleArg0(String arg0) {
    return 'Article $arg0';
  }

  @override
  String get invitationPrivateTitle => 'Create a private room';

  @override
  String get invitationPrivateLabel => 'Private room';

  @override
  String get invitationCasualTitle => 'Online (Casual) as a duo';

  @override
  String get invitationCasualLabel => 'Casual duo';

  @override
  String get invitationRankedTitle => 'Online (Ranked) as a duo';

  @override
  String get invitationRankedLabel => 'Ranked duo';

  @override
  String get classicCardBack => 'Classic card back';

  @override
  String gamesPlayedCount(String count) {
    return '$count games';
  }

  @override
  String avatarOption(String name, String number) {
    return '$name: option $number';
  }

  @override
  String get nicknameLengthError =>
      'Your nickname must contain 1 to 24 characters.';

  @override
  String get deleteAccountError => 'Deletion failed. Try again.';

  @override
  String get connectionUnavailable => 'Connection unavailable. Try again.';

  @override
  String seasonName(String name) {
    return 'Season $name';
  }

  @override
  String questPlay(String count) {
    return 'Finish $count games';
  }

  @override
  String questWin(String count) {
    return 'Win $count games';
  }

  @override
  String questRanked(String count) {
    return 'Win $count ranked games';
  }

  @override
  String get questGeneric => 'Weekly challenge';

  @override
  String get catalogUnknown => 'Cosmetic';

  @override
  String get catalogUnknownDescription => 'Customise your look at the table.';

  @override
  String get catalogSun => 'Sun';

  @override
  String get catalogMountain => 'Mountain';

  @override
  String get catalogBlue => 'Blue';

  @override
  String get catalogGreen => 'Green';

  @override
  String get catalogOcean => 'Ocean';

  @override
  String get catalogRuby => 'Ruby';

  @override
  String get catalogDiamondBorder => 'Diamond border';

  @override
  String get catalogLeagueTxapela => 'League Txapela';

  @override
  String get catalogLeagueCrown => 'League crown';

  @override
  String get catalogEmeraldBorder => 'Emerald frame';

  @override
  String get catalogAmethystBorder => 'Amethyst frame';

  @override
  String get catalogEmeraldBack => 'Emerald card back';

  @override
  String get catalogVioletBack => 'Purple card back';

  @override
  String get catalogEskerrik => 'Eskerrik asko !';

  @override
  String get catalogRematch => 'Rematch?';

  @override
  String get catalogMullet => 'Mullet';

  @override
  String get catalogStriped => 'Blue and white striped shirt';

  @override
  String get catalogGoldGlasses => 'Gold sunglasses';

  @override
  String get catalogCap => 'Blue cap';

  @override
  String get catalogBeanie => 'Copper beanie';

  @override
  String get catalogRoundGlasses => 'Round glasses';

  @override
  String get catalogOceanBack => 'Ocean card back';

  @override
  String get catalogCoralBack => 'Coral card back';

  @override
  String get catalogEmeraldBorderDescription =>
      'An emerald ring around your avatar.';

  @override
  String get catalogAmethystBorderDescription =>
      'A purple border to show at the table.';

  @override
  String get catalogEmeraldBackDescription => 'An emerald green card back.';

  @override
  String get catalogVioletBackDescription => 'A purple card back.';

  @override
  String get catalogEskerrikDescription => 'Thank other players with one tap.';

  @override
  String get catalogRematchDescription => 'Suggest another game to the table.';

  @override
  String get catalogMulletDescription =>
      'Short in front, long at the back: a bold haircut.';

  @override
  String get catalogStripedDescription =>
      'Blue and white stripes for your outfit.';

  @override
  String get catalogGoldGlassesDescription => 'Dark lenses with gold frames.';

  @override
  String get catalogCapDescription => 'A blue cap worn over your hair.';

  @override
  String get catalogBeanieDescription => 'A copper beanie with a pompom.';

  @override
  String get catalogFineGlassesDescription =>
      'Thin gold frames that leave your eyes visible.';

  @override
  String get catalogRoundGlassesDescription =>
      'Clear lenses with round frames.';

  @override
  String get catalogOceanBackDescription => 'A classic pattern in deep blue.';

  @override
  String get catalogCoralBackDescription => 'A classic pattern in coral.';

  @override
  String get catalogBaldDescription => 'A clean head with no hair layer.';

  @override
  String get catalogMohawkDescription =>
      'A centred mohawk, visible from the front.';

  @override
  String get legalTermsBody =>
      'ISAMUS — TERMS OF USE\nDraft dated 26 October 2026 — to be completed before publication\n\nPublisher: [NAME / COMPANY NAME], [ADDRESS], [COUNTRY]. Contact: [SUPPORT EMAIL].\n\n1. The service\nIsaMus lets you play Mus, the 4 Kings / 4 Aces variant, with players or bots. Points and rankings have no monetary value. The service offers neither cash wagers nor winnings exchangeable for money.\n\n2. Account\nA guest account lets you start playing. Linking a verified email address or an Apple/Google identity lets you recover your account. Without this link, losing your session or device may make your progress unrecoverable. Protect your sign-in credentials and choose a respectful nickname that does not disclose personal data.\n\n3. Play and player relationships\nCheating, exploiting vulnerabilities, impersonation, harassment and abusive solicitation are prohibited. Friend requests and invitations may be declined. Bots are identified as such. Disconnections trigger automatic actions so play can continue.\n\n4. Digital items\nCosmetics are visual elements that give no advantage in cards or scores. Items, features and prices are shown before purchase confirmation in the app store. Apple or Google processes payment. IsaMus does not receive your bank card number. Purchases must be linked to a secured account. Restore purchases requests synchronisation. A digital item cannot be converted into money or transferred between players in the app.\nRefund terms and applicable legal rights remain those of your country and app store. Nothing in these terms limits mandatory consumer guarantees. Any information or consent required for immediate delivery of digital content must be provided through the store purchase flow.\n\n5. Advertising\nAds may appear on the home screen. Ad privacy choices are available from your profile. Refusing optional use of your data must not prevent you from playing.\n\n6. Availability and changes\nThe service depends on networks and third-party services. Outages or maintenance may occur. The publisher informs players of significant changes affecting the service or acquired items and respects applicable mandatory rights.\n\n7. Deletion and support\nAccount deletion can be requested in Account & security. It removes the profile and associated data according to the privacy policy. It does not automatically cancel a store transaction. For assistance, contact [SUPPORT EMAIL].\n\n8. Applicable law and disputes\nMandatory consumer protection rules in your place of residence apply. Provisions on applicable law, mediation and the competent authority must be adapted to the publisher’s actual country and status before publication.\n';

  @override
  String get legalPrivacyBody =>
      'ISAMUS — PRIVACY POLICY\nDraft dated 26 October 2026 — to be completed before publication\n\nData controller: [NAME / COMPANY NAME], [ADDRESS], [COUNTRY]. Contact for your rights: [PRIVACY EMAIL].\n\nData and uses\nYour account has a technical identifier, nickname, Elo rating and statistics. An email address or Apple/Google identity is used only if you choose to secure your account. Sessions authenticate you. Passwords are handled by the authentication service and are not accessible in the app.\nGames contain the participants, actions and states needed to play. History stores results and Elo changes. Friend requests and invitations enable social features. Presence tells accepted friends whether you are online or in a game; it does not reveal the room code.\nYour nickname, avatar and Elo are visible to other authenticated players. Cards and game states are accessible to participants in the current architecture. Do not put sensitive data in your nickname.\n\nPurchases and advertising\nApple/Google stores and RevenueCat handle purchases and validation. Your account identifier and cosmetic access rights allow purchase restoration. We do not collect your bank details.\nWhen advertising is enabled, Google AdMob and its consent mechanism may process technical data about your device, network, ad delivery and privacy choices. The integration requests non-personalised ads; this does not exclude all data processing by the SDK. Applicable consent forms and the Ad privacy choices link let you manage optional uses. The app does not require access to your contacts, microphone or precise location.\n\nGrounds for processing\nOperating the account, game and purchases is based on providing the service you request. Abuse prevention and security are based on the publisher’s legitimate interests, subject to your rights. Optional processing requiring consent must only be enabled after the required choice. Applicable legal obligations may require certain transaction records to be retained.\n\nProviders and transfers\nSupabase provides the database, authentication, server functions and real-time features. Apple, Google and RevenueCat take part in authentication, purchases or advertising depending on the features used. Before publication, the publisher must specify the actual regions, recipients, any international transfers and applicable contractual safeguards; these settings cannot be inferred from the app code.\n\nRetention\nYour profile, inventory and social relationships are kept while your account exists. Presence is linked to your connection. The publisher must document retention periods for history and technical logs: [HISTORY RETENTION], [LOG RETENTION], [BACKUP RETENTION]. Invitations are functionally valid for ten minutes; expiration does not mean immediate deletion from the database. Providers may have their own retention obligations.\n\nYour rights and deletion\nYou may request access, correction, deletion and, where legally applicable, portability, restriction or objection at [PRIVACY EMAIL]. Withdrawing consent does not affect previous lawful processing. Your profile offers account deletion. Requests concerning payments or an advertising identifier may also need to go to the relevant store or provider. You may contact the competent supervisory authority; in France, the CNIL (www.cnil.fr).\n\nMinors\nBefore publication, the publisher must define the minimum age, target audience and any necessary parental consent mechanism. Ad configuration and app store age declarations must reflect this choice.\n\nUpdates\nThe date and significant changes to this policy will be communicated in the app. This draft must be completed with actual publisher and provider information before going online.\n';

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
