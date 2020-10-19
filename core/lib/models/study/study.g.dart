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
    ..studyDetails =
        StudyDetailsBase.fromJson(json['studyDetails'] as Map<String, dynamic>);
}

Map<String, dynamic> _$StudyBaseToJson(StudyBase instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'contact': instance.contact.toJson(),
      'iconName': instance.iconName,
      'published': instance.published,
      'studyDetails': instance.studyDetails.toJson(),
    };
