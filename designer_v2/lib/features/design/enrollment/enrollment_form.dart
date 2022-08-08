import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_question_form.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class EnrollmentFormData implements IStudyFormData {
  final Participation enrollmentType;
  final List<EnrollmentQuestionFormData> enrollmentQuestions;

  EnrollmentFormData({
    required this.enrollmentType,
    required this.enrollmentQuestions
  });

  factory EnrollmentFormData.fromStudy(Study study) {
    return EnrollmentFormData(
        enrollmentType: study.participation,
        enrollmentQuestions: []
    );
  }

  @override
  Study apply(Study study) {
    // TODO: implement apply
    throw UnimplementedError();
  }
}

class EnrollmentFormViewModel extends FormViewModel<EnrollmentFormData>
    implements IFormViewModelDelegate<EnrollmentQuestionFormViewModel> {

  EnrollmentFormViewModel({super.formData});

  final List<EnrollmentQuestionFormViewModel> enrollmentQuestionFormViewModels = [];

  // - Form fields

  final FormControl<Participation> enrollmentTypeControl = FormControl();

  FormArray get enrollmentQuestionsArray => FormArray(
      enrollmentQuestionFormViewModels.map((vm) => vm.form).toList());

  @override
  FormGroup get form => FormGroup({
    'enrollmentType': enrollmentTypeControl,
    'enrollmentQuestions': enrollmentQuestionsArray,
  });

  @override
  void setControlsFrom(EnrollmentFormData data) {
    enrollmentTypeControl.value = data.enrollmentType;
    for (final enrollmentQuestion in data.enrollmentQuestions) {
      enrollmentQuestionFormViewModels.add(
          EnrollmentQuestionFormViewModel(formData: enrollmentQuestion, delegate: this));
    }
  }

  @override
  EnrollmentFormData buildFormData() {
    return EnrollmentFormData(
      enrollmentType: enrollmentTypeControl.value!,
      enrollmentQuestions: enrollmentQuestionFormViewModels.map(
              (vm) => vm.buildFormData()).toList()
    );
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();

  // - IFormViewModelDelegate

  @override
  void onCancel(EnrollmentQuestionFormViewModel formViewModel, FormMode prevFormMode) {
    // TODO: implement onClose
  }

  @override
  void onSave(EnrollmentQuestionFormViewModel formViewModel, FormMode prevFormMode) {
    // TODO: implement onSave
  }

// Operates on:
// study.participation
// study.questionnaire
// study.eligibilityCriteria

// FormControl enrollmentType
// => study.participation
// FormArray screenerQuestions (ScreenerQuestion: question, eligibilityCriterion)
// => study.questionnaire.questions = screenerQuestions.map((s) => s.question))
// => study.eligibilityCriteria = screenerQuestions.map((s) => s.eligibilityCriterion))

// Where should we update the diffent fields of Study?
// StudyEnrollmentFormViewModel vs ScreenerQuestionFormViewModel
// it has to be in the parent
}
