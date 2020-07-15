import '../../questionnaire/questionnaire_state.dart';
import '../expression.dart';

abstract class ValueExpression<V> extends Expression {
  String target;

  ValueExpression(String type) : super(type);

  bool checkValue(V value);

  @override
  bool evaluate(QuestionnaireState state) {
    return checkValue(state.getAnswer<V>(target));
  }
}
