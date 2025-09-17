// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_pain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BodyPain _$BodyPainFromJson(Map<String, dynamic> json) => BodyPain(
  painLevel: (json['painLevel'] as num?)?.toInt() ?? 0,
  type: json['type'] == null
      ? null
      : PainType.fromJson(json['type'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BodyPainToJson(BodyPain instance) => <String, dynamic>{
  'painLevel': instance.painLevel,
  if (instance.type?.toJson() case final value?) 'type': value,
};
