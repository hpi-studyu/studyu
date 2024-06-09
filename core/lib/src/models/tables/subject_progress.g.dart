// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectProgress _$SubjectProgressFromJson(Map<String, dynamic> json) =>
    SubjectProgress(
      subjectId: json['subject_id'] as String,
      interventionId: json['intervention_id'] as String,
      taskId: json['task_id'] as String,
      resultType: json['result_type'] as String,
      result: Result<dynamic>.fromJson(json['result'] as Map<String, dynamic>),
    )..completedAt = json['completed_at'] == null
        ? null
        : DateTime.parse(json['completed_at'] as String);

Map<String, dynamic> _$SubjectProgressToJson(SubjectProgress instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('completed_at', instance.completedAt?.toIso8601String());
  val['subject_id'] = instance.subjectId;
  val['intervention_id'] = instance.interventionId;
  val['task_id'] = instance.taskId;
  val['result_type'] = instance.resultType;
  val['result'] = instance.result.toJson();
  return val;
}
