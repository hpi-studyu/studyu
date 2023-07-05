import 'package:studyu_core/core.dart';
import 'package:studyu_core/core.dart' as core;
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

enum StudyActionType {
  pin,
  unpin,
  edit,
  duplicate,
  duplicateDraft,
  addCollaborator,
  export,
  delete,
}

/// Provides a human-readable translation of the model action type
extension StudyActionTypeFormatted on StudyActionType {
  String get string {
    switch (this) {
      case StudyActionType.pin:
        return tr.action_pin;
      case StudyActionType.unpin:
        return tr.action_unpin;
      case StudyActionType.edit:
        return tr.action_edit;
      case StudyActionType.delete:
        return tr.action_delete;
      case StudyActionType.duplicate:
        return tr.action_duplicate;
      case StudyActionType.duplicateDraft:
        return tr.action_study_duplicate_draft;
      case StudyActionType.addCollaborator:
        return "[StudyActionType.addCollaborator]"; // not implemented yet
      case StudyActionType.export:
        return tr.action_study_export_results;
      default:
        return "[Invalid ModelActionType]";
    }
  }
}

typedef StudyID = String;
typedef MeasurementID = String;
typedef InstanceID = String;

typedef InterventionProvider = Intervention? Function(String id);

extension StudyHelpers on core.Study {
  Intervention? getIntervention(String id) {
    if (id == Study.baselineID) {
      return Intervention(Study.baselineID, 'Baseline'.hardcoded);
    }
    return interventions.firstWhereOrNull((i) => i.id == id);
  }
}

/// Provides a human-readable translation of the study status
extension StudyStatusFormatted on StudyStatus {
  String get string {
    switch (this) {
      case StudyStatus.draft:
        return tr.study_status_draft;
      case StudyStatus.running:
        return tr.study_status_running;
      case StudyStatus.closed:
        return tr.study_status_closed;
      default:
        return "[Invalid StudyStatus]";
    }
  }

  String get description {
    switch (this) {
      case StudyStatus.draft:
        return tr.study_status_draft_description;
      case StudyStatus.running:
        return tr.study_status_running_description;
      case StudyStatus.closed:
        return tr.study_status_closed_description;
      default:
        return "[Invalid StudyStatus]";
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
    copy.registryPublished = false;
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
  static String get kUnnamedStudyTitle => tr.form_field_study_title_default;

  static Study emptyDraft(String userId) {
    final newDraft = Study.withId(userId);
    newDraft.title = StudyTemplates.kUnnamedStudyTitle;
    newDraft.iconName = '';
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
    return isOwner(user);
  }

  bool canChangeSettings(sb.User user) {
    return isOwner(user);
  }
}
