import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/medication/medication_answer.dart';
import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';

part 'medication_question.g.dart';

@JsonSerializable()
class MedicationQuestion extends Question<MedicationAnswer> {
  static const String questionType = 'medication';

  MedicationQuestion() : super(questionType);

  MedicationQuestion.withId() : super.withId(questionType);

  factory MedicationQuestion.fromJson(Map<String, dynamic> json) =>
      _$MedicationQuestionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MedicationQuestionToJson(this);

  Answer<MedicationAnswer> constructAnswer(MedicationAnswer response) =>
      Answer.forQuestion(this, response);
}
