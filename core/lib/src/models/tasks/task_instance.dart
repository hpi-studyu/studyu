import 'package:studyu_core/core.dart';

class TaskInstance {
  final Task task;
  final String taskInstanceId;

  TaskInstance(this.task, this.taskInstanceId);

  TaskInstance.fromInstanceId(
      this.taskInstanceId, DateTime now, StudySubject subject)
      : task = subject
            .scheduleFor(now)
            .firstWhere((element) => element.taskInstanceId == taskInstanceId)
            .task;

  CompletionPeriod get completionPeriod => task.schedule.completionPeriods
      .firstWhere((element) => element.id == taskInstanceId);
}
