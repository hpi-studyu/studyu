import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';
import 'package:studyu_core/src/models/questionnaire/questions/questions.dart';
import 'package:studyu_core/src/models/unknown_json_type_error.dart';
import 'package:uuid/uuid.dart';

typedef QuestionParser = Question Function(Map<String, dynamic> data);

abstract class Question<V> {
  static const String keyType = 'type';
  String type;
  late String id;
  String? prompt;
  String? rationale;

  static const String keyConditional = 'conditional';
  QuestionConditional<V>? conditional;

  Question(this.type);

  Question.withId(this.type) : id = const Uuid().v4();

  factory Question.fromJson(Map<String, dynamic> data) => switch (data[keyType]) {
        BooleanQuestion.questionType => BooleanQuestion.fromJson(data),
        ChoiceQuestion.questionType => ChoiceQuestion.fromJson(data),
        ScaleQuestion.questionType => ScaleQuestion.fromJson(data),
        AnnotatedScaleQuestion.questionType => AnnotatedScaleQuestion.fromJson(data),
        VisualAnalogueQuestion.questionType => VisualAnalogueQuestion.fromJson(data),
        ImageCapturingQuestion.questionType: (json) => ImageCapturingQuestion.fromJson(json),
        AudioRecordingQuestion.questionType: (json) => AudioRecordingQuestion.fromJson(json),
        FreeTextQuestion.questionType => FreeTextQuestion.fromJson(data),
        _ => throw UnknownJsonTypeError(data[keyType]),
      } as Question<V>;

  Map<String, dynamic> toJson();

  bool shouldBeShown(QuestionnaireState state) {
    if (conditional == null) return true;
    return conditional!.condition.evaluate(state) != false;
  }

  Answer<V>? getDefaultAnswer() {
    if (conditional == null || conditional!.defaultValue == null) return null;
    return Answer.forQuestion(this, conditional!.defaultValue as V);
  }

  Type getAnswerType() => V;

  @override
  String toString() {
    return toJson().toString();
  }
}
