import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'counter_balanced_schedule_segment.g.dart';

@JsonSerializable()
class CounterBalancedScheduleSegment extends StudyScheduleSegment {
  @override
  @JsonKey(includeFromJson: true, includeToJson: true)
  final StudyScheduleSegmentType type =
      StudyScheduleSegmentType.counterBalanced;

  @override
  final String name = StudyScheduleSegmentType.counterBalanced.string;

  int interventionDuration;
  int cycleAmount;

  CounterBalancedScheduleSegment(this.interventionDuration, this.cycleAmount);

  factory CounterBalancedScheduleSegment.fromJson(Map<String, dynamic> json) =>
      _$CounterBalancedScheduleSegmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CounterBalancedScheduleSegmentToJson(this);

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
    if (day < 0 || day >= getDuration(interventions)) {
      throw ArgumentError(
        "Day must be between 0 and [${getDuration(interventions) - 1}[0m",
      );
    }
    // Counterbalancing: rotate the order of interventions for each cycle
    final cycle = day ~/ (interventionDuration * interventions.length);
    final dayInCycle = day % (interventionDuration * interventions.length);
    final interventionIndex =
        (dayInCycle ~/ interventionDuration + cycle) % interventions.length;
    return interventions[interventionIndex];
  }
}
