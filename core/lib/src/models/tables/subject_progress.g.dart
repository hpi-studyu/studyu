// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectProgress _$SubjectProgressFromJson(Map<String, dynamic> json) {
  return SubjectProgress(
    subjectId: json['subjectId'] as String,
    interventionId: json['interventionId'] as String,
    taskId: json['taskId'] as String,
    resultType: json['resultType'] as String,
    result: Result.fromJson(json['result'] as Map<String, dynamic>),
  )
    ..id = json['id'] as String
    ..completedAt = json['completedAt'] == null
        ? null
        : DateTime.parse(json['completedAt'] as String);
}

Map<String, dynamic> _$SubjectProgressToJson(SubjectProgress instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('completedAt', instance.completedAt?.toIso8601String());
  val['subjectId'] = instance.subjectId;
  val['interventionId'] = instance.interventionId;
  val['taskId'] = instance.taskId;
  val['resultType'] = instance.resultType;
  val['result'] = instance.result.toJson();
  return val;
}
