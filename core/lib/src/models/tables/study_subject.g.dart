// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySubject _$StudySubjectFromJson(Map<String, dynamic> json) {
  return StudySubject()
    ..id = json['id'] as String?
    ..studyId = json['studyId'] as String
    ..userId = json['userId'] as String
    ..startedAt = json['startedAt'] == null
        ? null
        : DateTime.parse(json['startedAt'] as String)
    ..selectedInterventionIds =
        (json['selectedInterventionIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList()
    ..results = (json['results'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => Result.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
}

Map<String, dynamic> _$StudySubjectToJson(StudySubject instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['studyId'] = instance.studyId;
  val['userId'] = instance.userId;
  writeNotNull('startedAt', instance.startedAt?.toIso8601String());
  val['selectedInterventionIds'] = instance.selectedInterventionIds;
  val['results'] = instance.results
      .map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList()));
  return val;
}
