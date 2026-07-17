import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_core/core.dart';

void main() {
  testWidgets('shows failed eligibility immediately after the answer', (
    tester,
  ) async {
    final question = BooleanQuestion.withId()
      ..id = 'eligible'
      ..prompt = 'Do you fulfill the criterion?';
    final criterion = EligibilityCriterion.withId()
      ..reason = 'Criterion not fulfilled'
      ..condition = (BooleanExpression()..target = question.id);
    final study = Study.withId('user')
      ..title = 'Study'
      ..questionnaire.questions = [question]
      ..eligibilityCriteria = [criterion];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => EligibilityScreen(study: study),
        ),
      ],
    );
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp.router(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('no'));
    await tester.pumpAndSettle();

    expect(find.text('You are not eligible for this study'), findsOneWidget);
    expect(find.text('Criterion not fulfilled'), findsOneWidget);
    expect(find.text('Complete'), findsNothing);
  });

  testWidgets('unknown choice criteria fail without throwing on completion', (
    tester,
  ) async {
    final gate = BooleanQuestion.withId()
      ..id = 'gate'
      ..prompt = 'Show the optional choice?';
    final optionalChoice = ChoiceQuestion.withId()
      ..id = 'choice'
      ..prompt = 'Select any'
      ..multiple = true
      ..choices = [
        Choice.withText(id: 'a', text: 'A'),
        Choice.withText(id: 'b', text: 'B'),
        Choice.withText(id: 'c', text: 'C'),
      ]
      ..conditional = QuestionConditional<List<String>>.withCondition(
        CompositeExpression(
          logicType: LogicType.and,
          expressions: [BooleanExpression()..target = gate.id],
        ),
      );
    final criterion = EligibilityCriterion.withId()
      ..reason = 'Choice criterion not fulfilled'
      ..condition = CompositeExpression(
        logicType: LogicType.and,
        expressions: optionalChoice.choices
            .map(
              (choice) => NotExpression()
                ..expression = (ChoiceExpression()
                  ..target = optionalChoice.id
                  ..choices = {choice.id}),
            )
            .toList(),
      );
    final study = Study.withId('user')
      ..title = 'Study'
      ..questionnaire.questions = [gate, optionalChoice]
      ..eligibilityCriteria = [criterion];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => EligibilityScreen(study: study),
        ),
      ],
    );
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp.router(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('no'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('You are not eligible for this study'), findsOneWidget);
    expect(find.text('Choice criterion not fulfilled'), findsOneWidget);
  });
}
