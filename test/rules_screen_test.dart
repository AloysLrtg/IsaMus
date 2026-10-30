import 'package:flutter/material.dart';
import 'package:isamus/l10n/app_localizations.dart';
import 'package:isamus/features/rules/rules_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/features/rules/rules_screen.dart';

void main() {
  testWidgets('Le règlement contient les 21 articles et les relances du PDF', (
    tester,
  ) async {
    final rules = officialMusRules(lookupAppLocalizations(const Locale('fr')));
    final articles = (rules['sections'] as List)
        .expand((section) => section['articles'] as List)
        .toList();
    expect(articles.map((a) => a['number']), List.generate(21, (i) => i + 1));
    expect(articles.every((a) => (a['paragraphs'] as List).isNotEmpty), isTrue);
    expect(
      articles[16]['paragraphs'],
      contains('Embido (2 points) - Iduki = 2 points'),
    );
  });

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Règles lisibles sans débordement à $size, texte ×$scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.dark(useMaterial3: true),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const RulesScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(testL10n.menuOfficialRules), findsOneWidget);
        expect(tester.takeException(), isNull);
        final scrollable = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byKey(const ValueKey('rules-scroll')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        // Check every viewport, including long articles and landscape layout.
        while (scrollable.position.pixels <
            scrollable.position.maxScrollExtent) {
          scrollable.position.jumpTo(
            (scrollable.position.pixels + size.height / 2).clamp(
              0,
              scrollable.position.maxScrollExtent,
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
        await Scrollable.ensureVisible(
          tester.element(find.text('Article 21')),
          alignment: .5,
        );
        await tester.pumpAndSettle();
        expect(find.text('Article 21').hitTestable(), findsOneWidget);
      });
    }
  }
}

final testL10n = lookupAppLocalizations(const Locale('fr'));
