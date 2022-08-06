import 'package:studyu_designer_v2/domain/questionnaire.dart';
import 'package:uuid/uuid.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_data.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class MeasurementSurveyFormData {
  static final kDefaultTitle = "Unnamed survey".hardcoded;

  MeasurementSurveyFormData({
    required this.measurementId,
    required this.title,
    this.introText,
    this.outroText,
    this.surveyQuestionsData,
    required this.isTimeRestricted,
    this.restrictedTimeStart,
    this.restrictedTimeEnd,
    required this.hasReminder,
    this.reminderTime,
  });

  final MeasurementID measurementId;
  final String title;
  final String? introText;
  final String? outroText;
  final List<SurveyQuestionFormData>? surveyQuestionsData;
  final bool isTimeRestricted;
  final StudyUTimeOfDay? restrictedTimeStart;
  final StudyUTimeOfDay? restrictedTimeEnd;
  final bool hasReminder;
  final StudyUTimeOfDay? reminderTime;

  factory MeasurementSurveyFormData.fromDomainModel(
      QuestionnaireTask questionnaireTask) {
    return MeasurementSurveyFormData(
        measurementId: questionnaireTask.id,
        title: questionnaireTask.title ?? '',
        introText: questionnaireTask.header,
        outroText: questionnaireTask.footer,
        surveyQuestionsData: questionnaireTask.questions.questions
            .map((question) => SurveyQuestionFormData.fromDomainModel(question))
            .toList(),
        isTimeRestricted: questionnaireTask.schedule.isTimeRestricted,
        restrictedTimeStart: questionnaireTask.schedule.restrictedTimeStart,
        restrictedTimeEnd: questionnaireTask.schedule.restrictedTimeEnd,
        hasReminder: questionnaireTask.schedule.hasReminder,
        reminderTime: questionnaireTask.schedule.reminderTime,

    );
  }

  MeasurementSurveyFormData copy() {
    return MeasurementSurveyFormData(
      measurementId: const Uuid().v4(), // always regenerate id
      title: title.withDuplicateLabel(),
      introText: introText,
      outroText: outroText,
      surveyQuestionsData: surveyQuestionsData, // TODO: map(copyFrom)
      isTimeRestricted: isTimeRestricted,
      restrictedTimeStart: restrictedTimeStart,
      restrictedTimeEnd: restrictedTimeEnd,
      hasReminder: hasReminder,
      reminderTime: reminderTime,
    );
  }

// We can't have this because we might produce multiple domain models?
// Idea: should we provide a function to modify/update/write the study here? (or a on-write copy of the study)?
/*
  QuestionnaireTask toDomainModel() {
    return QuestionnaireTask(

  }*/
}
