import 'package:flutter/foundation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/bool_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/choice_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/scale_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/bool_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/choice_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/scale_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:uuid/uuid.dart';

class QuestionFormViewModelWrapper<Q extends QuestionFormViewModel> extends ManagedFormViewModel<QuestionFormData> {
  QuestionFormViewModelWrapper(this.model) {
    super.validationSet = model.validationSet ?? StudyFormValidationSet.draft;
  }

  Q model;
  SurveyQuestionType get type => model.questionType;
  QuestionID get questionId => questionIdControl.value!;

  // CONTROLS ----------------------------------------------------------------
  final FormControl<QuestionID> questionIdControl = FormControl(value: const Uuid().v4()); // hidden
  final FormControl<String> questionTextControl = FormControl();
  final FormControl<String> questionInfoTextControl = FormControl();
  late final FormControl<SurveyQuestionType> questionTypeControl = CustomFormControl(
    value: type,
    onValueChanged: onQuestionTypeChanged,
  );
  late final Map<String, AbstractControl> questionBaseControls = {
    'questionId': questionIdControl,
    'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,
    'questionType': questionTypeControl,
  };

  // VALIDATION --------------------------------------------------------------
  get questionTextRequired => FormControlValidation(control: questionTextControl, validators: [
        Validators.required,
        Validators.minLength(1)
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_question_required,
        ValidationMessage.minLength: (error) => tr.form_field_question_required,
      });
  late final FormValidationConfigSet _sharedValidationConfig = {
    StudyFormValidationSet.draft: [questionTextRequired],
    StudyFormValidationSet.publish: [questionTextRequired],
  };
  @override
  FormValidationConfigSet get sharedValidationConfig => {
        StudyFormValidationSet.draft: _getValidationConfig(StudyFormValidationSet.draft),
        StudyFormValidationSet.publish: _getValidationConfig(StudyFormValidationSet.publish),
        StudyFormValidationSet.test: _getValidationConfig(StudyFormValidationSet.test),
      };
  List<FormControlValidation> _getValidationConfig(StudyFormValidationSet validationSet) {
    return [
      ...(_sharedValidationConfig[validationSet] ?? []),
      ...(model.validationConfigs?[validationSet] ?? [])
    ];
  }


  @override
  late final FormGroup form = FormGroup({
    ...questionBaseControls,
    ...model.form.controls,
  });

  @protected
  onQuestionTypeChanged(SurveyQuestionType? newType) {
    switch (newType) {
      case SurveyQuestionType.bool:
        model = BoolQuestionFormViewModel(
          formData: model.formData == null ? null : (model.formData as QuestionFormData) as BoolQuestionFormData,
          delegate: model.delegate,
          validationSet: model.validationSet) as Q;
        break;
      case SurveyQuestionType.scale:
        model = ScaleQuestionFormViewModel(
          formData: model.formData == null ? null : (model.formData as QuestionFormData) as ScaleQuestionFormData,
          delegate: model.delegate,
          validationSet: model.validationSet) as Q;
        break;
      case SurveyQuestionType.choice:
        model = ChoiceQuestionFormViewModel(
          formData: model.formData == null ? null : (model.formData as QuestionFormData) as ChoiceQuestionFormData,
          delegate: model.delegate,
          validationSet: model.validationSet) as Q;
        break;
      default:
        throw UnimplementedError();
    }
    for (final controlKey in form.controls.keys) {
      if (!questionBaseControls.containsKey(controlKey)) form.removeControl(controlKey, emitEvent: false);
    }
    form.addAll(model.form.controls);
    markFormGroupChanged();
  }

  @override buildFormData() {
    switch (type) {
      // TODO: create common partial constructor
      case SurveyQuestionType.bool:
        return model.supplementFormData(BoolQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!,
          questionInfoText: questionInfoTextControl.value,
        ));
      case SurveyQuestionType.choice:
        return model.supplementFormData(ChoiceQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!,
          questionInfoText: questionInfoTextControl.value,
          answerOptions: [],
        ));
      case SurveyQuestionType.scale:
        return model.supplementFormData(ScaleQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!,
          questionInfoText: questionInfoTextControl.value,
          minValue: 0,
          maxValue: 0,
          midValues: [],
          midLabels: []
        ));
    }
  }

  @override void setControlsFrom(data) {
    questionIdControl.value = data.questionId;
    questionTextControl.value = data.questionText;
    questionInfoTextControl.value = data.questionInfoText ?? '';
    model.setControlsFrom(data);
  }

  @override ManagedFormViewModel<QuestionFormData> createDuplicate()
    => QuestionFormViewModelWrapper<Q>(model.createDuplicate() as Q);

  @override Map<FormMode, String> get titles => model.titles;
}
