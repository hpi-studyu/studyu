import 'package:uuid/uuid.dart';

import '../results/result.dart';
import '../tasks/schedule.dart';

abstract class Task {
  static const String keyType = 'type';
  String type;

  String id;
  String title;

  List<Schedule> schedule;

  Task(this.type);

  Task.designer(this.type)
      : id = Uuid().v4(),
        schedule = [];

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }

  Map<DateTime, T> extractPropertyResults<T>(String property, List<Result> sourceResults);

  Map<String, Type> getAvailableProperties();

  String getHumanReadablePropertyName(String property);
}
