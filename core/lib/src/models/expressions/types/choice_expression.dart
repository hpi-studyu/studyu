import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/expressions/types/value_expression.dart';

part 'choice_expression.g.dart';

@JsonSerializable()
class ChoiceExpression extends ValueExpression<dynamic> {
  static const String expressionType = 'choice';

  Set<dynamic> choices = {};

  ChoiceExpression() : super(expressionType);

  ChoiceExpression.withId() : super(expressionType);

  factory ChoiceExpression.fromJson(Map<String, dynamic> json) =>
      _$ChoiceExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChoiceExpressionToJson(this);

  @override
  bool checkValue(dynamic value) {
    if (value is List) {
      if (value.isEmpty) {
        // todo workaround until not expression is implemented for V2
        return true;
      } else {
        return value.any((element) => choices.contains(element));
      }
    }
    return choices.contains(value);
  }
}
