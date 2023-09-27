import 'package:studyu_core/src/models/expressions/types/types.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';

typedef ExpressionParser = Expression Function(Map<String, dynamic> data);

abstract class Expression {
  static Map<String, ExpressionParser> expressionTypes = {
    BooleanExpression.expressionType: (data) => BooleanExpression.fromJson(data),
    ChoiceExpression.expressionType: (data) => ChoiceExpression.fromJson(data),
    NotExpression.expressionType: (data) => NotExpression.fromJson(data),
  };
  static const String keyType = 'type';
  String? type;

  Expression(this.type);

  factory Expression.fromJson(Map<String, dynamic> data) => expressionTypes[data[keyType]]!(data);
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }

  bool? evaluate(QuestionnaireState state);
}
