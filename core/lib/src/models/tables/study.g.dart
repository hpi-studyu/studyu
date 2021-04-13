// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Study _$StudyFromJson(Map<String, dynamic> json) {
  return Study(
    json['id'] as String?,
  )
    ..title = json['title'] as String?
    ..description = json['description'] as String?
    ..contact = Contact.fromJson(json['contact'] as Map<String, dynamic>)
    ..iconName = json['iconName'] as String
    ..published = json['published'] as bool
    ..questionnaire =
        Questionnaire.fromJson(json['questionnaire'] as List<dynamic>)
    ..eligibilityCriteria = (json['eligibilityCriteria'] as List<dynamic>)
        .map((e) => EligibilityCriterion.fromJson(e as Map<String, dynamic>))
        .toList()
    ..consent = (json['consent'] as List<dynamic>)
        .map((e) => ConsentItem.fromJson(e as Map<String, dynamic>))
        .toList()
    ..interventionSet = InterventionSet.fromJson(
        json['interventionSet'] as Map<String, dynamic>)
    ..observations = (json['observations'] as List<dynamic>)
        .map((e) => Observation.fromJson(e as Map<String, dynamic>))
        .toList()
    ..schedule =
        StudySchedule.fromJson(json['schedule'] as Map<String, dynamic>)
    ..reportSpecification = ReportSpecification.fromJson(
        json['reportSpecification'] as Map<String, dynamic>)
    ..results = (json['results'] as List<dynamic>)
        .map((e) => StudyResult.fromJson(e as Map<String, dynamic>))
        .toList()
    ..fhirQuestionnaire = json['fhirQuestionnaire'] == null
        ? null
        : fhir.Questionnaire.fromJson(
            json['fhirQuestionnaire'] as Map<String, dynamic>);
}

Map<String, dynamic> _$StudyToJson(Study instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  val['contact'] = instance.contact.toJson();
  val['iconName'] = instance.iconName;
  val['published'] = instance.published;
  val['questionnaire'] = instance.questionnaire.toJson();
  val['eligibilityCriteria'] =
      instance.eligibilityCriteria.map((e) => e.toJson()).toList();
  val['consent'] = instance.consent.map((e) => e.toJson()).toList();
  val['interventionSet'] = instance.interventionSet.toJson();
  val['observations'] = instance.observations.map((e) => e.toJson()).toList();
  val['schedule'] = instance.schedule.toJson();
  val['reportSpecification'] = instance.reportSpecification.toJson();
  val['results'] = instance.results.map((e) => e.toJson()).toList();
  writeNotNull('fhirQuestionnaire', instance.fhirQuestionnaire?.toJson());
  return val;
}
