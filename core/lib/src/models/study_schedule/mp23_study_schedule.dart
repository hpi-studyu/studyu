import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/util/thompson_sampling.dart';

part 'mp23_study_schedule.g.dart';

@JsonSerializable()
class MP23StudySchedule {
  // todo why are interventions and observations saved in the schedule?
  @JsonKey(includeToJson: false, defaultValue: [])
  List<Intervention> interventions;

  @JsonKey(includeToJson: false, defaultValue: [])
  List<Observation> observations;

  @StudyScheduleSegmentConverter()
  List<StudyScheduleSegment> segments = [];

  MP23StudySchedule(this.interventions, this.observations);

  factory MP23StudySchedule.fromJson(Map<String, dynamic> json) =>
      _$MP23StudyScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$MP23StudyScheduleToJson(this);

  int get duration => segments.isEmpty
      ? 0
      : segments
          .map((e) => e.getDuration(interventions))
          .reduce((a, b) => a + b);

  /// Returns the segment for the given day and the nth day of the segment
  (StudyScheduleSegment?, int) getSegmentForDay(int day) {
    if (day >= duration || day < 0) {
      throw ArgumentError("Day must be between 0 and $duration");
    }

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

  Intervention? getInterventionForDay(int day, List<SubjectProgress> progress) {
    final (segment, dayInSegment) = getSegmentForDay(day);
    return segment?.getInterventionOnDay(dayInSegment, interventions, progress);
  }
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
    fromJson: StudyScheduleSegmentType.fromJson,
    toJson: StudyScheduleSegmentType.toJson,
    includeFromJson: true,
    includeToJson: true,
  )
  final StudyScheduleSegmentType type = StudyScheduleSegmentType.baseline;

  @override
  final String name = "Baseline";

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
    switch (json['type'] as String) {
      case 'baseline':
        return BaselineScheduleSegment.fromJson(json);
      case 'alternating':
        return AlternatingScheduleSegment.fromJson(json);
      case 'thompsonSampling':
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
    fromJson: StudyScheduleSegmentType.fromJson,
    toJson: StudyScheduleSegmentType.toJson,
    includeFromJson: true,
    includeToJson: true,
  )
  final StudyScheduleSegmentType type = StudyScheduleSegmentType.alternating;

  @override
  final String name = "Alternating";

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
    fromJson: StudyScheduleSegmentType.fromJson,
    toJson: StudyScheduleSegmentType.toJson,
    includeFromJson: true,
    includeToJson: true,
  )
  final StudyScheduleSegmentType type =
      StudyScheduleSegmentType.thompsonSampling;

  @override
  final String name = "Thompson Sampling";

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

    print("_________ analyzing progress:________");

    // for each progress update, e.g. if a user did the intervention that day, or other questionnaires
    for (final progress in progress) {
      if (progress.result.runtimeType == Result<QuestionnaireState>) {
        final interventionId = progress.interventionId;

        if (progress.result.result is QuestionnaireState) {
          final r = progress.result.result as QuestionnaireState;
//
          for (final answer in r.answers.values) {
            if (questionId == answer.question) {
              print(answer.runtimeType);
              if (answer.runtimeType == Answer<num>) {
                final response = answer.response as int;
                final interventionIndex = interventions.indexWhere(
                  (element) => element.id == interventionId,
                );
                print("updating observation: $interventionIndex $response");
                ts.updateObservations(interventionIndex, response.toDouble());
              }
            }
          }
        }
      }
    }

    final index = ts.selectArm();
    print("selected arm: $index");

    return interventions[index];
  }
}

enum StudyScheduleSegmentType {
  baseline,
  alternating,
  counterBalanced,
  thompsonSampling;

  static StudyScheduleSegmentType fromJson(String value) {
    return StudyScheduleSegmentType.values
        .firstWhere((e) => e.toString().split('.')[1] == value);
  }

  static String toJson(StudyScheduleSegmentType type) {
    return type.toString().split('.')[1];
  }

  String get name {
    switch (this) {
      case StudyScheduleSegmentType.baseline:
        return 'Baseline';
      case StudyScheduleSegmentType.alternating:
        return 'Alternating';
      case StudyScheduleSegmentType.counterBalanced:
        return 'Counter Balanced';
      case StudyScheduleSegmentType.thompsonSampling:
        return 'Thompson Sampling';
    }
  }
}
