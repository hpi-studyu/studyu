import 'dart:math';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';

class StudyMonitorItem extends Equatable {
  final StudySubject studySubject;
  final String participantId;
  final String? inviteCode;
  final DateTime startedAt;
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

  const StudyMonitorItem({
    required this.studySubject,
    required this.participantId,
    required this.inviteCode,
    required this.startedAt,
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
  })  : assert(missedTasksPerDay.length == currentDayOfStudy),
        assert(completedTasksPerDay.length == currentDayOfStudy);

  @override
  List<Object?> get props => [participantId];
}

extension StudyMonitoringX on Study {
  List<StudyMonitorItem> get monitorData {
    final List<StudyMonitorItem> items = [];

    final participants = this.participants ?? [];
    final participantsProgress = this.participantsProgress ?? [];

    participants
        .sort((a, b) => a.startedAt!.compareTo(b.startedAt!)); // ascending

    for (final participant in participants) {
      final progresses = participantsProgress
          .where((progress) => progress.subjectId == participant.id)
          .toList();
      progresses.sort(
        (b, a) => a.completedAt!.compareTo(b.completedAt!),
      ); // descending
      final interventionOrder = schedule
          .generateInterventionIdsInOrder(participant.selectedInterventionIds);
      final lastActivityAt = progresses.isNotEmpty
          ? progresses.first.completedAt!
          : participant.startedAt!;
      final studyDurationInDays = schedule.length;
      final currentDayOfStudy = min(
        studyDurationInDays,
        DateTime.now().toUtc().difference(participant.startedAt!).inDays,
      );
      final daysInBaseline =
          schedule.includeBaseline ? schedule.phaseDuration : 0;

      final Set<String> requiredSurveyTaskIds =
          observations.map((o) => o.id).toSet();

      int completedInterventions = 0;
      int completedSurveys = 0;
      final List<Set<String>> missedTasksPerDay = [];
      final List<Set<String>> completedTasksPerDay = [];

      for (int day = 0; day < currentDayOfStudy; day++) {
        final Set<String> requiredInterventionTaskIds = {};
        if (day >= daysInBaseline) {
          final interventionIdForThisPhase =
              interventionOrder[day ~/ schedule.phaseDuration];
          final interventionForThisPhase = interventions
              .firstWhere((i) => i.id == interventionIdForThisPhase);
          requiredInterventionTaskIds
              .addAll(interventionForThisPhase.tasks.map((t) => t.id));
        }

        final requiredTaskIds =
            requiredInterventionTaskIds.union(requiredSurveyTaskIds);

        final completedTaskIds = progresses
            .where(
              (p) =>
                  p.completedAt!.isAfter(
                    participant.startedAt!.add(Duration(days: day)),
                  ) &&
                  p.completedAt!.isBefore(
                    participant.startedAt!.add(Duration(days: day + 1)),
                  ),
            )
            .map((p) => p.taskId)
            .toSet();

        final missedTaskIds = requiredTaskIds.difference(completedTaskIds);
        missedTasksPerDay.add(missedTaskIds);

        final completedTaskIdsPerDay =
            requiredTaskIds.intersection(completedTaskIds);
        completedTasksPerDay.add(completedTaskIdsPerDay);

        final completedSurveysSet =
            requiredSurveyTaskIds.intersection(completedTaskIds);
        final completedIntervention = requiredInterventionTaskIds.isNotEmpty &&
            requiredInterventionTaskIds.intersection(completedTaskIds).length ==
                requiredInterventionTaskIds.length;
        completedSurveys += completedSurveysSet.length;
        completedInterventions += completedIntervention ? 1 : 0;
      }

      final totalSurveys = currentDayOfStudy * observations.length;
      final totalInterventions = max(0, currentDayOfStudy - daysInBaseline);

      final missedInterventions = totalInterventions - completedInterventions;
      final missedSurveys = totalSurveys - completedSurveys;

      items.add(
        StudyMonitorItem(
          studySubject: participant,
          participantId: participant.id,
          inviteCode: participant.inviteCode,
          startedAt: participant.startedAt!,
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
        ),
      );
    }

    final participantCategories = items.activeParticipants.toList() +
        items.inactiveParticipants.toList() +
        items.dropoutParticipants.toList() +
        items.completedParticipants.toList();
    final deepEq = const DeepCollectionEquality.unordered().equals;
    assert(deepEq(items, participantCategories));

    return items;
  }
}

extension ListX on List<StudyMonitorItem> {
  static final inactiveDate = DateTime.now()
      .subtract(const Duration(days: Config.participantInactiveDuration));
  static final dropoutDate = DateTime.now()
      .subtract(const Duration(days: Config.participantDropoutDuration));

  static bool Function(StudyMonitorItem p) get studyStillRunning =>
      (StudyMonitorItem p) => p.currentDayOfStudy < p.studyDurationInDays;

  static bool Function(StudyMonitorItem p) get inactive => (p) =>
      p.lastActivityAt.isBefore(inactiveDate) &&
      p.lastActivityAt.isAfter(dropoutDate);

  static bool Function(StudyMonitorItem p) get dropout =>
      (p) => p.droppedOut || dropoutByDuration(p) && studyStillRunning(p);

  static bool Function(StudyMonitorItem p) get dropoutByDuration =>
      (p) => p.lastActivityAt.isBefore(dropoutDate);

  /// Number of participants who are currently active in the study
  /// Active means that the the study has not ended yet and the participant
  /// did not drop out
  Iterable<StudyMonitorItem> get activeParticipants =>
      where((p) => !dropout(p) && !inactive(p) && studyStillRunning(p));

  /// Number of participants who are currently inactive in the study for more
  /// than [participantDropoutDuration] days in a row
  Iterable<StudyMonitorItem> get inactiveParticipants => where(
        (p) => !dropout(p) && inactive(p) && studyStillRunning(p),
      );

  /// Number of participants who dropped out of the study before the study ended
  /// Hint: The is_deleted flag in the study_subject database table marks a
  /// participant as dropped out
  /// Note: If the participant's last activity exceeds
  /// [participantDropoutDuration] days, they will also be counted as a dropout
  Iterable<StudyMonitorItem> get dropoutParticipants => where(
        (p) => dropout(p),
      );

  /// Number of participants who completed the study
  /// Completed means that the participant has reached the end of the study
  Iterable<StudyMonitorItem> get completedParticipants =>
      where((p) => !dropout(p) && !studyStillRunning(p));
}
