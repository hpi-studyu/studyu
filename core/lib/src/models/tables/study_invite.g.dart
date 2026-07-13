// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyInvite _$StudyInviteFromJson(Map<String, dynamic> json) => StudyInvite(
  json['code'] as String,
  json['study_id'] as String,
  preselectedInterventionIds:
      (json['preselected_intervention_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$StudyInviteToJson(StudyInvite instance) =>
    <String, dynamic>{
      'code': instance.code,
      'study_id': instance.studyId,
      'preselected_intervention_ids': ?instance.preselectedInterventionIds,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'updated_at': ?instance.updatedAt?.toIso8601String(),
    };
