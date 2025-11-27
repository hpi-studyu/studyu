import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'adaptive_study_schedule.g.dart';

@JsonSerializable()
class AdaptiveStudySchedule {
  @StudyScheduleSegmentConverter()
  List<StudyScheduleSegment> segments = [];

  /// Number of interventions participants should select
  /// If null or 0, all interventions must be selected
  @JsonKey(defaultValue: 2)
  int numberOfInterventionsToSelect = 2;

  AdaptiveStudySchedule();

  AdaptiveStudySchedule.withSegments(
    this.segments, {
    this.numberOfInterventionsToSelect = 2,
  });

  factory AdaptiveStudySchedule.fromJson(Map<String, dynamic> json) =>
      _$AdaptiveStudyScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$AdaptiveStudyScheduleToJson(this);
}

abstract class StudyScheduleSegment {
  String get name =>
      throw UnimplementedError("Subclasses should return String name");

  int getDuration(List<Intervention> interventions);

  Intervention? getInterventionOnDay(
    int day,
    List<Intervention> interventions,
    List<SubjectProgress> progress,
  );

  StudyScheduleSegmentType get type =>
      throw UnimplementedError("Subclasses should return String type");

  Map<String, dynamic> toJson();
}

class StudyScheduleSegmentConverter
    implements JsonConverter<StudyScheduleSegment, Map<String, dynamic>> {
  const StudyScheduleSegmentConverter();

  @override
  StudyScheduleSegment fromJson(Map<String, dynamic> json) {
    final type = StudyScheduleSegmentType.fromJson(json['type'] as String);
    switch (type) {
      case StudyScheduleSegmentType.baseline:
        return BaselineScheduleSegment.fromJson(json);
      case StudyScheduleSegmentType.alternating:
        return AlternatingScheduleSegment.fromJson(json);
      case StudyScheduleSegmentType.counterBalanced:
        return CounterBalancedScheduleSegment.fromJson(json);
      case StudyScheduleSegmentType.thompsonSampling:
        return ThompsonSamplingScheduleSegment.fromJson(json);
      case StudyScheduleSegmentType.singleIntervention:
        return SingleInterventionScheduleSegment.fromJson(json);
    }
  }

  @override
  Map<String, dynamic> toJson(StudyScheduleSegment segment) => segment.toJson();
}

enum StudyScheduleSegmentType {
  baseline,
  alternating,
  counterBalanced,
  thompsonSampling,
  singleIntervention;

  String toJson() => name;

  static StudyScheduleSegmentType fromJson(String json) => values.byName(json);

  // todo localize
  String get string {
    switch (this) {
      case StudyScheduleSegmentType.baseline:
        return 'baseline';
      case StudyScheduleSegmentType.alternating:
        return 'alternating';
      case StudyScheduleSegmentType.counterBalanced:
        return 'counter_balanced';
      case StudyScheduleSegmentType.thompsonSampling:
        return 'thompson_sampling';
      case StudyScheduleSegmentType.singleIntervention:
        return 'single_intervention';
    }
  }
}
