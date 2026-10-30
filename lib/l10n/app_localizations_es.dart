// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'IsaMus';

  @override
  String get you => 'Tú';

  @override
  String get partner => 'Compañero';

  @override
  String team(String name) {
    return 'Equipo $name';
  }

  @override
  String rounds(int count) {
    return 'Rondas: $count / 3';
  }

  @override
  String get startGame => 'Repartir';

  @override
  String get nextHand => 'Siguiente mano';

  @override
  String get newGame => 'Nueva partida';

  @override
  String get dealing => 'Reparto';

  @override
  String get discarding => 'Descarte';

  @override
  String get roundScoring => 'Recuento';

  @override
  String get gameOver => 'Partida terminada';

  @override
  String get yourTurn => 'Te toca';

  @override
  String waitingFor(String name) {
    return 'Turno de $name';
  }

  @override
  String discardCards(int count) {
    return 'Cambiar $count carta(s)';
  }

  @override
  String get keepCards => 'Conservar mis cartas';

  @override
  String currentBid(int amount) {
    return 'Apuesta: $amount Tantto';
  }

  @override
  String roundWinner(String team) {
    return '$team gana la ronda';
  }

  @override
  String gameWinner(String team) {
    return '$team gana la partida';
  }

  @override
  String get actionFailed => 'Acción no disponible: la situación ha cambiado.';

  @override
  String cardLabel(int value, String suit) {
    return '$value de $suit';
  }

  @override
  String get oros => 'Oro';

  @override
  String get copas => 'Copas';

  @override
  String get espadas => 'Espadas';

  @override
  String get bastos => 'Bastos';

  @override
  String get hasPairs => 'Pariak dut';

  @override
  String get hasGame => 'Jokoa dut';

  @override
  String get hasNeither => 'Ez dut';

  @override
  String get sendSign => 'Hacer una seña al compañero';

  @override
  String get signTwoKings => '2 Reyes';

  @override
  String get signTwoAces => '2 Ases';

  @override
  String get signGame => 'Juego';

  @override
  String opponentShort(int number) {
    return 'Rival $number';
  }

  @override
  String scoreTotal(int total, int hamarreko, int tantto) {
    return 'Puntuación: $total pts ($hamarreko Hamarreko, $tantto Tantto)';
  }

  @override
  String get quickChat => 'Mensajes rápidos';

  @override
  String get chatGoodLuck => 'Buena suerte';

  @override
  String get chatNothing => 'No tengo nada';

  @override
  String get chatWellPlayed => '¡Bien jugado!';

  @override
  String get turnTime => 'Tiempo para jugar';

  @override
  String get raiseAmount => 'Subir…';

  @override
  String get openingAmount => 'Apostar…';

  @override
  String get increase => 'Aumentar';

  @override
  String get decrease => 'Reducir';

  @override
  String get validate => 'Confirmar';

  @override
  String bidTotal(int amount) {
    return 'Apuesta total: $amount Tantto';
  }

  @override
  String get playTitle => 'Jugar';

  @override
  String get leaderboardTitle => 'Top 100';

  @override
  String get shopTitle => 'Tienda';

  @override
  String get friendsTitle => 'Amigos';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get seasonPassTitle => 'Pase de temporada';

  @override
  String get tutorialTitle => 'Tutorial';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get menuUnableToCompleteThisActionCheckYourConnectionAnd =>
      'No se ha podido completar la acción. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get menuDocumentUnavailableTryAgain =>
      'Documento no disponible. Inténtalo de nuevo.';

  @override
  String get menuSoundEffects => 'Efectos de sonido';

  @override
  String get menuPreferenceUnavailable => 'Preferencia no disponible';

  @override
  String get menuTryAgain => 'Reintentar';

  @override
  String get menuAccountSecurity => 'Cuenta y seguridad';

  @override
  String get menuAdPrivacyChoices => 'Opciones de privacidad publicitaria';

  @override
  String get menuTermsOfUse => 'Condiciones de uso';

  @override
  String get menuPrivacyPolicy => 'Política de privacidad';

  @override
  String get menuLastDay => 'Último día';

  @override
  String menuOnlyArg0DLeft(String arg0) {
    return 'Solo quedan ${arg0}d';
  }

  @override
  String get menuSeasonInProgress => 'Temporada en curso';

  @override
  String get menuPlayer => 'Jugador';

  @override
  String get menuUnableToCompleteThisActionTheRoomMayHave =>
      'No se ha podido completar la acción. Es posible que la sala haya cambiado. Inténtalo de nuevo.';

  @override
  String menuCodeArg0CopiedToClipboard(String arg0) {
    return '¡Código $arg0 copiado al portapapeles!';
  }

  @override
  String get menuWAITINGROOM => 'SALA DE ESPERA';

  @override
  String get menuSyncErrorTryAgain => 'Error de sincronización. Reintentar';

  @override
  String get menuThisRoomIsReservedForPublicMatchmaking =>
      'Esta sala está reservada al emparejamiento público.';

  @override
  String get menuINVITATIONCODE => 'CÓDIGO DE INVITACIÓN';

  @override
  String get menuCopyCode => 'Copiar código';

  @override
  String get menuStartGame => 'Iniciar partida';

  @override
  String get menuFillWithAIPlayers => 'Completar con IA';

  @override
  String get menuTwoPlayersPerTeamAreRequired =>
      'Se necesitan dos jugadores por equipo.';

  @override
  String get menuWaitingForTheHost => 'Esperando al anfitrión...';

  @override
  String get menuTheRoomHasBeenClosed => 'La sala se ha cerrado.';

  @override
  String menuTeamArg0Arg12(String arg0, String arg1) {
    return 'Equipo $arg0 · $arg1/2';
  }

  @override
  String get menuYourTeam => 'Tu equipo';

  @override
  String get menuJoin => 'Unirse';

  @override
  String get menuYOU => 'TÚ';

  @override
  String get menuOpenSeat => 'Asiento libre';

  @override
  String get menuWaiting => 'Esperando…';

  @override
  String get menuHost => 'Anfitrión';

  @override
  String get menuAI => 'IA';

  @override
  String get menuInviteMyFriends => 'Invitar a mis amigos';

  @override
  String get menuAddFriendsFromTheFriendsTab =>
      'Añade amigos desde la pestaña Amigos.';

  @override
  String get menuFriend => 'Amigo';

  @override
  String menuInvitationSentToArg0(String arg0) {
    return 'Invitación enviada a $arg0.';
  }

  @override
  String get menuUnableToSendTheInvitation =>
      'No se ha podido enviar la invitación.';

  @override
  String get menuInvite => 'Invitar';

  @override
  String get menuSignInToPlay => 'Inicia sesión para jugar.';

  @override
  String get menuPleaseEnterYourNickname => 'Introduce tu apodo.';

  @override
  String get menuSignInToCreateYourProfile =>
      'Inicia sesión para crear tu perfil.';

  @override
  String get menuTheCodeMustContainExactly5Characters =>
      'El código debe tener exactamente 5 caracteres.';

  @override
  String get menuIAlreadyHaveAnAccount => 'Ya tengo una cuenta';

  @override
  String menuArg0Coins(String arg0) {
    return '$arg0 monedas';
  }

  @override
  String get menuWeeklyQuests => 'Misiones semanales';

  @override
  String get menuGAMEMODES => 'MODOS DE JUEGO';

  @override
  String get menuATYOUROWNPACE => 'A TU RITMO';

  @override
  String get menuTakeASeatAndLearnMusFromYourFirst =>
      'Siéntate a la mesa y aprende Mus, desde las primeras decisiones hasta el recuento de puntos.';

  @override
  String get menuNoTimerGuidedThenFreePlay =>
      'Sin cronómetro · Guiado y luego libre';

  @override
  String get menuLearnMus => 'Aprender Mus';

  @override
  String get menuOfficialRules => 'Reglas oficiales';

  @override
  String get menuQUICKMULTIPLAYER => 'MULTIJUGADOR RÁPIDO';

  @override
  String get menuONLINECASUAL => 'EN LÍNEA (CLÁSICO)';

  @override
  String get menuChallengePlayersOnlineInRelaxedFriendlyGamesWithNo =>
      'Desafía a jugadores en línea en partidas amistosas y relajadas, sin arriesgar Elo. Ideal para disfrutar del Mus.';

  @override
  String get menuOfficial4KingsAnd4AcesRulesNoPressure =>
      'Reglas oficiales de 4 Reyes y 4 Ases • Sin presión';

  @override
  String get menuOFFICIALCOMPETITION => 'COMPETICIÓN OFICIAL';

  @override
  String get menuONLINERANKED => 'EN LÍNEA (CLASIFICATORIO)';

  @override
  String menuYourCurrentEloArg0(String arg0) {
    return 'Tu Elo actual: $arg0';
  }

  @override
  String get menuSeasonRewards => 'Recompensas de temporada';

  @override
  String get menuClimbTheCompetitiveRankingsEveryWinRaisesYourElo =>
      'Escala en la clasificación. Cada victoria sube tu Elo y cada derrota lo baja. ¡Apunta al Top 100!';

  @override
  String get menuPlayRanked => 'Jugar (Clasificatorio)';

  @override
  String get menuSOLOPRACTICE => 'ENTRENAMIENTO EN SOLITARIO';

  @override
  String get menuSOLOVSAI => 'EN SOLITARIO CONTRA IA';

  @override
  String get menuPlayAgainst3LocalAIPlayersWithoutWaitingFor =>
      'Juega contra 3 IA locales sin esperar a otros jugadores. Ideal para repasar las reglas, las tácticas y las señas vascas.';

  @override
  String get menuInstantStart3IndependentBots =>
      'Inicio inmediato • 3 bots autónomos';

  @override
  String get menuPlayAgainstAI => 'Jugar contra la IA';

  @override
  String get menuPRIVATEROOM => 'SALA PRIVADA';

  @override
  String get menuPLAYWITHFRIENDS => 'JUGAR CON AMIGOS';

  @override
  String get menuCreateAPrivateRoom => 'Crear una sala privada';

  @override
  String get menuORJOINWITHACODE => 'O ÚNETE CON UN CÓDIGO';

  @override
  String get menuConfirmAndJoin => 'Confirmar y unirse';

  @override
  String get menuBASQUECARDGAMEMULTIPLAYER =>
      'JUEGO DE CARTAS VASCO • MULTIJUGADOR';

  @override
  String get menuCONNECTING => 'CONECTANDO...';

  @override
  String get menuCREATEYOURPROFILE => 'CREA TU PERFIL';

  @override
  String get menuYourNicknameEGPatxiAmaia => 'Tu apodo (p. ej., Patxi, Amaia…)';

  @override
  String get menuCreateMyProfile => 'Crear mi perfil';

  @override
  String get menuTop100Players => 'Top 100 de jugadores';

  @override
  String get menuRefreshRankings => 'Actualizar clasificación';

  @override
  String get menuLoadingRankings => 'Cargando clasificación';

  @override
  String get menuUnableToLoadRankingsCheckYourConnectionAndTry =>
      'No se ha podido cargar la clasificación. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get menuNoRankedPlayersYet => 'Aún no hay jugadores clasificados.';

  @override
  String get menuTheHighestEloRatings => 'Las mejores puntuaciones Elo';

  @override
  String menuYourPositionArg0(String arg0) {
    return 'Tu posición: #$arg0';
  }

  @override
  String get menuReachTheTop100ToAppearHere =>
      '¡Entra en el Top 100 para aparecer aquí!';

  @override
  String get menuRankedByDescendingElo => 'Ordenados por Elo de mayor a menor.';

  @override
  String menuPositionArg0Arg1Arg2EloArg3(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Posición $arg0, $arg1, $arg2 Elo$arg3';
  }

  @override
  String menuLevelArg0Arg1500XP(String arg0, String arg1) {
    return 'Nivel $arg0 · $arg1 / 500 XP';
  }

  @override
  String menuLevelArg0Arg1XPOutOf500(String arg0, String arg1) {
    return 'Nivel $arg0, $arg1 XP de 500';
  }

  @override
  String get menuYouHaveTwoKingsAndAGameTotalOf =>
      'Tienes dos Reyes y Juego de 31. Conserva la mano: di Mintza.';

  @override
  String get menuYourOpponentRaisesCallIdukiToCompareCardsAt =>
      'El rival sube la apuesta. Iguala (Iduki) para comparar las cartas en el recuento.';

  @override
  String get menuYouHaveTwoKingsBaiAnnouncesYourPairBet =>
      'Tienes dos Reyes: Bai anuncia tu pareja. ¡Apuesta 2 piedras!';

  @override
  String get menuYouHave31TheBestGameTotalBet2 =>
      'Tienes 31, el mejor Juego. Apuesta 2 piedras para abrir las apuestas.';

  @override
  String get menuThisIsHighHandiaYouHaveStrongCardsBet =>
      'Es la Grande (Handia). Tienes cartas fuertes, ¡apuesta!';

  @override
  String get menuAtLowYourAceIsFollowedByThreeFace =>
      'En la Chica, tu As va seguido de tres figuras. Pasa con Paso.';

  @override
  String get menuWatchTheOtherPlayersAnnouncementsAndResponses =>
      'Observa los anuncios y las respuestas de los demás jugadores.';

  @override
  String get menuTheTutorialIsWaitingForMintza => 'El tutorial espera Mintza.';

  @override
  String get menuDiscardingIsNotAvailableAtThisStep =>
      'El descarte no está disponible en este paso.';

  @override
  String get menuThisIsNotTheActionExpectedByTheTutorial =>
      'Esta no es la acción que espera el tutorial.';

  @override
  String get menuTheOtherPlayersAreTakingTheirTurns =>
      'Los demás jugadores están jugando…';

  @override
  String get menuIdukiCall => 'Iduki (Igualar)';

  @override
  String get menuRaise => 'Subir';

  @override
  String get menuBet2 => 'Apostar 2';

  @override
  String get menuMusOrMintza => '¿Mus o Mintza?';

  @override
  String get menuAtTheStartOfEachHandEachPlayerChooses =>
      'Al principio de cada mano, cada jugador elige Mus para pedir un cambio de cartas. Si los cuatro dicen Mus, todos pueden descartarse y recibir cartas nuevas. Mintza corta el Mus: se conservan las manos y comienzan las apuestas. Pulsa Mintza: solo está activo el botón esperado y su contorno brilla.';

  @override
  String get menuBettingPasoAndEmbido => 'Apostar: Paso y Embido';

  @override
  String get menuInEachPhaseYouCanBetStonesForYour =>
      'En cada fase puedes apostar piedras por tu equipo. Paso cede el turno sin abrir una apuesta. Embido propone una apuesta; Gehiago la sube. Tu equipo puede farolear con las apuestas, pero nunca enviar una seña falsa.';

  @override
  String get menuRespondingTiraAndIduki => 'Responder: Tira e Iduki';

  @override
  String get menuWhenFacingABetIdukiAcceptsTheCardsWill =>
      'Ante una apuesta, Iduki acepta: las cartas decidirán en el recuento. Tira rechaza: la fase termina y el rival suma los puntos de rechazo según las apuestas anteriores. Una subida propone una apuesta mayor.';

  @override
  String get menuHordagoTheWholeRound => 'Hordago: toda la ronda';

  @override
  String get menuHordagoPutsTheEntireRoundAtStakeIfAccepted =>
      'Hordago pone en juego toda la ronda. Si se acepta con Iduki, se comparan las manos inmediatamente en esta fase y el ganador se lleva la ronda. Tira rechaza el desafío y solo cede los puntos de rechazo. Apostarás 2 en Grande y Parejas, y después igualarás una subida en Juego. Las demás opciones seguirán desactivadas hasta el juego libre.';

  @override
  String get menuYourTurnToCall => 'Te toca igualar';

  @override
  String get menuYourOpponentRaisesBy8TheBetGoesFrom =>
      'El rival sube 8: la apuesta pasa de 2 a 10 piedras. Pulsa Iduki para aceptar. Las cartas decidirán el ganador en el recuento.';

  @override
  String get menuTheCardsAreRevealedBetsAndPointsForPairs =>
      'Se muestran las cartas. Se suman las apuestas y los puntos de Parejas y Juego. El primer equipo en llegar a 40 piedras gana la ronda.';

  @override
  String get menuHighHandia => 'Grande — Handia';

  @override
  String get menuCompareCardsFromHighestToLowestTheKingIs =>
      'Se comparan las cartas de mayor a menor. El Rey es la más alta. Pulsa Apostar 2 para proponer dos piedras. Un rival aceptará esta primera apuesta.';

  @override
  String get menuLowTtipia => 'Chica — Ttipia';

  @override
  String get menuNowCompareTheLowestCardsTheAceIsBest =>
      'Ahora se comparan las cartas más bajas. El As es la mejor. En caso de empate, se comparan las siguientes; Esku desempata una igualdad total.';

  @override
  String get menuPairsPareak => 'Parejas — Pareak';

  @override
  String get menuTwoMatchingCardsMakeAPairThreeMakeMediak =>
      'Dos cartas iguales forman pareja; tres forman Mediak; dos parejas o cuatro iguales forman Dobliak. Solo participan los jugadores con parejas. Tienes dos Reyes: Bai anuncia tu pareja. Pulsa Apostar 2 para defenderla.';

  @override
  String get menuGameJoko => 'Juego — Joko';

  @override
  String get menuFaceCardsAreWorth10AndOtherCardsTheir =>
      'Las figuras valen 10 y las demás cartas su valor. Se necesitan al menos 31. El mejor Juego es 31, seguido de 32. Si nadie tiene Juego, se juega al Punto, buscando acercarse a 30. Apuesta 2: un rival subirá y aprenderás a igualar con Iduki.';

  @override
  String get menuYourTurnToPlay => '¡Te toca jugar!';

  @override
  String get menuYouHaveLearnedYourWayAroundTheTable =>
      'Ya has recorrido toda la mesa.';

  @override
  String get menuKeepPlayingAgainstTheBotsAllActionsAreAvailable =>
      'Sigue jugando contra los bots: todas las acciones están disponibles, sin cronómetro ni consejos. También puedes volver al menú.';

  @override
  String get menuReturnToMenu => 'Volver al menú';

  @override
  String get menuFinishThisGameFreePlay => 'Terminar la partida (Libre)';

  @override
  String get menuGotIt => 'Entendido';

  @override
  String get menuCheckYourEmailToActivateYourAccount =>
      'Revisa tu correo para activar tu cuenta.';

  @override
  String get menuAnAccountAlreadyUsesThisEmailAddress =>
      'Ya existe una cuenta con esta dirección de correo.';

  @override
  String get menuChooseAStrongerPassword => 'Elige una contraseña más segura.';

  @override
  String get menuTooManyAttemptsTryAgainShortly =>
      'Demasiados intentos. Inténtalo de nuevo en unos instantes.';

  @override
  String get menuUnableToSignUpTryAnotherNicknameAndCheck =>
      'No se ha podido crear la cuenta. Prueba otro apodo y comprueba tus datos.';

  @override
  String get menuServiceUnavailableCheckYourConnectionAndTryAgain =>
      'Servicio no disponible. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get menuSignUp => 'Registro';

  @override
  String get menuJoinIsaMus => 'Únete a IsaMus';

  @override
  String get menuChooseYourNicknameAndJoinTheGame =>
      'Elige tu apodo y entra en la partida.';

  @override
  String get menuNickname => 'Apodo';

  @override
  String get menuChooseANickname => 'Elige un apodo.';

  @override
  String get menu24CharactersMaximum => 'Máximo 24 caracteres.';

  @override
  String get menuEmail => 'Correo electrónico';

  @override
  String get menuEnterAValidEmailAddress =>
      'Introduce una dirección de correo válida.';

  @override
  String get menuPassword => 'Contraseña';

  @override
  String get menuAtLeast8Characters => 'Mínimo 8 caracteres';

  @override
  String get menuShowPassword => 'Mostrar contraseña';

  @override
  String get menuHidePassword => 'Ocultar contraseña';

  @override
  String get menuUseAtLeast8Characters => 'Usa al menos 8 caracteres.';

  @override
  String get menuCreateMyAccount => 'Crear mi cuenta';

  @override
  String get menuAlreadyHaveAnAccountSignIn =>
      '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get menuIncorrectEmailOrPassword => 'Correo o contraseña incorrectos.';

  @override
  String get menuConfirmYourEmailAddressBeforeSigningIn =>
      'Confirma tu correo antes de iniciar sesión.';

  @override
  String get menuUnableToSignInCheckYourDetailsAndTry =>
      'No se ha podido iniciar sesión. Comprueba tus datos e inténtalo de nuevo.';

  @override
  String get menuYourTableIsWaiting => 'Tu mesa te espera.';

  @override
  String get menuEnterYourPassword => 'Introduce tu contraseña.';

  @override
  String get menuSignIn => 'Iniciar sesión';

  @override
  String get menuPlayAsAGuest => 'Jugar como invitado';

  @override
  String get menuNoAccountYetSignUp => '¿Aún no tienes cuenta? Regístrate';

  @override
  String get menuQuestsUnavailable => 'Misiones no disponibles';

  @override
  String get menuClose => 'Cerrar';

  @override
  String get menuANewWeekNewChallenges => 'Una nueva semana, nuevos desafíos.';

  @override
  String get menuResetsOnMondayAt0000UTCXPRewards =>
      'Se reinicia los lunes a las 00:00 UTC. Las recompensas de XP se conceden automáticamente.';

  @override
  String get menuNewChallengesComingSoon => 'Pronto llegarán nuevos desafíos.';

  @override
  String menuArg0XPRewardReceived(String arg0) {
    return '+$arg0 XP · Recompensa recibida';
  }

  @override
  String get menuRewardReceived => 'Recompensa recibida';

  @override
  String menuArg0XP(String arg0) {
    return '+$arg0 XP';
  }

  @override
  String get menuXPRewardUnavailable => 'Recompensa de XP no disponible';

  @override
  String menuTierArg0Arg1(String arg0, String arg1) {
    return 'Nivel $arg0, $arg1';
  }

  @override
  String get menuNextGoal => 'próximo objetivo';

  @override
  String get menuLocked => 'bloqueado';

  @override
  String get menuVIP => 'VIP';

  @override
  String get menuFree => 'Gratis';

  @override
  String get menuNoReward => 'Sin recompensa';

  @override
  String get menuEarned => 'Conseguido';

  @override
  String get menuNextGoal189 => 'Próximo objetivo';

  @override
  String menuLevelArg0(String arg0) {
    return 'Nivel $arg0';
  }

  @override
  String get menuVIPRequired => 'Se requiere VIP';

  @override
  String get menuSeasonEnded => 'Temporada terminada';

  @override
  String get menuPleaseWait => 'Espera…';

  @override
  String get menuClaim => 'Reclamar';

  @override
  String menuArg0Coins195(String arg0) {
    return ', $arg0 monedas';
  }

  @override
  String get menuPreviewOnlyCosmeticNotYetDefinedOrAvailable =>
      'Solo vista previa: cosmético aún sin definir ni distribuir.';

  @override
  String get menuUpcomingCosmetic => 'Próximo cosmético';

  @override
  String get menuGoldCardBack => 'Dorso dorado';

  @override
  String get menuRubyTableFelt => 'Tapete rubí';

  @override
  String get menuActionUnavailableTryAgainShortly =>
      'Acción no disponible. Inténtalo de nuevo en unos instantes.';

  @override
  String get menuPassUnavailable => 'Pase no disponible.';

  @override
  String get menuNoActiveSeason => 'No hay temporada activa';

  @override
  String get menuDemoCalendar => 'Calendario de demostración';

  @override
  String menuArg0Arg1TiersUnlocked(String arg0, String arg1) {
    return '$arg0 / $arg1 niveles desbloqueados';
  }

  @override
  String get menuAllTiersUnlocked => '¡Todos los niveles desbloqueados!';

  @override
  String menuNextGoalTierArg0(String arg0) {
    return 'Próximo objetivo: nivel $arg0';
  }

  @override
  String menuArg0XPLeftToReachIt(String arg0) {
    return 'Faltan $arg0 XP para alcanzarlo.';
  }

  @override
  String get menuTapAnUnlockedRewardToClaimItAFree =>
      'Toca una recompensa desbloqueada para reclamarla. Una recompensa gratuita cada 5 niveles y una VIP en cada nivel.';

  @override
  String get menuRewardPath => 'Ruta de recompensas';

  @override
  String get menuReached => 'Alcanzado';

  @override
  String get menuGoal => 'Objetivo';

  @override
  String get menuComingUp => 'Próximamente';

  @override
  String get menuRewardAlreadyReceived => 'Recompensa ya recibida';

  @override
  String menuArg0CoinsReceivedArg1(String arg0, String arg1) {
    return '$arg0 monedas recibidas$arg1';
  }

  @override
  String get menuCosmeticUnlocked => ' · Cosmético desbloqueado';

  @override
  String get menuPREMIUM => 'PRÉMIUM';

  @override
  String get menuYourVIPPassIsActive => 'Tu pase VIP está activo';

  @override
  String get menuUnlockTheVIPPass => 'Desbloquea el pase VIP';

  @override
  String get menuNoAds => 'Sin anuncios';

  @override
  String get menuVIPPassTrack => 'Ruta VIP del pase';

  @override
  String get menuXP2 => 'XP ×2';

  @override
  String get menuCoinsCanOnlyBeEarnedThroughTheSeasonPass =>
      'Las monedas solo se consiguen en el pase de temporada. XP ×2 en partidas y misiones.';

  @override
  String get menuVIPIsTemporarilyUnavailable =>
      'El VIP no está disponible temporalmente.';

  @override
  String get menuVIPActive => 'VIP activo';

  @override
  String get menuVIPComingSoon => 'VIP disponible pronto';

  @override
  String menuBecomeVIPArg0Month(String arg0) {
    return 'Hazte VIP · $arg0/mes';
  }

  @override
  String get menuMonthlySubscriptionWithAutomaticRenewalCancelThroughYourApp =>
      'Suscripción mensual con renovación automática. Cancela desde tu tienda de aplicaciones.';

  @override
  String get menuRestorePurchases => 'Restaurar compras';

  @override
  String get menuNotEnoughCoinsForThisItem =>
      'No tienes suficientes monedas para este artículo.';

  @override
  String get menuThisItemIsAlreadyInYourInventory =>
      'Este artículo ya está en tu inventario.';

  @override
  String get menuThePriceHasChangedTheShopHasBeenRefreshed =>
      'El precio ha cambiado. Se ha actualizado la tienda.';

  @override
  String get menuThisItemIsNoLongerAvailable =>
      'Este artículo ya no está disponible.';

  @override
  String get menuPurchaseFailedTryAgainShortly =>
      'No se ha podido comprar. Inténtalo de nuevo en unos instantes.';

  @override
  String menuArg0AddedToYourInventory(String arg0) {
    return '$arg0 añadido a tu inventario';
  }

  @override
  String get menuOutfits => 'Conjuntos';

  @override
  String get menuCardBacks => 'Dorsos de cartas';

  @override
  String get menuHeadwear => 'Sombreros';

  @override
  String get menuGlasses => 'Gafas';

  @override
  String get menuHair => 'Cabello';

  @override
  String get menuQuickChats => 'Mensajes rápidos';

  @override
  String get menuShopUnavailable => 'Tienda no disponible.';

  @override
  String get menuNewItemsComingSoon => 'Pronto llegarán nuevos artículos.';

  @override
  String get menuOwned => 'En propiedad';

  @override
  String menuBuyArg0Arg1Coins(String arg0, String arg1) {
    return 'Comprar $arg0, $arg1 monedas';
  }

  @override
  String get menuBuying => 'Comprando…';

  @override
  String get menuBuy => 'Comprar';

  @override
  String get menuUnableToCompleteThisActionCheckYourConnectionOr =>
      'No se ha podido completar la acción. Comprueba tu conexión o inténtalo de nuevo.';

  @override
  String get menuYourFriend => 'tu amigo';

  @override
  String menuInvitationSentArg0(String arg0) {
    return 'Invitación enviada: $arg0';
  }

  @override
  String get menuInAGame => 'En una partida';

  @override
  String get menuOnline => 'En línea';

  @override
  String get menuOffline => 'Sin conexión';

  @override
  String get menuInviteToPlay => 'Invitar a jugar';

  @override
  String get menuFriendOptions => 'Opciones de amigo';

  @override
  String get menuRemoveFriend => 'Eliminar de mis amigos';

  @override
  String get menuFriendsPrivateRooms => 'Amigos y salas privadas';

  @override
  String get menuRequests => 'Solicitudes';

  @override
  String get menuBlocked => 'Bloqueados';

  @override
  String get menuSearchForANickname => 'Buscar un apodo';

  @override
  String get menuSearch => 'Buscar';

  @override
  String get menuNoResultsEnterAtLeast2Characters =>
      'Sin resultados. Introduce al menos 2 caracteres.';

  @override
  String get menuSendFriendRequest => 'Enviar solicitud de amistad';

  @override
  String get menuFriendRequestSent => 'Solicitud de amistad enviada';

  @override
  String get menuUnableToLoadFriendsTryAgain =>
      'No se han podido cargar los amigos. Reintentar';

  @override
  String get menuYourListIsEmptySearchForAPlayerTo =>
      'Tu lista está vacía. Busca un jugador para enviarle una solicitud.';

  @override
  String get menuUnableToLoadRequestsTryAgain =>
      'No se han podido cargar las solicitudes. Reintentar';

  @override
  String get menuNoPendingRequests => 'No hay solicitudes pendientes.';

  @override
  String get menuReceived => 'Recibidas';

  @override
  String get menuSent => 'Enviadas';

  @override
  String get menuRequestReceived => 'Solicitud recibida';

  @override
  String get menuRequestSent => 'Solicitud enviada';

  @override
  String get menuAccept => 'Aceptar';

  @override
  String get menuDecline => 'Rechazar';

  @override
  String get menuCancel => 'Cancelar';

  @override
  String get menuUnableToLoadBlockedPlayersTryAgain =>
      'No se han podido cargar los bloqueos. Reintentar';

  @override
  String get menuNoBlockedPlayers => 'No hay jugadores bloqueados.';

  @override
  String get menuBlockedPlayer => 'Jugador bloqueado';

  @override
  String get menuPlayerUnblocked => 'Jugador desbloqueado';

  @override
  String get menuUnblock => 'Desbloquear';

  @override
  String menuInviteArg0(String arg0) {
    return 'Invitar a $arg0';
  }

  @override
  String get menuChooseHowToPlayTogether => 'Elegid cómo jugar juntos.';

  @override
  String get menuSameTeamAgainstTwoOtherPlayers =>
      'Mismo equipo, contra otros dos jugadores';

  @override
  String get menuRoomWithACodeAndTeamSelection =>
      'Sala con código y elección de equipos';

  @override
  String get menuLeaveYourCurrentGame => 'Sal de la partida actual';

  @override
  String get menuNavigationUnavailable => 'Navegación no disponible';

  @override
  String get menuInvitationUnavailableLeaveYourCurrentGameOrTryAgain =>
      'Invitación no disponible. Sal de la partida actual o inténtalo de nuevo.';

  @override
  String get menuAFriend => 'Un amigo';

  @override
  String menuArg0InvitesYouToPlayArg1(String arg0, String arg1) {
    return '$arg0 te invita a jugar en $arg1';
  }

  @override
  String get menuYouWillPlayOnTheSameTeam => 'Jugaréis en el mismo equipo.';

  @override
  String get menuChooseYourTeamsInTheRoom => 'Elegid los equipos en la sala.';

  @override
  String get menuDecline296 => 'Rechazar';

  @override
  String get menuNewFriendRequestReceived =>
      'Nueva solicitud de amistad recibida';

  @override
  String menuArg0NewFriendRequests(String arg0) {
    return '$arg0 nuevas solicitudes de amistad';
  }

  @override
  String get menuCloseNotification => 'Cerrar notificación';

  @override
  String get menuOverallStatistics => 'Estadísticas globales';

  @override
  String get menuCurrentElo => 'Elo actual';

  @override
  String get menuPeakElo => 'Elo máximo';

  @override
  String get menuNoCompletedGames => 'Ninguna partida terminada';

  @override
  String menuArg0Wins(String arg0) {
    return '$arg0 % de victorias';
  }

  @override
  String get menuDetailsByMode => 'Detalles por modo';

  @override
  String menuArg0WinsArg1LossesInArg2Games(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return '$arg0 victorias, $arg1 derrotas en $arg2 partidas';
  }

  @override
  String get menuNoGames => 'Ninguna partida';

  @override
  String get menuWins => 'de victorias';

  @override
  String get menuWins309 => 'Victorias';

  @override
  String get menuLosses => 'Derrotas';

  @override
  String get menuCasual => 'Clásico';

  @override
  String get menuRanked => 'Clasificatorio';

  @override
  String get menuSolo => 'Solitario';

  @override
  String get menuPrivateRoomsWithHumanPlayersAreIncludedInCasual =>
      'Las salas privadas entre jugadores se incluyen en Clásico.';

  @override
  String menuArg0OlderGamesWithoutDetailedHistoryAreNotAssigned(String arg0) {
    return '$arg0 partidas antiguas sin historial detallado no se han asignado a ningún modo.';
  }

  @override
  String get menuUnableToSendTheRequestTryAgain =>
      'No se ha podido enviar la solicitud. Inténtalo de nuevo.';

  @override
  String get menuBlockThisPlayer => '¿Bloquear a este jugador?';

  @override
  String get menuYourFriendshipWillBeRemovedAndPendingRequestsAnd =>
      'Se eliminará vuestra amistad y se cancelarán las solicitudes e invitaciones pendientes. Este jugador ya no podrá contactarte por estos medios. Puedes desbloquearlo desde la pestaña Bloqueados.';

  @override
  String get menuBlock => 'Bloquear';

  @override
  String get menuUnableToUpdateTheBlockTryAgain =>
      'No se ha podido modificar el bloqueo. Inténtalo de nuevo.';

  @override
  String get menuProfileUnavailable => 'Perfil no disponible.';

  @override
  String get menuPlayerProfile => 'Perfil del jugador';

  @override
  String get menuWinRate => 'Porcentaje de victorias';

  @override
  String get menuGamesPlayed => 'Partidas jugadas';

  @override
  String menuArg0WinsArg1Losses(String arg0, String arg1) {
    return '$arg0 victorias · $arg1 derrotas';
  }

  @override
  String get menuAddFriend => 'Añadir amigo';

  @override
  String get menuSignInRequired => 'Debes iniciar sesión';

  @override
  String get menuYourProfile => 'Tu perfil';

  @override
  String get menuSending => 'Enviando…';

  @override
  String get menuCheckingFriendship => 'Comprobando la relación…';

  @override
  String get menuAlreadyFriends => 'Ya sois amigos';

  @override
  String get menuCheckFriendshipAgain => 'Reintentar relación';

  @override
  String get menuServiceUnavailableTryAgainShortly =>
      'Servicio no disponible. Inténtalo de nuevo en unos instantes.';

  @override
  String get menuDeleteYourAccount => '¿Eliminar tu cuenta?';

  @override
  String get menuYourProfileFriendsAndHistoryWillBePermanentlyDeleted =>
      'Tu perfil, amigos e historial se eliminarán definitivamente. Las compras siguen sujetas a las normas de las tiendas. Esta acción es irreversible.';

  @override
  String get menuDeletePermanently => 'Eliminar definitivamente';

  @override
  String get menuAccountDeleted => 'Cuenta eliminada.';

  @override
  String get menuGuestAccount => 'Cuenta de invitado';

  @override
  String get menuSignedInAccount => 'Cuenta conectada';

  @override
  String get menuGuest => 'Invitado';

  @override
  String get menuSignedOut => 'Sesión cerrada.';

  @override
  String get menuSignOut => 'Cerrar sesión';

  @override
  String get menuDeleteMyAccount => 'Eliminar mi cuenta';

  @override
  String menuArg0Arg1XP(String arg0, String arg1) {
    return '$arg0 / $arg1 XP';
  }

  @override
  String menuLevelArg0ProgressArg1XPOutOf500(String arg0, String arg1) {
    return 'Progreso del nivel $arg0, $arg1 XP de 500';
  }

  @override
  String menuArg0XPToGoBeforeLevelArg1(String arg0, String arg1) {
    return 'Faltan $arg0 XP para el nivel $arg1';
  }

  @override
  String get menuChangeNickname => 'Cambiar apodo';

  @override
  String get menuSave => 'Guardar';

  @override
  String get menuProfileUnavailableTryAgain =>
      'Perfil no disponible. Reintentar';

  @override
  String get menuPlayerProfile352 => 'Perfil de jugador';

  @override
  String get menuEditMyAvatar => 'Editar mi avatar';

  @override
  String get menuCustomisation => 'Personalización';

  @override
  String get menuRecentGames => 'Últimas partidas';

  @override
  String get menuReloadHistory => 'Recargar historial';

  @override
  String get menuYourNextCompletedGamesWillAppearHere =>
      'Tus próximas partidas terminadas aparecerán aquí.';

  @override
  String get menuWin => 'Victoria';

  @override
  String get menuLoss => 'Derrota';

  @override
  String get menuPrivate => 'Privado';

  @override
  String get menuEquipmentSavedTryLoadingTheInventoryAgain =>
      'Equipamiento guardado. Vuelve a cargar el inventario.';

  @override
  String get menuUnableToEquipCheckYourConnectionAndTryAgain =>
      'No se ha podido equipar. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get menuInventoryUnavailable => 'Inventario no disponible.';

  @override
  String get menuTheOriginalBlueCardBackAlwaysAvailable =>
      'El dorso azul original, siempre disponible.';

  @override
  String get menuEquipped => 'Equipado';

  @override
  String menuArg0Equipped(String arg0) {
    return '$arg0 equipado';
  }

  @override
  String get menuEquip => 'Equipar';

  @override
  String menuSeasonArg0Arg1(String arg0, String arg1) {
    return 'Temporada $arg0/$arg1';
  }

  @override
  String get menuSeasonEnds => 'Fin de temporada';

  @override
  String get menuDays => 'Días';

  @override
  String get menuHours => 'Horas';

  @override
  String get menuMinutes => 'Minutos';

  @override
  String get menuSeconds => 'Segundos';

  @override
  String menuSeasonEndsInArg0DaysArg1HoursArg2Minutes(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'La temporada termina en $arg0 días, $arg1 horas, $arg2 minutos y $arg3 segundos';
  }

  @override
  String get menuYourSeasonsBestEloDeterminesYourRewardsTiersAre =>
      'Tu mejor Elo de la temporada determina tus recompensas. Los niveles son acumulativos.';

  @override
  String get menuBronzeBorder => 'Borde de bronce';

  @override
  String get menuSilverBorder => 'Borde de plata';

  @override
  String get menuGoldBorder => 'Borde de oro';

  @override
  String get menuTxapelaBeret => 'Txapela (boina)';

  @override
  String get menuAtTheMonthlyCloseEloAndPeakEloReset =>
      'Al cierre mensual, el Elo y el Elo máximo vuelven a 800. Conservas tus cosméticos: equípalos en Editar mi avatar → Bordes / Trofeos.';

  @override
  String get menuSkin => 'Piel';

  @override
  String get menuTop => 'Camiseta';

  @override
  String get menuBackgroundColour => 'Color de fondo';

  @override
  String get menuHairColour => 'Color del cabello';

  @override
  String get menuBorders => 'Bordes';

  @override
  String get menuNone => 'Ninguna';

  @override
  String get menuBronze => 'Bronce';

  @override
  String get menuSilver => 'Plata';

  @override
  String get menuDiamond => 'Diamante';

  @override
  String get menuNone391 => 'Ninguno';

  @override
  String get menuTxapela => 'Txapela';

  @override
  String get menuCrown => 'Corona';

  @override
  String get menuCap => 'Gorra';

  @override
  String get menuBeanie => 'Gorro';

  @override
  String get menuBald => 'Calvo';

  @override
  String get menuMohawk => 'Cresta';

  @override
  String get menuGoldFrames => 'Montura dorada';

  @override
  String get menuRound => 'Redondas';

  @override
  String get menuStripedShirt => 'Camiseta de rayas';

  @override
  String get menuUnableToSaveCheckYourConnectionAndTryAgain =>
      'No se ha podido guardar. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get menuSaving => 'Guardando…';

  @override
  String get menuSave403 => 'Guardar';

  @override
  String menuAvatarSkinArg0HairArg1GlassesArg2TopArg3(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Avatar: piel $arg0, cabello $arg1, gafas $arg2, camiseta $arg3';
  }

  @override
  String get menuBrightRed => 'Rojo vivo';

  @override
  String get menuOrange => 'Naranja';

  @override
  String get menuSunshineYellow => 'Amarillo sol';

  @override
  String get menuAppleGreen => 'Verde manzana';

  @override
  String get menuPineGreen => 'Verde abeto';

  @override
  String get menuCyan => 'Cian';

  @override
  String get menuNavyBlue => 'Azul marino';

  @override
  String get menuDeepPurple => 'Violeta intenso';

  @override
  String get menuFuchsiaPink => 'Rosa fucsia';

  @override
  String get menuBrown => 'Marrón';

  @override
  String get menuLightGrey => 'Gris claro';

  @override
  String get menuCharcoal => 'Antracita';

  @override
  String get menuBrunette => 'Castaño';

  @override
  String get menuBlonde => 'Rubio';

  @override
  String get menuBlack => 'Negro';

  @override
  String get menuCopper => 'Cobrizo';

  @override
  String get menuPurple => 'Violeta';

  @override
  String get menuFrenchMusChampionshipRegulations =>
      'Reglamento del Campeonato de Francia de Mus';

  @override
  String get menuFederationFrancaiseDeMus => 'Fédération Française de Mus';

  @override
  String get menuLastRevisedJanuary2023 =>
      'Última modificación: enero de 2023.';

  @override
  String get menuPrinciplesAndRankings => 'Principios y clasificación';

  @override
  String get menuMusIsPlayedInTeamsOf2WithA =>
      'El Mus se juega por equipos de 2 jugadores, con una baraja española de 40 cartas, en 3 rondas de 40 puntos (40 tantto u 8 hamarreko), salvo excepción.';

  @override
  String get menuRankingsAreCalculatedAsFollows3RoundsWon1 =>
      'La clasificación se calcula así: 3 rondas ganadas = 1 victoria.';

  @override
  String get menuAWinnerOneWinIsCountedRegardlessOfRounds =>
      'a) Ganador: se cuenta una victoria, sin tener en cuenta las rondas perdidas ni los puntos conseguidos en ellas.';

  @override
  String get menuBLoser0WinsAreCountedAlongWithRounds =>
      'b) Perdedor: se cuentan 0 victorias, las rondas ganadas y solo los puntos conseguidos en las rondas perdidas.';

  @override
  String get menuForTheFirstDealThePlayerWhoDrewThe =>
      'En el primer reparto, da quien haya sacado la carta más baja. Debe barajar y hacer cortar al rival de su izquierda, que dejará más de una carta por encima o por debajo del corte. Se reparte una a una por arriba, empezando por el rival de la derecha, que será mano (Esku). Cada jugador debe comprobar cuántas cartas recibe. Se pueden mirar las cartas antes de terminar el reparto.';

  @override
  String get menuIfACardIsTurnedOverDuringTheFirst =>
      'Si se descubre una carta en el primer reparto o se detecta otra anomalía (más o menos de 4 cartas, etc.), se recogen todas, se baraja, se corta y se vuelve a repartir.';

  @override
  String get menuIfTheErrorIsFoundAfterPlayHasBegun =>
      'Si el error se detecta una vez iniciado el juego, es decir, después de que un jugador haya cortado, quien tenga más o menos de cuatro cartas no participa y se anulan los puntos de su equipo.';

  @override
  String get menuIfACardIsTurnedOverAfterMusHas =>
      'Si se descubre una carta después de haber habido Mus una vez, el juego continúa normalmente.';

  @override
  String get menuEskuAndTheirPartnerDecideWhetherToStopWith =>
      'Esku y su compañero deciden si cortan con Mintza o van a Mus diciendo Zuetan o «A vosotros». Después, sus rivales hacen lo mismo por turno.';

  @override
  String get menuIfThereIsMusAll4PlayersDiscardThe =>
      'Si hay Mus, los 4 jugadores se descartan de las cartas que quieran de una sola vez, empezando por ESKU. El repartidor entrega después las cartas nuevas de una vez a cada jugador.';

  @override
  String get menuPlayBeginsWithESKUFirstHighThenLowPairs =>
      'Se empieza siempre por ESKU: primero Grande, luego Chica, Parejas, Juego o Punto. Se permiten las apuestas Biak Embido y Biak Hordago.';

  @override
  String get menuTiraIdukiAndHordagoBindTheTeamTheSpeakers =>
      'Tira, Iduki y Hordago vinculan al equipo: el compañero no puede contradecirlos, aunque sea Esku. Se admiten Nere gatik tira y Tira nere gatik, o «Por mí, no quiero», dejando al compañero la posibilidad de subir. Si ambos apuestan o suben, prevalece la primera decisión. Tras Hordago Kanta no se anota ningún punto (tantto).';

  @override
  String get menuSigns => 'Señas';

  @override
  String get menuOnlyTheFollowingOfficialSignsAreAllowed =>
      'Solo se permiten las siguientes señas reglamentarias:';

  @override
  String get menu2KingsLowerLip => '2 reyes: labio inferior.';

  @override
  String get menu2AcesStickOutTheTongue => '2 ases: sacar la lengua.';

  @override
  String get menuMediakMoveOneSideOfTheLips =>
      'Mediak: mover un lado de los labios.';

  @override
  String get menuDobliakMoveBothSidesOfTheLips =>
      'Dobliak: mover ambos lados de los labios.';

  @override
  String get menu29SameAsMediak => '29: como los mediak.';

  @override
  String get menu30Or31Wink => '30 o 31: guiñar un ojo.';

  @override
  String get menuGameRaiseTheEyebrows => 'Juego: levantar las cejas.';

  @override
  String get menuTheSignFor30Or31MayBeMade =>
      'La seña de 30 o 31 puede hacerse en cualquier momento. La de 29 solo después de terminar Parejas. La seña de Juego está prohibida si se tiene 31.';

  @override
  String get menuDoublePairs => 'Duples';

  @override
  String get menuWhen2OpponentsHaveDoublePairsWithTheSame =>
      'Si 2 rivales tienen duples con la pareja superior igual, siempre gana quien tenga la pareja inferior más alta. Ejemplo: dos onces + dos sietes superan a dos onces + dos seises, incluso siendo postre.';

  @override
  String get menuErrors => 'Errores';

  @override
  String get menuAnnouncingPairsWithoutHavingAny =>
      'Anunciar parejas sin tenerlas:';

  @override
  String get menuAIfThePartnerHasNoneAllBetsOn =>
      'a) Si el compañero no tiene, se anulan todas las apuestas de Parejas. El rival cuenta los puntos de su pareja o parejas.';

  @override
  String get menuBIfThePartnerHasPairsAndTheOpponents =>
      'b) Si el compañero tiene y los rivales también, se anulan todas las apuestas de Parejas; el rival cuenta el TIRA de Parejas y los puntos de su pareja o parejas.';

  @override
  String get menuFailingToAnnouncePairsWhenHoldingThem =>
      'No anunciar parejas teniéndolas:';

  @override
  String get menuUnannouncedPairsCannotBeUsedToBetCallOr =>
      'Las parejas negadas no sirven para apostar, aceptar ni contarlas después.';

  @override
  String get menuIfThePartnerHasNoPairsAnOpponentWith =>
      'Si el compañero no tiene parejas, el rival que las tenga suma un punto de Tira.';

  @override
  String get menuAnnouncingGameWithoutHavingIt => 'Anunciar Juego sin tenerlo:';

  @override
  String get menuAIfNoneOfTheOther3PlayersHas =>
      'a) Si ninguno de los otros 3 jugadores tiene Juego, los rivales suman el Tira de Punto y el punto de Pontua.';

  @override
  String get menuBIfThePartnerHasGameAndTheOpponents =>
      'b) Si el compañero tiene Juego y los rivales no, no se tiene en cuenta el error.';

  @override
  String get menuCIfThePartnerHasNoGameButAn =>
      'c) Si el compañero no tiene Juego y el rival sí, se anulan las apuestas de Juego y el rival suma los puntos de su Juego.';

  @override
  String get menuDIfThePartnerAndAnOpponentBothHave =>
      'd) Si el compañero y un rival tienen Juego, se anulan las apuestas de Juego; el rival suma el TIRA de Juego y sus puntos de Juego.';

  @override
  String get menuFailingToAnnounceGameWhenHoldingIt =>
      'No anunciar Juego teniéndolo:';

  @override
  String get menuAIfNoneOfTheOther3PlayersHas465 =>
      'a) Si ninguno de los otros 3 jugadores tiene Juego, se anulan las apuestas de Punto y el rival suma el ttantto de Tira y el punto de Pontua. El Juego no anunciado no cuenta.';

  @override
  String get menuBIfThePartnerHasGameAndTheOpponents466 =>
      'b) Si el compañero tiene Juego y los rivales no, solo cuenta el Juego del compañero.';

  @override
  String get menuCIfThePartnerHasNoGameAndAn =>
      'c) Si el compañero no tiene Juego y el rival sí, este suma el TIRA de Juego y sus puntos de Juego. Un jugador sin parejas ni Juego no puede apostar ni subir en lugar de su compañero que sí los tenga.';

  @override
  String get menuScoringAndRaises => 'Recuento y subidas';

  @override
  String get menuDuringPlayPointsConcededThroughTIRAAreScoredAs =>
      'Durante el juego, los puntos cedidos con TIRA se anotan a medida que se producen. En caso de empate total, siempre gana ESKU. Al final de cada mano, los cuatro jugadores deben mostrar todas sus cartas sobre la mesa.';

  @override
  String get menuScoreHighThenLowPairsGameOrPointAs =>
      'Se cuenta Grande, después Chica, Parejas, Juego o Punto del siguiente modo:';

  @override
  String get menuHighIfEveryoneSaidPASOTheBestHighScores =>
      'Grande: si solo hubo PASO, la mejor Grande suma 1 punto (Haundi Pasa). Si se rechazó Grande tras Embido, no se suma nada. Si hubo Iduki, solo se cuentan los puntos apostados.';

  @override
  String get menuLowTheSameAsHigh => 'Chica: igual que Grande.';

  @override
  String get menuPairsAfterPasoTheTeamWithTheBestPair =>
      'Parejas: tras Paso, el equipo con la mejor pareja cuenta sus parejas: 1 punto por pareja, 2 por mediak o 3 por duples. Si hubo Iduki, se suman además los puntos apostados.';

  @override
  String get menuGameTheSameAsPairsCounting2PointsFor =>
      'Juego: igual que Parejas, contando 2 puntos por Juego o 3 por 31, por cada Juego del equipo ganador.';

  @override
  String get menuPointPontuaAfterPasoTheBestPontuaScores1 =>
      'Punto (Pontua): tras Paso, el mejor Pontua suma 1 punto. Tras Tira, el equipo ganador del Tira suma 1 punto de Pontua. Tras Iduki, se cuentan los puntos apostados más 1 de Pontua.';

  @override
  String get menuRaiseExamples => 'Ejemplos de subidas:';

  @override
  String get menuEmbido2PointsTira1Point =>
      'Embido (2 puntos) - Tira = 1 punto';

  @override
  String get menuEmbido2PointsIduki2Points =>
      'Embido (2 puntos) - Iduki = 2 puntos';

  @override
  String get menuHordagoTira1Point => 'Hordago - Tira = 1 punto';

  @override
  String get menuHiruEmbido3PointsTira1Point =>
      'Hiru Embido (3 puntos) - Tira = 1 punto';

  @override
  String get menuHiruEmbido3PointsIduki3Points =>
      'Hiru Embido (3 puntos) – Iduki = 3 puntos';

  @override
  String get menuEmbido2PointsLauGehiago4Tira2Points =>
      'Embido (2 puntos) Lau gehiago (+ 4) - Tira = 2 puntos';

  @override
  String get menuEmbido2PointsBigehiago2HordagoTira4Points =>
      'Embido (2 puntos) – Bigehiago( +2 ) – Hordago - Tira = 4 puntos';

  @override
  String get menuHiruEmbido3PointsLauGehiago4Iduki7 =>
      'Hiru Embido (3 puntos) Lau gehiago (+ 4) Iduki = 7 puntos';

  @override
  String get menuEmbido2PointsBortzGehiago5Bigehiago2Tira =>
      'Embido (2 puntos) Bortz gehiago (+ 5) Bigehiago (+2) Tira = 7 puntos';

  @override
  String get menuNoTtanttoMayBeScoredOnceTheCardsHave =>
      'No se puede anotar ningún ttantto si se han recogido las cartas.';

  @override
  String get menuRefereeing => 'Arbitraje';

  @override
  String get menuTheRefereeIntervenesOnlyAtAPlayersRequestOr =>
      'El juez solo interviene a petición de un jugador o al observar una irregularidad.';

  @override
  String get menuAnyDisputeOverTheseRegulationsOrAnySituationNot =>
      'Cualquier disputa sobre la interpretación de este reglamento o situación no contemplada será resuelta por el juez.';

  @override
  String get menuTheRefereeMayImposePenaltiesUpToAndIncluding =>
      'El juez puede imponer sanciones hasta la exclusión.';

  @override
  String menuArticleArg0(String arg0) {
    return 'Artículo $arg0';
  }

  @override
  String get invitationPrivateTitle => 'Crear una sala privada';

  @override
  String get invitationPrivateLabel => 'Sala privada';

  @override
  String get invitationCasualTitle => 'En línea (Clásico) en dúo';

  @override
  String get invitationCasualLabel => 'Clásico en dúo';

  @override
  String get invitationRankedTitle => 'En línea (Clasificatorio) en dúo';

  @override
  String get invitationRankedLabel => 'Clasificatorio en dúo';

  @override
  String get classicCardBack => 'Dorso clásico';

  @override
  String gamesPlayedCount(String count) {
    return '$count partidas';
  }

  @override
  String avatarOption(String name, String number) {
    return '$name: opción $number';
  }

  @override
  String get nicknameLengthError =>
      'El apodo debe tener entre 1 y 24 caracteres.';

  @override
  String get deleteAccountError =>
      'No se ha podido eliminar la cuenta. Inténtalo de nuevo.';

  @override
  String get connectionUnavailable =>
      'Conexión no disponible. Inténtalo de nuevo.';

  @override
  String seasonName(String name) {
    return 'Temporada $name';
  }

  @override
  String questPlay(String count) {
    return 'Termina $count partidas';
  }

  @override
  String questWin(String count) {
    return 'Gana $count partidas';
  }

  @override
  String questRanked(String count) {
    return 'Gana $count partidas clasificatorias';
  }

  @override
  String get questGeneric => 'Desafío semanal';

  @override
  String get catalogUnknown => 'Cosmético';

  @override
  String get catalogUnknownDescription => 'Personaliza tu aspecto en la mesa.';

  @override
  String get catalogSun => 'Sol';

  @override
  String get catalogMountain => 'Montaña';

  @override
  String get catalogBlue => 'Azul';

  @override
  String get catalogGreen => 'Verde';

  @override
  String get catalogOcean => 'Océano';

  @override
  String get catalogRuby => 'Rubí';

  @override
  String get catalogDiamondBorder => 'Borde de diamante';

  @override
  String get catalogLeagueTxapela => 'Txapela de liga';

  @override
  String get catalogLeagueCrown => 'Corona de liga';

  @override
  String get catalogEmeraldBorder => 'Marco esmeralda';

  @override
  String get catalogAmethystBorder => 'Marco amatista';

  @override
  String get catalogEmeraldBack => 'Dorso esmeralda';

  @override
  String get catalogVioletBack => 'Dorso violeta';

  @override
  String get catalogEskerrik => 'Eskerrik asko !';

  @override
  String get catalogRematch => '¿La revancha?';

  @override
  String get catalogMullet => 'Corte mullet';

  @override
  String get catalogStriped => 'Camiseta de rayas azules y blancas';

  @override
  String get catalogGoldGlasses => 'Gafas de sol doradas';

  @override
  String get catalogCap => 'Gorra azul';

  @override
  String get catalogBeanie => 'Gorro cobrizo';

  @override
  String get catalogRoundGlasses => 'Gafas redondas';

  @override
  String get catalogOceanBack => 'Dorso océano';

  @override
  String get catalogCoralBack => 'Dorso coral';

  @override
  String get catalogEmeraldBorderDescription =>
      'Un anillo esmeralda alrededor de tu avatar.';

  @override
  String get catalogAmethystBorderDescription =>
      'Un borde violeta para lucir en la mesa.';

  @override
  String get catalogEmeraldBackDescription =>
      'Un dorso de cartas verde esmeralda.';

  @override
  String get catalogVioletBackDescription => 'Un dorso de cartas violeta.';

  @override
  String get catalogEskerrikDescription =>
      'Da las gracias a los demás con un toque.';

  @override
  String get catalogRematchDescription => 'Propón otra partida a la mesa.';

  @override
  String get catalogMulletDescription =>
      'Corto por delante, largo por detrás: un corte con carácter.';

  @override
  String get catalogStripedDescription =>
      'Rayas azules y blancas para tu conjunto.';

  @override
  String get catalogGoldGlassesDescription =>
      'Cristales oscuros con montura dorada.';

  @override
  String get catalogCapDescription => 'Una gorra azul sobre el cabello.';

  @override
  String get catalogBeanieDescription => 'Un gorro cobrizo con pompón.';

  @override
  String get catalogFineGlassesDescription =>
      'Una montura dorada fina que deja ver los ojos.';

  @override
  String get catalogRoundGlassesDescription =>
      'Cristales transparentes con montura redonda.';

  @override
  String get catalogOceanBackDescription =>
      'Un diseño clásico en azul intenso.';

  @override
  String get catalogCoralBackDescription => 'Un diseño clásico en tono coral.';

  @override
  String get catalogBaldDescription => 'Cabeza despejada, sin capa de cabello.';

  @override
  String get catalogMohawkDescription =>
      'Una cresta centrada, visible de frente.';

  @override
  String get legalTermsBody =>
      'ISAMUS — CONDICIONES DE USO\nBorrador del 26 de octubre de 2026 — completar antes de su publicación\n\nEditor: [NOMBRE / RAZÓN SOCIAL], [DIRECCIÓN], [PAÍS]. Contacto: [CORREO DE SOPORTE].\n\n1. El servicio\nIsaMus permite jugar al Mus, variante de 4 Reyes / 4 Ases, con jugadores o bots. Los puntos y la clasificación no tienen valor monetario. El servicio no ofrece apuestas de dinero ni premios canjeables por dinero.\n\n2. Cuenta\nUna cuenta de invitado permite empezar a jugar. Vincular un correo verificado o una identidad Apple/Google permite recuperar la cuenta. Sin esta vinculación, perder la sesión o el dispositivo puede hacer irrecuperable el progreso. Protege tus credenciales y elige un apodo respetuoso que no revele datos personales.\n\n3. Juego y relaciones entre jugadores\nSe prohíben las trampas, la explotación de vulnerabilidades, la suplantación de identidad, el acoso y las solicitudes abusivas. Se pueden rechazar solicitudes de amistad e invitaciones. Los bots se identifican como tales. Las desconexiones activan acciones automáticas para que la partida continúe.\n\n4. Objetos digitales\nLos cosméticos son elementos visuales sin ventajas sobre las cartas ni las puntuaciones. Los artículos, sus características y precios se muestran antes de confirmar la compra en la tienda. Apple o Google procesan el pago. IsaMus no recibe el número de tu tarjeta bancaria. Las compras deben vincularse a una cuenta protegida. Restaurar compras permite solicitar su sincronización. Un objeto digital no puede convertirse en dinero ni transferirse entre jugadores en la aplicación.\nLas condiciones de reembolso y los derechos legales aplicables son los de tu país y tienda. Ninguna cláusula limita las garantías obligatorias del consumidor. La información y los consentimientos necesarios para la entrega inmediata de contenido digital deben facilitarse en el proceso de compra de la tienda.\n\n5. Publicidad\nPueden aparecer anuncios en el inicio. Las opciones de privacidad publicitaria están disponibles en el perfil. Rechazar un uso opcional de tus datos no debe impedir jugar.\n\n6. Disponibilidad y evolución\nEl funcionamiento depende de la red y de servicios externos. Puede haber interrupciones o mantenimiento. El editor informa de cambios importantes que afecten al servicio o a los objetos adquiridos y respeta los derechos imperativos aplicables.\n\n7. Eliminación y asistencia\nPuedes solicitar la eliminación de la cuenta en Cuenta y seguridad. Se eliminan el perfil y los datos asociados según la política de privacidad. No se cancela automáticamente una transacción de la tienda. Para obtener ayuda, escribe a [CORREO DE SOPORTE].\n\n8. Legislación y litigios\nSe aplican las normas imperativas de protección al consumidor de tu lugar de residencia. Las menciones sobre legislación aplicable, mediación y autoridad competente deben adaptarse al país y al estatus real del editor antes de la publicación.\n';

  @override
  String get legalPrivacyBody =>
      'ISAMUS — POLÍTICA DE PRIVACIDAD\nBorrador del 26 de octubre de 2026 — completar antes de su publicación\n\nResponsable del tratamiento: [NOMBRE / RAZÓN SOCIAL], [DIRECCIÓN], [PAÍS]. Contacto para ejercer tus derechos: [CORREO DE PRIVACIDAD].\n\nDatos y usos\nLa cuenta tiene un identificador técnico, un apodo, una puntuación Elo y estadísticas. Solo se utiliza un correo o una identidad Apple/Google si decides proteger la cuenta. Las sesiones sirven para autenticarte. El servicio de autenticación gestiona las contraseñas, que no son accesibles desde la aplicación.\nLas partidas contienen los participantes, acciones y estados necesarios para jugar. El historial conserva los resultados y cambios de Elo. Las solicitudes de amistad e invitaciones permiten las funciones sociales. La presencia indica a los amigos aceptados si estás en línea o en una partida, sin revelar el código de la sala.\nEl apodo, el avatar y el Elo son visibles para otros jugadores autenticados. En la arquitectura actual, los participantes pueden acceder a las cartas y estados de la partida. No incluyas datos sensibles en tu apodo.\n\nCompras y publicidad\nLas tiendas Apple/Google y RevenueCat gestionan las compras y su validación. El identificador de cuenta y los derechos de acceso a cosméticos permiten restaurarlas. No recopilamos tus datos bancarios.\nCuando hay publicidad, Google AdMob y su mecanismo de consentimiento pueden tratar datos técnicos del dispositivo, la red, la difusión publicitaria y tus opciones de privacidad. La integración solicita anuncios no personalizados; esto no excluye todo tratamiento de datos por el SDK. Los formularios aplicables y el enlace Opciones de privacidad publicitaria permiten gestionar usos opcionales. La aplicación no exige acceso a tus contactos, micrófono ni ubicación precisa.\n\nBases del tratamiento\nEl funcionamiento de la cuenta, el juego y las compras se basa en prestar el servicio solicitado. La prevención de abusos y la seguridad se basan en el interés legítimo del editor, sin perjuicio de tus derechos. Los tratamientos opcionales sujetos a consentimiento solo deben activarse tras la elección requerida. Las obligaciones legales aplicables pueden exigir conservar determinados registros de transacciones.\n\nProveedores y transferencias\nSupabase proporciona la base de datos, la autenticación, las funciones del servidor y el tiempo real. Apple, Google y RevenueCat intervienen en la autenticación, las compras o la publicidad según las funciones utilizadas. Antes de publicar, el editor debe especificar las regiones elegidas, destinatarios, posibles transferencias internacionales y garantías contractuales aplicables; estos parámetros no pueden deducirse del código.\n\nConservación\nEl perfil, el inventario y las relaciones sociales se conservan mientras exista la cuenta. La presencia está vinculada a la conexión. El editor debe documentar los plazos de conservación del historial y los registros técnicos: [PLAZO DEL HISTORIAL], [PLAZO DE REGISTROS], [PLAZO DE COPIAS]. Las invitaciones tienen una validez funcional de diez minutos; su caducidad no implica borrado inmediato de la base de datos. Los proveedores pueden tener obligaciones propias de conservación.\n\nTus derechos y eliminación\nPuedes solicitar acceso, rectificación, supresión y, cuando proceda legalmente, portabilidad, limitación u oposición en [CORREO DE PRIVACIDAD]. Retirar un consentimiento no afecta a tratamientos anteriores lícitos. El perfil permite eliminar la cuenta. Las solicitudes sobre pagos o identificadores publicitarios también pueden corresponder a la tienda o proveedor. Puedes acudir a la autoridad de control competente; en Francia, la CNIL (www.cnil.fr).\n\nMenores\nAntes de publicar, el editor debe definir la edad mínima, el público objetivo y el mecanismo de consentimiento parental que pueda ser necesario. La configuración publicitaria y la declaración de edad de las tiendas deben ajustarse a esta elección.\n\nActualizaciones\nLa fecha y los cambios importantes de esta política se comunicarán en la aplicación. Este borrador debe completarse con la información real del editor y los proveedores antes de publicarse.\n';

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
