// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) {
  return Contact()
    ..organization = json['organization'] as String
    ..researchers = json['researchers'] as String
    ..email = json['email'] as String
    ..website = json['website'] as String
    ..phone = json['phone'] as String;
}

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
      'organization': instance.organization,
      'researchers': instance.researchers,
      'email': instance.email,
      'website': instance.website,
      'phone': instance.phone,
    };
