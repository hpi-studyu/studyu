import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/choice_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/validation.dart';

class ChoiceQuestionFormViewModel extends QuestionFormViewModel<ChoiceQuestionFormData> {
  ChoiceQuestionFormViewModel({
    super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
    titles,
  }) : _titleResources = titles;

  final Map<FormMode, LocalizedStringResolver>? _titleResources;

  final FormControl<bool> isMultipleChoiceControl = FormControl(validators: [Validators.required], value: false);
  final int customOptionsMin = 2;
  final int customOptionsMax = 10;
  final int customOptionsInitial = 2;

  late final FormArray<String> _responseOptionsArray = 
      FormArray([for (int i = 0; i < customOptionsInitial; i++) FormControl(value: "")]);

  get numValidOptions => FormControlValidation(control: _responseOptionsArray, validators: [
        CountWhereValidator<dynamic>((value) => value != null && value.isNotEmpty,
            minCount: customOptionsMin, maxCount: customOptionsMax)
      ], validationMessages: {
        CountWhereValidator.kValidationMessageMaxCount: (error) =>
            tr.form_array_response_options_choice_countmax(customOptionsMax),
        CountWhereValidator.kValidationMessageMinCount: (error) =>
            tr.form_array_response_options_choice_countmin(customOptionsMin),
      });

  bool get isAddOptionButtonVisible =>
      _responseOptionsArray.value != null && _responseOptionsArray.value!.length < customOptionsMax;

  @override
  SurveyQuestionType get questionType => SurveyQuestionType.choice;

  @override
  Map<FormMode, LocalizedStringResolver>? get titleResources => _titleResources;

  @override
  FormArray<String> get responseOptionsArray => _responseOptionsArray;

  @override
  FormGroup get controls => FormGroup({
    'isMultipleChoice': isMultipleChoiceControl,
    'choiceOptionsArray': _responseOptionsArray,
  });

  @override
  FormValidationConfigSet? get validationConfigs => {
    StudyFormValidationSet.draft: [numValidOptions],
    StudyFormValidationSet.publish: [numValidOptions],
  };

  @override
  ChoiceQuestionFormData buildFormData() => ChoiceQuestionFormData(
    questionId: questionId,
    questionText: questionTextControl.value!,
    // required
    questionInfoText: questionInfoTextControl.value,
    isMultipleChoice: isMultipleChoiceControl.value!,
    // required
    answerOptions: validAnswerOptions,
  );


  @override
  void setControlsFrom(ChoiceQuestionFormData data) {
      super.setControlsFrom(data);
      // Unfortunately needed because of how [FormArray.updateValue] is implemented
      // Note: `formArray.value = []` does not remove any controls!
      _responseOptionsArray.clear();
      _responseOptionsArray.value = data.answerOptions;
    }

  @override
  ChoiceQuestionFormViewModel createDuplicate() {
    return ChoiceQuestionFormViewModel(
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
      titles: _titleResources,
    );
  }
}
