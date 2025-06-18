import 'package:collection/collection.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ConditionRowFormViewModel extends FormViewModel<ConditionRowFormData> {
  // --- Controls ---
  final questionIdControl = FormControl<String>();
  final comparatorControl = FormControl<dynamic>();
  final valueControl = FormControl<dynamic>();

  // todo do not make this static, try to use a provider to get the questions
  static List<Question> availableQuestions = [];
  final String currentQuestionId;

  ConditionRowFormViewModel({
    required this.currentQuestionId,
    Expression? initialExpression,
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

  // --- Get selected question object ---
  Question? get selectedQuestion {
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
          const FormControlOption(NumericComparator.equal, '='),
          const FormControlOption(NumericComparator.notEqual, '≠'),
          const FormControlOption(NumericComparator.greaterThan, '>'),
          const FormControlOption(NumericComparator.lessThan, '<'),
          const FormControlOption(NumericComparator.greaterThanOrEqual, '≥'),
          const FormControlOption(NumericComparator.lessThanOrEqual, '≤'),
        ];
      case 'freeText':
        return [
          FormControlOption(
              TextComparator.equal, tr.form_array_question_visibility_logic_is),
          FormControlOption(TextComparator.notEqual,
              tr.form_array_question_visibility_logic_is_not),
          FormControlOption(TextComparator.contains,
              tr.form_array_question_visibility_logic_contains),
          FormControlOption(TextComparator.doesNotContain,
              tr.form_array_question_visibility_logic_does_not_contain),
        ];
      default:
        return [];
    }
  }

  // --- Get available values for a 'choice' question ---
  List<FormControlOption<dynamic>> get availableChoiceValues {
    if (selectedQuestion?.type == 'choice') {
      final choiceQuestion = selectedQuestion as ChoiceQuestion?;
      return choiceQuestion?.choices
              .map((choice) => FormControlOption(choice.id, choice.text))
              .toList() ??
          [];
    }
    return [];
  }

  // --- Extract initial values from Expression ---
  static String? _extractQuestionId(Expression? expression) {
    if (expression is ValueExpression) {
      return expression.target;
    } else if (expression is NotExpression &&
        expression.expression is ValueExpression) {
      return (expression.expression as ValueExpression).target;
    }
    return null;
  }

  static dynamic _extractComparator(Expression? expression) {
    if (expression is NumericExpression) {
      return expression.comparator;
    } else if (expression is TextExpression) {
      return expression.comparator;
    } else if (expression is ChoiceExpression) {
      return '='; // Default for ChoiceExpression if no NotExpression
    } else if (expression is BooleanExpression) {
      return 'is'; // Default for BooleanExpression if no NotExpression
    } else if (expression is NotExpression) {
      if (expression.expression is ChoiceExpression) {
        return '!=';
      } else if (expression.expression is BooleanExpression) {
        return 'is';
      }
    }
    return null;
  }

  static dynamic _extractValue(Expression? expression) {
    if (expression is ValueExpression) {
      if (expression is NumericExpression) {
        // Always store as String for scale to avoid type error in TextField
        return expression.value.toString();
      }
      if (expression is TextExpression) return expression.value;
      if (expression is ChoiceExpression) {
        return expression.choices.firstOrNull;
      }
      if (expression is BooleanExpression) {
        return true;
      }
      return null;
    } else if (expression is NotExpression) {
      if (expression.expression is ChoiceExpression) {
        return (expression.expression as ChoiceExpression).choices.firstOrNull;
      }
      if (expression.expression is BooleanExpression) {
        return false;
      }
    }
    return null;
  }

  // --- Build Expression from Form Controls ---
  Expression? buildExpression() {
    final questionId = questionIdControl.value;
    final comparator = comparatorControl.value;
    var value = valueControl.value;
    final selectedQ = selectedQuestion;

    if (questionId == null || selectedQ == null) return null;

    Expression? baseExpression;
    switch (selectedQ.type) {
      case 'boolean':
        baseExpression = BooleanExpression()..target = questionId;
        if (value == false) {
          return NotExpression()..expression = baseExpression;
        }
        return baseExpression;
      case 'choice':
        if (value == null) return null;
        baseExpression = ChoiceExpression()
          ..target = questionId
          ..choices = {value};
        if (comparator == '!=') {
          return NotExpression()..expression = baseExpression;
        }
        return baseExpression;
      case 'scale':
        if (value is String) {
          value = num.tryParse(value);
        }
        if (comparator is! NumericComparator || value is! num) return null;
        return NumericExpression(comparator: comparator, value: value)
          ..target = questionId;
      case 'freeText':
        if (comparator is! TextComparator || value == null) return null;
        return TextExpression(comparator: comparator, value: value as String)
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
    throw UnimplementedError();
    /*print("Building form data from controls");
    return ConditionRowFormData(
      questionId: questionIdControl.value,
      comparator: comparatorControl.value,
      value: valueControl.value,
    );*/
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError();

  @override
  void setControlsFrom(ConditionRowFormData data) {
    throw UnimplementedError();
    /*print("Setting controls from data: $data");
    questionIdControl.value = data.questionId;
    comparatorControl.value = data.comparator;
    valueControl.value = data.value;*/
  }
}
