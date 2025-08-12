import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'mp23_study_schedule.g.dart';

@JsonSerializable()
class MP23StudySchedule {
  @StudyScheduleSegmentConverter()
  List<StudyScheduleSegment> segments = [];

  MP23StudySchedule();

  MP23StudySchedule.withSegments(this.segments);

  factory MP23StudySchedule.fromJson(Map<String, dynamic> json) =>
      _$MP23StudyScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$MP23StudyScheduleToJson(this);
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
    }
  }

  @override
  Map<String, dynamic> toJson(StudyScheduleSegment segment) => segment.toJson();
}

enum StudyScheduleSegmentType {
  baseline,
  alternating,
  counterBalanced,
  thompsonSampling;

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
    }
  }
}
