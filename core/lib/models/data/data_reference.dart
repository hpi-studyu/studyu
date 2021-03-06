import 'package:json_annotation/json_annotation.dart';

import '../results/result.dart';
import '../study/user_study.dart';
import '../tasks/task.dart';

part 'data_reference.g.dart';

@JsonSerializable()
class DataReference<T> {
  String task;
  String property;

  DataReference();

  factory DataReference.fromJson(Map<String, dynamic> json) => _$DataReferenceFromJson(json);

  Map<String, dynamic> toJson() => _$DataReferenceToJson(this);

  @override
  String toString() => toJson().toString();

  Map<DateTime, T> retrieveFromResults(UserStudyBase studyInstance) {
    final Task sourceTask = studyInstance.observations.firstWhere((task) => task.id == this.task, orElse: () => null) ??
        studyInstance.interventionSet.interventions.firstWhere((task) => task.id == this.task, orElse: () => null);
    if (sourceTask == null) throw ArgumentError("Could not find a task with the id '$task'.");

    final List<Result> sourceResults = studyInstance.resultsFor(task) ?? [];

    return sourceTask.extractPropertyResults<T>(property, sourceResults);
  }
}
