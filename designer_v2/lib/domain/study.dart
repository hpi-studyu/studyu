import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart' as core;
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        return tr.drafts;
      case StudyStatus.running:
        return tr.running;
      case StudyStatus.closed:
        return tr.closed;
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
        return tr.invite;
      case core.Participation.open:
        return tr.open;
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

class StudyTemplates {
  static Study emptyDraft(String userId) {
    final newDraft = Study.withId(userId);
    newDraft.title = tr.unnamed_Study;
    newDraft.description = tr.lorem_ipsum;
    return newDraft;
  }
}
