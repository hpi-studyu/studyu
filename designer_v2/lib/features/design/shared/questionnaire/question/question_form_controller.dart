import 'dart:math';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_tabs.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/validation.dart';

class QuestionFormViewModel extends ManagedFormViewModel<QuestionFormData>
    implements
        IListActionProvider<AbstractControl<String>>,
        QuestionFormTabsViewModel {
  static const defaultQuestionType = SurveyQuestionType.choice;

  QuestionFormViewModel({
    super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
  });

  // - Form fields (any question type)

  final FormControl<QuestionID> questionIdControl =
      FormControl(value: const Uuid().v4()); // hidden
  late final FormControl<SurveyQuestionType> questionTypeControl =
      CustomFormControl(
    value: defaultQuestionType,
    onValueChanged: _updateFormControls,
  );
  final FormControl<String> questionTextControl = FormControl();
  final FormControl<String> questionInfoTextControl = FormControl();

  QuestionID get questionId => questionIdControl.value!;
  SurveyQuestionType get questionType => questionTypeControl.value ?? defaultQuestionType;

  List<FormControlOption<SurveyQuestionType>> get questionTypeControlOptions =>
      QuestionFormData.questionTypeFormDataFactories.keys
          .map((questionType) =>
              FormControlOption(questionType, questionType.string))
          .toList();

  late final Map<String, AbstractControl> _questionBaseControls = {
    'questionId': questionIdControl, // hidden
    'questionType': questionTypeControl,
    'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,
  };

  // - Form fields (question type-specific)

  // Multiple Choice
  final FormControl<bool> isMultipleChoiceControl =
      FormControl(validators: [Validators.required], value: false);
  late final FormArray<String> choiceResponseOptionsArray = FormArray([
    for (int i = 0; i < customOptionsInitial; i++)
      FormControl<String>(value: "")
  ]);
  final int customOptionsMin = 2;
  final int customOptionsMax = 10;
  final int customOptionsInitial = 2;

  FormArray<String> get answerOptionsArray => {
        SurveyQuestionType.bool: boolResponseOptionsArray,
        SurveyQuestionType.choice: choiceResponseOptionsArray,
      }[questionType]!;
  List<AbstractControl<String>> get answerOptionsControls =>
      answerOptionsArray.controls;

  // Yes/no
  final FormArray<String> boolResponseOptionsArray = FormArray([
    FormControl<String>(value: "Yes".hardcoded, disabled: true),
    FormControl<String>(value: "No".hardcoded, disabled: true),
  ]);

  // Scale TODO
  static const int kDefaultScaleMinValue = 0;
  static const int kDefaultScaleMaxValue = 10;
  static const int kNumMidValueControls = 10;
  static const int kMidValueDebounceMilliseconds = 350;

  late final FormControl<int> scaleMinValueControl = CustomFormControl(
    value: kDefaultScaleMinValue,
    onValueChanged: (_) => _onScaleRangeChanged(),
    onValueChangedDebounceTime: kMidValueDebounceMilliseconds,
  );
  late final FormControl<int> scaleMaxValueControl = CustomFormControl(
    value: kDefaultScaleMaxValue,
    onValueChanged: (_) => _onScaleRangeChanged(),
    onValueChangedDebounceTime: kMidValueDebounceMilliseconds,
  );
  final FormControl<int> scaleRangeControl = FormControl(); // hidden
  final FormControl<String> scaleMinLabelControl = FormControl();
  final FormControl<String> scaleMaxLabelControl = FormControl();
  final FormArray<int> scaleMidValueControls = FormArray([]);
  final FormArray<String> scaleMidLabelControls = FormArray([]);

  List<int?>? prevMinValues;

  int get scaleMinValue => scaleMinValueControl.value ?? kDefaultScaleMinValue;
  int get scaleMaxValue => scaleMaxValueControl.value ?? 0;

  String? scaleMidLabelAt(int scaleMidValue) {
    final idx = scaleMidValueControls.value?.indexOf(scaleMidValue);
    if (idx == null || idx == -1) {
      return null;
    }
    return scaleMidLabelControls.value?[idx];
  }

  _onScaleRangeChanged() {
    scaleRangeControl.value = scaleMaxValue - scaleMinValue;
    _updateScaleMidValueControls();
  }

  _updateScaleMidValueControls() {
    final int midValueStepSize =
        max((scaleMaxValue / kNumMidValueControls).ceil(), 1);
    final List<int> midValues = [];
    final List<String> midLabels = [];

    for (int midValue =
            scaleMinValue + kDefaultScaleMinValue + midValueStepSize;
        midValue < scaleMaxValue;
        midValue += midValueStepSize) {
      final prevLabel = scaleMidLabelAt(midValue);
      midValues.add(midValue);
      midLabels.add(prevLabel ?? ''); // retain previous label at value if any
      if (midValues.length >= kNumMidValueControls) {
        break;
      }
    }

    // Reset controls to new values + labels
    prevMinValues = scaleMidValueControls.value;
    scaleMidValueControls.clear(emitEvent: false);
    scaleMidLabelControls.clear(emitEvent: false);
    scaleMidValueControls.value = midValues;
    scaleMidLabelControls.value = midLabels;

    // Prevent mid-value controls from being edited
    scaleMidValueControls.markAsDisabled();
  }

  late final Map<SurveyQuestionType, FormGroup> _controlsByQuestionType = {
    SurveyQuestionType.bool: FormGroup({
      'boolOptionsArray': boolResponseOptionsArray,
    }),
    SurveyQuestionType.choice: FormGroup({
      'isMultipleChoice': isMultipleChoiceControl,
      'choiceOptionsArray': choiceResponseOptionsArray,
    }),
    SurveyQuestionType.scale: FormGroup({
      'scaleMinValue': scaleMinValueControl,
      'scaleMaxValue': scaleMaxValueControl,
      '_scaleRange': scaleRangeControl, // hidden, included for validation
      'scaleMinLabel': scaleMinLabelControl,
      'scaleMaxLabel': scaleMaxLabelControl,
      'scaleMidValues': scaleMidValueControls,
      'scaleMidLabels': scaleMidLabelControls,
    }),
  };

  late final FormValidationConfigSet _sharedValidationConfig = {
    StudyFormValidationSet.draft: [questionTextRequired],
    StudyFormValidationSet.publish: [questionTextRequired],
  };

  late final Map<SurveyQuestionType, FormValidationConfigSet> _validationConfigsByQuestionType = {
    SurveyQuestionType.choice: {
      StudyFormValidationSet.draft: [numValidChoiceOptions],
      StudyFormValidationSet.publish: [numValidChoiceOptions],
    },
    SurveyQuestionType.scale: {
      StudyFormValidationSet.draft: [scaleRangeValid],
      StudyFormValidationSet.publish: [scaleRangeValid],
    },
  };

  @override
  FormValidationConfigSet get validationConfig => {
      StudyFormValidationSet.draft: _getValidationConfig(StudyFormValidationSet.draft),
      StudyFormValidationSet.publish: _getValidationConfig(StudyFormValidationSet.publish),
      StudyFormValidationSet.test: _getValidationConfig(StudyFormValidationSet.test),
    };

  List<FormControlValidation> _getValidationConfig(StudyFormValidationSet validationSet) {
    return [
      ...(_sharedValidationConfig[validationSet] ?? []),
      ...(_validationConfigsByQuestionType[questionType]?[validationSet] ?? [])
    ];
  }

  get questionTextRequired =>
      FormControlValidation(control: questionTextControl, validators: [
        Validators.required, Validators.minLength(1)
      ], validationMessages: {
        ValidationMessage.required: (error) => 'Your question must not be empty'.hardcoded,
        ValidationMessage.minLength: (error) => 'Your question must not be empty'.hardcoded,
      });

  get numValidChoiceOptions =>
      FormControlValidation(control: choiceResponseOptionsArray, validators: [
        CountWhereValidator<String>(
                (value) => value != null && value.isNotEmpty,
                minCount: customOptionsMin,
                maxCount: customOptionsMax)
            .validate
      ], validationMessages: {
        CountWhereValidator.kValidationMessageMaxCount: (error) =>
            'Your question must have at most ${customOptionsMax.toString()} non-empty response options'
                .hardcoded,
        CountWhereValidator.kValidationMessageMinCount: (error) =>
            'Your question must have at least ${customOptionsMin.toString()} non-empty response options'
                .hardcoded,
      });

  get scaleRangeValid =>
      FormControlValidation(control: scaleRangeControl, validators: [
        Validators.min(1),
        Validators.max(1000),
      ], validationMessages: {
        'min': (error) => 'The high value of the scale must be greater than the low value'.hardcoded,
        'max': (error) => 'The maximum difference between the high and low values of the scale is 1000'.hardcoded,
      });

  /// The form containing the controls for the currently selected
  /// [SurveyQuestionType]
  ///
  /// By default, contains all the controls shared among question types.
  /// Controls specific to the currently selected [questionType] are added /
  /// removed dynamically via the [_questionTypeChanges] subscription.
  @override
  late final FormGroup form = FormGroup({
    'questionId': questionIdControl, // hidden
    'questionType': questionTypeControl,
    'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,
    ..._controlsByQuestionType[questionType]!.controls,
  });

  /// Dynamically updates the [form] based on the given [questionType]
  void _updateFormControls(SurveyQuestionType? questionType) {
    final subtypeFormControls = _controlsByQuestionType[questionType]!.controls;
    for (final controlName in form.controls.keys) {
      if (!_questionBaseControls.containsKey(controlName)) {
        form.removeControl(controlName, emitEvent: false);
      }
    }
    form.addAll(subtypeFormControls);
    revalidate();
    form.updateValueAndValidity();
  }

  @override
  void setControlsFrom(QuestionFormData data) {
    // Shared controls
    questionIdControl.value = data.questionId;
    questionTextControl.value = data.questionText;
    questionTypeControl.value = data.questionType;
    questionInfoTextControl.value = data.questionInfoText ?? '';

    // Type-specific controls
    switch (data.questionType) {
      case SurveyQuestionType.bool:
        break;
      case SurveyQuestionType.choice:
        data = data as ChoiceQuestionFormData;
        isMultipleChoiceControl.value = data.isMultipleChoice;
        // Unfortunately needed because of how [FormArray.updateValue] is implemented
        // Note: `formArray.value = []` does not remove any controls!
        answerOptionsArray.clear();
        answerOptionsArray.value =
            data.answerOptions.map((option) => option.label).toList();
        break;
      case SurveyQuestionType.scale:
        break;
    }
  }

  @override
  QuestionFormData buildFormData() {
    switch (questionType) {
      case SurveyQuestionType.bool:
        return BoolQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
        );
      case SurveyQuestionType.choice:
        return ChoiceQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          isMultipleChoice: isMultipleChoiceControl.value!, // required
          answerOptions: answerOptionsArray.value! // required
              .where((optionStr) => optionStr != null && optionStr.isNotEmpty)
              .map((optionStr) =>
                  FormControlOption<String>(optionStr!.toKey(), optionStr))
              .toList(),
        );
      case SurveyQuestionType.scale:
        return ScaleQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
        );
    }
  }

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: "New Question".hardcoded,
        FormMode.edit: "Edit Question".hardcoded,
        FormMode.readonly: "View Question".hardcoded,
      };

  @override
  List<ModelAction> availableActions(AbstractControl<String> model) {
    final isNotReadonly = formMode != FormMode.readonly;

    final actions = [
      ModelAction(
        type: ModelActionType.remove,
        label: ModelActionType.remove.string,
        onExecute: () {
          final controlIdx = answerOptionsArray.controls.indexOf(model);
          answerOptionsArray.removeAt(controlIdx);
        },
        isAvailable: isNotReadonly,
      ),
    ].where((action) => action.isAvailable).toList();

    return withIcons(actions, modelActionIcons);
  }

  @override
  void onNewItem() {
    answerOptionsArray.add(FormControl<String>());
  }

  @override
  void onSelectItem(AbstractControl<String> item) {
    return; // no-op
  }

  @override
  QuestionFormViewModel createDuplicate() {
    return QuestionFormViewModel(
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
    );
  }

  bool get isAddOptionButtonVisible =>
      choiceResponseOptionsArray.value != null &&
      choiceResponseOptionsArray.value!.length < customOptionsMax;

  @override
  // TODO: implement isDesignTabEnabled
  bool get isDesignTabEnabled => true;

  @override
  // TODO: implement isDesignTabVisible
  bool get isDesignTabVisible => true;

  @override
  // TODO: implement isLogicTabEnabled
  bool get isLogicTabEnabled => true;

  @override
  // TODO: implement isLogicTabVisible
  bool get isLogicTabVisible => true;

  // - IScaleQuestionFormViewModel

  bool get isMidValuesClearedInfoVisible => prevMinValues != scaleMidValueControls.value;
}
