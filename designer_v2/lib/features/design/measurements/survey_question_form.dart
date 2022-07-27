import 'package:reactive_forms/src/models/models.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class SurveyQuestionFormData {
  SurveyQuestionFormData({required this.question});

  final Question question;
}
typedef QuestionType = String;

// TODO: maybe reuse EligibilityQuestionFormViewModel as a general QuestionFormViewModel here
class SurveyQuestionFormViewModel extends FormViewModel<SurveyQuestionFormData> {

  SurveyQuestionFormViewModel({
    super.formData,
    super.delegate
  });

  // - Form fields

  final FormControl<String> questionTextControl = FormControl();
  final FormControl<QuestionType> questionTypeControl = FormControl();

  // TODO: question controls specific for each questionType
  // TODO: logic controls specific for each question type

  @override
  late final FormGroup form = FormGroup({
    'questionText': questionTextControl,
    'questionType': questionTypeControl,
  });

  @override
  void setFormControlValuesFrom(SurveyQuestionFormData data) {
    questionTextControl.value = data.question.prompt ?? '';
    questionTypeControl.value = data.question.type;
  }

  @override
  SurveyQuestionFormData buildFormDataFromControls() {
    // TODO: create question of corresponding type (for now create boolean default)
    final question = BooleanQuestion();
    question.prompt = questionTextControl.value;
    return SurveyQuestionFormData(question: question);
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: "New Survey Question".hardcoded,
    FormMode.edit: "Edit Survey Question".hardcoded,
  };
}
