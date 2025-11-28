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

  /// Optional list of intervention IDs or choice placeholders to alternate between.
  /// Can contain:
  /// - Intervention IDs (e.g., 'intervention_123')
  /// - Choice placeholders (e.g., 'choice_0' for participant's 1st selection)
  /// If null or empty, uses all available interventions.
  List<String>? interventionIds;

  /// If true and only 2 interventions, balance by reversing A/B for participants
  @JsonKey(defaultValue: false)
  bool balanceFirstIntervention;

  /// Ratio for first group when balancing (0.0 to 1.0). Default 0.5 means 50/50 split.
  /// Only used when balanceFirstIntervention is true and there are 2 interventions.
  /// Examples: 0.5 = 50/50, 0.6 = 60/40, 0.7 = 70/30
  @JsonKey(defaultValue: 0.5)
  double balanceRatio;

  AlternatingScheduleSegment(
    this.interventionDuration,
    this.cycleAmount, {
    this.interventionIds,
    this.balanceFirstIntervention = false,
    this.balanceRatio = 0.5,
  });

  @override
  int getDuration(List<Intervention> interventions) {
    final count = (interventionIds != null && interventionIds!.isNotEmpty)
        ? interventionIds!.length
        : interventions.length;
    return interventionDuration * cycleAmount * count;
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

    final useCustomIds = interventionIds != null && interventionIds!.isNotEmpty;
    final count = useCustomIds ? interventionIds!.length : interventions.length;
    // Maximum 2 interventions (A and B) can be used
    final clampedCount = count > 2 ? 2 : count;

    final indexInSequence = (day ~/ interventionDuration) % clampedCount;

    if (useCustomIds) {
      final idOrChoice = interventionIds![indexInSequence];

      // Check if it's a choice placeholder (e.g., 'choice_0')
      if (idOrChoice.startsWith('choice_')) {
        final choiceIndex = int.tryParse(idOrChoice.substring(7)) ?? 0;
        // Get participant's selected intervention at this choice index
        // Note: This requires participant selections to be stored in progress
        // For now, fallback to using the index directly
        if (choiceIndex < interventions.length) {
          return interventions[choiceIndex];
        }
      } else {
        // It's an intervention ID, find it in the list
        return interventions.firstWhere(
          (intervention) => intervention.id == idOrChoice,
          orElse: () => interventions.first,
        );
      }
    }

    // Fallback: use index-based access
    return interventions[indexInSequence % interventions.length];
  }

  factory AlternatingScheduleSegment.fromJson(Map<String, dynamic> json) =>
      _$AlternatingScheduleSegmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AlternatingScheduleSegmentToJson(this);
}
