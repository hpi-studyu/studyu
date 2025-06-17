import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/conditional_question_properties.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ConditionValidator extends Validator<dynamic> {
  final ConditionRowFormViewModel viewModel;

  ConditionValidator(this.viewModel);

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    print("Validating condition row: ${viewModel.form.value}");
    final question = viewModel.selectedQuestion;
    if (question == null) return null;

    final parentViewModel =
        viewModel.delegate as IConditionalQuestionProperties?;
    if (parentViewModel == null) return null;

    switch (question.type) {
      case 'boolean':
        final otherConditions = parentViewModel.conditionsArray.controls
            .where((c) => c.value != viewModel)
            .map((c) => c.value!)
            .where((vm) =>
                vm.questionIdControl.value ==
                viewModel.questionIdControl.value);

        for (final otherCondition in otherConditions) {
          if (otherCondition.valueControl.value !=
              viewModel.valueControl.value) {
            return {
              'contradictoryConditions':
                  tr.form_array_question_visibility_logic_contradictory_bool,
            };
          }
        }

      case 'choice':
        if (viewModel.valueControl.value == null) {
          return {
            'required': tr.form_array_question_visibility_logic_choice_required,
          };
        }
        final choiceQuestion = question as ChoiceQuestion;
        final otherChoiceConditions = parentViewModel.conditionsArray.controls
            .where((c) => c.value != viewModel)
            .map((c) => c.value!)
            .where((vm) =>
                vm.questionIdControl.value ==
                viewModel.questionIdControl.value);

        if (!choiceQuestion.multiple) {
          // For single choice questions, only one condition allowed per question
          if (otherChoiceConditions.isNotEmpty) {
            return {
              'contradictoryConditions':
                  'tr.form_array_question_visibility_logic_single_choice_only_one',
            };
          }
        }

      case 'scale':
        final value = viewModel.valueControl.value;
        if (value == null || value is! num) {
          return {
            'number': tr.form_array_question_visibility_logic_number_required,
          };
        }
        final scaleQuestion = question as ScaleQuestion;
        if (value < scaleQuestion.minimum || value > scaleQuestion.maximum) {
          return {
            'range': tr.form_array_question_visibility_logic_number_range(
              scaleQuestion.minimum,
              scaleQuestion.maximum,
            ),
          };
        }

        final otherConditions = parentViewModel.conditionsArray.controls
            .where((c) => c.value != viewModel)
            .map((c) => c.value!)
            .where((vm) =>
                vm.questionIdControl.value ==
                viewModel.questionIdControl.value);

        // Check for contradictory scale conditions
        for (final otherCondition in otherConditions) {
          final comparator1 = viewModel.comparatorControl.value;
          final value1 = viewModel.valueControl.value;
          final comparator2 = otherCondition.comparatorControl.value;
          final value2 = otherCondition.valueControl.value;

          if ((comparator1 == NumericComparator.lessThan &&
                  comparator2 == NumericComparator.greaterThan &&
                  value1 == value2) ||
              (comparator1 == NumericComparator.greaterThan &&
                  comparator2 == NumericComparator.lessThan &&
                  value1 == value2)) {
            return {
              'contradictoryConditions':
                  'tr.form_array_question_visibility_logic_contradictory_scale',
            };
          }
        }

      case 'freeText':
        if (viewModel.valueControl.value == null ||
            (viewModel.valueControl.value as String).isEmpty) {
          return {
            'required': tr.form_array_question_visibility_logic_text_required,
          };
        }
    }
    return null;
  }
}
