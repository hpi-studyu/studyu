// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionnaireTask _$QuestionnaireTaskFromJson(Map<String, dynamic> json) =>
    QuestionnaireTask()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..title = json['title'] as String?
      ..header = json['header'] as String?
      ..footer = json['footer'] as String?
      ..schedule = Schedule.fromJson(json['schedule'] as Map<String, dynamic>)
      ..questions =
          StudyUQuestionnaire.fromJson(json['questions'] as List<dynamic>);

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
  writeNotNull('header', instance.header);
  writeNotNull('footer', instance.footer);
  val['schedule'] = instance.schedule.toJson();
  val['questions'] = instance.questions.toJson();
  return val;
}
