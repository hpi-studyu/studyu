import 'package:studyu_core/core.dart';

class TaskInstance {
  final Task task;
  final String id;
  final String interventionId;

  TaskInstance(this.task, this.id, {required this.interventionId})
    : assert(task.id != id);

  factory TaskInstance.fromInstanceId(
    String taskInstanceId, {
    StudySubject? subject,
    Study? study,
    String? interventionId,
    DateTime? date,
  }) {
    date ??= DateTime.now();
    if (subject != null) {
      return subject
          .scheduleFor(date)
          .firstWhere((element) => element.id == taskInstanceId);
    }
    if (study == null || interventionId == null) {
      throw "Either subject or study with interventionId need to be given to create TaskInstance";
    }
    final tempTask = _taskFromStudy(taskInstanceId, study);
    assert(tempTask.id != taskInstanceId);
    return TaskInstance(
      tempTask,
      taskInstanceId,
      interventionId: interventionId,
    );
  }

  static Task _taskFromStudy(String taskInstanceId, Study study) {
    final tasks = <Task>[
      ...study.observations,
      ...study.interventions
          .map((intervention) => intervention.tasks)
          .expand((element) => element),
    ];
    return tasks.firstWhere((task) {
      if (task.schedule.completionPeriods.any(
        (completionPeriod) => completionPeriod.id == taskInstanceId,
      )) {
        return true;
      }
      return false;
    });
  }

  CompletionPeriod get completionPeriod =>
      task.schedule.completionPeriods.firstWhere((element) => element.id == id);
}
