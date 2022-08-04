import 'package:reactive_forms/src/models/models.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class EnrollmentQuestionFormData {
  EnrollmentQuestionFormData({required this.question, this.eligibilityCriterion});

  final Question question;
  final EligibilityCriterion? eligibilityCriterion;
}
typedef EnrollmentQuestionType = String;

class EnrollmentQuestionFormViewModel extends FormViewModel<EnrollmentQuestionFormData> {
  EnrollmentQuestionFormViewModel({
    super.formData,
    super.delegate,
  });

  // - Form fields

  final FormControl<String> questionTextControl = FormControl();
  final FormControl<EnrollmentQuestionType> questionTypeControl = FormControl();

  // TODO: question controls specific for each questionType
  // TODO: logic controls specific for each question type

  @override
  FormGroup get form => FormGroup({
    'questionText': questionTextControl,
    'questionType': questionTypeControl,
  });

  @override
  void setControlsFrom(EnrollmentQuestionFormData data) {
    questionTextControl.value = data.question.prompt ?? '';
    questionTypeControl.value = data.question.type;
  }

  @override
  EnrollmentQuestionFormData buildFormData() {
    // TODO: create question of corresponding type (for now create boolean default)
    final question = BooleanQuestion();
    question.prompt = questionTextControl.value;
    return EnrollmentQuestionFormData(question: question);
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: "New Screener Question".hardcoded,
    FormMode.edit: "Edit Screener Question".hardcoded,
  };
}
