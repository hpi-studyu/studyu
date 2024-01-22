// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:studyu_designer_v2/features/design/interventions/schedule_creator/model/intervention.dart';

class StudySchedule {
  List<Intervention> interventions = [];
  List<StudyScheduleSegment> segments = [];

  StudySchedule(this.interventions);

  int get duration => segments.isEmpty
      ? 0
      : segments
          .map((e) => e.getDuration(interventions))
          .reduce((a, b) => a + b);

  /// Returns the segment for the given day and the nth day of the segment
  (StudyScheduleSegment?, int) getSegmentForDay(int day) {
    if (day > duration || day < 0)
      throw ArgumentError("Day must be between 0 and $duration");

    int remainingDays = day;

    for (final segment in segments) {
      final int segmentDuration = segment.getDuration(interventions);
      if (segmentDuration > remainingDays) {
        return (segment, remainingDays);
      } else {
        remainingDays -= segmentDuration;
      }
    }

    throw StateError("This should never happen");
  }

  Intervention? getInterventionForDay(int day) {
    final (segment, dayInSegment) = getSegmentForDay(day);
    return segment?.getIntervetionOnDay(dayInSegment, interventions);
  }
}

abstract class StudyScheduleSegment {
  int getDuration(List<Intervention> interventions);

  Intervention? getIntervetionOnDay(int day, List<Intervention> interventions);

  String get type =>
      throw UnimplementedError("Subclasses should return String type");
}

class Baseline extends StudyScheduleSegment {
  int duration;

  @override
  final String type = "baseline";

  @override
  int getDuration(List<Intervention> interventions) {
    return duration;
  }

  @override
  Intervention? getIntervetionOnDay(int day, List<Intervention> interventions) {
    return null;
  }

  Baseline(this.duration);
}

class Alternating extends StudyScheduleSegment {
  @override
  final String type = "alterating";

  int interventionDuration;
  int cycleAmount;

  Alternating(this.interventionDuration, this.cycleAmount);

  @override
  int getDuration(List<Intervention> interventions) {
    return interventionDuration * cycleAmount * interventions.length;
  }

  @override
  Intervention? getIntervetionOnDay(int day, List<Intervention> interventions) {
    if (day < 0 || day > getDuration(interventions)) {
      throw ArgumentError(
          "Day must be between 0 and ${getDuration(interventions)}");
    }
    final interventionIndex = day % interventions.length;
    return interventions[interventionIndex];
  }
}
