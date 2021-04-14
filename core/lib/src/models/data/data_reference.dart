import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';

import '../results/result.dart';
import '../tables/user_study.dart';
import '../tasks/task.dart';

part 'data_reference.g.dart';

@JsonSerializable()
class DataReference<T> {
  String task;
  String property;

  DataReference(this.task, this.property);

  factory DataReference.fromJson(Map<String, dynamic> json) => _$DataReferenceFromJson(json);

  Map<String, dynamic> toJson() => _$DataReferenceToJson(this);

  @override
  String toString() => toJson().toString();

  Map<DateTime, T> retrieveFromResults(UserStudy studyInstance) {
    final Task? sourceTask = studyInstance.study.observations.firstWhereOrNull((task) => task.id == this.task) ??
        studyInstance.selectedInterventions
            .expand((i) => i.tasks)
            .firstWhereOrNull((task) => task.id == this.task);
    if (sourceTask == null) throw ArgumentError("Could not find a task with the id '$task'.");

    final List<Result> sourceResults = studyInstance.resultsFor(task) ?? [];

    return sourceTask.extractPropertyResults<T>(property, sourceResults);
  }
}
