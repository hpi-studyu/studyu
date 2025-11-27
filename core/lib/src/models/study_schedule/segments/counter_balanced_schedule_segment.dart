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

  /// Optional list of intervention IDs or choice placeholders to counter-balance between.
  /// Can contain:
  /// - Intervention IDs (e.g., 'intervention_123')
  /// - Choice placeholders (e.g., 'choice_0' for participant's 1st selection)
  /// If null or empty, uses all available interventions.
  List<String>? interventionIds;

  CounterBalancedScheduleSegment(
    this.interventionDuration,
    this.cycleAmount, {
    this.interventionIds,
  });

  factory CounterBalancedScheduleSegment.fromJson(Map<String, dynamic> json) =>
      _$CounterBalancedScheduleSegmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CounterBalancedScheduleSegmentToJson(this);

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
    if (day < 0 || day >= getDuration(interventions)) {
      throw ArgumentError(
        "Day must be between 0 and [${getDuration(interventions) - 1}]",
      );
    }

    final useIndices = interventionIds != null && interventionIds!.isNotEmpty;
    final count = useIndices ? interventionIds!.length : interventions.length;
    // Maximum 2 interventions (A and B) can be used
    final clampedCount = count > 2 ? 2 : count;

    // Counterbalancing: rotate the order of interventions for each cycle
    final cycle = day ~/ (interventionDuration * clampedCount);
    final dayInCycle = day % (interventionDuration * clampedCount);
    final indexInSequence =
        (dayInCycle ~/ interventionDuration + cycle) % clampedCount;

    if (useIndices) {
      final idOrChoice = interventionIds![indexInSequence];

      // Check if it's a choice placeholder (e.g., 'choice_0')
      if (idOrChoice.startsWith('choice_')) {
        final choiceIndex = int.tryParse(idOrChoice.substring(7)) ?? 0;
        // Get participant's selected intervention at this choice index
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
}
