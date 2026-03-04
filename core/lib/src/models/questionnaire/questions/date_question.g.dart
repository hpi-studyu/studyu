// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateQuestion _$DateQuestionFromJson(Map<String, dynamic> json) =>
    DateQuestion(
        minDate: json['minDate'] == null
            ? null
            : DateTime.parse(json['minDate'] as String),
        maxDate: json['maxDate'] == null
            ? null
            : DateTime.parse(json['maxDate'] as String),
        dateFormatPreset:
            $enumDecodeNullable(
              _$DateFormatPresetEnumMap,
              json['dateFormatPreset'],
            ) ??
            DateFormatPreset.isoDate,
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
      'minDate': ?instance.minDate?.toIso8601String(),
      'maxDate': ?instance.maxDate?.toIso8601String(),
      'dateFormatPreset': instance.dateFormatPreset.toJson(),
    };

const _$DateFormatPresetEnumMap = {
  DateFormatPreset.isoDate: 'isoDate',
  DateFormatPreset.europeanDate: 'europeanDate',
  DateFormatPreset.usDate: 'usDate',
  DateFormatPreset.germanDate: 'germanDate',
  DateFormatPreset.isoDateTime: 'isoDateTime',
  DateFormatPreset.europeanDateTime: 'europeanDateTime',
  DateFormatPreset.usDateTimeAmPm: 'usDateTimeAmPm',
};
