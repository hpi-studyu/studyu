import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

/// Provides a human-readable translation
extension ParticipationFormatted on Participation {
  String get string {
    switch (this) {
      case Participation.open:
        return "Open".hardcoded;
      case Participation.invite:
        return "Private (Invite-only)".hardcoded;
      default:
        return "[Invalid Participation]";
    }
  }

  String get designDescription {
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

  String get description {
    switch (this) {
      case Participation.open:
        return "All StudyU users may enroll to the open study in the StudyU app.".hardcoded;
      case Participation.invite:
        return "Only participants with an access "
            "code can enroll in the StudyU app.".hardcoded;
      default:
        return "[Invalid Participation]";
    }
  }

  String get whoShort {
    switch (this) {
      case Participation.open:
        return "Everyone".hardcoded;
      case Participation.invite:
        return "Invite-only".hardcoded;
      default:
        return "[Invalid Participation]";
    }
  }

  String get asAdjective { // used when launching the study
    switch (this) {
      case Participation.open:
        return "open".hardcoded;
      case Participation.invite:
        return "private, invite-only".hardcoded;
      default:
        return "[Invalid Participation]";
    }
  }

  String get launchDescription {
    switch (this) {
      case Participation.open:
        return "Once launched, all users of the StudyU platform can enroll in "
            "your study as long as they meet your screening criteria.".hardcoded;
      case Participation.invite:
        return "Once launched, you can invite participants by sending "
            "them a code to access & enroll in your study.".hardcoded;
      default:
        return "[Invalid Participation]";
    }
  }
}
