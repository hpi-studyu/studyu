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
      id: json['id'] as String,
      unlockTime: StudyUTimeOfDay.fromJson(json['unlockTime'] as String),
      lockTime: StudyUTimeOfDay.fromJson(json['lockTime'] as String),
    );

Map<String, dynamic> _$CompletionPeriodToJson(CompletionPeriod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unlockTime': instance.unlockTime.toJson(),
      'lockTime': instance.lockTime.toJson(),
    };
