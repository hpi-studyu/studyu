// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyDetailsBase _$StudyDetailsBaseFromJson(Map<String, dynamic> json) {
  return StudyDetailsBase()
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
        json['reportSpecification'] as Map<String, dynamic>);
}

Map<String, dynamic> _$StudyDetailsBaseToJson(StudyDetailsBase instance) =>
    <String, dynamic>{
      'questionnaire': instance.questionnaire.toJson(),
      'eligibility': instance.eligibility.map((e) => e.toJson()).toList(),
      'consent': instance.consent.map((e) => e.toJson()).toList(),
      'interventionSet': instance.interventionSet.toJson(),
      'observations': instance.observations.map((e) => e.toJson()).toList(),
      'schedule': instance.schedule.toJson(),
      'reportSpecification': instance.reportSpecification.toJson(),
    };
