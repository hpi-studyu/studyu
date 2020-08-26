import 'package:json_annotation/json_annotation.dart';
import 'package:studyou_core/models/results/result.dart';

import '../../tasks/schedule.dart';
import '../intervention_task.dart';

part 'checkmark_task.g.dart';

@JsonSerializable()
class CheckmarkTask extends InterventionTask {
  static const String taskType = 'checkmark';

  CheckmarkTask() : super(taskType);

  factory CheckmarkTask.fromJson(Map<String, dynamic> json) => _$CheckmarkTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CheckmarkTaskToJson(this);

  @override
  Map<DateTime, T> extractPropertyResults<T>(String property, List<Result> sourceResults) {
    throw new ArgumentError('${this.runtimeType.toString()} does not have a property named \'$property\'.');
  }

  @override
  Map<String, Type> getAvailableProperties() => {};

  @override
  String getHumanReadablePropertyName(String property) => null;
}
