// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyInvite _$StudyInviteFromJson(Map<String, dynamic> json) {
  return StudyInvite(
    json['code'] as String,
    json['studyId'] as String,
  );
}

Map<String, dynamic> _$StudyInviteToJson(StudyInvite instance) =>
    <String, dynamic>{
      'code': instance.code,
      'studyId': instance.studyId,
    };
