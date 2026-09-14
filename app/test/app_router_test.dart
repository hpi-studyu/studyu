import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/study_unavailable_screen.dart';
import 'package:studyu_app/screens/app_onboarding/welcome.dart';
import 'package:studyu_app/screens/study/onboarding/journey_overview.dart';
import 'package:studyu_app/screens/study/onboarding/study_overview.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

void main() {
  test('internal browser routes initialize before reading empty app state', () {
    final appState = AppState();
    final router = createAppRouter(
      queryParameters: const {},
      initialLocation: initialRouteFromPlatformRoute(
        '/${RouteNames.studyInformation}',
      ),
    );
    addTearDown(router.dispose);

    expect(appState.activeSubject, isNull);
    expect(
      router.routeInformationProvider.value.uri.path,
      '/${RouteNames.loading}',
    );
  });

  test('browser entry routes bypass initial loading', () {
    for (final route in [
      '/${RouteNames.preview}?studyid=study-1',
      '/${RouteNames.invite}/invite-1',
      '/${RouteNames.study}/study-1',
      '$appScheme://${RouteNames.invite}/invite-1',
      '$appScheme://${RouteNames.study}/study-1',
    ]) {
      expect(initialRouteFromPlatformRoute(route), route);
    }
  });

  test('routes with missing app state return to loading', () {
    final appState = AppState();
    const loading = '/${RouteNames.loading}';

    for (final route in [
      RouteNames.studyOverview,
      RouteNames.interventionSelection,
      RouteNames.eligibilityCheck,
      RouteNames.dashboard,
      RouteNames.journey,
      RouteNames.consent,
      RouteNames.kickoff,
      RouteNames.appSettings,
      RouteNames.studyInformation,
      RouteNames.reportHistory,
    ]) {
      expect(
        routePrerequisiteRedirect('/$route', null, appState),
        loading,
        reason: route,
      );
    }
  });

  test('routes open when their required app state exists', () {
    final study = Study('study', 'user');
    final appState = AppState()..selectedStudy = study;

    for (final route in [
      RouteNames.studyOverview,
      RouteNames.interventionSelection,
      RouteNames.eligibilityCheck,
    ]) {
      expect(routePrerequisiteRedirect('/$route', null, appState), isNull);
    }

    appState.activeSubject = StudySubject.fromStudy(study, 'user', [], null);
    for (final route in [
      RouteNames.journey,
      RouteNames.consent,
      RouteNames.kickoff,
    ]) {
      expect(routePrerequisiteRedirect('/$route', null, appState), isNull);
    }

    appState.activeSubject!.startedAt = DateTime(2026, 7, 10);
    for (final route in [
      RouteNames.dashboard,
      RouteNames.appSettings,
      RouteNames.studyInformation,
      RouteNames.reportHistory,
    ]) {
      expect(routePrerequisiteRedirect('/$route', null, appState), isNull);
    }
  });

  test('eligibility route accepts a study argument', () {
    expect(
      routePrerequisiteRedirect(
        '/${RouteNames.eligibilityCheck}',
        Study('study', 'user'),
        AppState(),
      ),
      isNull,
    );
  });

  test('welcome returns an active study to the dashboard', () {
    final study = Study('study', 'user')
      ..interventions = [
        Intervention('first', 'First'),
        Intervention('second', 'Second'),
      ];
    final subject = StudySubject.fromStudy(study, 'user', [], null)
      ..startedAt = DateTime(2026, 7, 10);
    final appState = AppState()..activeSubject = subject;

    expect(
      routePrerequisiteRedirect('/${RouteNames.welcome}', null, appState),
      '/${RouteNames.dashboard}',
    );
  });

  test('partial onboarding subject does not open the dashboard', () {
    final study = Study('study', 'user')
      ..interventions = [
        Intervention('first', 'First'),
        Intervention('second', 'Second'),
      ];
    final appState = AppState()
      ..activeSubject = StudySubject.fromStudy(study, 'user', [], null);

    expect(
      routePrerequisiteRedirect('/${RouteNames.welcome}', null, appState),
      isNull,
    );
    expect(
      routePrerequisiteRedirect('/${RouteNames.dashboard}', null, appState),
      '/${RouteNames.loading}',
    );
  });

  testWidgets('partial onboarding subject stays on welcome', (tester) async {
    final study = Study('study', 'user')
      ..interventions = [
        Intervention('first', 'First'),
        Intervention('second', 'Second'),
      ];
    final appState = AppState()
      ..activeSubject = StudySubject.fromStudy(study, 'user', [
        'first',
        'second',
      ], null);
    final router = createAppRouter(
      queryParameters: const {},
      initialLocation: '/${RouteNames.welcome}',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp.router(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid study routes stay on unavailable screen', (
    tester,
  ) async {
    final supabase = SupabaseClient(
      'http://localhost',
      'anon',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    setEnv(
      'http://localhost',
      'anon',
      supabaseClient: supabase,
      envAppDeepLinkScheme: 'studyu-app://',
    );
    final study = Study('study', 'user')
      ..interventions = [Intervention('intervention', 'Intervention')];
    final appState = AppState()..selectedStudy = study;
    final router = createAppRouter(
      queryParameters: const {},
      initialLocation: '/${RouteNames.studyUnavailable}',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp.router(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/${RouteNames.studyUnavailable}',
    );

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);

    router.push('/${RouteNames.studyOverview}');
    await tester.pumpAndSettle();
    expect(find.byType(StudyUnavailableScreen), findsOneWidget);
    expect(find.byType(StudyOverviewScreen), findsNothing);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    appState
      ..selectedStudy = null
      ..activeSubject = StudySubject.fromStudy(study, 'user', [], null);

    router.push('/${RouteNames.journey}');
    await tester.pumpAndSettle();
    expect(find.byType(StudyUnavailableScreen), findsOneWidget);
    expect(find.byType(JourneyOverviewScreen), findsNothing);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    router.push('/${RouteNames.appSettings}');
    await tester.pumpAndSettle();
    expect(find.byType(StudyUnavailableScreen), findsOneWidget);
  });
}
