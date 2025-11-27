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

  /// Optional list of intervention indices to alternate between.
  /// If null or empty, uses all available interventions.
  /// If provided, only alternates between these specific indices.
  List<int>? interventionIds;

  AlternatingScheduleSegment(
    this.interventionDuration,
    this.cycleAmount, {
    this.interventionIds,
  });

  @override
  int getDuration(List<Intervention> interventions) {
    final count = (interventionIds != null && interventionIds!.isNotEmpty)
        ? interventionIds!.length
        : interventions.length;
    // Maximum 2 interventions (A and B) can be used
    final clampedCount = count > 2 ? 2 : count;
    return interventionDuration * cycleAmount * clampedCount;
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

    final useIndices = interventionIds != null && interventionIds!.isNotEmpty;
    final count = useIndices ? interventionIds!.length : interventions.length;
    // Maximum 2 interventions (A and B) can be used
    final clampedCount = count > 2 ? 2 : count;

    final indexInSequence = (day ~/ interventionDuration) % clampedCount;
    final actualIndex = useIndices
        ? interventionIds![indexInSequence]
        : indexInSequence;

    return interventions[actualIndex];
  }

  factory AlternatingScheduleSegment.fromJson(Map<String, dynamic> json) =>
      _$AlternatingScheduleSegmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AlternatingScheduleSegmentToJson(this);
}
