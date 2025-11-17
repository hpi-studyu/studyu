import 'package:collection/collection.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ConditionRowFormViewModel
    extends ManagedFormViewModel<ConditionRowFormData> {
  // --- Controls ---
  final questionIdControl = FormControl<String>();
  final comparatorControl = FormControl<dynamic>();
  final valueControl = FormControl<dynamic>();

  void _updateValueForQuestionType() {
    final question = selectedQuestion;
    if (question == null) return;

    final currentValue = valueControl.value;

    if (currentValue is bool) {
      switch (question.type) {
        case ScaleQuestion.questionType:
          valueControl.value = currentValue.toString();
        case FreeTextQuestion.questionType:
          valueControl.value = currentValue.toString();
        case BooleanQuestion.questionType:
          break;
        case ChoiceQuestion.questionType:
          valueControl.value = null;
        default:
          valueControl.value = null;
      }
    }
  }

  // todo do not make this static, try to use a provider to get the questions
  static List<Question> availableQuestions = [];
  final String currentQuestionId;

  void refreshAvailableQuestions() {
    final question = selectedQuestion;
    if (question != null) {
      _updateValueForQuestionType();
    }
  }

  ConditionRowFormViewModel({
    required this.currentQuestionId,
    Expression? initialExpression,
  }) {
    if (initialExpression != null) {
      questionIdControl.value = extractQuestionId(initialExpression);
      comparatorControl.value = extractComparator(initialExpression);
      valueControl.value = extractValue(initialExpression);
      _updateValueForQuestionType();
    }

    // Listen for question selection changes
    questionIdControl.valueChanges.listen((questionId) {
      if (questionId != null) {
        final question = availableQuestions.firstWhereOrNull(
          (q) => q.id == questionId,
        );
        if (question?.type == BooleanQuestion.questionType) {
          // Automatically set 'is' comparator for boolean questions and disable the control
          comparatorControl.value = 'is';
          comparatorControl.markAsDisabled();
          valueControl.value = null;
          // Add required validator for boolean questions
          valueControl.setValidators([Validators.required]);
        } else {
          // Enable the control for non-boolean questions
          comparatorControl.markAsEnabled();
          comparatorControl.value = null;
          valueControl.value = null;
          // Clear validators for non-boolean questions
          valueControl.clearValidators();
        }
        _updateValueForQuestionType();
      }
      // Mark the form as dirty to trigger value propagation
      form.markAsDirty();
    });

    // Listen for comparator changes
    comparatorControl.valueChanges.listen((_) {
      form.markAsDirty();
    });

    // Listen for value changes
    valueControl.valueChanges.listen((_) {
      form.markAsDirty();
    });
  }

  @override
  late final FormGroup form = FormGroup({
    'questionId': questionIdControl,
    'comparator': comparatorControl,
    'value': valueControl,
  });

  /*void onControlChanged(void Function() callback) {
    questionIdControl.valueChanges.listen((_) => callback());
    comparatorControl.valueChanges.listen((_) => callback());
    valueControl.valueChanges.listen((_) => callback());
  }*/

  // --- Get selected question object ---
  Question? get selectedQuestion {
    return availableQuestions.firstWhereOrNull(
      (q) => q.id == questionIdControl.value,
    );
  }

  // --- Get available comparators for selected question ---
  List<FormControlOption<dynamic>> get availableComparators {
    final q = selectedQuestion;
    if (q == null) return [];
    switch (q.type) {
      case BooleanQuestion.questionType:
        return [
          FormControlOption('is', tr.form_array_question_visibility_logic_is),
        ];
      case ChoiceQuestion.questionType:
        return [
          FormControlOption('=', tr.form_array_question_visibility_logic_is),
          FormControlOption(
            '!=',
            tr.form_array_question_visibility_logic_is_not,
          ),
        ];
      case ScaleQuestion.questionType:
        return [
          const FormControlOption(NumericComparator.equal, '='),
          const FormControlOption(NumericComparator.notEqual, '≠'),
          const FormControlOption(NumericComparator.greaterThan, '>'),
          const FormControlOption(NumericComparator.lessThan, '<'),
          const FormControlOption(NumericComparator.greaterThanOrEqual, '≥'),
          const FormControlOption(NumericComparator.lessThanOrEqual, '≤'),
        ];
      case FreeTextQuestion.questionType:
        return [
          FormControlOption(
            TextComparator.equal,
            tr.form_array_question_visibility_logic_is,
          ),
          FormControlOption(
            TextComparator.notEqual,
            tr.form_array_question_visibility_logic_is_not,
          ),
          FormControlOption(
            TextComparator.contains,
            tr.form_array_question_visibility_logic_contains,
          ),
          FormControlOption(
            TextComparator.doesNotContain,
            tr.form_array_question_visibility_logic_does_not_contain,
          ),
        ];
      default:
        return [];
    }
  }

  // --- Get available values for a 'choice' question ---
  List<FormControlOption<dynamic>> get availableChoiceValues {
    if (selectedQuestion?.type == ChoiceQuestion.questionType) {
      final choiceQuestion = selectedQuestion as ChoiceQuestion?;
      return choiceQuestion?.choices
              .map((choice) => FormControlOption(choice.id, choice.text))
              .toList() ??
          [];
    }
    return [];
  }

  // --- Extract initial values from Expression ---
  String? extractQuestionId(Expression? expression) {
    if (expression is ValueExpression) {
      return expression.target;
    } else if (expression is NotExpression &&
        expression.expression is ValueExpression) {
      return (expression.expression as ValueExpression).target;
    }
    return null;
  }

  dynamic extractComparator(Expression? expression) {
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

  dynamic extractValue(Expression? expression) {
    if (expression is ValueExpression) {
      if (expression is NumericExpression) {
        // Always store as String for scale to avoid type error in TextField
        return expression.value.toString();
      }
      if (expression is TextExpression) return expression.value;
      if (expression is ChoiceExpression) {
        // For choice expressions, check if we need to handle multiple choices
        if (expression.choices.length > 1) {
          // Return the whole set for multiple choices
          return expression.choices.toList();
        } else {
          // Return a single value for single choice
          return expression.choices.firstOrNull;
        }
      }
      if (expression is BooleanExpression) {
        return true;
      }
      return null;
    } else if (expression is NotExpression) {
      if (expression.expression is ChoiceExpression) {
        final choiceExp = expression.expression as ChoiceExpression;
        // Same logic for NotExpression containing ChoiceExpression
        if (choiceExp.choices.length > 1) {
          return choiceExp.choices.toList();
        } else {
          return choiceExp.choices.firstOrNull;
        }
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
      case BooleanQuestion.questionType:
        if (value == null) return null;
        baseExpression = BooleanExpression()..target = questionId;
        if (value == false) {
          return NotExpression()..expression = baseExpression;
        }
        return baseExpression;
      case ChoiceQuestion.questionType:
        if (value == null) return null;
        final choiceExpression = ChoiceExpression()..target = questionId;

        // Handle both single and multiple choice values
        if (value is List) {
          // Filter out null/empty values
          final validValues = value
              .where((v) => v != null && v.toString().isNotEmpty)
              .toList();
          if (validValues.isEmpty) return null;
          choiceExpression.choices = Set.from(validValues);
        } else {
          // Check for null/empty values
          if (value.toString().isEmpty) return null;
          choiceExpression.choices = {value};
        }

        if (comparator == '!=') {
          return NotExpression()..expression = choiceExpression;
        }
        return choiceExpression;
      case ScaleQuestion.questionType:
        if (value is String) {
          value = num.tryParse(value);
        }
        if (comparator is! NumericComparator || value is! num) return null;
        return NumericExpression(comparator: comparator, value: value)
          ..target = questionId;
      case FreeTextQuestion.questionType:
        if (comparator is! TextComparator || value == null) return null;
        return TextExpression(comparator: comparator, value: value as String)
          ..target = questionId;
      default:
        return null;
    }
  }

  @override
  ConditionRowFormData buildFormData() {
    return ConditionRowFormData(
      questionId: questionIdControl.value,
      comparator: comparatorControl.value,
      value: valueControl.value,
    );
  }

  @override
  void setControlsFrom(ConditionRowFormData data) {
    questionIdControl.value = data.questionId;
    comparatorControl.value = data.comparator;
    valueControl.value = data.value;

    // Re-run question selection logic
    final questionId = questionIdControl.value;
    if (questionId != null) {
      final question = availableQuestions.firstWhereOrNull(
        (q) => q.id == questionId,
      );
      if (question?.type == BooleanQuestion.questionType) {
        comparatorControl.value = 'is';
        comparatorControl.markAsDisabled();
        // Add required validator for boolean questions
        valueControl.setValidators([Validators.required]);
      } else {
        comparatorControl.markAsEnabled();
        // Clear validators for non-boolean questions
        valueControl.clearValidators();
      }
      _updateValueForQuestionType();
    }
  }

  @override
  ManagedFormViewModel<ConditionRowFormData> createDuplicate() {
    return ConditionRowFormViewModel(currentQuestionId: currentQuestionId);
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: tr.form_mode_visibility_create,
    FormMode.edit: tr.form_mode_visibility_edit,
    FormMode.readonly: tr.form_mode_visibility_readonly,
  };
}
