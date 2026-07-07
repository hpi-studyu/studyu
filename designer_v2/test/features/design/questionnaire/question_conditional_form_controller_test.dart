import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';

void main() {
  late FormControl<QuestionConditional<dynamic>?> conditionalControl;

  FreeTextQuestion freeTextQuestion(
    String id, {
    FreeTextQuestionType textType = FreeTextQuestionType.any,
  }) => FreeTextQuestion.withId(textType: textType, lengthRange: [0, 500])
    ..id = id
    ..prompt = id;

  ConditionalQuestionFormViewModel viewModelWithQuestion(Question question) {
    ConditionRowFormViewModel.availableQuestions = [question];
    conditionalControl = FormControl<QuestionConditional<dynamic>?>();
    final viewModel = ConditionalQuestionFormViewModel(
      currentQuestionId: 'current-question',
      questionConditionalControl: conditionalControl,
    );
    viewModel.addCondition();
    viewModel.conditionModels.single.questionIdControl.value = question.id;
    return viewModel;
  }

  tearDown(() {
    ConditionRowFormViewModel.availableQuestions = [];
  });

  group('ConditionalQuestionFormViewModel', () {
    test('saves non-numeric free text same length as text length equality', () {
      final viewModel = viewModelWithQuestion(freeTextQuestion('q1'));
      final condition = viewModel.conditionModels.single;

      condition.comparatorControl.value = TextComparator.lengthEqual;
      condition.valueControl.value = '8';

      final expression = viewModel.compositeExpression!.expressions.single;

      expect(expression, isA<TextExpression>());
      expect(expression.toJson(), containsPair('comparator', 'length_equal'));
      expect(expression.toJson(), containsPair('value', '8'));
      expect(expression.toJson(), containsPair('target', 'q1'));
    });

    test(
      'saves non-numeric free text different length as text length inequality',
      () {
        final viewModel = viewModelWithQuestion(freeTextQuestion('q1'));
        final condition = viewModel.conditionModels.single;

        condition.comparatorControl.value = TextComparator.lengthNotEqual;
        condition.valueControl.value = '8';

        final expression = viewModel.compositeExpression!.expressions.single;

        expect(expression, isA<TextExpression>());
        expect(
          expression.toJson(),
          containsPair('comparator', 'length_not_equal'),
        );
        expect(expression.toJson(), containsPair('value', '8'));
        expect(expression.toJson(), containsPair('target', 'q1'));
      },
    );

    test(
      'saves numeric free text symbolic comparator as numeric expression',
      () {
        final viewModel = viewModelWithQuestion(
          freeTextQuestion('q1', textType: FreeTextQuestionType.numeric),
        );
        final condition = viewModel.conditionModels.single;

        condition.comparatorControl.value = NumericComparator.greaterThan;
        condition.valueControl.value = '5';

        final expression = viewModel.compositeExpression!.expressions.single;

        expect(expression, isA<NumericExpression>());
        expect(expression.toJson(), containsPair('comparator', '>'));
        expect(expression.toJson(), containsPair('value', 5));
        expect(expression.toJson(), containsPair('target', 'q1'));
      },
    );
  });
}
