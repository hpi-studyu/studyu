import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/results/result.dart';
import 'package:studyu_core/src/util/supabase_object.dart';

part 'subject_progress.g.dart';

@JsonSerializable()
class SubjectProgress extends SupabaseObjectFunctions<SubjectProgress> {
  static const String tableName = 'subject_progress';

  @override
  Map<String, Object> get primaryKeys =>
      {'completed_at': completedAt!, 'subject_id': subjectId};

  // stored in UTC format, be careful when comparing dates
  @JsonKey(name: 'completed_at')
  DateTime? completedAt;
  @JsonKey(name: 'subject_id')
  String subjectId;
  @JsonKey(name: 'intervention_id')
  String interventionId;
  @JsonKey(name: 'task_id')
  String taskId;
  @JsonKey(name: 'result_type')
  String resultType;
  Result result;

  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime? startedAt;

  SubjectProgress({
    required this.subjectId,
    required this.interventionId,
    required this.taskId,
    required this.resultType,
    required this.result,
  });

  factory SubjectProgress.fromJson(Map<String, dynamic> json) {
    final progress = _$SubjectProgressFromJson(json);

    final String? startedAt = json['started_at'] as String?;
    if (startedAt != null) {
      progress.startedAt = DateTime.parse(startedAt);
    }

    return progress;
  }

  @override
  Map<String, dynamic> toJson() => _$SubjectProgressToJson(this);

  SubjectProgress setStartDateBackBy({required int days}) {
    completedAt = completedAt!.subtract(Duration(days: days));
    startedAt = startedAt?.subtract(Duration(days: days));
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectProgress &&
          runtimeType == other.runtimeType &&
          jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => toJson().hashCode;
}
