import 'package:studyu_core/src/models/expressions/types/types.dart';
import 'package:studyu_core/src/models/expressions/types/unknown_expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';

typedef ExpressionParser = Expression Function(Map<String, dynamic> data);

abstract class Expression {
  static const String keyType = 'type';
  String? type;

  Expression(this.type);

  bool get isSupported => true;

  factory Expression.fromJson(Map<String, dynamic> data) => switch (data[keyType]) {
        BooleanExpression.expressionType => BooleanExpression.fromJson(data),
        ChoiceExpression.expressionType => ChoiceExpression.fromJson(data),
        NotExpression.expressionType => NotExpression.fromJson(data),
        _ => UnknownExpression()
      };

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }

  bool? evaluate(QuestionnaireState state);
}
