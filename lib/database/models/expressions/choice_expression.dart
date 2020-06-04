import 'package:collection/collection.dart';

import 'expression.dart';
import 'value_expression.dart';

class ChoiceExpression extends ValueExpression<List<String>> {
  static String conditionType = Expression.registerExpressionType('choice', (data) => ChoiceExpression.fromJSON(data));
  @override
  String get type => conditionType;

  static String keyChoices = 'choices';
  Set<String> choices;

  ChoiceExpression.fromJSON(Map<String, dynamic> data) : super.fromJSON(data) {
    choices = Set.from(data['choices']);
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
    keyChoices: choices.toList()
  });

  @override
  bool checkValue(List<String> value) => value.any((element) => choices.contains(element));
}
