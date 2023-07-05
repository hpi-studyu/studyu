import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/bool_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/choice_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/scale_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';

class QuestionTypeController {

  QuestionTypeController(QuestionFormViewModel initial): formViewModel = initial;

  QuestionFormViewModel formViewModel;
  SurveyQuestionType get type => formViewModel.questionType;

  late final FormControl<SurveyQuestionType> questionTypeControl = CustomFormControl(
    value: formViewModel.questionType,
    onValueChanged: _onQuestionTypeChanged,
  );

  _onQuestionTypeChanged(SurveyQuestionType? newType) {
    formViewModel.form.markAsDirty();
    switch (newType) {
      case SurveyQuestionType.bool:
        formViewModel = BoolQuestionFormViewModel(delegate: formViewModel.delegate, validationSet: formViewModel.validationSet);
        break;
      case SurveyQuestionType.scale:
        formViewModel = ScaleQuestionFormViewModel(delegate: formViewModel.delegate, validationSet: formViewModel.validationSet);
        break;
      case SurveyQuestionType.choice:
        formViewModel = ChoiceQuestionFormViewModel(delegate: formViewModel.delegate, validationSet: formViewModel.validationSet);
        break;
      default:
        throw UnimplementedError();
    }
  }
}
