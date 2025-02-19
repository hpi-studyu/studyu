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
      if (instance.startedAt?.toIso8601String() case final value?)
        'started_at': value,
      'selected_intervention_ids': instance.selectedInterventionIds,
      if (instance.inviteCode case final value?) 'invite_code': value,
      'is_deleted': instance.isDeleted,
    };
