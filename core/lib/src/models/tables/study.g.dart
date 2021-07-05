// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Study _$StudyFromJson(Map<String, dynamic> json) {
  return Study(
    json['id'] as String,
    json['user_id'] as String,
  )
    ..title = json['title'] as String?
    ..description = json['description'] as String?
    ..participation =
        _$enumDecode(_$ParticipationEnumMap, json['participation'])
    ..resultSharing =
        _$enumDecode(_$ResultSharingEnumMap, json['result_sharing'])
    ..contact = Contact.fromJson(json['contact'] as Map<String, dynamic>)
    ..iconName = json['icon_name'] as String
    ..published = json['published'] as bool
    ..questionnaire =
        StudyUQuestionnaire.fromJson(json['questionnaire'] as List<dynamic>)
    ..eligibilityCriteria = (json['eligibility_criteria'] as List<dynamic>)
        .map((e) => EligibilityCriterion.fromJson(e as Map<String, dynamic>))
        .toList()
    ..consent = (json['consent'] as List<dynamic>)
        .map((e) => ConsentItem.fromJson(e as Map<String, dynamic>))
        .toList()
    ..interventions = (json['interventions'] as List<dynamic>)
        .map((e) => Intervention.fromJson(e as Map<String, dynamic>))
        .toList()
    ..observations = (json['observations'] as List<dynamic>)
        .map((e) => Observation.fromJson(e as Map<String, dynamic>))
        .toList()
    ..schedule =
        StudySchedule.fromJson(json['schedule'] as Map<String, dynamic>)
    ..reportSpecification = ReportSpecification.fromJson(
        json['report_specification'] as Map<String, dynamic>)
    ..results = (json['results'] as List<dynamic>)
        .map((e) => StudyResult.fromJson(e as Map<String, dynamic>))
        .toList()
    ..collaboratorEmails = (json['collaborator_emails'] as List<dynamic>)
        .map((e) => e as String)
        .toList()
    ..fhirQuestionnaire = json['fhir_questionnaire'] == null
        ? null
        : Questionnaire.fromJson(
            json['fhir_questionnaire'] as Map<String, dynamic>);
}

Map<String, dynamic> _$StudyToJson(Study instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  val['user_id'] = instance.userId;
  val['participation'] = _$ParticipationEnumMap[instance.participation];
  val['result_sharing'] = _$ResultSharingEnumMap[instance.resultSharing];
  val['contact'] = instance.contact.toJson();
  val['icon_name'] = instance.iconName;
  val['published'] = instance.published;
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
  writeNotNull('fhir_questionnaire', instance.fhirQuestionnaire?.toJson());
  return val;
}

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
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
