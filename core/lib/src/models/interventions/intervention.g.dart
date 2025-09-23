// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervention.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Intervention _$InterventionFromJson(Map<String, dynamic> json) =>
    Intervention(json['id'] as String, json['name'] as String?)
      ..description = json['description'] as String?
      ..icon = json['icon'] as String
      ..tasks = (json['tasks'] as List<dynamic>)
          .map((e) => InterventionTask.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$InterventionToJson(Intervention instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.name case final value?) 'name': value,
      if (instance.description case final value?) 'description': value,
      'icon': instance.icon,
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
    };
