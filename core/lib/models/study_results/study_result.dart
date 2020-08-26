import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/study_results/results/numeric_result.dart';

typedef StudyResultParser = StudyResult Function(Map<String, dynamic> json);

abstract class StudyResult {
  static Map<String, StudyResultParser> studyResultTypes = {
    InterventionResult.studyResultType: (json) => InterventionResult.fromJson(json),
    NumericResult.studyResultType: (json) => NumericResult.fromJson(json),
  };
  static const String keyType = 'type';
  String type;

  String id;
  String filename;

  StudyResult(this.type);

  factory StudyResult.fromJson(Map<String, dynamic> data) {
    return studyResultTypes[data[keyType]](data);
  }
  Map<String, dynamic> toJson();

  List<String> getHeaders(StudyBase studySpec);
  List<dynamic> getValues(UserStudyBase instance);
}
