// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Study _$StudyFromJson(Map<String, dynamic> json) => Study(
      json['id'] as String,
      json['user_id'] as String,
    )
      ..title = json['title'] as String?
      ..description = json['description'] as String?
      ..participation =
          $enumDecode(_$ParticipationEnumMap, json['participation'])
      ..resultSharing =
          $enumDecode(_$ResultSharingEnumMap, json['result_sharing'])
      ..contact = Study._contactFromJson(json['contact'])
      ..iconName = json['icon_name'] as String? ?? 'accountHeart'
      ..published = json['published'] as bool? ?? false
      ..questionnaire = Study._questionnaireFromJson(json['questionnaire'])
      ..eligibilityCriteria =
          Study._eligibilityCriteriaFromJson(json['eligibility_criteria'])
      ..consent = (json['consent'] as List<dynamic>?)
              ?.map((e) => ConsentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..interventions = (json['interventions'] as List<dynamic>?)
              ?.map((e) => Intervention.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..observations = (json['observations'] as List<dynamic>?)
              ?.map((e) => Observation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..schedule = Study._studyScheduleFromJson(json['schedule'])
      ..reportSpecification =
          Study._reportSpecificationFromJson(json['report_specification'])
      ..results = (json['results'] as List<dynamic>?)
              ?.map((e) => StudyResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..collaboratorEmails = (json['collaborator_emails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..registryPublished = json['registry_published'] as bool? ?? false;

Map<String, dynamic> _$StudyToJson(Study instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'user_id': instance.userId,
      'participation': instance.participation,
      'result_sharing': instance.resultSharing,
      'contact': instance.contact,
      'icon_name': instance.iconName,
      'published': instance.published,
      'questionnaire': instance.questionnaire,
      'eligibility_criteria': instance.eligibilityCriteria,
      'consent': instance.consent,
      'interventions': instance.interventions,
      'observations': instance.observations,
      'schedule': instance.schedule,
      'report_specification': instance.reportSpecification,
      'results': instance.results,
      'collaborator_emails': instance.collaboratorEmails,
      'registry_published': instance.registryPublished,
    };

const _$ParticipationEnumMap = {
  Participation.open: 'open',
  Participation.invite: 'invite',
};

const _$ResultSharingEnumMap = {
  ResultSharing.public: 'public',
  ResultSharing.private: 'private',
  ResultSharing.organization: 'organization',
};
