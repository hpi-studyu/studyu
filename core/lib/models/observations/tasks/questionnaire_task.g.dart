// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionnaireTask _$QuestionnaireTaskFromJson(Map<String, dynamic> json) {
  return QuestionnaireTask()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..schedule = (json['schedule'] as List)
        .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
        .toList()
    ..questions = Questionnaire.fromJson(json['questions'] as List);
}

Map<String, dynamic> _$QuestionnaireTaskToJson(QuestionnaireTask instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': instance.title,
      'schedule': instance.schedule.map((e) => e.toJson()).toList(),
      'questions': instance.questions.toJson(),
    };
