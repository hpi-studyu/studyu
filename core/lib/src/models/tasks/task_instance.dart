import 'package:studyu_core/core.dart';

class TaskInstance {
  final Task task;
  final String taskInstanceId;

  TaskInstance(this.task, this.taskInstanceId);

  factory TaskInstance.fromInstanceId(String taskInstanceId, DateTime now, StudySubject subject) {
    final task = _taskFromInstanceId(taskInstanceId, now, subject);
    return TaskInstance(task, taskInstanceId);
  }

  static Task _taskFromInstanceId(String id, DateTime now, StudySubject subject) {
    return subject.scheduleFor(now).firstWhere((element) => element.taskInstanceId == id).task;
  }
  
  CompletionPeriod get completionPeriod =>
      task.schedule.completionPeriods.firstWhere((element) => element.id == taskInstanceId);
}
