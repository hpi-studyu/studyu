// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Body _$BodyFromJson(Map<String, dynamic> json) => Body(
      parts: (json['parts'] as List<dynamic>?)
              ?.map((e) => BodyPart.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BodyToJson(Body instance) => <String, dynamic>{
      'parts': instance.parts.map((e) => e.toJson()).toList(),
    };
