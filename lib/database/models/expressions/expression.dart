import '../questionnaire/questionnaire_state.dart';
import 'types/boolean_expression.dart';
import 'types/choice_expression.dart';
import 'types/not_expression.dart';

typedef ExpressionParser = Expression Function(Map<String, dynamic> data);

abstract class Expression {
  static Map<String, ExpressionParser> expressionTypes = {
    BooleanExpression.expressionType: (data) => BooleanExpression.fromJson(data),
    ChoiceExpression.expressionType: (data) => ChoiceExpression.fromJson(data),
    NotExpression.expressionType: (data) => NotExpression.fromJson(data)
  };
  static const String keyType = 'type';
  String type;

  Expression();

  factory Expression.fromJson(Map<String, dynamic> data) => expressionTypes[data[keyType]](data);
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }

  bool evaluate(QuestionnaireState state);
}
