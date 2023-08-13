// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataReference<T> _$DataReferenceFromJson<T>(Map<String, dynamic> json) =>
    DataReference<T>(
      json['task'] as String,
      json['property'] as String,
    );

Map<String, dynamic> _$DataReferenceToJson<T>(DataReference<T> instance) =>
    <String, dynamic>{
      'task': instance.task,
      'property': instance.property,
    };
