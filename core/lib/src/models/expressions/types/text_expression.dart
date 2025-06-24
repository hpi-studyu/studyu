import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/expressions/types/value_expression.dart';

part 'text_expression.g.dart';

enum TextComparator {
  @JsonValue('=')
  equal,
  @JsonValue('!=')
  notEqual,
  @JsonValue('contains')
  contains,
  @JsonValue('does_not_contain')
  doesNotContain,
}

@JsonSerializable()
class TextExpression extends ValueExpression<String> {
  static const String expressionType = 'text';

  TextComparator comparator;
  String value; // The text to compare against

  TextExpression({required this.comparator, required this.value})
      : super(expressionType);

  factory TextExpression.fromJson(Map<String, dynamic> json) =>
      _$TextExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextExpressionToJson(this);

  @override
  bool checkValue(String targetValue) {
    switch (comparator) {
      case TextComparator.equal:
        return targetValue == value;
      case TextComparator.notEqual:
        return targetValue != value;
      case TextComparator.contains:
        return targetValue.contains(value);
      case TextComparator.doesNotContain:
        return !targetValue.contains(value);
    }
  }
}
