import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/util/thompson_sampling.dart';

part 'thompson_sampling_schedule_segment.g.dart';

@JsonSerializable()
class ThompsonSamplingScheduleSegment extends StudyScheduleSegment {
  @override
  @JsonKey(includeFromJson: true, includeToJson: true)
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
