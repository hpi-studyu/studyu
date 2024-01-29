import 'package:studyu_core/src/models/models.dart';

class UnknownTask extends Observation {
  static const String taskType = 'unknown';

  UnknownTask() : super(taskType);

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
  Map<String, dynamic> toJson() {
    throw ArgumentError('UnknownTask should not be serialized');
  }
}
