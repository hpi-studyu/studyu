import 'package:json_annotation/json_annotation.dart';

import 'value_expression.dart';

part 'boolean_expression.g.dart';

@JsonSerializable()
class BooleanExpression extends ValueExpression<bool> {
  static const String expressionType = 'boolean';

  BooleanExpression();

  factory BooleanExpression.fromJson(Map<String, dynamic> json) => _$BooleanExpressionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BooleanExpressionToJson(this);

  @override
  bool checkValue(bool value) => value;
}
