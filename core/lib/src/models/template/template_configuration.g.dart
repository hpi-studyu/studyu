// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TemplateConfiguration _$TemplateConfigurationFromJson(
        Map<String, dynamic> json) =>
    TemplateConfiguration(
      lockPublisherInformation:
          json['lockPublisherInformation'] as bool? ?? false,
      lockEnrollmentType: json['lockEnrollmentType'] as bool? ?? false,
      lockStudySchedule: json['lockStudySchedule'] as bool? ?? false,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TemplateConfigurationToJson(
    TemplateConfiguration instance) {
  final val = <String, dynamic>{
    'lockPublisherInformation': instance.lockPublisherInformation,
    'lockEnrollmentType': instance.lockEnrollmentType,
    'lockStudySchedule': instance.lockStudySchedule,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  return val;
}
