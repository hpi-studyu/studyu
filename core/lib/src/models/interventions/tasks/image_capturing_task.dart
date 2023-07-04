import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/interventions/intervention_task.dart';
import 'package:studyu_core/src/models/tables/subject_progress.dart';
import 'package:studyu_core/src/models/tasks/schedule.dart';

part 'image_capturing_task.g.dart';

@JsonSerializable()
class ImageCapturingTask extends InterventionTask {
  static const String taskType = 'image_capturing';

  ImageCapturingTask() : super(taskType);

  ImageCapturingTask.withId() : super.withId(taskType);

  factory ImageCapturingTask.fromJson(Map<String, dynamic> json) => _$ImageCapturingTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageCapturingTaskToJson(this);

  @override
  Map<DateTime, T> extractPropertyResults<T>(String property, List<SubjectProgress> sourceResults) {
    throw ArgumentError("$runtimeType does not have a property named '$property'.");
  }

  @override
  Map<String, Type> getAvailableProperties() => {};

  @override
  String? getHumanReadablePropertyName(String property) => null;
}
