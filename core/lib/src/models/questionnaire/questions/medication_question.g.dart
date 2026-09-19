// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationQuestion _$MedicationQuestionFromJson(Map<String, dynamic> json) =>
    MedicationQuestion()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<MedicationAnswer>.fromJson(
              json['conditional'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$MedicationQuestionToJson(MedicationQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'prompt': ?instance.prompt,
      'rationale': ?instance.rationale,
      'conditional': ?instance.conditional?.toJson(),
    };
