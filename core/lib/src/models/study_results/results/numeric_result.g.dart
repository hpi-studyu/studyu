// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'numeric_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NumericResult _$NumericResultFromJson(Map<String, dynamic> json) =>
    NumericResult()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..filename = json['filename'] as String
      ..resultProperty = DataReference<num>.fromJson(
          json['resultProperty'] as Map<String, dynamic>);

Map<String, dynamic> _$NumericResultToJson(NumericResult instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'filename': instance.filename,
      'resultProperty': instance.resultProperty,
    };
