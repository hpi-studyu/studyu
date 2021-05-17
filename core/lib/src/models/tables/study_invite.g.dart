// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyInvite _$StudyInviteFromJson(Map<String, dynamic> json) {
  return StudyInvite(
    json['code'] as String,
    json['studyId'] as String,
    preselectedInterventionIds:
        (json['preselectedInterventionIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
  );
}

Map<String, dynamic> _$StudyInviteToJson(StudyInvite instance) {
  final val = <String, dynamic>{
    'code': instance.code,
    'studyId': instance.studyId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'preselectedInterventionIds', instance.preselectedInterventionIds);
  return val;
}
