import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/util/thompson_sampling.dart';

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

@JsonSerializable()
class BaselineScheduleSegment extends StudyScheduleSegment {
  int duration;

  @override
  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
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
      case StudyScheduleSegmentType.thompsonSampling:
        return ThompsonSamplingScheduleSegment.fromJson(json);
      default:
        throw ArgumentError('Invalid type for StudyScheduleSegment');
    }
  }

  @override
  Map<String, dynamic> toJson(StudyScheduleSegment segment) => segment.toJson();
}

@JsonSerializable()
class AlternatingScheduleSegment extends StudyScheduleSegment {
  @override
  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
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

@JsonSerializable()
class ThompsonSamplingScheduleSegment extends StudyScheduleSegment {
  @override
  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
  final StudyScheduleSegmentType type =
      StudyScheduleSegmentType.thompsonSampling;

  @override
  final String name = StudyScheduleSegmentType.thompsonSampling.string;

  int interventionDuration;
  int interventionDrawAmount;
  String observationId;
  String questionId;

  ThompsonSamplingScheduleSegment(
    this.interventionDuration,
    this.interventionDrawAmount,
    this.observationId,
    this.questionId,
  );

  factory ThompsonSamplingScheduleSegment.fromJson(Map<String, dynamic> json) =>
      _$ThompsonSamplingScheduleSegmentFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$ThompsonSamplingScheduleSegmentToJson(this);

  @override
  int getDuration(List<Intervention> interventions) {
    return interventionDuration * interventionDrawAmount;
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

    final ThompsonSampling ts = ThompsonSampling(interventions.length);

    // for each progress update, e.g. if a user did the intervention that day, or other questionnaires
    for (final progress in progress) {
      if (progress.result.runtimeType == Result<QuestionnaireState>) {
        final interventionId = progress.interventionId;

        if (progress.result.result is QuestionnaireState) {
          final r = progress.result.result as QuestionnaireState;
          for (final answer in r.answers.values) {
            if (questionId == answer.question) {
              print(answer.runtimeType);
              if (answer.runtimeType == Answer<num>) {
                final response = answer.response as int;
                final interventionIndex = interventions.indexWhere(
                  (element) => element.id == interventionId,
                );
                ts.updateObservations(interventionIndex, response.toDouble());
              }
            }
          }
        }
      }
    }

    final index = ts.selectArm();
    return interventions[index];
  }
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
