// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChoiceExpression _$ChoiceExpressionFromJson(Map<String, dynamic> json) {
  return ChoiceExpression()
    ..type = json['type'] as String
    ..target = json['target'] as String
    ..choices = (json['choices'] as List).map((e) => e as String).toSet();
}

Map<String, dynamic> _$ChoiceExpressionToJson(ChoiceExpression instance) => <String, dynamic>{
      'type': instance.type,
      'target': instance.target,
      'choices': instance.choices.toList(),
    };
