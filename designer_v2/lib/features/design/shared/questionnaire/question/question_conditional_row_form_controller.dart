import 'package:collection/collection.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart' as core;
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ConditionRowFormViewModel extends FormViewModel<ConditionRowFormData> {
  // --- Controls ---
  final questionIdControl = FormControl<String>();
  final comparatorControl = FormControl<dynamic>();
  final valueControl = FormControl<dynamic>();

  // todo do not make this static, try to use a provider to get the questions
  static List<core.Question> allQuestions = [];
  final String currentQuestionId;

  ConditionRowFormViewModel({
    required this.currentQuestionId,
    core.Expression? initialExpression,
  }) {
    if (initialExpression != null) {
      questionIdControl.value = _extractQuestionId(initialExpression);
      comparatorControl.value = _extractComparator(initialExpression);
      valueControl.value = _extractValue(initialExpression);
    }

    // Listen for question selection changes
    questionIdControl.valueChanges.listen((questionId) {
      if (questionId != null) {
        final question =
            availableQuestions.firstWhereOrNull((q) => q.id == questionId);
        if (question?.type == 'boolean') {
          // Automatically set 'is' comparator for boolean questions and disable the control
          comparatorControl.value = 'is';
          comparatorControl.markAsDisabled();
        } else {
          // Enable the control for non-boolean questions
          comparatorControl.markAsEnabled();
        }
      }
    });
  }

  /*void onControlChanged(void Function() callback) {
    questionIdControl.valueChanges.listen((_) => callback());
    comparatorControl.valueChanges.listen((_) => callback());
    valueControl.valueChanges.listen((_) => callback());
  }*/

// --- Available questions for dropdown (exclude current and all later ones) ---
  List<core.Question> get availableQuestions {
    final currentIndex =
        allQuestions.indexWhere((q) => q.id == currentQuestionId);
    if (currentIndex == -1) return [];
    return allQuestions.take(currentIndex).toList();
  }

  // --- Get selected question object ---
  core.Question? get selectedQuestion {
    return availableQuestions
        .firstWhereOrNull((q) => q.id == questionIdControl.value);
  }

  // --- Get available comparators for selected question ---
  List<FormControlOption<dynamic>> get availableComparators {
    final q = selectedQuestion;
    if (q == null) return [];
    switch (q.type) {
      case 'boolean':
        return [
          FormControlOption('is', tr.form_array_question_visibility_logic_is),
        ];
      case 'choice':
        return [
          FormControlOption('=', tr.form_array_question_visibility_logic_is),
          FormControlOption(
              '!=', tr.form_array_question_visibility_logic_is_not),
        ];
      case 'scale':
        return [
          const FormControlOption(core.NumericComparator.equal, '='),
          const FormControlOption(core.NumericComparator.notEqual, '≠'),
          const FormControlOption(core.NumericComparator.greaterThan, '>'),
          const FormControlOption(core.NumericComparator.lessThan, '<'),
          const FormControlOption(
              core.NumericComparator.greaterThanOrEqual, '≥'),
          const FormControlOption(core.NumericComparator.lessThanOrEqual, '≤'),
        ];
      case 'text':
        return [
          FormControlOption(core.TextComparator.equal,
              tr.form_array_question_visibility_logic_is),
          FormControlOption(core.TextComparator.notEqual,
              tr.form_array_question_visibility_logic_is_not),
          FormControlOption(core.TextComparator.contains,
              tr.form_array_question_visibility_logic_contains),
          FormControlOption(core.TextComparator.doesNotContain,
              tr.form_array_question_visibility_logic_does_not_contain),
        ];
      default:
        return [];
    }
  }

  // --- Get available values for a 'choice' question ---
  List<FormControlOption<dynamic>> get availableChoiceValues {
    if (selectedQuestion?.type == 'choice') {
      final choiceQuestion = selectedQuestion as core.ChoiceQuestion?;
      return choiceQuestion?.choices
              .map((choice) => FormControlOption(choice.id, choice.text))
              .toList() ??
          [];
    }
    return [];
  }

  // --- Extract initial values from Expression ---
  static String? _extractQuestionId(core.Expression? expression) {
    if (expression is core.ValueExpression) {
      return expression.target;
    } else if (expression is core.NotExpression &&
        expression.expression is core.ValueExpression) {
      return (expression.expression as core.ValueExpression).target;
    }
    return null;
  }

  static dynamic _extractComparator(core.Expression? expression) {
    if (expression is core.NumericExpression) {
      return expression.comparator;
    } else if (expression is core.TextExpression) {
      return expression.comparator;
    } else if (expression is core.ChoiceExpression) {
      return '='; // Default for ChoiceExpression if no NotExpression
    } else if (expression is core.BooleanExpression) {
      return 'is'; // Default for BooleanExpression if no NotExpression
    } else if (expression is core.NotExpression) {
      if (expression.expression is core.ChoiceExpression) {
        return '!=';
      } else if (expression.expression is core.BooleanExpression) {
        return 'is';
      }
    }
    return null;
  }

  static dynamic _extractValue(core.Expression? expression) {
    if (expression is core.ValueExpression) {
      if (expression is core.NumericExpression) return expression.value;
      if (expression is core.TextExpression) return expression.value;
      if (expression is core.ChoiceExpression) {
        return expression.choices.firstOrNull;
      }
      if (expression is core.BooleanExpression) {
        return true;
      }
      return null;
    } else if (expression is core.NotExpression) {
      if (expression.expression is core.ChoiceExpression) {
        return (expression.expression as core.ChoiceExpression)
            .choices
            .firstOrNull;
      }
      if (expression.expression is core.BooleanExpression) {
        return false;
      }
    }
    return null;
  }

  // --- Build Expression from Form Controls ---
  core.Expression? buildExpression() {
    final questionId = questionIdControl.value;
    final comparator = comparatorControl.value;
    final value = valueControl.value;
    final selectedQ = selectedQuestion;

    if (questionId == null || selectedQ == null) return null;

    core.Expression? baseExpression;
    switch (selectedQ.type) {
      case 'boolean':
        baseExpression = core.BooleanExpression()..target = questionId;
        if (value == false) {
          return core.NotExpression()..expression = baseExpression;
        }
        return baseExpression;
      case 'choice':
        if (value == null) return null;
        baseExpression = core.ChoiceExpression()
          ..target = questionId
          ..choices = {value};
        if (comparator == '!=') {
          return core.NotExpression()..expression = baseExpression;
        }
        return baseExpression;
      case 'scale':
        if (comparator is! core.NumericComparator || value is! num) return null;
        return core.NumericExpression(comparator: comparator, value: value)
          ..target = questionId;
      case 'text':
        if (comparator is! core.TextComparator || value == null) return null;
        return core.TextExpression(
            comparator: comparator, value: value as String)
          ..target = questionId;
      default:
        return null;
    }
  }

  @override
  FormGroup get form => FormGroup({
        'questionId': questionIdControl,
        'comparator': comparatorControl,
        'value': valueControl,
      });

  @override
  ConditionRowFormData buildFormData() {
    print("Building form data from controls");
    return ConditionRowFormData(
      questionId: questionIdControl.value,
      comparator: comparatorControl.value,
      value: valueControl.value,
    );
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError();

  @override
  void setControlsFrom(ConditionRowFormData data) {
    print("Setting controls from data: $data");
    questionIdControl.value = data.questionId;
    comparatorControl.value = data.comparator;
    valueControl.value = data.value;
  }
}
