// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_study.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStudy _$UserStudyFromJson(Map<String, dynamic> json) {
  return UserStudy()
    ..id = json['id'] as String?
    ..studyId = json['studyId'] as String
    ..userId = json['userId'] as String
    ..title = json['title'] as String
    ..contact = Contact.fromJson(json['contact'] as Map<String, dynamic>)
    ..description = json['description'] as String
    ..iconName = json['iconName'] as String
    ..startDate = DateTime.parse(json['startDate'] as String)
    ..schedule =
        StudySchedule.fromJson(json['schedule'] as Map<String, dynamic>)
    ..interventionOrder = (json['interventionOrder'] as List<dynamic>)
        .map((e) => e as String)
        .toList()
    ..interventionSet = InterventionSet.fromJson(
        json['interventionSet'] as Map<String, dynamic>)
    ..observations = (json['observations'] as List<dynamic>)
        .map((e) => Observation.fromJson(e as Map<String, dynamic>))
        .toList()
    ..consent = (json['consent'] as List<dynamic>)
        .map((e) => ConsentItem.fromJson(e as Map<String, dynamic>))
        .toList()
    ..results = (json['results'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => Result.fromJson(e as Map<String, dynamic>))
              .toList()),
    )
    ..reportSpecification = ReportSpecification.fromJson(
        json['reportSpecification'] as Map<String, dynamic>)
    ..fhirQuestionnaire = json['fhirQuestionnaire'] == null
        ? null
        : fhir.Questionnaire.fromJson(
            json['fhirQuestionnaire'] as Map<String, dynamic>);
}

Map<String, dynamic> _$UserStudyToJson(UserStudy instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['studyId'] = instance.studyId;
  val['userId'] = instance.userId;
  val['title'] = instance.title;
  val['contact'] = instance.contact.toJson();
  val['description'] = instance.description;
  val['iconName'] = instance.iconName;
  val['startDate'] = instance.startDate.toIso8601String();
  val['schedule'] = instance.schedule.toJson();
  val['interventionOrder'] = instance.interventionOrder;
  val['interventionSet'] = instance.interventionSet.toJson();
  val['observations'] = instance.observations.map((e) => e.toJson()).toList();
  val['consent'] = instance.consent.map((e) => e.toJson()).toList();
  val['results'] = instance.results
      .map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList()));
  val['reportSpecification'] = instance.reportSpecification.toJson();
  writeNotNull('fhirQuestionnaire', instance.fhirQuestionnaire?.toJson());
  return val;
}
