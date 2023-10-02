import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyMeasurementsRobot {
  const StudyMeasurementsRobot(this.$);

  final PatrolTester $;

  Future<void> tapAddSurveyButton() async {
    await $(tr.form_array_measurements_surveys_new).tap();
  }

  Future<void> tapAddSurveyQuestionButton() async {
    await $(tr.form_array_measurement_survey_questions_new).tap();
  }

  Future<void> tapSaveSurveyButton() async {
    await $(tr.dialog_save).tap();
  }

  Future<void> tapSaveSurveyQuestionButton() async {
    await $(tr.dialog_save).tap();
  }

  Future<void> enterSurveyName(String surveyName) async {
    await $(TextField)
        .which<TextField>((widget) =>
            widget.decoration is InputDecoration &&
            widget.decoration!.hintText != null &&
            widget.decoration!.hintText! == tr.form_field_measurement_survey_title)
        .scrollTo()
        .enterText(surveyName);
  }

  Future<void> enterSurveyIntroText(String introText) async {
    await $(TextField)
        .which<TextField>((widget) =>
            widget.decoration is InputDecoration &&
            widget.decoration!.hintText != null &&
            widget.decoration!.hintText! == tr.form_field_measurement_survey_intro_text_hint)
        .scrollTo()
        .enterText(introText);
  }

  Future<void> enterSurveyOutroText(String outroText) async {
    await $(TextField)
        .which<TextField>((widget) =>
            widget.decoration is InputDecoration &&
            widget.decoration!.hintText != null &&
            widget.decoration!.hintText! == tr.form_field_measurement_survey_outro_text_hint)
        .scrollTo()
        .enterText(outroText);
  }

  Future<void> enterSurveyQuestionText(String questionText) async {
    await $(TextField)
        .which<TextField>((widget) =>
            widget.decoration is InputDecoration &&
            widget.decoration!.hintText != null &&
            widget.decoration!.hintText! == tr.form_field_question)
        .scrollTo()
        .enterText(questionText);
  }

  Future<void> enterSurveyQuestionOption1(String optionText) async {
    await $(TextField)
        .which<TextField>((widget) =>
            widget.decoration is InputDecoration &&
            widget.decoration!.hintText != null &&
            widget.decoration!.hintText! == tr.form_array_response_options_choice_hint)
        .at(0)
        .scrollTo()
        .enterText(optionText);
  }

  Future<void> enterSurveyQuestionOption2(String optionText) async {
    await $(TextField)
        .which<TextField>((widget) =>
            widget.decoration is InputDecoration &&
            widget.decoration!.hintText != null &&
            widget.decoration!.hintText! == tr.form_array_response_options_choice_hint)
        .at(1)
        .scrollTo()
        .enterText(optionText);
  }
}
