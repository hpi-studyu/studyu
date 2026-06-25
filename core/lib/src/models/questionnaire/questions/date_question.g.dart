// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateQuestion _$DateQuestionFromJson(Map<String, dynamic> json) =>
    DateQuestion(
        inputType:
            $enumDecodeNullable(_$DateInputTypeEnumMap, json['inputType']) ??
            DateInputType.date,
        minDate: json['minDate'] == null
            ? null
            : DateTime.parse(json['minDate'] as String),
        maxDate: json['maxDate'] == null
            ? null
            : DateTime.parse(json['maxDate'] as String),
        minTime: json['minTime'] as String?,
        maxTime: json['maxTime'] as String?,
        dateFormatPreset:
            $enumDecodeNullable(
              _$DateFormatPresetEnumMap,
              json['dateFormatPreset'],
            ) ??
            DateFormatPreset.iso,
        timeFormatPreset:
            $enumDecodeNullable(
              _$TimeFormatPresetEnumMap,
              json['timeFormatPreset'],
            ) ??
            TimeFormatPreset.h24,
        defaultOption:
            $enumDecodeNullable(
              _$DefaultDateOptionEnumMap,
              json['defaultOption'],
            ) ??
            DefaultDateOption.none,
        defaultSpecificDate: json['defaultSpecificDate'] == null
            ? null
            : DateTime.parse(json['defaultSpecificDate'] as String),
        defaultSpecificTime: json['defaultSpecificTime'] as String?,
      )
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<DateTime>.fromJson(
              json['conditional'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$DateQuestionToJson(DateQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'prompt': ?instance.prompt,
      'rationale': ?instance.rationale,
      'conditional': ?instance.conditional?.toJson(),
      'inputType': instance.inputType.toJson(),
      'minDate': ?instance.minDate?.toIso8601String(),
      'maxDate': ?instance.maxDate?.toIso8601String(),
      'minTime': ?instance.minTime,
      'maxTime': ?instance.maxTime,
      'dateFormatPreset': instance.dateFormatPreset.toJson(),
      'timeFormatPreset': instance.timeFormatPreset.toJson(),
      'defaultOption': instance.defaultOption.toJson(),
      'defaultSpecificDate': ?instance.defaultSpecificDate?.toIso8601String(),
      'defaultSpecificTime': ?instance.defaultSpecificTime,
    };

const _$DateInputTypeEnumMap = {
  DateInputType.date: 'date',
  DateInputType.time: 'time',
  DateInputType.dateTime: 'dateTime',
};

const _$DateFormatPresetEnumMap = {
  DateFormatPreset.iso: 'iso',
  DateFormatPreset.european: 'european',
  DateFormatPreset.us: 'us',
  DateFormatPreset.german: 'german',
};

const _$TimeFormatPresetEnumMap = {
  TimeFormatPreset.h24: 'h24',
  TimeFormatPreset.h12: 'h12',
};

const _$DefaultDateOptionEnumMap = {
  DefaultDateOption.none: 'none',
  DefaultDateOption.today: 'today',
  DefaultDateOption.now: 'now',
  DefaultDateOption.specific: 'specific',
};
