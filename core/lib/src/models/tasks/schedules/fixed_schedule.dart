import 'package:json_annotation/json_annotation.dart';

import '../schedule.dart';

part 'fixed_schedule.g.dart';

@JsonSerializable()
class FixedSchedule extends Schedule {
  static const String scheduleType = 'fixed';

  ScheduleTime time;

  FixedSchedule() : super(scheduleType);

  factory FixedSchedule.fromJson(Map<String, dynamic> json) => _$FixedScheduleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FixedScheduleToJson(this);
}

class ScheduleTime {
  int hour;
  int minute;

  ScheduleTime({this.hour, this.minute}) : super();

  ScheduleTime.fromJson(String value) {
    final elements = value.split(':').map(int.parse);
    hour = elements.elementAt(0);
    minute = elements.elementAt(1);
  }

  String toJson() => toString();

  @override
  String toString() => '$hour:${minute.toString().padLeft(2, '0')}';

  bool earlierThan(ScheduleTime time) {
    return hour < time.hour || hour == time.hour && minute < time.minute;
  }
}
