// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChoiceExpression _$ChoiceExpressionFromJson(Map<String, dynamic> json) =>
    ChoiceExpression()
      ..type = json['type'] as String?
      ..target = json['target'] as String?
      ..choices = (json['choices'] as List<dynamic>).toSet();

Map<String, dynamic> _$ChoiceExpressionToJson(ChoiceExpression instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  writeNotNull('target', instance.target);
  val['choices'] = instance.choices.toList();
  return val;
}
