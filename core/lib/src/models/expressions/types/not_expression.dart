import 'package:json_annotation/json_annotation.dart';

import '../../questionnaire/questionnaire_state.dart';
import '../expression.dart';
import 'boolean_expression.dart';

part 'not_expression.g.dart';

@JsonSerializable()
class NotExpression extends Expression {
  static const String expressionType = 'not';

  late Expression expression;

  NotExpression() : super(expressionType);

  NotExpression.withId()
      : expression = BooleanExpression(),
        super(expressionType);

  factory NotExpression.fromJson(Map<String, dynamic> json) => _$NotExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NotExpressionToJson(this);

  @override
  bool? evaluate(QuestionnaireState state) {
    final bool? result = expression.evaluate(state);
    return result != null ? !result : result;
  }
}
