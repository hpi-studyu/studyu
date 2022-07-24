import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_core/core.dart' as core;

enum StudyActionType {
  edit,
  duplicate,
  addCollaborator,
  recruit,
  export,
  delete
}

// TODO: Add status field to core package domain model
enum StudyStatus {
  draft,
  running,
  closed
}

typedef StudyID = String;

extension StudyWithStatus on core.Study {
  StudyStatus get status {
    // TODO: missing a flag to indicate a study has been completed & participation is closed
    if (published) {
      return StudyStatus.running;
    }
    return StudyStatus.draft;
  }
}

typedef InterventionProvider = Intervention? Function(String id);

extension StudyHelpers on core.Study {
  Intervention? getIntervention(String id) {
    return interventions.firstWhere((i) => i.id == id);
  }
}

/// Provides a human-readable translation of the study status
extension StudyStatusFormatted on StudyStatus {
  String get string {
    switch (this) {
      case StudyStatus.draft:
        return "Draft".hardcoded;
      case StudyStatus.running:
        return "Running".hardcoded;
      case StudyStatus.closed:
        return "Closed".hardcoded;
      default:
        return "[Invalid StudyStatus]";
    }
  }
}

/// Provides a human-readable translation of the participation / enrollment type
extension ParticipationTypeFormatted on core.Participation {
  String get value {
    switch (this) {
      case core.Participation.invite:
        return "Invite".hardcoded;
      case core.Participation.open:
        return "Open".hardcoded;
      default:
        return "[Invalid ParticipationFormatted]";
    }
  }
}

