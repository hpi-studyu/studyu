import 'package:collection/collection.dart';

import 'expression.dart';
import 'value_expression.dart';

class ChoiceExpression extends ValueExpression<List<String>> {
  static const String expressionType = 'choice';
  @override
  String get type => expressionType;

  static String keyChoices = 'choices';
  Set<String> choices;

  ChoiceExpression.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    choices = Set.from(data['choices']);
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
    keyChoices: choices.toList()
  });

  @override
  bool checkValue(List<String> value) => value.any((element) => choices.contains(element));
}
