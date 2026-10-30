import 'package:isamus/l10n/app_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/network/auth_repository.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/core/network/social_repository.dart';
import 'package:isamus/features/profile/player_inspection_dialog.dart';
import 'package:isamus/main.dart';

const me = '00000000-0000-4000-8000-000000000001';
const other = '00000000-0000-4000-8000-000000000002';

class CardAuth implements AuthRepository {
  @override
  String? get currentUserId => me;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class CardSocial extends SocialRepository {
  List<Map<String, dynamic>> rows = [];
  final changes = StreamController<List<Map<String, dynamic>>>.broadcast();
  int sent = 0;
  bool fail = false;
  Completer<void>? gate;
  @override
  Stream<List<Map<String, dynamic>>> friendships() async* {
    yield rows;
    yield* changes.stream;
  }

  @override
  Future<void> request(String id) async {
    sent++;
    await gate?.future;
    if (fail) throw Exception('offline');
    rows = [
      {'id': 'relation', 'user_id_1': me, 'user_id_2': id, 'status': 'pending'},
    ];
    changes.add(rows);
  }
}

void main() {
  late CardSocial social;
  Future<void> mount(
    WidgetTester tester, {
    String viewed = other,
    String? status,
    bool incoming = false,
  }) async {
    social = CardSocial();
    if (status != null) {
      social.rows = [
        {
          'id': 'relation',
          'sender_id': incoming ? other : me,
          'receiver_id': incoming ? me : other,
          'status': status,
        },
      ];
    }
    addTearDown(() => social.changes.close());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(CardAuth()),
          socialRepositoryProvider.overrideWithValue(social),
          publicPlayerProfileProvider(viewed).overrideWith(
            (ref) async => {
              'username': 'Amaia avec un très long pseudo',
              'elo': 1350,
              'peak_elo': 1600,
              'games_played': 10,
              'games_won': 6,
            },
          ),
        ],
        child: MyApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => PlayerInspectionDialog(userId: viewed),
                ),
                child: const Text('Voir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Voir'));
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets(
      'Carte joueur $size : statistiques, action et croix fixe sans débordement',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await mount(tester);
        expect(find.text('1350'), findsOneWidget);
        expect(find.text('1600'), findsOneWidget);
        expect(find.text('60 %'), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
        final add = find.byKey(const ValueKey('add-player-friend'));
        await tester.ensureVisible(add);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(add).onPressed, isNotNull);
        expect(find.text(testL10n.menuClose), findsNothing);
        expect(
          find.byKey(const ValueKey('close-player-card')).hitTestable(),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('close-player-card')));
        await tester.pumpAndSettle();
        expect(find.byType(PlayerInspectionDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final scenario in [
    ('accepted', false, 'Déjà amis'),
    ('pending', false, 'Demande envoyée'),
    ('pending', true, 'Demande reçue'),
  ]) {
    testWidgets('Relation ${scenario.$3} : pas de nouvelle demande', (
      tester,
    ) async {
      await mount(tester, status: scenario.$1, incoming: scenario.$2);
      expect(find.text(scenario.$3), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('add-player-friend')),
            )
            .onPressed,
        isNull,
      );
      expect(social.sent, 0);
    });
  }
  testWidgets('Envoi unique et état mis à jour en direct', (tester) async {
    await mount(tester);
    social.gate = Completer<void>();
    final add = find.byKey(const ValueKey('add-player-friend'));
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pump();
    await tester.tap(add);
    expect(social.sent, 1);
    social.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text(testL10n.menuRequestSent), findsOneWidget);
    social.rows = [
      {
        'id': 'relation',
        'user_id_1': me,
        'user_id_2': other,
        'status': 'accepted',
      },
    ];
    social.changes.add(social.rows);
    await tester.pump();
    await tester.pump();
    expect(find.text(testL10n.menuAlreadyFriends), findsOneWidget);
  });
  testWidgets('Erreur d’envoi : message utile et nouvelle tentative possible', (
    tester,
  ) async {
    await mount(tester);
    social.fail = true;
    final add = find.byKey(const ValueKey('add-player-friend'));
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(
      find.text(testL10n.menuUnableToSendTheRequestTryAgain),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(add).onPressed, isNotNull);
  });
  testWidgets('Son propre profil ne permet pas de se demander en ami', (
    tester,
  ) async {
    await mount(tester, viewed: me);
    expect(find.text(testL10n.menuYourProfile), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('add-player-friend')))
          .onPressed,
      isNull,
    );
  });
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
