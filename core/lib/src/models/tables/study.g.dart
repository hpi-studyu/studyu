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
      ..status = $enumDecode(_$StudyStatusEnumMap, json['status'])
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
      if (instance.title case final value?) 'title': value,
      if (instance.description case final value?) 'description': value,
      'user_id': instance.userId,
      'participation': instance.participation.toJson(),
      'result_sharing': instance.resultSharing.toJson(),
      'contact': instance.contact.toJson(),
      'icon_name': instance.iconName,
      'published': instance.published,
      'status': instance.status.toJson(),
      'questionnaire': instance.questionnaire.toJson(),
      'eligibility_criteria':
          instance.eligibilityCriteria.map((e) => e.toJson()).toList(),
      'consent': instance.consent.map((e) => e.toJson()).toList(),
      'interventions': instance.interventions.map((e) => e.toJson()).toList(),
      'observations': instance.observations.map((e) => e.toJson()).toList(),
      'schedule': instance.schedule.toJson(),
      'report_specification': instance.reportSpecification.toJson(),
      'results': instance.results.map((e) => e.toJson()).toList(),
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

const _$StudyStatusEnumMap = {
  StudyStatus.draft: 'draft',
  StudyStatus.running: 'running',
  StudyStatus.closed: 'closed',
};
