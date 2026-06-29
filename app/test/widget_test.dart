// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/screens/app_onboarding/about.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/app_onboarding/welcome.dart';

Widget setup(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => AppState(),
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      home: child,
      routes: {
        Routes.about: (_) => const AboutScreen(),
        Routes.terms: (_) => const TermsScreen(),
        Routes.welcome: (_) => const WelcomeScreen(),
      },
    ),
  );
}

void main() {
  testWidgets('Counter increments smoke test', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
  });

  test('opens welcome screen when tour is completed without preview', () {
    expect(
      initialRouteForMissingSubjectRoute(isPreview: false, onBoarded: true),
      Routes.welcome,
    );
  });

  test('opens onboarding when tour is not completed', () {
    expect(
      initialRouteForMissingSubjectRoute(isPreview: false, onBoarded: false),
      Routes.onboarding,
    );
  });

  test('keeps designer preview on study terms', () {
    expect(
      initialRouteForMissingSubjectRoute(isPreview: true, onBoarded: true),
      Routes.terms,
    );
  });

  testWidgets('terms back is disabled without previous screen', (tester) async {
    await tester.pumpWidget(setup(const TermsScreen()));
    await tester.pump();

    final back = tester.widget<TextButton>(
      find.byKey(const ValueKey('terms_back')),
    );

    expect(back.onPressed, isNull);
  });

  testWidgets('terms back pops to welcome when available', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('welcome_get_started')));
    await tester.pumpAndSettle();
    expect(find.byType(TermsScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('terms_back')));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('about get started replaces about before terms', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('welcome_about')));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(0, -10000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.byType(TermsScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('terms_back')));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(AboutScreen), findsNothing);
  });
}
