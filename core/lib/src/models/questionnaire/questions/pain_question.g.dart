// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pain_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PainQuestion _$PainQuestionFromJson(Map<String, dynamic> json) => PainQuestion()
  ..type = json['type'] as String
  ..id = json['id'] as String
  ..prompt = json['prompt'] as String?
  ..rationale = json['rationale'] as String?
  ..conditional = json['conditional'] == null
      ? null
      : QuestionConditional<List<BodyPart>>.fromJson(
          json['conditional'] as Map<String, dynamic>);

Map<String, dynamic> _$PainQuestionToJson(PainQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      if (instance.prompt case final value?) 'prompt': value,
      if (instance.rationale case final value?) 'rationale': value,
      if (instance.conditional?.toJson() case final value?)
        'conditional': value,
    };
