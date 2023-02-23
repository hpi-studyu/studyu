import 'package:studyu_core/core.dart';

class TaskInstance {
  final Task task;
  final String id;

  TaskInstance(this.task, this.id) : assert(task.id != id);

  factory TaskInstance.fromInstanceId(String taskInstanceId, DateTime now, StudySubject subject) {
    final task = _taskFromInstanceId(taskInstanceId, now, subject);
    assert(task.id != taskInstanceId);
    return TaskInstance(task, taskInstanceId);
  }

  static Task _taskFromInstanceId(String id, DateTime now, StudySubject subject) {
    return subject.scheduleFor(now).firstWhere((element) => element.id == id).task;
  }
  
  CompletionPeriod get completionPeriod =>
      task.schedule.completionPeriods.firstWhere((element) => element.id == id);
}
