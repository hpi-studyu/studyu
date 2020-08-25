import 'package:json_annotation/json_annotation.dart';
import 'package:studyou_core/models/study/study.dart';
import 'package:studyou_core/models/study/user_study.dart';

import '../study_result.dart';

part 'intervention_result.g.dart';

@JsonSerializable()
class InterventionResult extends StudyResult {
  static const String studyResultType = 'intervention';

  InterventionResult() : super(studyResultType);

  factory InterventionResult.fromJson(Map<String, dynamic> json) => _$InterventionResultFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$InterventionResultToJson(this);

  @override
  List<String> getHeaders(StudyBase studySpec) {
    var schedule = studySpec.studyDetails.schedule;
    final numberOfDays = schedule.getNumberOfPhases() * schedule.phaseDuration;
    return Iterable<int>.generate(numberOfDays).map((e) => e.toString()).toList();
  }

  @override
  List getValues(UserStudyBase instance) {
    instance.interventionOrder
        .expand((intervention) => List<String>.filled(instance.schedule.phaseDuration, intervention));
  }
}
