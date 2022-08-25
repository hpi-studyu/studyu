import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

enum SurveyQuestionType {
  choice, bool, scale;

  static SurveyQuestionType of(Question question) {
    final typeMapping = {
      BooleanQuestion.questionType: SurveyQuestionType.bool,
      ChoiceQuestion.questionType: SurveyQuestionType.choice,
      AnnotatedScaleQuestion.questionType: SurveyQuestionType.scale,
      VisualAnalogueQuestion.questionType: SurveyQuestionType.scale,
    };
    if (!typeMapping.containsKey(question.type)) {
      throw UnimplementedError(
          "Missing SurveyQuestionType for question of type: ${question.type}");
    }
    return typeMapping[question.type]!;
  }

  String get string {
    switch (this) {
      case SurveyQuestionType.choice:
        return tr.multiple_choice;
      case SurveyQuestionType.bool:
        return tr.yes_No;
      case SurveyQuestionType.scale:
        return tr.scale;
      default:
        return "[Invalid SurveyQuestionType]";
    }
  }
}
