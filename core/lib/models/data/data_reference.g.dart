// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataReference<T> _$DataReferenceFromJson<T>(Map<String, dynamic> json) {
  return DataReference<T>()
    ..observation = json['observation'] as String
    ..property = json['property'] as String;
}

Map<String, dynamic> _$DataReferenceToJson<T>(DataReference<T> instance) =>
    <String, dynamic>{
      'observation': instance.observation,
      'property': instance.property,
    };
