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
          json['conditional'] as Map<String, dynamic>,
        );

Map<String, dynamic> _$PainQuestionToJson(PainQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'prompt': ?instance.prompt,
      'rationale': ?instance.rationale,
      'conditional': ?instance.conditional?.toJson(),
    };
