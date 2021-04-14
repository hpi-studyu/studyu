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
    ..startDate = DateTime.parse(json['startDate'] as String)
    ..interventionSet = InterventionSet.fromJson(
        json['interventionSet'] as Map<String, dynamic>)
    ..interventionOrder = (json['interventionOrder'] as List<dynamic>)
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
  val['startDate'] = instance.startDate.toIso8601String();
  val['interventionSet'] = instance.interventionSet.toJson();
  val['interventionOrder'] = instance.interventionOrder;
  val['results'] = instance.results
      .map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList()));
  return val;
}
