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
import 'package:studyu_app/screens/app_onboarding/restore_account_screen.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/app_onboarding/welcome.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/onboarding/study_selection.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

Widget setup(Widget child, {AppState? appState}) {
  return ChangeNotifierProvider(
    create: (_) => appState ?? AppState(),
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
            path: '/${RouteNames.studySelection}',
            builder: (_, _) => const Text(
              'Study selection',
              key: ValueKey('study_selection_test_screen'),
            ),
          ),
          GoRoute(
            path: '/${RouteNames.restoreAccount}',
            name: RouteNames.restoreAccount,
            builder: (_, _) => const RestoreAccountScreen(),
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
  setUpAll(() {
    setEnv(
      'https://example.supabase.co',
      'test-anon-key',
      supabaseClient: SupabaseClient('https://example.supabase.co', 'test'),
    );
  });
  testWidgets('welcome prioritizes study discovery', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(FilledButton, 'Browse public studies'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Use invite code'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Restore StudyU account'),
      findsOneWidget,
    );
  });

  testWidgets('restore account opens restore account route', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore StudyU account'));
    await tester.pumpAndSettle();

    expect(find.byType(RestoreAccountScreen), findsOneWidget);
  });

  testWidgets('browse action opens study selection directly', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('welcome_get_started')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('study_selection_test_screen')),
      findsOneWidget,
    );
    expect(find.byType(TermsScreen), findsNothing);
  });

  testWidgets('invite action opens invite code dialog over welcome', (
    tester,
  ) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('welcome_use_invite_code')));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(InviteCodeDialog), findsOneWidget);
    expect(find.byType(TermsScreen), findsNothing);
  });

  test('restore account route is registered by name', () {
    final router = createAppRouter(queryParameters: const {});

    expect(router.namedLocation(RouteNames.restoreAccount), '/restoreAccount');
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

  test('dashboard showcase waits until next-day study has started', () {
    final now = DateTime(2026, 7, 10, 12);

    expect(
      isDashboardShowcaseEligible(
        startedAt: DateTime(2026, 7, 11),
        now: now,
        isPreview: false,
        checkStarted: false,
      ),
      isFalse,
    );
    expect(
      isDashboardShowcaseEligible(
        startedAt: DateTime(2026, 7, 10),
        now: now,
        isPreview: false,
        checkStarted: false,
      ),
      isTrue,
    );
    expect(shouldMarkDashboardShowcaseCompleted(wasStarted: false), isFalse);
    expect(shouldMarkDashboardShowcaseCompleted(wasStarted: true), isTrue);
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

    await tester.ensureVisible(button);
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

  testWidgets('terms back preserves pending invite state', (tester) async {
    final study = Study('study-1', 'owner-1')..title = 'Study';
    final appState = AppState()
      ..setPendingDeepLink(study: study, inviteCode: 'invite-1');
    const overview = Text('Study overview');
    await tester.pumpWidget(setup(overview, appState: appState));
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byWidget(overview)),
    ).push('/${RouteNames.terms}');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('terms_back')));
    await tester.pumpAndSettle();

    expect(appState.hasPendingDeepLink, isTrue);
    expect(appState.selectedStudy, same(study));
  });

  testWidgets('about get started opens study selection', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    final about = find.byKey(const ValueKey('welcome_about'));
    await tester.ensureVisible(about);
    await tester.tap(about);
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(0, -10000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('study_selection_test_screen')),
      findsOneWidget,
    );
    expect(find.byType(TermsScreen), findsNothing);
    expect(find.byType(AboutScreen), findsNothing);
  });
}
