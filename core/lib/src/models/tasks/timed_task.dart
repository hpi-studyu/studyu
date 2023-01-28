import 'package:studyu_core/core.dart';

class TimedTask {
  final Task task;
  final CompletionPeriod completionPeriod;
  // todo Use CompletionPeriod.id instead of CompletionPeriod here
  // CompletionPeriod is already a sub child of Task.
  // This change will break backwards compatibility because not every
  // completionPeriod in the current database has an Id
  // final String periodId;

  TimedTask(this.task, this.completionPeriod);
}
