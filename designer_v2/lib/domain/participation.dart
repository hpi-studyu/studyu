import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

/// Provides a human-readable translation
extension ParticipationFormatted on Participation {
  String get string {
    switch (this) {
      case Participation.open:
        return "Open".hardcoded;
      case Participation.invite:
        return "Private (Invitation-Based)".hardcoded;
      default:
        return "[Invalid Participation]";
    }
  }

  String get description {
    switch (this) {
      case Participation.open:
        return "Your study will be open for enrollment to all users of the StudyU platform as "
            "long as they match your screening criteria, if any.".hardcoded;
      case Participation.invite:
        return "Only select participants will be able to enroll in your study "
            "using a designated access code. Choose this option if you have a "
            "preselected pool of participants.".hardcoded;
      default:
        return "[Invalid Participation]";
    }
  }
}
