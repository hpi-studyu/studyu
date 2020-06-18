import 'fixed_schedule.dart';

typedef ScheduleParser = Schedule Function(Map<String, dynamic> data);

abstract class Schedule {
  static Map<String, ScheduleParser> scheduleTypes = {
    FixedSchedule.scheduleType: (json) => FixedSchedule.fromJson(json),
  };
  static const String keyType = 'type';
  String type;

  Schedule();

  factory Schedule.fromJson(Map<String, dynamic> data) => scheduleTypes[data[keyType]](data);

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }
}
