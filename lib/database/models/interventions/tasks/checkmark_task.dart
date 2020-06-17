import 'package:json_annotation/json_annotation.dart';

import '../task.dart';

part 'checkmark_task.g.dart';

@JsonSerializable()
class CheckmarkTask extends Task {
  static const String taskType = 'checkmark';

  CheckmarkTask();

  factory CheckmarkTask.fromJson(Map<String, dynamic> json) => _$CheckmarkTaskFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CheckmarkTaskToJson(this);
}
