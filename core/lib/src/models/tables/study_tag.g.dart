// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyTag _$StudyTagFromJson(Map<String, dynamic> json) => StudyTag(
      json['id'] as String,
      json['name'] as String,
      json['color'] as String,
      parentId: json['parent_id'] as String?,
    );

Map<String, dynamic> _$StudyTagToJson(StudyTag instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'color': instance.color,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('parent_id', instance.parentId);
  return val;
}
