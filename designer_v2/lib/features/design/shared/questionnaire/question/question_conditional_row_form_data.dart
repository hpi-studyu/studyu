import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class ConditionRowFormData extends IFormData {
  ConditionRowFormData({
    required this.questionId,
    required this.comparator,
    required this.value,
  });

  final String? questionId;
  final dynamic comparator;
  final dynamic value;

  Expression? buildExpression() {
    if (questionId == null) return null;

    // Handle boolean questions
    if (comparator == 'is') {
      final baseExpression = BooleanExpression()..target = questionId;
      if (value == false) {
        return NotExpression()..expression = baseExpression;
      }
      return baseExpression;
    }

    // Handle choice questions
    if (comparator == NumericComparator.equal ||
        comparator == NumericComparator.notEqual) {
      final baseExpression = ChoiceExpression()
        ..target = questionId
        ..choices = {value?.toString() ?? ''};
      if (comparator == NumericComparator.notEqual) {
        return NotExpression()..expression = baseExpression;
      }
      return baseExpression;
    }

    // Handle numeric questions
    if (comparator is NumericComparator) {
      final numValue =
          value is String ? num.tryParse(value as String) : (value as num?);
      if (numValue == null) return null;
      return NumericExpression(
          comparator: comparator as NumericComparator, value: numValue)
        ..target = questionId;
    }

    // Handle text questions
    if (comparator is TextComparator) {
      if (value == null) return null;
      return TextExpression(
          comparator: comparator as TextComparator, value: value.toString())
        ..target = questionId;
    }

    return null;
  }

  @override
  String toString() =>
      'ConditionRowFormData(questionId: $questionId, comparator: $comparator, value: $value)';

  @override
  IFormData copy() {
    return ConditionRowFormData(
      questionId: questionId,
      comparator: comparator,
      value: value,
    );
  }

  @override
  FormDataID get id => throw UnimplementedError();
}
