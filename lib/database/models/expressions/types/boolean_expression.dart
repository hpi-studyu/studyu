import 'package:Nof1/database/models/expressions/expression.dart';
import 'package:json_annotation/json_annotation.dart';

import 'value_expression.dart';

part 'boolean_expression.g.dart';

@JsonSerializable()
class BooleanExpression extends ValueExpression<bool> {
  static const String expressionType = 'boolean';
  @override
  String get type => expressionType;

  BooleanExpression();

  factory BooleanExpression.fromJson(Map<String, dynamic> json) => _$BooleanExpressionFromJson(json);
  @override
  Map<String, dynamic> toJsonData() => _$BooleanExpressionToJson(this);

  @override
  bool checkValue(bool value) => value;
}
