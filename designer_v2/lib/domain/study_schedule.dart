import 'package:studyu_designer_v2/localization/app_translation.dart';


enum StudyScheduleType {
  abab,
}

/// Provides a human-readable translation of the study schedule
extension StudyScheduleTypeFormatted on StudyScheduleType {
  String get string {
    switch (this) {
      case StudyScheduleType.abab:
        return tr.alternating_abab;
      default:
        return "[Invalid StudyScheduleType]";
    }
  }
}
