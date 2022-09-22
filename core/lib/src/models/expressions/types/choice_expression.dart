import 'package:json_annotation/json_annotation.dart';

import 'value_expression.dart';

part 'choice_expression.g.dart';

@JsonSerializable()
class ChoiceExpression extends ValueExpression<dynamic> {
  static const String expressionType = 'choice';

  Set<dynamic> choices = {};

  ChoiceExpression() : super(expressionType);

  ChoiceExpression.withId() : super(expressionType);

  factory ChoiceExpression.fromJson(Map<String, dynamic> json) => _$ChoiceExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChoiceExpressionToJson(this);

  @override
  bool checkValue(dynamic value) {
    if (value is List) {
      return value.any((element) => choices.contains(element));
    }
    return choices.contains(value);
  }
}
