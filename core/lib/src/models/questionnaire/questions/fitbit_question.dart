import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/models/fitbit/fitbit_datas/fibit_data.dart';

part 'fitbit_question.g.dart';

@JsonSerializable()
class FitbitQuestion extends Question<FitbitQuestion> {
  static const String questionType = 'FitbitQuestion';

  List<FitbitQuestionType> types;

  FitbitQuestion({
    required this.types,
  }) : super(questionType);

  FitbitQuestion.withId({
    required String questionType,
    required this.types,
  }) : super.withId(questionType);

  factory FitbitQuestion.fromJson(Map<String, dynamic> json) =>
      _$FitbitQuestionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FitbitQuestionToJson(this);

  Answer<List<FitbitData>> constructAnswer(List<FitbitData> data) =>
      Answer.forQuestion(
        this,
        data,
      );
}

enum FitbitQuestionType {
  steps,
  sleep,
  heartrate;

  String toJson() => name;

  static FitbitQuestionType fromJson(String json) => values.byName(json);
}
