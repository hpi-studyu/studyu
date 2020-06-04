import 'package:collection/collection.dart';

import '../questionnaire/questionnaire.dart';
import 'expression.dart';

class NotExpression extends Expression {
  static String conditionType = Expression.registerExpressionType('not', (data) => NotExpression.fromJSON(data));
  @override
  String get type => conditionType;

  static String keyExpression = 'expression';
  Expression expression;

  NotExpression.fromJSON(Map<String, dynamic> data) : super.fromJSON(data) {
    expression = Expression.parseJson(data[keyExpression]);
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
    keyExpression: expression.toJson()
  });

  bool evaluate(QuestionnaireState state) => !expression.evaluate(state);
}
