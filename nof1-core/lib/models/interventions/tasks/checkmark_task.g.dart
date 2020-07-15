// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkmark_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckmarkTask _$CheckmarkTaskFromJson(Map<String, dynamic> json) {
  return CheckmarkTask()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..schedule = (json['schedule'] as List)
        .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$CheckmarkTaskToJson(CheckmarkTask instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': instance.title,
      'schedule': instance.schedule.map((e) => e.toJson()).toList(),
    };
