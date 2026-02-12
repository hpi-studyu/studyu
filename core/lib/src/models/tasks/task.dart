import 'package:studyu_core/src/models/models.dart';
import 'package:uuid/uuid.dart';

abstract class Task {
  static const String keyType = 'type';
  String type;

  late String id;
  String? title;

  String? header;
  String? footer;

  Schedule schedule = Schedule();

  /// When non-null, this task should only be shown on the given
  /// study day (0-based from the study start date).
  int? scheduledStudyDay;

  Task(this.type);

  Task.withId(this.type) : id = const Uuid().v4();

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }

  Map<DateTime, T> extractPropertyResults<T>(
    String property,
    List<SubjectProgress> sourceResults,
  );

  Map<String, Type> getAvailableProperties();

  String? getHumanReadablePropertyName(String property);
}
