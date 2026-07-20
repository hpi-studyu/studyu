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
import 'package:studyu_core/env.dart';
import 'package:supabase/supabase.dart';

void main() {
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
  });
}
