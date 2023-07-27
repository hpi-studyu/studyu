import 'package:flutter/foundation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/bool_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/choice_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/scale_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
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

  @protected
  onQuestionTypeChanged(SurveyQuestionType? newType) {
    model.form.markAsDirty();
    switch (newType) {
      case SurveyQuestionType.bool:
        model = BoolQuestionFormViewModel(delegate: model.delegate, validationSet: model.validationSet) as Q;
        break;
      case SurveyQuestionType.scale:
        model = ScaleQuestionFormViewModel(delegate: model.delegate, validationSet: model.validationSet) as Q;
        break;
      case SurveyQuestionType.choice:
        model = ChoiceQuestionFormViewModel(delegate: model.delegate, validationSet: model.validationSet) as Q;
        break;
      default:
        throw UnimplementedError();
    }
  }

  @override buildFormData() => model.buildFormData();
  @override void setControlsFrom(data) => model.setControlsFrom(data);
  @override ManagedFormViewModel<QuestionFormData> createDuplicate() => model.createDuplicate();
  @override Map<FormMode, String> get titles => model.titles;
  @override FormGroup get form => model.form;
}
