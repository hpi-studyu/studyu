import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_core/core.dart';

Widget setup(Widget child) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

BooleanQuestion _boolQuestion(String id, String prompt) =>
    BooleanQuestion.withId()
      ..id = id
      ..prompt = prompt;

void main() {
  testWidgets('unevaluable eligibility criterion fails final evaluation', (
    tester,
  ) async {
    final question = _boolQuestion('q1', 'Are you ready?');
    final criterion = EligibilityCriterion.withId()
      ..reason = 'Missing answer should fail eligibility.'
      ..condition = (BooleanExpression()..target = 'missing-question');
    final study = Study('study-id', 'owner-id')
      ..title = 'Eligibility Study'
      ..questionnaire.questions = [question]
      ..eligibilityCriteria = [criterion];

    await tester.pumpWidget(setup(EligibilityScreen(study: study)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('eligibility_fail_banner')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('eligibility_pass_banner')), findsNothing);

    final nextButton = tester.widget<TextButton>(
      find.byKey(const ValueKey('eligibility_continue')),
    );
    expect(nextButton.onPressed, isNull);
  });
}
