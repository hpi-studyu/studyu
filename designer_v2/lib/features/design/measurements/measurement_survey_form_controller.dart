import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey_question_form.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:uuid/uuid.dart';

// TODO: scheduling fields
class MeasurementSurveyFormData {
  static final kDefaultTitle = "Unnamed survey".hardcoded;

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

  factory MeasurementSurveyFormData.copyFrom(MeasurementSurveyFormData formData) {
    return MeasurementSurveyFormData(
      measurementId: const Uuid().v4(), // always regenerate id
      title: formData.title + kDuplicateSuffix,
      introText: formData.introText,
      outroText: formData.outroText,
      surveyQuestionsFormData: formData.surveyQuestionsFormData, // TODO: map(copyFrom)
    );
  }

  // We can't have this because we might produce multiple domain models?
  // Idea: should we provide a function to modify/update/write the study here? (or a on-write copy of the study)?
  /*
  QuestionnaireTask toDomainModel() {
    return QuestionnaireTask(

  }*/
}

class MeasurementSurveyFormViewModel extends FormViewModel<MeasurementSurveyFormData>
    implements IFormViewModelDelegate<SurveyQuestionFormViewModel> {

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
  late final FormGroup form = FormGroup({
    'surveyTitle': surveyTitleControl,
    'surveyIntroText': surveyIntroTextControl,
    'surveyOutroText': surveyOutroTextControl,
    'surveyQuestions': surveyQuestionsArray,
  });

  @override
  void setFormControlDefaults() {
    surveyTitleControl.value = MeasurementSurveyFormData.kDefaultTitle;
  }

  @override
  void setFormControlValuesFrom(MeasurementSurveyFormData data) {
    surveyTitleControl.value = data.title;
    surveyIntroTextControl.value = data.introText ?? '';
    surveyOutroTextControl.value = data.outroText ?? '';
    if (data.surveyQuestionsFormData != null) {
      for (final surveyQuestionFormData in data.surveyQuestionsFormData!) {
        surveyQuestionFormViewModels.add(
            SurveyQuestionFormViewModel(formData: surveyQuestionFormData, delegate: this));
      }
    }
  }

  @override
  MeasurementSurveyFormData buildFormDataFromControls() {
    return MeasurementSurveyFormData(
      measurementId: formData?.measurementId ?? const Uuid().v4(), // existing or new
      title: surveyTitleControl.value!, // required field
      introText: surveyIntroTextControl.value,
      outroText: surveyOutroTextControl.value,
      surveyQuestionsFormData: surveyQuestionFormViewModels.map(
              (vm) => vm.buildFormDataFromControls()).toList()
    );
  }

  String get breadcrumbsTitle {
    final components = [
      study.title, formData?.title ?? MeasurementSurveyFormData.kDefaultTitle
    ];
    return components.join(kPathSeparator);
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: breadcrumbsTitle,
    FormMode.edit: breadcrumbsTitle,
  };

  // - IFormViewModelDelegate

  @override
  void onClose(SurveyQuestionFormViewModel formViewModel, FormMode prevFormMode) {
    // TODO: implement onClose
  }

  @override
  void onSave(SurveyQuestionFormViewModel formViewModel, FormMode prevFormMode) {
    // TODO: implement onSave
  }
}
