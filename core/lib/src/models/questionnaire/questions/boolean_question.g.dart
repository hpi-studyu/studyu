// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boolean_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BooleanQuestion _$BooleanQuestionFromJson(Map<String, dynamic> json) =>
    BooleanQuestion()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<bool>.fromJson(
              json['conditional'] as Map<String, dynamic>);

Map<String, dynamic> _$BooleanQuestionToJson(BooleanQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'prompt': instance.prompt,
      'rationale': instance.rationale,
      'conditional': instance.conditional,
    };
