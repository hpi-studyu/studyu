import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/choice_question_widget.dart';
import 'package:studyu_app/widgets/selectable_button.dart';
import 'package:studyu_core/core.dart';

Widget _setup(ChoiceQuestion question, ValueChanged<Answer> onDone) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: Scaffold(
      body: ChoiceQuestionWidget(
        question: question,
        onDone: onDone,
        multiSelectionText: 'Select all that apply (optional)',
        requiredMultiSelectionText:
            'Select all that apply (at least one required)',
      ),
    ),
  );
}

ChoiceQuestion _question({required bool selectionRequired}) {
  return ChoiceQuestion.withId()
    ..multiple = true
    ..selectionRequired = selectionRequired
    ..choices = [Choice.withText(text: 'A'), Choice.withText(text: 'B')];
}

void main() {
  testWidgets('required multi-selection cannot confirm an empty answer', (
    tester,
  ) async {
    Answer? answer;
    final question = _question(selectionRequired: true);

    await tester.pumpWidget(_setup(question, (value) => answer = value));

    final confirmButton = find.widgetWithText(
      OutlinedButton,
      'Confirm selection',
    );
    final disabledButton = tester.widget<OutlinedButton>(confirmButton);
    final colorScheme = Theme.of(tester.element(confirmButton)).colorScheme;
    expect(disabledButton.onPressed, isNull);
    expect(
      disabledButton.style?.foregroundColor?.resolve({WidgetState.disabled}),
      colorScheme.onSurfaceVariant,
    );
    expect(
      disabledButton.style?.backgroundColor?.resolve({WidgetState.disabled}),
      colorScheme.surfaceContainerHighest,
    );
    expect(
      tester
          .widget<ChoiceQuestionWidget>(find.byType(ChoiceQuestionWidget))
          .subtitle,
      'Select all that apply (at least one required)',
    );

    await tester.tap(find.text('A'));
    await tester.pump();

    expect(tester.widget<OutlinedButton>(confirmButton).onPressed, isNotNull);

    await tester.tap(find.text('A'));
    await tester.pump();

    final firstOption = find.ancestor(
      of: find.text('A'),
      matching: find.byType(SelectableButton),
    );
    expect(tester.widget<SelectableButton>(firstOption).selected, isFalse);
    expect(tester.widget<OutlinedButton>(confirmButton).onPressed, isNull);

    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.text('Confirm selection'));
    await tester.pump();

    expect(answer?.response, [question.choices.first.id]);
  });

  testWidgets('optional multi-selection can still confirm an empty answer', (
    tester,
  ) async {
    Answer? answer;

    await tester.pumpWidget(
      _setup(_question(selectionRequired: false), (value) => answer = value),
    );

    expect(
      tester
          .widget<ChoiceQuestionWidget>(find.byType(ChoiceQuestionWidget))
          .subtitle,
      'Select all that apply (optional)',
    );

    await tester.tap(find.text('Confirm selection'));
    await tester.pump();

    expect(answer?.response, isEmpty);
  });
}
