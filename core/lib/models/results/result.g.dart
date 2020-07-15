// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result<T> _$ResultFromJson<T>(Map<String, dynamic> json) {
  return Result<T>()
    ..taskId = json['taskId'] as String
    ..timeStamp = DateTime.parse(json['timeStamp'] as String)
    ..type = json['type'] as String;
}

Map<String, dynamic> _$ResultToJson<T>(Result<T> instance) => <String, dynamic>{
      'taskId': instance.taskId,
      'timeStamp': instance.timeStamp.toIso8601String(),
      'type': instance.type,
    };
