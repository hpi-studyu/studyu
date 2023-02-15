import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'schedule.g.dart';

typedef ScheduleParser = Schedule Function(Map<String, dynamic> data);

@JsonSerializable()
class Schedule {
  List<CompletionPeriod> completionPeriods = [
    CompletionPeriod.withId(
      unlockTime: StudyUTimeOfDay(hour: 8),
      lockTime: StudyUTimeOfDay(hour: 20),
    )
  ];
  List<StudyUTimeOfDay> reminders = [];

  Schedule();

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable()
class CompletionPeriod {
  // Todo make non-nullable (breaks backwards compatibility)
  String? id;
  final StudyUTimeOfDay unlockTime;
  final StudyUTimeOfDay lockTime;

  CompletionPeriod({required this.unlockTime, required this.lockTime});
  CompletionPeriod.withId({required this.unlockTime, required this.lockTime}) : id = const Uuid().v4();

  factory CompletionPeriod.fromJson(Map<String, dynamic> json) => _$CompletionPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$CompletionPeriodToJson(this);

  @override
  String toString() => '$unlockTime - $lockTime';

  bool contains(StudyUTimeOfDay time) {
    return unlockTime.earlierThan(time) && time.earlierThan(lockTime);
  }
}

class StudyUTimeOfDay {
  int hour = 0;
  int minute = 0;

  StudyUTimeOfDay({this.hour = 0, this.minute = 0}) : super();

  StudyUTimeOfDay.fromDateTime(DateTime date) {
    hour = date.toLocal().hour;
    minute = date.toLocal().minute;
  }

  StudyUTimeOfDay.now() {
    final now = StudyUTimeOfDay.fromDateTime(DateTime.now());
    hour = now.hour;
    minute = now.minute;
  }

  StudyUTimeOfDay.fromJson(String value) {
    final elements = value.split(':').map(int.parse);
    hour = elements.elementAt(0);
    minute = elements.elementAt(1);
  }

  String toJson() => toString();

  @override
  String toString() => '$hour:${minute.toString().padLeft(2, '0')}';

  bool earlierThan(StudyUTimeOfDay time, {bool exact = false}) {
    if (exact) {
      return hour < time.hour || hour == time.hour && minute < time.minute;
    }
    return hour < time.hour || hour == time.hour && minute <= time.minute;
  }
}
