import 'package:collection/collection.dart';

import '../../questionnaire/questionnaire.dart';
import '../expression.dart';

abstract class ValueExpression<V> extends Expression {
  static const String keyTarget = 'target';
  String target;

  ValueExpression.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    target = data[keyTarget];
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
    keyTarget: target
  });

  bool checkValue(V value);

  @override
  bool evaluate(QuestionnaireState state) {
    return checkValue(state.getAnswer<V>(target));
  }
}
