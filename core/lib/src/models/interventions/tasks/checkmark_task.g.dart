// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkmark_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckmarkTask _$CheckmarkTaskFromJson(Map<String, dynamic> json) {
  return CheckmarkTask()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..title = json['title'] as String?
    ..header = json['header'] as String?
    ..footer = json['footer'] as String?
    ..schedule = (json['schedule'] as List<dynamic>)
        .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$CheckmarkTaskToJson(CheckmarkTask instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  writeNotNull('header', instance.header);
  writeNotNull('footer', instance.footer);
  val['schedule'] = instance.schedule.map((e) => e.toJson()).toList();
  return val;
}
