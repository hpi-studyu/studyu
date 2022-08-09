import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

enum StudyScheduleType {
  abab,
}

/// Provides a human-readable translation of the study schedule
extension StudyScheduleTypeFormatted on StudyScheduleType {
  String get string {
    switch (this) {
      case StudyScheduleType.abab:
        return "Alternating (AB AB)".hardcoded;
      default:
        return "[Invalid StudyScheduleType]";
    }
  }
}
