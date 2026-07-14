import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/onboarding/intervention_selection.dart';
import 'package:studyu_core/core.dart';

void main() {
  testWidgets('back reopens eligibility when the study has a check', (
    tester,
  ) async {
    final question = BooleanQuestion.withId()..prompt = 'Eligible?';
    final study = Study.withId('owner-1')
      ..title = 'Study'
      ..questionnaire.questions = [question]
      ..eligibilityCriteria = [EligibilityCriterion.withId()];
    final appState = AppState()..selectedStudy = study;
    final router = GoRouter(
      initialLocation: '/${RouteNames.interventionSelection}',
      routes: [
        GoRoute(
          path: '/${RouteNames.interventionSelection}',
          builder: (_, _) => const InterventionSelectionScreen(),
        ),
        GoRoute(
          path: '/${RouteNames.eligibilityCheck}',
          builder: (_, state) =>
              EligibilityScreen(study: state.extra! as Study),
        ),
      ],
    );
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(EligibilityScreen), findsOneWidget);
  });
}
