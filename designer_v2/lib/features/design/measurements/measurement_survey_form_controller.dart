import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey_question_form.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:uuid/uuid.dart';

// TODO: scheduling fields

/*
class MeasurementSurveyFormData {
  MeasurementSurveyFormData({required this.questionnaireTask});

  final QuestionnaireTask questionnaireTask;

  MeasurementID get measurementId => questionnaireTask.id;
  String get title => questionnaireTask.title ?? '';
  String get introText => questionnaireTask.header ?? '';
  String get outroText => questionnaireTask.footer ?? '';
  List<SurveyQuestionFormData>? get surveyQuestions =>
      questionnaireTask.questions.questions.map(
              (q) => SurveyQuestionFormData(question: q)).toList();

  factory MeasurementSurveyFormData.fromDomainModel(QuestionnaireTask questionnaireTask) {

  }

  QuestionnaireTask toDomainModel
}
 */

class MeasurementSurveyFormData {
  MeasurementSurveyFormData({
    required this.measurementId,
    required this.title,
    this.introText,
    this.outroText,
    this.surveyQuestionsFormData
  });

  final MeasurementID measurementId;
  final String title;
  final String? introText;
  final String? outroText;
  final List<SurveyQuestionFormData>? surveyQuestionsFormData;

  factory MeasurementSurveyFormData.fromDomainModel(QuestionnaireTask questionnaireTask) {
    return MeasurementSurveyFormData(
      measurementId: questionnaireTask.id,
      title: questionnaireTask.title ?? '',
      introText: questionnaireTask.header,
      outroText: questionnaireTask.footer,
      surveyQuestionsFormData: questionnaireTask.questions.questions.map(
              (q) => SurveyQuestionFormData(question: q)).toList()
    );
  }

  // We can't have this because we might produce multiple domain models?
  // Idea: should we provide a function to modify/update/write the study here? (or a on-write copy of the study)?
  /*
  QuestionnaireTask toDomainModel() {
    return QuestionnaireTask(

  }*/
}

class MeasurementSurveyFormViewModel extends FormViewModel<MeasurementSurveyFormData> {
  MeasurementSurveyFormViewModel({
    required this.study,
    super.delegate,
    super.formData,
  });

  final Study study;
  final List<SurveyQuestionFormViewModel> surveyQuestionFormViewModels = [];

  // - Form fields

  final FormControl<String> surveyTitleControl = FormControl(validators: [
    Validators.minLength(3),
  ]);
  final FormControl<String> surveyIntroTextControl = FormControl();
  final FormControl<String> surveyOutroTextControl = FormControl();

  FormArray get surveyQuestionsArray => FormArray(
      surveyQuestionFormViewModels.map((vm) => vm.form).toList());

  @override
  FormGroup get form => FormGroup({
    'surveyTitle': surveyTitleControl,
    'surveyIntroText': surveyIntroTextControl,
    'surveyOutroText': surveyOutroTextControl,
    'surveyQuestions': surveyQuestionsArray,
  });

  @override
  void setFormDefaults() {
    surveyTitleControl.value = "Unnamed survey".hardcoded;
  }

  @override
  void fromData(MeasurementSurveyFormData data) {
    surveyTitleControl.value = data.title;
    surveyIntroTextControl.value = data.introText ?? '';
    surveyOutroTextControl.value = data.outroText ?? '';
    if (data.surveyQuestionsFormData != null) {
      for (final surveyQuestionFormData in data.surveyQuestionsFormData!) {
        surveyQuestionFormViewModels.add(
            SurveyQuestionFormViewModel(formData: surveyQuestionFormData, parent: this));
      }
    }
  }

  @override
  MeasurementSurveyFormData toData() {
    // Collect data from all controls
    // Create a new domain model instance from controls' values
    // TODO: build new/updated observation
    /*
    final questionnaireTask = QuestionnaireTask.withId();
    questionnaireTask.title = surveyTitleControl.value!;
    questionnaireTask.header
    return MeasurementSurveyFormData(
      questionnaireTask: ,
        observation: QuestionnaireTask(),
        title: surveyTitleControl.value!, // required field
        introText: surveyIntroTextControl.value,
        outroText: surveyOutroTextControl.value,
        surveyQuestions: surveyQuestionFormViewModels.map(
                (vm) => vm.toData()).toList()
    );
     */
    return MeasurementSurveyFormData(
      measurementId: data?.measurementId ?? const Uuid().v4(), // existing or new
      title: surveyTitleControl.value!, // required field
      introText: surveyIntroTextControl.value,
      outroText: surveyOutroTextControl.value,
      surveyQuestionsFormData: surveyQuestionFormViewModels.map(
              (vm) => vm.toData()).toList()
    );
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: "TODO Create",
    FormMode.edit: "TODO Edit",
  };
}
