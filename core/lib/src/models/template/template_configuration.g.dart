// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TemplateConfiguration _$TemplateConfigurationFromJson(
        Map<String, dynamic> json) =>
    TemplateConfiguration(
      lockPublisherInformation: json['locked_contact'] as bool? ?? false,
      lockEnrollmentType: json['locked_participation'] as bool? ?? false,
      lockStudySchedule: json['locked_schedule'] as bool? ?? false,
      lockStudySettings: json['locked_registry'] as bool? ?? false,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TemplateConfigurationToJson(
    TemplateConfiguration instance) {
  final val = <String, dynamic>{
    'locked_contact': instance.lockPublisherInformation,
    'locked_participation': instance.lockEnrollmentType,
    'locked_schedule': instance.lockStudySchedule,
    'locked_registry': instance.lockStudySettings,
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
