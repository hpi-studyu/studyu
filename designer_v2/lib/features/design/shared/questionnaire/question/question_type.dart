import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

enum SurveyQuestionType {
  choice,
  bool,
  scale;

  static SurveyQuestionType of(Question question) {
    final typeMapping = {
      BooleanQuestion.questionType: SurveyQuestionType.bool,
      ChoiceQuestion.questionType: SurveyQuestionType.choice,
      ScaleQuestion.questionType: SurveyQuestionType.scale,
      AnnotatedScaleQuestion.questionType: SurveyQuestionType.scale,
      VisualAnalogueQuestion.questionType: SurveyQuestionType.scale,
    };
    if (!typeMapping.containsKey(question.type)) {
      throw UnimplementedError("Missing SurveyQuestionType for question of type: ${question.type}");
    }
    return typeMapping[question.type]!;
  }

  String get string {
    switch (this) {
      case SurveyQuestionType.choice:
        return tr.question_type_choice;
      case SurveyQuestionType.bool:
        return tr.question_type_bool;
      case SurveyQuestionType.scale:
        return tr.question_type_scale;
      default:
        return "[Invalid SurveyQuestionType]";
    }
  }

  IconData? get icon {
    switch (this) {
      case SurveyQuestionType.choice:
        return Icons.format_list_bulleted_rounded;
      case SurveyQuestionType.bool:
        return Icons.rule_rounded; // Icons.contrast
      case SurveyQuestionType.scale:
        return Icons.tune_rounded;
      default:
        return null;
    }
  }

  String toJson() => name;
  static SurveyQuestionType fromJson(String json) => values.byName(json);
}
