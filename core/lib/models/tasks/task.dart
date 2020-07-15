import '../tasks/schedule.dart';

abstract class Task {
  static const String keyType = 'type';
  String type;

  String id;
  String title;

  List<Schedule> schedule;

  Task(this.type);

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }
}
