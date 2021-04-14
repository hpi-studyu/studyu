import 'package:uuid/uuid.dart';

import '../tables/study.dart';
import '../tables/study_subject.dart';
import 'results/results.dart';

typedef StudyResultParser = StudyResult Function(Map<String, dynamic> json);

abstract class StudyResult {
  static Map<String, StudyResultParser> studyResultTypes = {
    InterventionResult.studyResultType: (json) => InterventionResult.fromJson(json),
    NumericResult.studyResultType: (json) => NumericResult.fromJson(json),
  };
  static const String keyType = 'type';
  String type;

  late String id;
  String filename = 'results.csv';

  StudyResult(this.type);

  StudyResult.withId(this.type) : id = Uuid().v4();

  factory StudyResult.fromJson(Map<String, dynamic> data) {
    return studyResultTypes[data[keyType]]!(data);
  }

  Map<String, dynamic> toJson();

  List<String> getHeaders(Study studySpec);

  List<dynamic> getValues(StudySubject instance);
}
