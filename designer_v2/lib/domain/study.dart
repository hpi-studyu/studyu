import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_core/core.dart' as core;
import 'package:studyu_designer_v2/utils/extensions.dart';

enum StudyActionType {
  edit,
  duplicate,
  addCollaborator,
  recruit,
  export,
  delete,
}

typedef StudyID = String;
typedef MeasurementID = String;

typedef InterventionProvider = Intervention? Function(String id);

extension StudyHelpers on core.Study {
  Intervention? getIntervention(String id) {
    if (id == Study.baselineID) {
      return Intervention(Study.baselineID, 'Baseline');
    }
    return interventions.firstWhereOrNull((i) => i.id == id);
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
        return "This study is currently in progress.".hardcoded;
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
    final copy = Study.fromJson(toJson());
    copy.copyJsonIgnoredAttributes(from: this, createdAt: true);
    return copy;
  }

  /// Creates a clean copy of the given [study] only containing the
  /// study protocol / editor data model
  Study duplicateAsDraft(String userId) {
    final copy = Study.fromJson(toJson());
    copy.resetJsonIgnoredAttributes();
    copy.title = (copy.title ?? '').withDuplicateLabel();
    copy.userId = userId;
    copy.published = false;
    copy.resultSharing = ResultSharing.private;
    copy.results = [];
    copy.collaboratorEmails = [];
    copy.createdAt = DateTime.now();

    // Generate a new random UID
    final dummy = Study.withId(userId);
    copy.id = dummy.id;

    return copy;
  }

  Study asNewlyPublished() {
    final copy = Study.fromJson(toJson());
    copy.copyJsonIgnoredAttributes(from: this, createdAt: true);
    copy.resetParticipantData();
    copy.published = true;
    return copy;
  }

  Study copyJsonIgnoredAttributes({required Study from, createdAt = false}) {
    participantCount = from.participantCount;
    activeSubjectCount = from.activeSubjectCount;
    endedCount = from.endedCount;
    missedDays = from.missedDays;
    repo = from.repo;
    invites = from.invites;
    participants = from.participants;
    participantsProgress = from.participantsProgress;
    if (createdAt) {
      this.createdAt = from.createdAt;
    }
    return this;
  }

  Study resetJsonIgnoredAttributes() {
    participantCount = 0;
    activeSubjectCount = 0;
    endedCount = 0;
    missedDays = [];
    repo = null;
    invites = [];
    participants = [];
    participantsProgress = [];
    createdAt = null;
    return this;
  }

  Study resetParticipantData() {
    participantCount = 0;
    activeSubjectCount = 0;
    endedCount = 0;
    missedDays = [];
    results = [];
    participants = [];
    participantsProgress = [];
    return this;
  }
}

extension StudyRegistryX on Study {
  bool get publishedToRegistry => registryPublished;
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

extension StudyParticipantCountX on Study {
  int getParticipantCountForInvite(StudyInvite invite) {
    if (participants?.isEmpty ?? true) {
      return 0;
    }
    int count = 0;
    for (final participant in participants!) {
      if (participant.inviteCode == invite.code) {
        count += 1;
      }
    }
    return count;
  }
}

extension StudyPermissionsX on Study {
  bool canEditDraft(sb.User user) {
    return status == StudyStatus.draft && canEdit(user);
  }

  bool canCopy(sb.User user) {
    return canEdit(user) || registryPublished;
  }

  bool canDelete(sb.User user) {
    return isOwner(user) && !published;
  }

  bool canChangeSettings(sb.User user) {
    return isOwner(user);
  }
}
