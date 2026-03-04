import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';
import 'package:studyu_core/src/models/questionnaire/questions/date_format_preset.dart';

part 'date_question.g.dart';

@JsonSerializable()
class DateQuestion extends Question<DateTime> {
  static const String questionType = 'date';

  @JsonKey(name: 'minDate')
  DateTime? minDate;

  @JsonKey(name: 'maxDate')
  DateTime? maxDate;

  @JsonKey(name: 'dateFormatPreset')
  DateFormatPreset dateFormatPreset;

  DateQuestion({
    this.minDate,
    this.maxDate,
    this.dateFormatPreset = DateFormatPreset.isoDate,
  }) : super(questionType);

  DateQuestion.withId({
    this.minDate,
    this.maxDate,
    this.dateFormatPreset = DateFormatPreset.isoDate,
  }) : super.withId(questionType);

  factory DateQuestion.fromJson(Map<String, dynamic> json) =>
      _$DateQuestionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DateQuestionToJson(this);

  Answer<DateTime> constructAnswer(DateTime response) =>
      Answer.forQuestion(this, response);

  String get dateFormat => dateFormatPreset.pattern;

  bool get includeTime => dateFormatPreset.includesTime;
}
