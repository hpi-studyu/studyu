import '../expression.dart';
import 'value_expression.dart';

class BooleanExpression extends ValueExpression<bool> {
  static const String expressionType = 'boolean';
  @override
  String get type => expressionType;

  BooleanExpression.fromJson(Map<String, dynamic> data) : super.fromJson(data);

  @override
  Map<String, dynamic> toJson() => super.toJson();

  @override
  bool checkValue(bool value) => value;
}
