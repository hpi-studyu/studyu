import 'package:json_annotation/json_annotation.dart';

import '../../data/data_reference.dart';
import '../../study/studies.dart';
import '../study_result.dart';

part 'numeric_result.g.dart';

@JsonSerializable()
class NumericResult extends StudyResult {
  static const String studyResultType = 'numeric';

  DataReference<num> resultProperty;

  NumericResult() : super(studyResultType);

  NumericResult.designerDefault() : super.designer(studyResultType);

  factory NumericResult.fromJson(Map<String, dynamic> json) => _$NumericResultFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NumericResultToJson(this);

  @override
  List<String> getHeaders(StudyBase studySpec) {
    final schedule = studySpec.schedule;
    final numberOfDays = schedule.getNumberOfPhases() * schedule.phaseDuration;
    return Iterable<int>.generate(numberOfDays).map((e) => e.toString()).toList();
  }

  @override
  List getValues(UserStudyBase instance) {
    final resultSet = resultProperty
        .retrieveFromResults(instance)
        .map<int, num>((key, value) => MapEntry(instance.getDayOfStudyFor(key), value));
    final numberOfDays = instance.schedule.getNumberOfPhases() * instance.schedule.phaseDuration;
    return Iterable<int>.generate(numberOfDays).map((day) => resultSet[day]).toList();
  }
}
