// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Study _$StudyFromJson(Map<String, dynamic> json) => Study(
      json['id'] as String,
      json['user_id'] as String,
    )
      ..parentTemplateId = json['parent_template_id'] as String?
      ..templateConfiguration = json['template_configuration'] == null
          ? null
          : TemplateConfiguration.fromJson(
              json['template_configuration'] as Map<String, dynamic>)
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

Map<String, dynamic> _$StudyToJson(Study instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('parent_template_id', instance.parentTemplateId);
  writeNotNull(
      'template_configuration', instance.templateConfiguration?.toJson());
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  val['user_id'] = instance.userId;
  val['participation'] = instance.participation.toJson();
  val['result_sharing'] = instance.resultSharing.toJson();
  val['contact'] = instance.contact.toJson();
  val['icon_name'] = instance.iconName;
  val['published'] = instance.published;
  val['status'] = instance.status.toJson();
  val['questionnaire'] = instance.questionnaire.toJson();
  val['eligibility_criteria'] =
      instance.eligibilityCriteria.map((e) => e.toJson()).toList();
  val['consent'] = instance.consent.map((e) => e.toJson()).toList();
  val['interventions'] = instance.interventions.map((e) => e.toJson()).toList();
  val['observations'] = instance.observations.map((e) => e.toJson()).toList();
  val['schedule'] = instance.schedule.toJson();
  val['report_specification'] = instance.reportSpecification.toJson();
  val['results'] = instance.results.map((e) => e.toJson()).toList();
  val['collaborator_emails'] = instance.collaboratorEmails;
  val['registry_published'] = instance.registryPublished;
  return val;
}

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

Template _$TemplateFromJson(Map<String, dynamic> json) => Template(
      json['id'] as String,
      json['user_id'] as String,
    )
      ..parentTemplateId = json['parent_template_id'] as String?
      ..templateConfiguration = json['template_configuration'] == null
          ? null
          : TemplateConfiguration.fromJson(
              json['template_configuration'] as Map<String, dynamic>)
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

Map<String, dynamic> _$TemplateToJson(Template instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('parent_template_id', instance.parentTemplateId);
  writeNotNull(
      'template_configuration', instance.templateConfiguration?.toJson());
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  val['user_id'] = instance.userId;
  val['participation'] = instance.participation.toJson();
  val['result_sharing'] = instance.resultSharing.toJson();
  val['contact'] = instance.contact.toJson();
  val['icon_name'] = instance.iconName;
  val['published'] = instance.published;
  val['status'] = instance.status.toJson();
  val['questionnaire'] = instance.questionnaire.toJson();
  val['eligibility_criteria'] =
      instance.eligibilityCriteria.map((e) => e.toJson()).toList();
  val['consent'] = instance.consent.map((e) => e.toJson()).toList();
  val['interventions'] = instance.interventions.map((e) => e.toJson()).toList();
  val['observations'] = instance.observations.map((e) => e.toJson()).toList();
  val['schedule'] = instance.schedule.toJson();
  val['report_specification'] = instance.reportSpecification.toJson();
  val['results'] = instance.results.map((e) => e.toJson()).toList();
  val['collaborator_emails'] = instance.collaboratorEmails;
  val['registry_published'] = instance.registryPublished;
  return val;
}

TemplateSubStudy _$TemplateSubStudyFromJson(Map<String, dynamic> json) =>
    TemplateSubStudy(
      json['id'] as String,
      json['user_id'] as String,
    )
      ..parentTemplateId = json['parent_template_id'] as String?
      ..templateConfiguration = json['template_configuration'] == null
          ? null
          : TemplateConfiguration.fromJson(
              json['template_configuration'] as Map<String, dynamic>)
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

Map<String, dynamic> _$TemplateSubStudyToJson(TemplateSubStudy instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('parent_template_id', instance.parentTemplateId);
  writeNotNull(
      'template_configuration', instance.templateConfiguration?.toJson());
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  val['user_id'] = instance.userId;
  val['participation'] = instance.participation.toJson();
  val['result_sharing'] = instance.resultSharing.toJson();
  val['contact'] = instance.contact.toJson();
  val['icon_name'] = instance.iconName;
  val['published'] = instance.published;
  val['status'] = instance.status.toJson();
  val['questionnaire'] = instance.questionnaire.toJson();
  val['eligibility_criteria'] =
      instance.eligibilityCriteria.map((e) => e.toJson()).toList();
  val['consent'] = instance.consent.map((e) => e.toJson()).toList();
  val['interventions'] = instance.interventions.map((e) => e.toJson()).toList();
  val['observations'] = instance.observations.map((e) => e.toJson()).toList();
  val['schedule'] = instance.schedule.toJson();
  val['report_specification'] = instance.reportSpecification.toJson();
  val['results'] = instance.results.map((e) => e.toJson()).toList();
  val['collaborator_emails'] = instance.collaboratorEmails;
  val['registry_published'] = instance.registryPublished;
  return val;
}
