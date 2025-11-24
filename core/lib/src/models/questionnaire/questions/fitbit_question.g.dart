// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FitbitQuestion _$FitbitQuestionFromJson(Map<String, dynamic> json) =>
    FitbitQuestion(
        types: (json['types'] as List<dynamic>)
            .map((e) => $enumDecode(_$FitbitQuestionTypeEnumMap, e))
            .toList(),
      )
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<FitbitQuestion>.fromJson(
              json['conditional'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$FitbitQuestionToJson(FitbitQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'prompt': ?instance.prompt,
      'rationale': ?instance.rationale,
      'conditional': ?instance.conditional?.toJson(),
      'types': instance.types.map((e) => e.toJson()).toList(),
    };

const _$FitbitQuestionTypeEnumMap = {
  FitbitQuestionType.heartrate: 'heartrate',
  FitbitQuestionType.sleep: 'sleep',
  FitbitQuestionType.steps: 'steps',
};
