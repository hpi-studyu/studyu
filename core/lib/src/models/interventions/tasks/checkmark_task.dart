import 'package:json_annotation/json_annotation.dart';

import '../../tables/subject_progress.dart';
import '../../tasks/schedule.dart';
import '../intervention_task.dart';

part 'checkmark_task.g.dart';

@JsonSerializable()
class CheckmarkTask extends InterventionTask {
  static const String taskType = 'checkmark';

  CheckmarkTask() : super(taskType);

  CheckmarkTask.withId() : super.withId(taskType);

  factory CheckmarkTask.fromJson(Map<String, dynamic> json) => _$CheckmarkTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CheckmarkTaskToJson(this);

  @override
  Map<DateTime, T> extractPropertyResults<T>(String property, List<SubjectProgress> sourceResults) {
    throw ArgumentError("${runtimeType.toString()} does not have a property named '$property'.");
  }

  @override
  Map<String, Type> getAvailableProperties() => {};

  @override
  String? getHumanReadablePropertyName(String property) => null;
}
