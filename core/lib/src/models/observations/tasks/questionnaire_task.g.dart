// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionnaireTask _$QuestionnaireTaskFromJson(Map<String, dynamic> json) {
  return QuestionnaireTask()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..title = json['title'] as String?
    ..schedule = (json['schedule'] as List<dynamic>)
        .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
        .toList()
    ..questions = Questionnaire.fromJson(json['questions'] as List<dynamic>);
}

Map<String, dynamic> _$QuestionnaireTaskToJson(QuestionnaireTask instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  val['schedule'] = instance.schedule.map((e) => e.toJson()).toList();
  val['questions'] = instance.questions.toJson();
  return val;
}
