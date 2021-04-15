import 'package:json_annotation/json_annotation.dart';

import '../../util/supabase_object.dart';
import '../results/result.dart';

part 'subject_progress.g.dart';

@JsonSerializable()
class SubjectProgress extends SupabaseObjectFunctions<SubjectProgress> {
  static const String tableName = 'subject_progress';

  @override
  String? id;
  DateTime? completedAt;
  String subjectId;
  String interventionId;
  String taskId;
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
