// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return AppConfig(
    json['id'] as String,
    contact: Contact.fromJson(json['contact'] as Map<String, dynamic>),
    appPrivacy: Map<String, String>.from(json['app_privacy'] as Map),
    appTerms: Map<String, String>.from(json['app_terms'] as Map),
    designerPrivacy: Map<String, String>.from(json['designer_privacy'] as Map),
    designerTerms: Map<String, String>.from(json['designer_terms'] as Map),
    imprint: Map<String, String>.from(json['imprint'] as Map),
  );
}

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'id': instance.id,
      'contact': instance.contact.toJson(),
      'app_privacy': instance.appPrivacy,
      'app_terms': instance.appTerms,
      'designer_privacy': instance.designerPrivacy,
      'designer_terms': instance.designerTerms,
      'imprint': instance.imprint,
    };
