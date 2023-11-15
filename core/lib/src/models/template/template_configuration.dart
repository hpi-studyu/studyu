import 'package:json_annotation/json_annotation.dart';

part 'template_configuration.g.dart';

@JsonSerializable()
class TemplateConfiguration {
  final bool lockPublisherInformation;
  final bool lockParticipation;
  final bool lockStudySchedule;

  TemplateConfiguration({
    this.lockPublisherInformation = false,
    this.lockParticipation = false,
    this.lockStudySchedule = false,
  });

  factory TemplateConfiguration.fromJson(Map<String, dynamic> json) =>
      _$TemplateConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateConfigurationToJson(this);
}
