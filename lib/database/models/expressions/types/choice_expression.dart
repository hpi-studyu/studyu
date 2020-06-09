import 'package:json_annotation/json_annotation.dart';

import 'value_expression.dart';

part 'choice_expression.g.dart';

@JsonSerializable()
class ChoiceExpression extends ValueExpression<List<String>> {
  static const String expressionType = 'choice';
  @override
  String get type => expressionType;

  Set<String> choices;

  ChoiceExpression();

  factory ChoiceExpression.fromJson(Map<String, dynamic> json) => _$ChoiceExpressionFromJson(json);
  @override
  Map<String, dynamic> toJsonData() => _$ChoiceExpressionToJson(this);

  @override
  bool checkValue(List<String> value) => value.any((element) => choices.contains(element));
}
