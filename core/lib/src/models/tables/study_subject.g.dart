// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySubject _$StudySubjectFromJson(Map<String, dynamic> json) {
  return StudySubject(
    json['id'] as String,
    json['studyId'] as String,
    json['userId'] as String,
    (json['selectedInterventionIds'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
  )
    ..startedAt = json['startedAt'] == null
        ? null
        : DateTime.parse(json['startedAt'] as String)
    ..inviteCode = json['inviteCode'] as String?;
}

Map<String, dynamic> _$StudySubjectToJson(StudySubject instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'studyId': instance.studyId,
    'userId': instance.userId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('startedAt', instance.startedAt?.toIso8601String());
  val['selectedInterventionIds'] = instance.selectedInterventionIds;
  writeNotNull('inviteCode', instance.inviteCode);
  return val;
}
