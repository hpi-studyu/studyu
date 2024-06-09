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

Map<String, dynamic> _$FreeTextQuestionToJson(FreeTextQuestion instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('prompt', instance.prompt);
  writeNotNull('rationale', instance.rationale);
  writeNotNull('conditional', instance.conditional?.toJson());
  val['lengthRange'] = instance.lengthRange;
  val['textType'] = instance.textType.toJson();
  writeNotNull('customTypeExpression', instance.customTypeExpression);
  return val;
}

const _$FreeTextQuestionTypeEnumMap = {
  FreeTextQuestionType.any: 'any',
  FreeTextQuestionType.alphanumeric: 'alphanumeric',
  FreeTextQuestionType.numeric: 'numeric',
  FreeTextQuestionType.custom: 'custom',
};
