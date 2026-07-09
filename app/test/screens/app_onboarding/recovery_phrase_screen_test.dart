import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/app_onboarding/recovery_phrase_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp.router(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    routerConfig: GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => child),
        GoRoute(
          path: '/${RouteNames.terms}',
          name: RouteNames.terms,
          builder: (_, _) => const SizedBox(),
        ),
        GoRoute(
          path: '/${RouteNames.studySelection}',
          name: RouteNames.studySelection,
          builder: (_, _) => const SizedBox(),
        ),
      ],
    ),
  );
}

void main() {
  testWidgets('hides recovery words until reveal tap', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const RecoveryPhraseScreen(
          initialPhrase: [
            'alpha',
            'bravo',
            'charlie',
            'delta',
            'echo',
            'foxtrot',
            'golf',
            'hotel',
            'india',
            'juliet',
            'kilo',
            'lima',
            'mike',
          ],
        ),
      ),
    );

    expect(find.text('Save Recovery Phrase'), findsOneWidget);
    expect(find.text('Show Recovery Phrase'), findsOneWidget);
    expect(find.text('Your recovery phrase'), findsNothing);
    expect(
      find.text('I have written down all 13 words and stored them safely.'),
      findsNothing,
    );
    expect(find.byType(ListView), findsNothing);

    await tester.tap(find.text('Show Recovery Phrase'));
    await tester.pumpAndSettle();

    expect(find.text('Your recovery phrase'), findsOneWidget);
    expect(
      find.text('Write the words down in this exact order.'),
      findsOneWidget,
    );
    expect(
      find.text('I have written down all 13 words and stored them safely.'),
      findsOneWidget,
    );
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Show Recovery Phrase'), findsNothing);
    expect(find.text('Share'), findsNothing);
  });
}
