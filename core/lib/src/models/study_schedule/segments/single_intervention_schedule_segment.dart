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
  String get name {
    // Display as "Intervention A", "Intervention B", etc.
    if (interventionIndex >= 0 && interventionIndex < 26) {
      return 'Intervention ${String.fromCharCode(65 + interventionIndex)}';
    }
    return 'Intervention ${interventionIndex + 1}';
  }

  /// Index of the intervention (0 = A, 1 = B, 2 = C, etc.)
  /// This refers to the participant's selected interventions, not specific IDs
  int interventionIndex;
  int duration;

  SingleInterventionScheduleSegment(this.interventionIndex, this.duration);

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
    // Use the index to get the intervention from the participant's selected list
    if (interventionIndex < 0 || interventionIndex >= interventions.length) {
      throw ArgumentError(
        "Intervention index $interventionIndex is out of bounds for ${interventions.length} interventions",
      );
    }
    return interventions[interventionIndex];
  }

  factory SingleInterventionScheduleSegment.fromJson(
    Map<String, dynamic> json,
  ) => _$SingleInterventionScheduleSegmentFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$SingleInterventionScheduleSegmentToJson(this);
}
