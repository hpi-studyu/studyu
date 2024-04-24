import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:studyu_core/core.dart';

class StudyMonitorData {
  /// Number of participants who are currently active in the study
  /// Active means that the the study has not ended yet and the participant did not drop out
  final int activeParticipants;

  /// Number of participants who dropped out of the study before the study ended
  /// Hint: The is_deleted flag in the study_subject database table marks a participant as dropped out
  final int dropoutParticipants;

  /// Number of participants who completed the study
  /// Completed means that the participant has reached the end of the study
  final int completedParticipants;

  /// List of all participants with their monitoring data
  final List<StudyMonitorItem> items;

  const StudyMonitorData({
    required this.activeParticipants,
    required this.dropoutParticipants,
    required this.completedParticipants,
    required this.items,
  });
}

class StudyMonitorItem extends Equatable {
  final String participantId;
  final String? inviteCode;
  final DateTime enrolledAt;
  final DateTime lastActivityAt;
  final int currentDayOfStudy;
  final int studyDurationInDays;
  final int completedInterventions;
  final int missedInterventions;
  final int completedSurveys;
  final int missedSurveys;
  final bool droppedOut;

  const StudyMonitorItem({
    required this.participantId,
    required this.inviteCode,
    required this.enrolledAt,
    required this.lastActivityAt,
    required this.currentDayOfStudy,
    required this.studyDurationInDays,
    required this.completedInterventions,
    required this.missedInterventions,
    required this.completedSurveys,
    required this.missedSurveys,
    required this.droppedOut,
  });

  @override
  List<Object?> get props => [participantId];
}

extension StudyMonitoringX on Study {
  StudyMonitorData get monitorData {
    final List<StudyMonitorItem> items = [];

    final participants = this.participants ?? [];
    final participantsProgress = this.participantsProgress ?? [];

    participants.sort((a, b) => a.startedAt!.compareTo(b.startedAt!)); // ascending

    for (final participant in participants) {
      final progresses = participantsProgress.where((progress) => progress.subjectId == participant.id).toList();
      progresses.sort((b, a) => a.completedAt!.compareTo(b.completedAt!)); // descending
      final interventionOrder = schedule.generateInterventionIdsInOrder(participant.selectedInterventionIds);
      final lastActivityAt = progresses.isNotEmpty ? progresses.first.completedAt! : participant.startedAt!;
      final studyDurationInDays = schedule.length;
      final currentDayOfStudy =
          min(studyDurationInDays, DateTime.now().toUtc().difference(participant.startedAt!).inDays);
      final daysInBaseline = schedule.includeBaseline ? schedule.phaseDuration : 0;

      int totalInterventions = 0;
      for (int day = 0; day < currentDayOfStudy; day++) {
        if (day < daysInBaseline) {
          continue;
        }

        final interventionIdForThisPhase = interventionOrder[day ~/ schedule.phaseDuration];
        final interventionForThisPhase = interventions.firstWhere((i) => i.id == interventionIdForThisPhase);
        totalInterventions += interventionForThisPhase.tasks.length;
      }

      final totalSurveys = currentDayOfStudy * observations.length;

      final completedInterventions = progresses.where((p) => p.resultType == "bool").toList();
      final completedSurveys = progresses.where((p) => p.resultType != "bool").toList();

      final missedInterventions = totalInterventions - completedInterventions.length;
      final missedSurveys = totalSurveys - completedSurveys.length;

      items.add(StudyMonitorItem(
        participantId: participant.id,
        inviteCode: participant.inviteCode,
        enrolledAt: participant.startedAt!,
        lastActivityAt: lastActivityAt,
        currentDayOfStudy: currentDayOfStudy,
        studyDurationInDays: studyDurationInDays,
        completedInterventions: completedInterventions.length,
        missedInterventions: missedInterventions,
        completedSurveys: completedSurveys.length,
        missedSurveys: missedSurveys,
        droppedOut: participant.isDeleted,
      ));
    }

    final activeParticipants =
        items.where((item) => !item.droppedOut && item.currentDayOfStudy < item.studyDurationInDays).length;
    final dropoutParticipants =
        items.where((item) => item.droppedOut && item.currentDayOfStudy < item.studyDurationInDays).length;
    final completedParticipants = items.where((item) => item.currentDayOfStudy >= item.studyDurationInDays).length;

    assert(activeParticipants + dropoutParticipants + completedParticipants == items.length);

    return StudyMonitorData(
      activeParticipants: activeParticipants,
      dropoutParticipants: dropoutParticipants,
      completedParticipants: completedParticipants,
      items: items,
    );
  }
}
