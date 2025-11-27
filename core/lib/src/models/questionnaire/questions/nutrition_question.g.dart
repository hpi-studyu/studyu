// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionQuestion _$NutritionQuestionFromJson(Map<String, dynamic> json) =>
    NutritionQuestion()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<DailyRecall>.fromJson(
              json['conditional'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$NutritionQuestionToJson(NutritionQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'prompt': ?instance.prompt,
      'rationale': ?instance.rationale,
      'conditional': ?instance.conditional?.toJson(),
    };
