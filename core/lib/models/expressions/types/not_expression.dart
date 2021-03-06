import 'package:json_annotation/json_annotation.dart';
import 'package:studyou_core/models/expressions/types/boolean_expression.dart';

import '../../questionnaire/questionnaire_state.dart';
import '../expression.dart';

part 'not_expression.g.dart';

@JsonSerializable()
class NotExpression extends Expression {
  static const String expressionType = 'not';

  Expression expression;

  NotExpression() : super(expressionType);

  NotExpression.designerDefault()
      : expression = BooleanExpression(),
        super(expressionType);

  factory NotExpression.fromJson(Map<String, dynamic> json) => _$NotExpressionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NotExpressionToJson(this);

  @override
  bool evaluate(QuestionnaireState state) {
    final bool result = expression.evaluate(state);
    return result != null ? !result : result;
  }
}
