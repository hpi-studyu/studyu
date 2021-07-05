import 'package:json_annotation/json_annotation.dart';

import '../../util/supabase_object.dart';
import '../results/result.dart';

part 'subject_progress.g.dart';

@JsonSerializable()
class SubjectProgress extends SupabaseObjectFunctions<SubjectProgress> {
  static const String tableName = 'subject_progress';

  @override
  Map<String, dynamic> get primaryKeys => {'completedAt': completedAt, 'subjectId': subjectId};

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

  SubjectProgress(
      {required this.subjectId,
      required this.interventionId,
      required this.taskId,
      required this.resultType,
      required this.result});

  factory SubjectProgress.fromJson(Map<String, dynamic> json) => _$SubjectProgressFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubjectProgressToJson(this);

  SubjectProgress setStartDateBackBy({required int days}) {
    completedAt = completedAt!.subtract(Duration(days: days));
    return this;
  }
}
