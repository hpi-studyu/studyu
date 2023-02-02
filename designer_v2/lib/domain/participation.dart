import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

/// Provides a human-readable translation
extension ParticipationFormatted on Participation {
  String get string {
    switch (this) {
      case Participation.open:
        return tr.form_enrollment_option_open;
      case Participation.invite:
        return tr.form_enrollment_option_invite;
      default:
        return "[Invalid Participation]";
    }
  }

  String get designDescription {
    switch (this) {
      case Participation.open:
        return tr.form_field_enrollment_type_open_description;
      case Participation.invite:
        return tr.form_field_enrollment_type_invite_description;
      default:
        return "[Invalid Participation]";
    }
  }

  String get description {
    switch (this) {
      case Participation.open:
        return tr.participation_open_who_description;
      case Participation.invite:
        return tr.participation_invite_who_description;
      default:
        return "[Invalid Participation]";
    }
  }

  String get whoShort {
    switch (this) {
      case Participation.open:
        return tr.participation_open_who;
      case Participation.invite:
        return tr.participation_invite_who;
      default:
        return "[Invalid Participation]";
    }
  }

  String get asAdjective {
    // used when launching the study
    switch (this) {
      case Participation.open:
        return tr.participation_open_as_adjective;
      case Participation.invite:
        return tr.participation_invite_as_adjective;
      default:
        return "[Invalid Participation]";
    }
  }

  String get launchDescription {
    switch (this) {
      case Participation.open:
        return tr.participation_open_launch_description;
      case Participation.invite:
        return tr.participation_invite_launch_description;
      default:
        return "[Invalid Participation]";
    }
  }
}
