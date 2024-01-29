import 'package:studyu_core/src/models/study_results/study_result.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/models/tables/study_subject.dart';

class UnknownResult extends StudyResult {
  static const String studyResultType = 'unknown';

  UnknownResult() : super(studyResultType);

  @override
  bool get isSupported => false;

  @override
  List<String> getHeaders(Study studySpec) {
    throw UnimplementedError();
  }

  @override
  List getValues(StudySubject subject) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    throw ArgumentError('UnknownResult should not be serialized');
  }
}
