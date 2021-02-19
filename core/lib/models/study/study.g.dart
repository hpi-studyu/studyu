// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyBase _$StudyBaseFromJson(Map<String, dynamic> json) {
  return StudyBase()
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..description = json['description'] as String
    ..contact = Contact.fromJson(json['contact'] as Map<String, dynamic>)
    ..iconName = json['iconName'] as String
    ..published = json['published'] as bool
    ..questionnaire = Questionnaire.fromJson(json['questionnaire'] as List)
    ..eligibility = (json['eligibility'] as List)
        .map((e) => EligibilityCriterion.fromJson(e as Map<String, dynamic>))
        .toList()
    ..consent = (json['consent'] as List)
        .map((e) => ConsentItem.fromJson(e as Map<String, dynamic>))
        .toList()
    ..interventionSet = InterventionSet.fromJson(
        json['interventionSet'] as Map<String, dynamic>)
    ..observations = (json['observations'] as List)
        .map((e) => Observation.fromJson(e as Map<String, dynamic>))
        .toList()
    ..schedule =
        StudySchedule.fromJson(json['schedule'] as Map<String, dynamic>)
    ..reportSpecification = ReportSpecification.fromJson(
        json['reportSpecification'] as Map<String, dynamic>)
    ..results = (json['results'] as List)
        .map((e) => StudyResult.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$StudyBaseToJson(StudyBase instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'contact': instance.contact.toJson(),
      'iconName': instance.iconName,
      'published': instance.published,
      'questionnaire': instance.questionnaire.toJson(),
      'eligibility': instance.eligibility.map((e) => e.toJson()).toList(),
      'consent': instance.consent.map((e) => e.toJson()).toList(),
      'interventionSet': instance.interventionSet.toJson(),
      'observations': instance.observations.map((e) => e.toJson()).toList(),
      'schedule': instance.schedule.toJson(),
      'reportSpecification': instance.reportSpecification.toJson(),
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
