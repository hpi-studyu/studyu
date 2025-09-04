// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_part.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BodyPart _$BodyPartFromJson(Map<String, dynamic> json) => BodyPart(
  id: json['id'] as String,
  name: json['name'] as String,
  pain: json['pain'] == null
      ? const BodyPain()
      : BodyPain.fromJson(json['pain'] as Map<String, dynamic>),
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => BodyPart.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BodyPartToJson(BodyPart instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'pain': instance.pain.toJson(),
  'children': instance.children.map((e) => e.toJson()).toList(),
};
