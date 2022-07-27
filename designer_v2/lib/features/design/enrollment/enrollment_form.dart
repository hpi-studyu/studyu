import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_question_form.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';


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
}

class EnrollmentFormViewModel extends ChildFormViewModel<EnrollmentFormData, StudyFormViewModel> {

  EnrollmentFormViewModel({
    super.formData,
    required super.parent
  });

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
  void fromData(EnrollmentFormData data) {
    enrollmentTypeControl.value = data.enrollmentType;
    for (final enrollmentQuestion in data.enrollmentQuestions) {
      enrollmentQuestionFormViewModels.add(
          EnrollmentQuestionFormViewModel(formData: enrollmentQuestion, parent: this));
    }
  }

  @override
  EnrollmentFormData toData() {
    return EnrollmentFormData(
      enrollmentType: enrollmentTypeControl.value!,
      enrollmentQuestions: enrollmentQuestionFormViewModels.map(
              (vm) => vm.toData()).toList()
    );
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();

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
