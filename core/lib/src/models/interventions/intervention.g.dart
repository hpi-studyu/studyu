// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervention.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Intervention _$InterventionFromJson(Map<String, dynamic> json) => Intervention(
      json['id'] as String,
      json['name'] as String?,
    )
      ..description = json['description'] as String?
      ..icon = json['icon'] as String
      ..tasks = (json['tasks'] as List<dynamic>)
          .map((e) => InterventionTask.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$InterventionToJson(Intervention instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'tasks': instance.tasks,
    };
