import 'package:json_annotation/json_annotation.dart';

part 'template_configuration.g.dart';

@JsonSerializable()
class TemplateConfiguration {
  final bool lockPublisherInformation;
  final bool lockEnrollmentType;
  final bool lockStudySchedule;
  final bool lockStudySettings;

  /// The title of the parent template
  final String? title;

  /// The description of the parent template
  final String? description;

  TemplateConfiguration({
    this.lockPublisherInformation = false,
    this.lockEnrollmentType = false,
    this.lockStudySchedule = false,
    this.lockStudySettings = false,
    this.title,
    this.description,
  });

  TemplateConfiguration copyWith({
    bool? lockPublisherInformation,
    bool? lockEnrollmentType,
    bool? lockStudySchedule,
    bool? lockStudySettings,
    String? title,
    String? description,
  }) =>
      TemplateConfiguration(
        lockPublisherInformation:
            lockPublisherInformation ?? this.lockPublisherInformation,
        lockEnrollmentType: lockEnrollmentType ?? this.lockEnrollmentType,
        lockStudySchedule: lockStudySchedule ?? this.lockStudySchedule,
        lockStudySettings: lockStudySettings ?? this.lockStudySettings,
        title: title ?? this.title,
        description: description ?? this.description,
      );

  factory TemplateConfiguration.fromJson(Map<String, dynamic> json) =>
      _$TemplateConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateConfigurationToJson(this);
}
