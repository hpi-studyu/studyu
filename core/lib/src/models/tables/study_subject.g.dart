// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySubject _$StudySubjectFromJson(Map<String, dynamic> json) => StudySubject(
      json['id'] as String,
      json['study_id'] as String,
      json['user_id'] as String,
      (json['selected_intervention_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    )
      ..startedAt = json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String)
      ..inviteCode = json['invite_code'] as String?
      ..isDeleted = json['is_deleted'] as bool;

Map<String, dynamic> _$StudySubjectToJson(StudySubject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'study_id': instance.studyId,
      'user_id': instance.userId,
      'started_at': instance.startedAt?.toIso8601String(),
      'selected_intervention_ids': instance.selectedInterventionIds,
      'invite_code': instance.inviteCode,
      'is_deleted': instance.isDeleted,
    };
