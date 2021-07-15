// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_conditional.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionConditional<V> _$QuestionConditionalFromJson<V>(
        Map<String, dynamic> json) =>
    QuestionConditional<V>()
      ..condition =
          Expression.fromJson(json['condition'] as Map<String, dynamic>);

Map<String, dynamic> _$QuestionConditionalToJson<V>(
        QuestionConditional<V> instance) =>
    <String, dynamic>{
      'condition': instance.condition.toJson(),
    };
