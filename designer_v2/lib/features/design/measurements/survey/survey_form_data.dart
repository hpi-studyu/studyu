import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:uuid/uuid.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_data.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class MeasurementSurveyFormData extends IFormDataWithSchedule {
  static final kDefaultTitle = "Unnamed survey".hardcoded;

  MeasurementSurveyFormData({
    required this.measurementId,
    required this.title,
    this.introText,
    this.outroText,
    this.surveyQuestionsData,
    required super.isTimeLocked,
    super.timeLockStart,
    super.timeLockEnd,
    required super.hasReminder,
    super.reminderTime,
  });

  final MeasurementID measurementId;
  final String title;
  final String? introText;
  final String? outroText;
  final List<SurveyQuestionFormData>? surveyQuestionsData;

  @override
  FormDataID get id => measurementId;

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
      isTimeLocked: questionnaireTask.schedule.isTimeRestricted,
      timeLockStart: questionnaireTask.schedule.restrictedTimeStart,
      timeLockEnd: questionnaireTask.schedule.restrictedTimeEnd,
      hasReminder: questionnaireTask.schedule.hasReminder,
      reminderTime: questionnaireTask.schedule.reminderTime,
    );
  }

  QuestionnaireTask toQuestionnaireTask() {
    final questionnaireTask = QuestionnaireTask();
    questionnaireTask.id = measurementId;
    questionnaireTask.title = title;
    questionnaireTask.header = introText;
    questionnaireTask.footer = outroText;
    questionnaireTask.questions.questions = (surveyQuestionsData != null)
        ? surveyQuestionsData!.map((formData) => formData.toQuestion()).toList()
        : [];
    questionnaireTask.schedule = toSchedule();
    return questionnaireTask;
  }

  @override
  MeasurementSurveyFormData copy() {
    return MeasurementSurveyFormData(
      measurementId: const Uuid().v4(), // always regenerate id
      title: title.withDuplicateLabel(),
      introText: introText,
      outroText: outroText,
      surveyQuestionsData: surveyQuestionsData, // TODO: map(copyFrom)
      isTimeLocked: isTimeLocked,
      timeLockStart: timeLockStart,
      timeLockEnd: timeLockEnd,
      hasReminder: hasReminder,
      reminderTime: reminderTime,
    );
  }
}
