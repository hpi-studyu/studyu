import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'single_intervention_schedule_segment.g.dart';

@JsonSerializable()
class SingleInterventionScheduleSegment extends StudyScheduleSegment {
  @override
  @JsonKey(includeFromJson: true, includeToJson: true)
  final StudyScheduleSegmentType type =
      StudyScheduleSegmentType.singleIntervention;

  @override
  final String name = StudyScheduleSegmentType.singleIntervention.string;

  String? interventionId;
  int duration;

  SingleInterventionScheduleSegment(this.interventionId, this.duration);

  @override
  int getDuration(List<Intervention> interventions) {
    return duration;
  }

  @override
  Intervention? getInterventionOnDay(
    int day,
    List<Intervention> interventions,
    List<SubjectProgress> progress,
  ) {
    if (day < 0 || day > getDuration(interventions)) {
      throw ArgumentError(
        "Day must be between 0 and ${getDuration(interventions)}",
      );
    }
    return interventions.firstWhere((element) => element.id == interventionId);
  }

  factory SingleInterventionScheduleSegment.fromJson(
    Map<String, dynamic> json,
  ) => _$SingleInterventionScheduleSegmentFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$SingleInterventionScheduleSegmentToJson(this);
}
