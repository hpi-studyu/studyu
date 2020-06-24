import '../tasks/schedule.dart';

typedef TaskParser = Task Function(Map<String, dynamic> data);

abstract class Task {
  static const String keyType = 'type';
  String type;

  String id;
  String title;

  List<Schedule> schedule;

  Task();

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }
}
