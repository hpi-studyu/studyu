import 'package:flutter/foundation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/bool_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/choice_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/scale_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/bool_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/choice_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/scale_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';

class QuestionFormViewModelWrapper<Q extends QuestionFormViewModel> extends ManagedFormViewModel<QuestionFormData> {
  QuestionFormViewModelWrapper(this.model);

  Q model;
  SurveyQuestionType get type => model.questionType;

  late final FormControl<SurveyQuestionType> questionTypeControl = CustomFormControl(
    value: type,
    onValueChanged: onQuestionTypeChanged,
  );

  @override
  late final FormGroup form = FormGroup({
    'questionType': questionTypeControl,
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
      if (controlKey != 'questionType') form.removeControl(controlKey, emitEvent: false);
    }
    form.addAll(model.form.controls);
    markFormGroupChanged();
  }

  @override buildFormData() => model.buildFormData();
  @override void setControlsFrom(data) => model.setControlsFrom(data);
  @override ManagedFormViewModel<QuestionFormData> createDuplicate()
    => QuestionFormViewModelWrapper<Q>(model.createDuplicate() as Q);
  @override Map<FormMode, String> get titles => model.titles;
}
