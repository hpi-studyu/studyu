// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_capturing_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageCapturingTask _$ImageCapturingTaskFromJson(Map<String, dynamic> json) =>
    ImageCapturingTask()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..title = json['title'] as String?
      ..header = json['header'] as String?
      ..footer = json['footer'] as String?
      ..schedule = Schedule.fromJson(json['schedule'] as Map<String, dynamic>);

Map<String, dynamic> _$ImageCapturingTaskToJson(ImageCapturingTask instance) {
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
  val['schedule'] = instance.schedule.toJson();
  return val;
}
