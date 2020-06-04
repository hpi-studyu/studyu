import '../questionnaire/questionnaire.dart';

typedef ExpressionParser = Expression Function(Map<String, dynamic> data);

abstract class Expression {
  static Map<String, ExpressionParser> expressionTypes;
  static String registerExpressionType(String key, ExpressionParser f) {
    expressionTypes[key] = f;
    return key;
  }

  static const String keyType = 'type';
  String get type => null;

  Expression.fromJSON(Map<String, dynamic> data);

  factory Expression.parseJson(Map<String, dynamic> data) {
    return expressionTypes[data.remove(keyType)](data);
  }

  Map<String, dynamic> toJson() => { keyType: type };

  @override
  String toString() {
    return toJson().toString();
  }

  bool evaluate(QuestionnaireState state);
}
