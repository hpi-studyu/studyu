// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkmark_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckmarkTask _$CheckmarkTaskFromJson(Map<String, dynamic> json) =>
    CheckmarkTask()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..title = json['title'] as String?
      ..header = json['header'] as String?
      ..footer = json['footer'] as String?
      ..schedule = Schedule.fromJson(json['schedule'] as Map<String, dynamic>);

Map<String, dynamic> _$CheckmarkTaskToJson(CheckmarkTask instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      if (instance.title case final value?) 'title': value,
      if (instance.header case final value?) 'header': value,
      if (instance.footer case final value?) 'footer': value,
      'schedule': instance.schedule.toJson(),
    };
