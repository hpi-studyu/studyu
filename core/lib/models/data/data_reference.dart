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
    Task sourceTask = studyInstance.observations.firstWhere((task) => task.id == this.task, orElse: null) ??
        studyInstance.interventionSet.interventions.firstWhere((task) => task.id == this.task, orElse: null);
    if (sourceTask == null) throw new ArgumentError('Could not find a task with the id \'${this.task}\'.');

    List<Result> sourceResults = studyInstance.resultsFor(this.task);
    if (sourceResults == null) sourceResults = [];

    return sourceTask.extractPropertyResults<T>(this.property, sourceResults);
  }
}
