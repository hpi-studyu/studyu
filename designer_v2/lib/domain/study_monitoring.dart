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
  final List<Set<String>> missedTasksPerDay;
  final List<Set<String>> completedTasksPerDay;

  StudyMonitorItem({
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
    required this.missedTasksPerDay,
    required this.completedTasksPerDay,
  }) {
    assert(missedTasksPerDay.length == currentDayOfStudy);
    assert(completedTasksPerDay.length == currentDayOfStudy);
  }

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

      final Set<String> requiredSurveyTaskIds = observations.map((o) => o.id).toSet();

      int completedInterventions = 0;
      int completedSurveys = 0;
      final List<Set<String>> missedTasksPerDay = [];
      final List<Set<String>> completedTasksPerDay = [];

      for (int day = 0; day < currentDayOfStudy; day++) {
        final Set<String> requiredInterventionTaskIds = {};
        if (day >= daysInBaseline) {
          final interventionIdForThisPhase = interventionOrder[day ~/ schedule.phaseDuration];
          final interventionForThisPhase = interventions.firstWhere((i) => i.id == interventionIdForThisPhase);
          requiredInterventionTaskIds.addAll(interventionForThisPhase.tasks.map((t) => t.id));
        }

        final requiredTaskIds = requiredInterventionTaskIds.union(requiredSurveyTaskIds);

        final completedTaskIds = progresses
            .where((p) =>
                p.completedAt!.isAfter(participant.startedAt!.add(Duration(days: day))) &&
                p.completedAt!.isBefore(participant.startedAt!.add(Duration(days: day + 1))))
            .map((p) => p.taskId)
            .toSet();

        final missedTaskIds = requiredTaskIds.difference(completedTaskIds);
        missedTasksPerDay.add(missedTaskIds);

        final completedTaskIdsPerDay = requiredTaskIds.intersection(completedTaskIds);
        completedTasksPerDay.add(completedTaskIdsPerDay);

        final completedSurveysSet = requiredSurveyTaskIds.intersection(completedTaskIds);
        final completedIntervention = requiredInterventionTaskIds.isNotEmpty &&
            requiredInterventionTaskIds.intersection(completedTaskIds).length == requiredInterventionTaskIds.length;
        completedSurveys += completedSurveysSet.length;
        completedInterventions += completedIntervention ? 1 : 0;
      }

      final totalSurveys = currentDayOfStudy * observations.length;
      final totalInterventions = max(0, currentDayOfStudy - daysInBaseline);

      final missedInterventions = totalInterventions - completedInterventions;
      final missedSurveys = totalSurveys - completedSurveys;

      items.add(StudyMonitorItem(
        participantId: participant.id,
        inviteCode: participant.inviteCode,
        enrolledAt: participant.startedAt!,
        lastActivityAt: lastActivityAt,
        currentDayOfStudy: currentDayOfStudy,
        studyDurationInDays: studyDurationInDays,
        completedInterventions: completedInterventions,
        missedInterventions: missedInterventions,
        completedSurveys: completedSurveys,
        missedSurveys: missedSurveys,
        droppedOut: participant.isDeleted,
        missedTasksPerDay: missedTasksPerDay,
        completedTasksPerDay: completedTasksPerDay,
      ));
    }

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7)); //dropout time

    final activeParticipants = items.where((item) {
      return !item.droppedOut && item.currentDayOfStudy < item.studyDurationInDays && item.lastActivityAt.isAfter(sevenDaysAgo);
    }).length;
    final dropoutParticipants = items.where((item) {
      return item.droppedOut && item.lastActivityAt.isBefore(sevenDaysAgo);
    }).length;
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
