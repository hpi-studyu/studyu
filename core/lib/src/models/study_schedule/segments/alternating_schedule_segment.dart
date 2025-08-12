import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'alternating_schedule_segment.g.dart';

@JsonSerializable()
class AlternatingScheduleSegment extends StudyScheduleSegment {
  @override
  @JsonKey(includeFromJson: true, includeToJson: true)
  final StudyScheduleSegmentType type = StudyScheduleSegmentType.alternating;

  @override
  final String name = StudyScheduleSegmentType.alternating.string;

  int interventionDuration;
  int cycleAmount;

  AlternatingScheduleSegment(this.interventionDuration, this.cycleAmount);

  @override
  int getDuration(List<Intervention> interventions) {
    return interventionDuration * cycleAmount * interventions.length;
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

    final interventionIndex =
        (day ~/ interventionDuration) % interventions.length;
    return interventions[interventionIndex];
  }

  factory AlternatingScheduleSegment.fromJson(Map<String, dynamic> json) =>
      _$AlternatingScheduleSegmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AlternatingScheduleSegmentToJson(this);
}
