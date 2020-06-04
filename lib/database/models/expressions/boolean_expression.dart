import 'expression.dart';
import 'value_expression.dart';

class BooleanExpression extends ValueExpression<bool> {
  static String conditionType = Expression.registerExpressionType('boolean', (data) => BooleanExpression.fromJSON(data));
  @override
  String get type => conditionType;

  BooleanExpression.fromJSON(Map<String, dynamic> data) : super.fromJSON(data);

  @override
  Map<String, dynamic> toJson() => super.toJson();

  @override
  bool checkValue(bool value) => value;
}
