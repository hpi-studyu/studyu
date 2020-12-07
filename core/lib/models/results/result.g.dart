// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result<T> _$ResultFromJson<T>(Map<String, dynamic> json) {
  return Result<T>()
    ..taskId = json['taskId'] as String
    // Keep .toString() until fixed: https://github.com/google/json_serializable.dart/issues/656
    ..timeStamp = DateTime.parse(json['timeStamp'].toString())
    ..type = json['type'] as String;
}

Map<String, dynamic> _$ResultToJson<T>(Result<T> instance) => <String, dynamic>{
      'taskId': instance.taskId,
      'timeStamp': instance.timeStamp.toIso8601String(),
      'type': instance.type,
    };
