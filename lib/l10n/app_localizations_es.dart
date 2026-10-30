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
  String get gameMenuTitle => 'Menú de la partida';

  @override
  String get gameQuitTitle => 'Salir de la partida';

  @override
  String get gameQuitConfirm => '¿Seguro que quieres salir de la partida?';

  @override
  String get gameQuitAction => 'Salir';

  @override
  String get gameQuitFailed =>
      'No se ha podido cerrar la sala. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get leaderboardYouSuffix => ', tú';
}
