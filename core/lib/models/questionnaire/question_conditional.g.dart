// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_conditional.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionConditional<V> _$QuestionConditionalFromJson<V>(
    Map<String, dynamic> json) {
  return QuestionConditional<V>()
    ..defaultValue =
        Answer.fromJson(json['defaultValue'] as Map<String, dynamic>)
    ..condition =
        Expression.fromJson(json['condition'] as Map<String, dynamic>);
}

Map<String, dynamic> _$QuestionConditionalToJson<V>(
        QuestionConditional<V> instance) =>
    <String, dynamic>{
      'defaultValue': instance.defaultValue.toJson(),
      'condition': instance.condition.toJson(),
    };
