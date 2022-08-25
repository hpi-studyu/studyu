import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class MeasurementSurveyFormData extends IFormDataWithSchedule {
  static final kDefaultTitle = tr.unnamed_survey;

  MeasurementSurveyFormData({
    required this.measurementId,
    required this.title,
    this.introText,
    this.outroText,
    required super.isTimeLocked,
    super.timeLockStart,
    super.timeLockEnd,
    required super.hasReminder,
    super.reminderTime,
    required this.questionnaireFormData,
  });

  final MeasurementID measurementId;
  final String title;
  final String? introText;
  final String? outroText;
  final QuestionnaireFormData questionnaireFormData;

  @override
  FormDataID get id => measurementId;

  factory MeasurementSurveyFormData.fromDomainModel(
      QuestionnaireTask questionnaireTask) {
    return MeasurementSurveyFormData(
      measurementId: questionnaireTask.id,
      title: questionnaireTask.title ?? '',
      introText: questionnaireTask.header,
      outroText: questionnaireTask.footer,
      questionnaireFormData:
          QuestionnaireFormData.fromDomainModel(questionnaireTask.questions),
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
    questionnaireTask.questions = questionnaireFormData.toQuestionnaire();
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
      questionnaireFormData: questionnaireFormData.copy(),
      isTimeLocked: isTimeLocked,
      timeLockStart: timeLockStart,
      timeLockEnd: timeLockEnd,
      hasReminder: hasReminder,
      reminderTime: reminderTime,
    );
  }
}
