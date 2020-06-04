import 'package:collection/collection.dart';

import '../questionnaire/questionnaire.dart';
import 'expression.dart';

class NotExpression extends Expression {
  static const String expressionType = 'not';
  @override
  String get type => expressionType;

  static String keyExpression = 'expression';
  Expression expression;

  NotExpression.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    expression = Expression.parseJson(data[keyExpression]);
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
    keyExpression: expression.toJson()
  });

  bool evaluate(QuestionnaireState state) => !expression.evaluate(state);
}
