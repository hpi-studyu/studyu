import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_core/core.dart' as core;
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

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
typedef MeasurementID = String;

extension StudyStatusX on core.Study {
  StudyStatus get status {
    // TODO: missing a flag to indicate a study has been completed & participation is closed
    if (published) {
      return StudyStatus.running;
    }
    return StudyStatus.draft;
  }

  bool isReadonly(sb.User user) {
    return status != StudyStatus.draft || !canEdit(user);
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
        return "Live".hardcoded;
      case StudyStatus.closed:
        return "Closed".hardcoded;
      default:
        return "[Invalid StudyStatus]";
    }
  }

  String get description {
    switch (this) {
      case StudyStatus.draft:
        return "This study is still being drafted.".hardcoded;
      case StudyStatus.running:
        return "This study is currently under way.".hardcoded;
      case StudyStatus.closed:
        return "This study has been completed.".hardcoded;
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

extension StudyInviteCodeX on Study {
  StudyInvite? getInvite(String code) {
    if (invites == null || invites!.isEmpty) {
      return null;
    }
    return invites!.firstWhere((invite) => invite.code == code);
  }
}

extension StudyDuplicateX on Study {
  Study exactDuplicate() {
    return Study.fromJson(toJson());
  }

  /// Creates a clean copy of the given [study] only containing the
  /// study protocol / editor data model
  Study duplicateAsDraft(String userId) {
    final copy = Study.fromJson(toJson());
    copy.title = (copy.title ?? '').withDuplicateLabel();
    copy.userId = userId;
    copy.published = false;
    copy.activeSubjectCount = 0;
    copy.participantCount = 0;
    copy.endedCount = 0;
    copy.missedDays = [];
    copy.resultSharing = ResultSharing.private;
    copy.results = [];
    copy.repo = null;
    copy.invites = null;
    copy.collaboratorEmails = [];

    // Generate a new random UID
    final dummy = Study.withId(userId);
    copy.id = dummy.id;

    return copy;
  }
}

extension StudyPublishX on Study {
  Study asNewlyPublished() {
    final copy = Study.fromJson(toJson());

    copy.published = true;
    copy.activeSubjectCount = 0;
    copy.participantCount = 0;
    copy.endedCount = 0;
    copy.missedDays = [];
    copy.results = [];

    return copy;
  }
}

extension StudyRegistryX on Study {
  bool get publishedToRegistry => false; // TODO add to core.Study
  bool get publishedToRegistryResults => resultSharing == ResultSharing.public;
}

class StudyTemplates {
  static Study emptyDraft(String userId) {
    final newDraft = Study.withId(userId);
    newDraft.title = "Unnamed study".hardcoded;
    newDraft.description = "Lorem ipsum".hardcoded;
    return newDraft;
  }
}
