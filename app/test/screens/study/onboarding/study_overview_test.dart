import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/study_overview.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('regular study overview returns to study selection', () {
    final state = AppState()..selectedStudy = Study('study-1', 'owner-1');

    expect(shouldReturnToStudySelection(state), isTrue);
  });

  test('invited study overview returns to terms', () {
    final state = AppState()
      ..setPendingDeepLink(
        study: Study('study-1', 'owner-1'),
        inviteCode: 'invite-1',
      );

    expect(shouldReturnToStudySelection(state), isFalse);
  });

  test('accepted app terms skip the terms gate', () {
    final state = AppState()..hasAcceptedTerms = true;

    expect(shouldSkipTermsGate(state), isTrue);
  });

  testWidgets('first continue opens terms before study onboarding', (
    tester,
  ) async {
    final study = Study('study-1', 'owner-1')..title = 'Study';
    final state = AppState()..selectedStudy = study;
    final router = GoRouter(
      initialLocation: '/${RouteNames.studyOverview}',
      routes: [
        GoRoute(
          path: '/${RouteNames.studyOverview}',
          builder: (_, _) => const StudyOverviewScreen(),
        ),
        GoRoute(
          path: '/${RouteNames.terms}',
          builder: (_, _) => const Scaffold(
            body: Text('Terms', key: ValueKey('terms_test_screen')),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('study_overview_continue')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('terms_test_screen')), findsOneWidget);
  });

  testWidgets('pending link clear does not rebuild with a null study', (
    tester,
  ) async {
    final study = Study('study-1', 'owner-1')..title = 'Study';
    final state = AppState()..setPendingDeepLink(study: study);
    final router = GoRouter(
      initialLocation: '/${RouteNames.studyOverview}',
      routes: [
        GoRoute(
          path: '/${RouteNames.studyOverview}',
          builder: (_, _) => const StudyOverviewScreen(),
        ),
        GoRoute(
          path: '/${RouteNames.studySelection}',
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    state.selectedStudy = null;
    state.clearPendingDeepLink();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
