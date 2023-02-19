// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule()
  ..completionPeriods = (json['completionPeriods'] as List<dynamic>)
      .map((e) => CompletionPeriod.fromJson(e as Map<String, dynamic>))
      .toList()
  ..reminders = (json['reminders'] as List<dynamic>)
      .map((e) => StudyUTimeOfDay.fromJson(e as String))
      .toList();

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
      'completionPeriods':
          instance.completionPeriods.map((e) => e.toJson()).toList(),
      'reminders': instance.reminders.map((e) => e.toJson()).toList(),
    };

CompletionPeriod _$CompletionPeriodFromJson(Map<String, dynamic> json) =>
    CompletionPeriod(
      unlockTime: StudyUTimeOfDay.fromJson(json['unlockTime'] as String),
      lockTime: StudyUTimeOfDay.fromJson(json['lockTime'] as String),
    )..id = json['id'] as String?;

Map<String, dynamic> _$CompletionPeriodToJson(CompletionPeriod instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['unlockTime'] = instance.unlockTime.toJson();
  val['lockTime'] = instance.lockTime.toJson();
  return val;
}
