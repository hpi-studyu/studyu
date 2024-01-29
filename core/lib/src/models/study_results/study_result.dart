import 'package:studyu_core/src/models/study_results/results/results.dart';
import 'package:studyu_core/src/models/study_results/results/unknown_result.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/models/tables/study_subject.dart';
import 'package:uuid/uuid.dart';

typedef StudyResultParser = StudyResult Function(Map<String, dynamic> json);

abstract class StudyResult {
  static const String keyType = 'type';
  String type;

  late String id;
  String filename = 'results.csv';

  bool get isSupported => true;

  StudyResult(this.type);

  StudyResult.withId(this.type) : id = const Uuid().v4();

  factory StudyResult.fromJson(Map<String, dynamic> data) => switch (data[keyType]) {
        InterventionResult.studyResultType => InterventionResult.fromJson(data),
        NumericResult.studyResultType => NumericResult.fromJson(data),
        _ => UnknownResult(),
      };

  Map<String, dynamic> toJson();

  List<String> getHeaders(Study studySpec);

  List<dynamic> getValues(StudySubject subject);
}
