import 'package:json_annotation/json_annotation.dart';

import '../../data/data_reference.dart';
import '../../tables/study.dart';
import '../../tables/study_subject.dart';
import '../study_result.dart';

part 'numeric_result.g.dart';

@JsonSerializable()
class NumericResult extends StudyResult {
  static const String studyResultType = 'numeric';

  late DataReference<num> resultProperty;

  NumericResult() : super(studyResultType);

  NumericResult.withId() : super.withId(studyResultType);

  factory NumericResult.fromJson(Map<String, dynamic> json) => _$NumericResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NumericResultToJson(this);

  @override
  List<String> getHeaders(Study studySpec) {
    final schedule = studySpec.schedule;
    final numberOfDays = schedule.getNumberOfPhases() * schedule.phaseDuration;
    return Iterable<int>.generate(numberOfDays).map((e) => e.toString()).toList();
  }

  @override
  List getValues(StudySubject subject) {
    final resultSet = resultProperty
        .retrieveFromResults(subject)
        .map<int, num>((key, value) => MapEntry(subject.getDayOfStudyFor(key), value));
    final numberOfDays = subject.study.schedule.getNumberOfPhases() * subject.study.schedule.phaseDuration;
    return Iterable<int>.generate(numberOfDays).map((day) => resultSet[day]).toList();
  }
}
