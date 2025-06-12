import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/expressions/expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';

part 'composite_expression.g.dart';

enum LogicType {
  @JsonValue('and')
  and,
  @JsonValue('or')
  or,
}

@JsonSerializable()
class CompositeExpression extends Expression {
  static const String expressionType = 'composite';

  LogicType logicType;
  List<Expression> expressions; // List of sub-expressions

  CompositeExpression({
    required this.logicType,
    required this.expressions,
  }) : super(expressionType);

  factory CompositeExpression.fromJson(Map<String, dynamic> json) =>
      _$CompositeExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CompositeExpressionToJson(this);

  @override
  bool? evaluate(QuestionnaireState state) {
    if (expressions.isEmpty) {
      return true; // No conditions means it's always true
    }

    // Evaluate all sub-expressions
    final evaluatedResults =
        expressions.map((exp) => exp.evaluate(state)).toList();

    // Filter out nulls if you want to ignore expressions that couldn't be evaluated,
    // or handle them as 'false' based on your specific logic.
    // For simplicity, if any sub-expression is null, the composite evaluation will be null.
    if (evaluatedResults.contains(null)) {
      return null;
    }

    // All results are non-null booleans now
    final boolResults = evaluatedResults.cast<bool>();

    switch (logicType) {
      case LogicType.and:
        return boolResults.every((result) => result == true);
      case LogicType.or:
        return boolResults.any((result) => result == true);
    }
  }
}
