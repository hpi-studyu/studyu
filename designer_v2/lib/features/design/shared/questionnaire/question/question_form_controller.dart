import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/color.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/validation.dart';
import 'package:uuid/uuid.dart';

// TODO: refactor break up into separate classes for each type
class QuestionFormViewModel extends ManagedFormViewModel<QuestionFormData>
    implements IListActionProvider<FormControl<dynamic>> {
  static const defaultQuestionType = SurveyQuestionType.choice;

  QuestionFormViewModel({
    super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
    titles,
  }) : _titles = titles {
    boolResponseOptionsArray.onChanged((control) => onResponseOptionsChanged(control.controls));
    choiceResponseOptionsArray.onChanged((control) => onResponseOptionsChanged(control.controls));
    _scaleResponseOptionsArray.onChanged((control) => onResponseOptionsChanged(control.controls));
    freeTextResponseOptionsArray.onChanged((control) => onResponseOptionsChanged(control.controls));
  }

  /// Customized titles (if any) depending on the context of use
  final Map<FormMode, LocalizedStringResolver>? _titles;

  // - Form fields (any question type)

  final FormControl<QuestionID> questionIdControl = FormControl(value: const Uuid().v4()); // hidden
  late final FormControl<SurveyQuestionType> questionTypeControl = CustomFormControl(
    value: defaultQuestionType,
    onValueChanged: onQuestionTypeChanged,
  );
  final FormControl<String> questionTextControl = FormControl();
  final FormControl<String> questionInfoTextControl = FormControl();

  QuestionID get questionId => questionIdControl.value!;

  SurveyQuestionType get questionType => questionTypeControl.value ?? defaultQuestionType;

  List<FormControlOption<SurveyQuestionType>> get questionTypeControlOptions =>
      QuestionFormData.questionTypeFormDataFactories.keys
          .map((questionType) => FormControlOption(questionType, questionType.string))
          .toList();

  late final Map<String, AbstractControl> questionBaseControls = {
    'questionId': questionIdControl, // hidden
    'questionType': questionTypeControl,
    'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,
  };

  // - Form fields (question type-specific)

  // Multiple Choice
  final FormControl<bool> isMultipleChoiceControl = FormControl(validators: [Validators.required], value: false);
  late final FormArray choiceResponseOptionsArray =
      FormArray([for (int i = 0; i < customOptionsInitial; i++) FormControl(value: "")]);
  final int customOptionsMin = 2;
  final int customOptionsMax = 10;
  final int customOptionsInitial = 2;

  FormArray get answerOptionsArray => {
        SurveyQuestionType.bool: boolResponseOptionsArray,
        SurveyQuestionType.choice: choiceResponseOptionsArray,
        SurveyQuestionType.scale: _scaleResponseOptionsArray,
        SurveyQuestionType.freeText: freeTextResponseOptionsArray,
      }[questionType]!;

  List<AbstractControl> get answerOptionsControls => answerOptionsArray.controls;

  List<String> get validAnswerOptions {
    final List<String> options = [];
    for (final optionValue in (answerOptionsArray.value ?? [])) {
      if (optionValue != null) {
        options.add(optionValue);
      }
    }
    return options;
  }

  // Yes/no
  List<AbstractControl<String>> get boolOptions =>
      BoolQuestionFormData.kResponseOptions.keys.map((e) => FormControl(value: e, disabled: true)).toList();
  late final FormArray<String> boolResponseOptionsArray = FormArray(boolOptions);

  // Scale
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
  late final FormControl<int> _scaleRangeControl = FormControl(value: scaleRange); // hidden
  final FormControl<String> scaleMinLabelControl = FormControl();
  final FormControl<String> scaleMaxLabelControl = FormControl();
  final FormArray<int> scaleMidValueControls = FormArray([]);
  final FormArray<String?> scaleMidLabelControls = FormArray([]);
  late final FormArray<int> _scaleResponseOptionsArray = FormArray([...scaleAllValueControls]);

  final FormControl<SerializableColor> scaleMinColorControl = FormControl();
  final FormControl<SerializableColor> scaleMaxColorControl = FormControl();

  List<int?>? prevMidValues;

  int get scaleMinValue => scaleMinValueControl.value ?? kDefaultScaleMinValue;

  int get scaleMaxValue => scaleMaxValueControl.value ?? 0;

  int get scaleRange => scaleMaxValue - scaleMinValue;

  List<AbstractControl<int>> get scaleAllValueControls => [
        scaleMinValueControl,
        ...(scaleMidValueControls.controls),
        scaleMaxValueControl,
      ];

  String? scaleMidLabelAt(int scaleMidValue) {
    final idx = scaleMidValueControls.value?.indexOf(scaleMidValue);
    if (idx == null || idx == -1) {
      return null;
    }
    return scaleMidLabelControls.value?[idx];
  }

  _onScaleRangeChanged() {
    if (formMode == FormMode.readonly) {
      return; // prevent change listener from firing in readonly mode
    }
    _applyInputFormatters();
    _scaleRangeControl.value = scaleMaxValue - scaleMinValue;
    _updateScaleMidValueControls();
    _scaleResponseOptionsArray.clear();
    _scaleResponseOptionsArray.addAll(scaleAllValueControls);
  }

  _applyInputFormatters() {
    // TODO refactor to FormControl extension or text field input formatters
    scaleMinValueControl.value ??= 0;
    scaleMaxValueControl.value ??= 0;
  }

  _updateScaleMidValueControls() {
    final int midValueStepSize = max((scaleMaxValue / kNumMidValueControls).ceil(), 1);
    final List<int> midValues = [];
    final List<String> midLabels = [];

    for (int midValue = scaleMinValue + kDefaultScaleMinValue + midValueStepSize;
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
    prevMidValues = scaleMidValueControls.value;
    scaleMidValueControls.clear();
    scaleMidLabelControls.clear();
    scaleMidValueControls.value = midValues;
    scaleMidLabelControls.value = midLabels;

    // Prevent mid-value controls from being edited
    scaleMidValueControls.markAsDisabled();
  }

  // Free Text
  final FormControl<FreeTextQuestionType> freeTextTypeControl =
      FormControl<FreeTextQuestionType>(value: FreeTextQuestionType.any);

  final FormControl<String> customRegexControl = FormControl<String>();
  late final FormArray freeTextResponseOptionsArray =
      FormArray([freeTextLengthMin, freeTextLengthMax, freeTextTypeControl, customRegexControl]);
  late final AbstractControl<int> freeTextLengthMin = FormControl(value: freeTextLengthControl.value!.start.toInt());
  late final AbstractControl<int> freeTextLengthMax = FormControl(value: freeTextLengthControl.value!.end.toInt());
  late final FormControl<String> freeTextExampleTextControl = FormControl<String>(
    value: '',
    validators: [Validators.delegate(_validateFreeText)],
  );

  Map<String, dynamic>? _validateFreeText(AbstractControl<dynamic> control) {
    List<Validator> validators = [];
    validators.add(Validators.minLength(freeTextLengthMin.value!));
    validators.add(Validators.maxLength(freeTextLengthMax.value!));
    switch (freeTextTypeControl.value) {
      case FreeTextQuestionType.any:
        break;
      case FreeTextQuestionType.alphanumeric:
        validators.add(Validators.pattern(alphanumericPattern));
        break;
      case FreeTextQuestionType.numeric:
        validators.add(Validators.number);
        break;
      case FreeTextQuestionType.custom:
        if (customRegexControl.value != null) {
          validators.add(Validators.pattern(r'^' + customRegexControl.value! + r'$'));
        }
        break;
      case null:
        return {'null': "freeTextTypeControl.value is null"};
    }

    return Validators.compose(validators)(control);
  }

  static const int kDefaultFreeTextMinLength = 0;
  static const int kDefaultFreeTextMaxLength = 120;

  late final FormControl<RangeValues> freeTextLengthControl = CustomFormControl<RangeValues>(
    value: RangeValues(kDefaultFreeTextMinLength.toDouble(), kDefaultFreeTextMaxLength.toDouble() / 2),
    onValueChanged: (_) => _onFreeTextLengthChanged(),
  );

  _onFreeTextLengthChanged() {
    if (formMode == FormMode.readonly) {
      return; // prevent change listener from firing in readonly mode
    }
    freeTextLengthMin.value = freeTextLengthControl.value!.start.toInt();
    freeTextLengthMax.value = freeTextLengthControl.value!.end.toInt();
  }

  // - Form fields (question type-specific) - end

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
      '_scaleRange': _scaleRangeControl, // hidden, included for validation
      'scaleMinLabel': scaleMinLabelControl,
      'scaleMaxLabel': scaleMaxLabelControl,
      'scaleMidValues': scaleMidValueControls,
      'scaleMidLabels': scaleMidLabelControls,
      'scaleMinColor': scaleMinColorControl,
      'scaleMaxColor': scaleMaxColorControl,
    }),
    SurveyQuestionType.freeText: FormGroup({
      'freeTextOptionsArray': freeTextResponseOptionsArray,
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
  FormValidationConfigSet get sharedValidationConfig => {
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

  get questionTextRequired => FormControlValidation(control: questionTextControl, validators: [
        Validators.required,
        Validators.minLength(1)
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_question_required,
        ValidationMessage.minLength: (error) => tr.form_field_question_required,
      });

  get numValidChoiceOptions => FormControlValidation(control: choiceResponseOptionsArray, validators: [
        CountWhereValidator<dynamic>((value) => value != null && value.isNotEmpty,
            minCount: customOptionsMin, maxCount: customOptionsMax)
      ], validationMessages: {
        CountWhereValidator.kValidationMessageMaxCount: (error) =>
            tr.form_array_response_options_choice_countmax(customOptionsMax),
        CountWhereValidator.kValidationMessageMinCount: (error) =>
            tr.form_array_response_options_choice_countmin(customOptionsMin),
      });

  get scaleRangeValid {
    const int scaleRangeValidMax = 1000;
    return FormControlValidation(control: _scaleRangeControl, validators: [
      Validators.min(1),
      Validators.max(scaleRangeValidMax),
    ], validationMessages: {
      'min': (error) => tr.form_array_response_options_scale_rangevalid_min,
      'max': (error) => tr.form_array_response_options_scale_rangevalid_max(scaleRangeValidMax),
    });
  }

  /// The form containing the controls for the currently selected
  /// [SurveyQuestionType]
  ///
  /// By default, contains all the controls shared among question types.
  /// Controls specific to the currently selected [questionType] are added /
  /// removed dynamically via the [_questionTypeChanges] subscription.
  @override
  late final FormGroup form = FormGroup({
    ...questionBaseControls,
    ..._controlsByQuestionType[questionType]!.controls,
  });

  onQuestionTypeChanged(SurveyQuestionType? questionType) {
    _updateFormControls(questionType);
  }

  onResponseOptionsChanged(List<AbstractControl> responseOptionControls) {
    return; // subclass responsibility
  }

  /// Dynamically updates the [form] based on the given [questionType]
  void _updateFormControls(SurveyQuestionType? questionType) {
    final subtypeFormControls = _controlsByQuestionType[questionType]!.controls;
    for (final controlName in form.controls.keys) {
      if (!questionBaseControls.containsKey(controlName)) {
        form.removeControl(controlName, emitEvent: false);
      }
    }
    form.addAll(subtypeFormControls);
    markFormGroupChanged();
    onResponseOptionsChanged(answerOptionsControls);
  }

  @override
  void initControls() {
    _updateScaleMidValueControls();
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
        answerOptionsArray.value = data.answerOptions;
        break;
      case SurveyQuestionType.scale:
        data = data as ScaleQuestionFormData;
        scaleMinValueControl.value = data.minValue.toInt();
        scaleMaxValueControl.value = data.maxValue.toInt();
        scaleMinLabelControl.value = data.minLabel;
        scaleMaxLabelControl.value = data.maxLabel;
        scaleMidValueControls.clear();
        scaleMidValueControls.value = data.midValues.map((v) => v?.toInt()).toList();
        scaleMidLabelControls.clear();
        scaleMidLabelControls.value = data.midLabels;
        scaleMinColorControl.value = data.minColor != null ? SerializableColor(data.minColor!.value) : null;
        scaleMaxColorControl.value = data.maxColor != null ? SerializableColor(data.maxColor!.value) : null;
        _updateScaleMidValueControls();
        // TODO scaleInitialValueControl
        // TODO scaleStepSizeControl
        break;
      case SurveyQuestionType.freeText:
        data = data as FreeTextQuestionFormData;
        freeTextLengthControl.value =
            RangeValues(data.textLengthRange.first.toDouble(), data.textLengthRange.last.toDouble());
        freeTextTypeControl.value = data.textType;
        customRegexControl.value = data.textTypeExpression;
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
          questionText: questionTextControl.value!,
          // required
          questionType: questionTypeControl.value!,
          // required
          questionInfoText: questionInfoTextControl.value,
          isMultipleChoice: isMultipleChoiceControl.value!,
          // required
          answerOptions: validAnswerOptions,
        );
      case SurveyQuestionType.scale:
        return ScaleQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!,
          // required
          questionType: questionTypeControl.value!,
          // required
          questionInfoText: questionInfoTextControl.value,
          minValue: scaleMinValueControl.value!.toDouble(),
          // non-empty formatter
          maxValue: scaleMaxValueControl.value!.toDouble(),
          // non-empty formatter
          minLabel: scaleMinLabelControl.value,
          maxLabel: scaleMaxLabelControl.value,
          midValues: scaleMidValueControls.value?.map((v) => v?.toDouble()).toList() ?? [],
          midLabels: scaleMidLabelControls.value ?? [],
          minColor: scaleMinColorControl.value,
          maxColor: scaleMaxColorControl.value,
          // TODO scaleInitialValueControl
          // TODO scaleStepSizeControl
        );
      case SurveyQuestionType.freeText:
        return FreeTextQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          textLengthRange: [
            freeTextLengthControl.value!.start.toInt(),
            freeTextLengthControl.value!.end.toInt()
          ], // required
          textType: freeTextTypeControl.value!,
          textTypeExpression: customRegexControl.value,
        );
    }
  }

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: _titles?[FormMode.create]?.call() ?? tr.form_question_create,
        FormMode.edit: _titles?[FormMode.edit]?.call() ?? tr.form_question_edit,
        FormMode.readonly: _titles?[FormMode.readonly]?.call() ?? tr.form_question_readonly,
      };

  @override
  List<ModelAction> availableActions(AbstractControl model) {
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
    answerOptionsArray.add(FormControl());
  }

  @override
  void onSelectItem(FormControl<dynamic> item) {
    return; // no-op
  }

  @override
  Future save() {
    // Clear custom regex if not custom type
    if (freeTextTypeControl.value != FreeTextQuestionType.custom) {
      customRegexControl.value = null;
    }
    return super.save();
  }

  @override
  QuestionFormViewModel createDuplicate() {
    return QuestionFormViewModel(
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
      titles: _titles,
    );
  }

  bool get isAddOptionButtonVisible =>
      choiceResponseOptionsArray.value != null && choiceResponseOptionsArray.value!.length < customOptionsMax;

  // - IScaleQuestionFormViewModel

  bool get isMidValuesClearedInfoVisible => prevMidValues != scaleMidValueControls.value;
}
