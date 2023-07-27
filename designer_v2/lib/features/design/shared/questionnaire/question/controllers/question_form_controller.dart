import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/bool_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/choice_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/scale_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/bool_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/choice_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/scale_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

abstract class QuestionFormViewModel<D extends QuestionFormData> extends ManagedFormViewModel<D>
    implements IListActionProvider<FormControl<dynamic>> {

  QuestionFormViewModel({
    D? super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
  });

  static QuestionFormViewModel<FD> concrete<FD extends QuestionFormData>({
    FD? formData,
    delegate,
    validationSet = StudyFormValidationSet.draft,
    titles
  }) {
    QuestionFormViewModel ret;
    switch (formData == null ? FD : formData.runtimeType) {
      case BoolQuestionFormData:
        ret = BoolQuestionFormViewModel(
          formData: formData as BoolQuestionFormData?,
          delegate: delegate,
          validationSet: validationSet,
          titles: titles);
        break;
      case ScaleQuestionFormData:
        ret = ScaleQuestionFormViewModel(
          formData: formData as ScaleQuestionFormData?,
          delegate: delegate,
          validationSet: validationSet,
          titles: titles);
        break;
      case ChoiceQuestionFormData:
      default:
        ret = ChoiceQuestionFormViewModel(
          formData: formData as ChoiceQuestionFormData?,
          delegate: delegate,
          validationSet: validationSet,
          titles: titles);
        break;
    }
    return ret as QuestionFormViewModel<FD>;
  }

  SurveyQuestionType get questionType;

  /// Customized titles (if any) depending on the context of use
  @protected
  Map<FormMode, LocalizedStringResolver>? get titleResources;

  // - Form fields

  List<FormControlOption<SurveyQuestionType>> get questionTypeControlOptions =>
      QuestionFormData.questionTypeFormDataFactories.keys
          .map((questionType) => FormControlOption(questionType, questionType.string))
          .toList();

  FormArray get responseOptionsArray;
  List<AbstractControl> get responseOptionsControls => responseOptionsArray.controls;

  List<String> get validAnswerOptions {
    final List<String> options = [];
    for (final optionValue in (responseOptionsArray.value ?? [])) {
      if (optionValue != null) {
        options.add(optionValue);
      }
    }
    return options;
  }

  @protected // can't be private because it's a sublass responsibility
  FormGroup get controls;

  FormValidationConfigSet? get validationConfigs => null;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
        StudyFormValidationSet.draft: _getValidationConfig(StudyFormValidationSet.draft),
        StudyFormValidationSet.publish: _getValidationConfig(StudyFormValidationSet.publish),
        StudyFormValidationSet.test: _getValidationConfig(StudyFormValidationSet.test),
      };
  List<FormControlValidation> _getValidationConfig(StudyFormValidationSet validationSet) {
    return validationConfigs?[validationSet] ?? [];
  }
  /// The form containing the controls for the currently selected
  /// [SurveyQuestionType]
  ///
  /// By default, contains all the controls shared among question types.
  /// Controls specific to the currently selected [questionType] are added /
  /// removed dynamically via the [_questionTypeChanges] subscription.
  late final FormGroup _form = FormGroup({ ...controls.controls });
  @override FormGroup get form => _form;

  @override
  void initControls() {}

  @override
  D buildFormData() {
    throw UnimplementedError();
  }

  D supplementFormData(D data) => data;

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: titleResources?[FormMode.create]?.call() ?? tr.form_question_create,
        FormMode.edit: titleResources?[FormMode.edit]?.call() ?? tr.form_question_edit,
        FormMode.readonly: titleResources?[FormMode.readonly]?.call() ?? tr.form_question_readonly,
      };

  @override
  List<ModelAction> availableActions(AbstractControl model) {
    final isNotReadonly = formMode != FormMode.readonly;

    final actions = [
      ModelAction(
        type: ModelActionType.remove,
        label: ModelActionType.remove.string,
        onExecute: () {
          final controlIdx = responseOptionsArray.controls.indexOf(model);
          responseOptionsArray.removeAt(controlIdx);
        },
        isAvailable: isNotReadonly,
      ),
    ].where((action) => action.isAvailable).toList();

    return withIcons(actions, modelActionIcons);
  }

  @override
  void onNewItem() {
    responseOptionsArray.add(FormControl());
  }

  @override
  void onSelectItem(FormControl<dynamic> item) {
    return; // no-op
  }
}
