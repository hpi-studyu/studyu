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
      lockParticipation: json['lockParticipation'] as bool? ?? false,
      lockStudySchedule: json['lockStudySchedule'] as bool? ?? false,
    );

Map<String, dynamic> _$TemplateConfigurationToJson(
        TemplateConfiguration instance) =>
    <String, dynamic>{
      'lockPublisherInformation': instance.lockPublisherInformation,
      'lockParticipation': instance.lockParticipation,
      'lockStudySchedule': instance.lockStudySchedule,
    };
