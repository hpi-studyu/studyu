import 'package:studyu_core/src/models/interventions/intervention_task.dart';
import 'package:studyu_core/src/models/tables/subject_progress.dart';

class UnknownInterventionTask extends InterventionTask {
  static const String taskType = 'unknown';

  UnknownInterventionTask() : super(taskType);

  @override
  bool get isSupported => false;

  @override
  Map<DateTime, T> extractPropertyResults<T>(String property, List<SubjectProgress> sourceResults) {
    throw UnimplementedError();
  }

  @override
  Map<String, Type> getAvailableProperties() {
    throw UnimplementedError();
  }

  @override
  String? getHumanReadablePropertyName(String property) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() => throw ArgumentError('UnknownTask should not be serialized');
}
