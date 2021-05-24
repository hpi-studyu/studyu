import 'package:studyou_core/core.dart';
import 'package:uuid/uuid.dart';

import '../tasks/schedule.dart';

abstract class Task {
  static const String keyType = 'type';
  String type;

  late String id;
  String? title;

  String? header;
  String? footer;

  List<Schedule> schedule = [];

  Task(this.type);

  Task.withId(this.type) : id = Uuid().v4();

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }

  Map<DateTime, T> extractPropertyResults<T>(String property, List<SubjectProgress> sourceResults);

  Map<String, Type> getAvailableProperties();

  String? getHumanReadablePropertyName(String property);
}
