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
    );

Map<String, dynamic> _$StudyInviteToJson(StudyInvite instance) =>
    <String, dynamic>{
      'code': instance.code,
      'study_id': instance.studyId,
      'preselected_intervention_ids': instance.preselectedInterventionIds,
    };
