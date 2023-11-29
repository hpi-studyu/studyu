import 'package:json_annotation/json_annotation.dart';

part 'template_configuration.g.dart';

@JsonSerializable()
class TemplateConfiguration {
  final bool lockPublisherInformation;
  final bool lockEnrollmentType;
  final bool lockStudySchedule;

  TemplateConfiguration({
    this.lockPublisherInformation = false,
    this.lockEnrollmentType = false,
    this.lockStudySchedule = false,
  });

  TemplateConfiguration copyWith({
    bool? lockPublisherInformation,
    bool? lockEnrollmentType,
    bool? lockStudySchedule,
  }) =>
      TemplateConfiguration(
        lockPublisherInformation: lockPublisherInformation ?? this.lockPublisherInformation,
        lockEnrollmentType: lockEnrollmentType ?? this.lockEnrollmentType,
        lockStudySchedule: lockStudySchedule ?? this.lockStudySchedule,
      );

  factory TemplateConfiguration.fromJson(Map<String, dynamic> json) => _$TemplateConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateConfigurationToJson(this);
}
