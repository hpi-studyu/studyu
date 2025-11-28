import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'baseline_schedule_segment.g.dart';

@JsonSerializable()
class BaselineScheduleSegment extends StudyScheduleSegment {
  int duration;

  @override
  @JsonKey(includeFromJson: true, includeToJson: true)
  final StudyScheduleSegmentType type = StudyScheduleSegmentType.baseline;

  @override
  final String name = StudyScheduleSegmentType.baseline.string;

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
    return null;
  }

  BaselineScheduleSegment(this.duration);

  factory BaselineScheduleSegment.fromJson(Map<String, dynamic> json) =>
      _$BaselineScheduleSegmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BaselineScheduleSegmentToJson(this);
}
