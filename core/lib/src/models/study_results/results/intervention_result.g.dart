// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervention_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterventionResult _$InterventionResultFromJson(Map<String, dynamic> json) =>
    InterventionResult()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..filename = json['filename'] as String;

Map<String, dynamic> _$InterventionResultToJson(InterventionResult instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'filename': instance.filename,
    };
