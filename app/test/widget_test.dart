// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/about.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/app_onboarding/welcome.dart';

Widget setup(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => AppState(),
    child: MaterialApp.router(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => child),
          GoRoute(
            path: '/${RouteNames.about}',
            builder: (_, _) => const AboutScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.terms}',
            builder: (_, _) => const TermsScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.welcome}',
            builder: (_, _) => const WelcomeScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.onboarding}',
            builder: (_, _) => const Text(
              'Onboarding',
              key: ValueKey('onboarding_test_screen'),
            ),
          ),
        ],
      ),
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
      initialRouteForMissingSubjectRoute(
        isPreview: false,
        isDebugMode: false,
        onBoarded: true,
      ),
      '/${RouteNames.welcome}',
    );
  });

  test('opens onboarding when tour is not completed', () {
    expect(
      initialRouteForMissingSubjectRoute(
        isPreview: false,
        isDebugMode: false,
        onBoarded: false,
      ),
      '/${RouteNames.onboarding}',
    );
  });

  test('keeps designer preview on study terms', () {
    expect(
      initialRouteForMissingSubjectRoute(
        isPreview: true,
        isDebugMode: false,
        onBoarded: false,
      ),
      '/${RouteNames.terms}',
    );
  });

  test('skips onboarding in debug mode', () {
    expect(
      initialRouteForMissingSubjectRoute(
        isPreview: false,
        isDebugMode: true,
        onBoarded: false,
      ),
      '/${RouteNames.welcome}',
    );
  });

  testWidgets('debug button opens onboarding', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    final button = find.byKey(const ValueKey('welcome_debug_onboarding'));
    expect(find.text('Show onboarding'), findsOneWidget);

    await tester.tap(button);
    await tester.pumpAndSettle();

    final onboarding = find.byKey(const ValueKey('onboarding_test_screen'));
    expect(onboarding, findsOneWidget);
    expect(GoRouter.of(tester.element(onboarding)).canPop(), isFalse);
  });

  testWidgets('terms back falls back to welcome without previous screen', (
    tester,
  ) async {
    await tester.pumpWidget(setup(const TermsScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('terms_back')));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
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
