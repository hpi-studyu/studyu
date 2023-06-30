import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:uuid/uuid.dart';

abstract class QuestionFormViewModel<D extends QuestionFormData> extends ManagedFormViewModel<D>
    implements IListActionProvider<FormControl<dynamic>> {

  QuestionFormViewModel({
    super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
  });

  /// Customized titles (if any) depending on the context of use
  @protected
  Map<FormMode, LocalizedStringResolver>? get titleResources;

  // - Form fields

  final FormControl<QuestionID> questionIdControl = FormControl(value: const Uuid().v4()); // hidden
  final FormControl<String> questionTextControl = FormControl();
  final FormControl<String> questionInfoTextControl = FormControl();

  QuestionID get questionId => questionIdControl.value!;

  List<FormControlOption<SurveyQuestionType>> get questionTypeControlOptions =>
      QuestionFormData.questionTypeFormDataFactories.keys
          .map((questionType) => FormControlOption(questionType, questionType.string))
          .toList();

  late final Map<String, AbstractControl> questionBaseControls = {
    'questionId': questionIdControl, // hidden
    'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,
  };

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

  late final FormValidationConfigSet _sharedValidationConfig = {
    StudyFormValidationSet.draft: [questionTextRequired],
    StudyFormValidationSet.publish: [questionTextRequired],
  };

  @protected // can't be private because it's a sublass responsibility
  FormValidationConfigSet? get validationConfigs => null;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
        StudyFormValidationSet.draft: _getValidationConfig(StudyFormValidationSet.draft),
        StudyFormValidationSet.publish: _getValidationConfig(StudyFormValidationSet.publish),
        StudyFormValidationSet.test: _getValidationConfig(StudyFormValidationSet.test),
      };

  List<FormControlValidation> _getValidationConfig(StudyFormValidationSet validationSet) {
    return [
      ...(_sharedValidationConfig[validationSet] ?? []),
      ...(validationConfigs?[validationSet] ?? [])
    ];
  }

  get questionTextRequired => FormControlValidation(control: questionTextControl, validators: [
        Validators.required,
        Validators.minLength(1)
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_question_required,
        ValidationMessage.minLength: (error) => tr.form_field_question_required,
      });

  /// The form containing the controls for the currently selected
  /// [SurveyQuestionType]
  ///
  /// By default, contains all the controls shared among question types.
  /// Controls specific to the currently selected [questionType] are added /
  /// removed dynamically via the [_questionTypeChanges] subscription.
  @override
  late final FormGroup form = FormGroup({
    ...questionBaseControls,
    ...controls.controls,
  });

  @override
  void initControls() {}

  @override
  void setControlsFrom(D data) {
    // Shared controls
    questionIdControl.value = data.questionId;
    questionTextControl.value = data.questionText;
    questionInfoTextControl.value = data.questionInfoText ?? '';
  }

  @override
  D buildFormData() {
    throw UnimplementedError();
  }

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
