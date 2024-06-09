// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_text_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeTextQuestion _$FreeTextQuestionFromJson(Map<String, dynamic> json) =>
    FreeTextQuestion(
      textType: $enumDecode(_$FreeTextQuestionTypeEnumMap, json['textType']),
      lengthRange: (json['lengthRange'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      customTypeExpression: json['customTypeExpression'] as String?,
    )
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<String>.fromJson(
              json['conditional'] as Map<String, dynamic>);

Map<String, dynamic> _$FreeTextQuestionToJson(FreeTextQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'prompt': instance.prompt,
      'rationale': instance.rationale,
      'conditional': instance.conditional,
      'lengthRange': instance.lengthRange,
      'textType': instance.textType,
      'customTypeExpression': instance.customTypeExpression,
    };

const _$FreeTextQuestionTypeEnumMap = {
  FreeTextQuestionType.any: 'any',
  FreeTextQuestionType.alphanumeric: 'alphanumeric',
  FreeTextQuestionType.numeric: 'numeric',
  FreeTextQuestionType.custom: 'custom',
};
