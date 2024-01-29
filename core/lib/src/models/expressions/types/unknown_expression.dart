import 'package:studyu_core/src/models/expressions/expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';

class UnknownExpression extends Expression {
  static const String expressionType = 'unknown';

  UnknownExpression() : super(expressionType);

  @override
  bool get isSupported => false;

  @override
  Map<String, dynamic> toJson() => throw ArgumentError('UnknownExpression should not be serialized');

  @override
  bool? evaluate(QuestionnaireState state) {
    throw UnimplementedError();
  }
}
