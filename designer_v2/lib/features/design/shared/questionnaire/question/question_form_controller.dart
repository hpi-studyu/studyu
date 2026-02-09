import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
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
    implements
        IListActionProvider<FormControl<dynamic>>,
        IConditionalQuestionProperties {
  static const defaultQuestionType = SurveyQuestionType.choice;

  QuestionFormViewModel({
    super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
    Map<FormMode, String Function()>? titles,
  }) : _titles = titles {
    // Existing initializations
    boolResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    choiceResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    _scaleResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    imageResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    audioResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    freeTextResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    fitbitResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    painResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    dateResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
  }

  /// Customized titles (if any) depending on the context of use
  final Map<FormMode, LocalizedStringResolver>? _titles;

  // - Form fields (any question type)

  final FormControl<QuestionID> questionIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  late final FormControl<SurveyQuestionType> questionTypeControl =
      CustomFormControl(
        value: defaultQuestionType,
        onValueChanged: onQuestionTypeChanged,
      );
  final FormControl<String> questionTextControl = FormControl();
  final FormControl<String> questionInfoTextControl = FormControl();

  @override
  String get currentQuestionId => questionIdControl.value!;

  @override
  CompositeExpression? get compositeExpression =>
      conditionalProperties.compositeExpression;

  @override
  FormControl<LogicType> get logicTypeControl =>
      conditionalProperties.logicTypeControl;

  @override
  FormArray get conditionsArray => conditionalProperties.conditionsArray;

  @override
  Stream<void> get conditionsValueChanges =>
      conditionalProperties.conditionsValueChanges;

  @override
  void addCondition({Expression? initialExpression}) =>
      conditionalProperties.addCondition(initialExpression: initialExpression);

  @override
  void updateCondition() => conditionalProperties.updateCondition();

  @override
  List<ConditionRowFormViewModel> get conditionModels =>
      conditionalProperties.conditionModels;

  @override
  void removeCondition(int index) =>
      conditionalProperties.removeCondition(index);

  @override
  void cleanupInvalidConditions() =>
      conditionalProperties.cleanupInvalidConditions();

  @override
  void initializeDeferredConditions() =>
      conditionalProperties.initializeDeferredConditions();

  // Initialize from existing data
  /*void _initializeConditions(QuestionConditional<bool>? initialCondition) {
    conditionsArray.clear();
    if (initialCondition != null) {
      CompositeExpression initialComposite;
      initialComposite = initialCondition.condition;
      for (final expression in initialComposite.expressions) {
        addCondition(allQuestions: , initialExpression: expression);
      }
      logicTypeControl.value = initialComposite.logicType;
    }
  }*/

  QuestionID get questionId => questionIdControl.value!;

  SurveyQuestionType get questionType =>
      questionTypeControl.value ?? defaultQuestionType;

  List<FormControlOption<SurveyQuestionType>> get questionTypeControlOptions =>
      QuestionFormData.questionTypeFormDataFactories.keys
          .map(
            (questionType) =>
                FormControlOption(questionType, questionType.string),
          )
          .toList();

  @override
  final FormControl<QuestionConditional<dynamic>?> questionConditionalControl =
      FormControl<QuestionConditional<dynamic>?>();

  late final Map<String, AbstractControl> questionBaseControls = {
    'questionId': questionIdControl, // hidden
    'questionType': questionTypeControl,
    'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,
    'questionConditional': questionConditionalControl,
  };

  // - Form fields (question type-specific)

  // Multiple Choice
  final FormControl<bool> isMultipleChoiceControl = FormControl(
    validators: [Validators.required],
    value: false,
  );
  late final FormArray<Choice> choiceResponseOptionsArray = FormArray([
    for (int i = 0; i < customOptionsInitial; i++)
      FormControl(value: Choice.withId()),
  ]);
  final int customOptionsMin = 2;
  final int customOptionsMax = 10;
  final int customOptionsInitial = 2;

  FormArray get answerOptionsArray => {
    SurveyQuestionType.bool: boolResponseOptionsArray,
    SurveyQuestionType.choice: choiceResponseOptionsArray,
    SurveyQuestionType.scale: _scaleResponseOptionsArray,
    SurveyQuestionType.image: imageResponseOptionsArray,
    SurveyQuestionType.audio: audioResponseOptionsArray,
    SurveyQuestionType.freeText: freeTextResponseOptionsArray,
    SurveyQuestionType.fitbit: fitbitResponseOptionsArray,
    SurveyQuestionType.pain: painResponseOptionsArray,
    SurveyQuestionType.date: dateResponseOptionsArray,
  }[questionType]!;

  List<AbstractControl> get answerOptionsControls =>
      answerOptionsArray.controls;

  List<Choice> get validAnswerOptions {
    final List<Choice> options = [];
    for (final optionValue in answerOptionsArray.value ?? []) {
      if (optionValue != null) {
        options.add(optionValue as Choice);
      }
    }
    return options;
  }

  // Yes/no
  List<AbstractControl<String>> get boolOptions => BoolQuestionFormData
      .kResponseOptions
      .keys
      .map((e) => FormControl(value: e, disabled: true))
      .toList();
  late final FormArray<String> boolResponseOptionsArray = FormArray(
    boolOptions,
  );

  // Image
  List<AbstractControl<String>> get imageOptions => BoolQuestionFormData
      .kResponseOptions
      .keys
      .map((e) => FormControl(value: e, disabled: true))
      .toList();
  late final FormArray<String> imageResponseOptionsArray = FormArray(
    imageOptions,
  );

  //Pain
  List<AbstractControl<String>> get painOptions => PainQuestionFormData
      .kResponseOptions
      .keys
      .map((e) => FormControl(value: e, disabled: true))
      .toList();

  late final FormArray<String> painResponseOptionsArray = FormArray(
    painOptions,
  );

  // Date
  final FormControl<DateTime?> dateMinControl = FormControl<DateTime?>();
  final FormControl<DateTime?> dateMaxControl = FormControl<DateTime?>();
  final FormControl<DateFormatPreset> dateFormatPresetControl =
      FormControl<DateFormatPreset>(
    value: DateFormatPreset.isoDate,
  );
  final FormControl<DateTime?> dateInitialValueControl = FormControl<DateTime?>();

  late final FormArray dateResponseOptionsArray = FormArray([
    dateMinControl,
    dateMaxControl,
    dateFormatPresetControl,
    dateInitialValueControl,
  ]);

  // Audio
  static const int kDefaultMaxRecordingDurationSeconds = 60;
  static const int kMaxRecordingDurationSeconds = 3600;
  List<AbstractControl<String>> get audioOptions => AudioQuestionFormData
      .kResponseOptions
      .keys
      .map((e) => FormControl(value: e, disabled: true))
      .toList();
  late final FormArray<String> audioResponseOptionsArray = FormArray(
    audioOptions,
  );
  final FormControl<int> maxRecordingDurationSecondsControl = FormControl(
    value: kDefaultMaxRecordingDurationSeconds,
    validators: [
      Validators.number(allowNegatives: false),
      Validators.min(1),
      Validators.max(kMaxRecordingDurationSeconds),
    ],
  );

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
  late final FormControl<int> _scaleRangeControl = FormControl(
    value: scaleRange,
  ); // hidden
  final FormControl<String> scaleMinLabelControl = FormControl();
  final FormControl<String> scaleMaxLabelControl = FormControl();
  final FormArray<int> scaleMidValueControls = FormArray([]);
  final FormArray<String?> scaleMidLabelControls = FormArray([]);
  late final FormArray<int> _scaleResponseOptionsArray = FormArray([
    ...scaleAllValueControls,
  ]);

  final FormControl<SerializableColor> scaleMinColorControl = FormControl();
  final FormControl<SerializableColor> scaleMaxColorControl = FormControl();

  List<int?>? prevMidValues;

  int get scaleMinValue => scaleMinValueControl.value ?? kDefaultScaleMinValue;

  int get scaleMaxValue => scaleMaxValueControl.value ?? 0;

  int get scaleRange => scaleMaxValue - scaleMinValue;

  List<AbstractControl<int>> get scaleAllValueControls => [
    scaleMinValueControl,
    ...scaleMidValueControls.controls,
    scaleMaxValueControl,
  ];

  String? scaleMidLabelAt(int scaleMidValue) {
    final idx = scaleMidValueControls.value?.indexOf(scaleMidValue);
    if (idx == null || idx == -1) {
      return null;
    }
    return scaleMidLabelControls.value?[idx];
  }

  void _onScaleRangeChanged() {
    if (formMode == FormMode.readonly) {
      return; // prevent change listener from firing in readonly mode
    }
    _applyInputFormatters();
    _scaleRangeControl.value = scaleMaxValue - scaleMinValue;
    _updateScaleMidValueControls();
    _scaleResponseOptionsArray.clear();
    _scaleResponseOptionsArray.addAll(scaleAllValueControls);
  }

  void _applyInputFormatters() {
    // TODO refactor to FormControl extension or text field input formatters
    scaleMinValueControl.value ??= 0;
    scaleMaxValueControl.value ??= 0;
  }

  void _updateScaleMidValueControls() {
    final int midValueStepSize = max(
      (scaleMaxValue / kNumMidValueControls).ceil(),
      1,
    );
    final List<int> midValues = [];
    final List<String> midLabels = [];

    for (
      int midValue = scaleMinValue + kDefaultScaleMinValue + midValueStepSize;
      midValue < scaleMaxValue;
      midValue += midValueStepSize
    ) {
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
  late final FormArray freeTextResponseOptionsArray = FormArray([
    freeTextLengthMin,
    freeTextLengthMax,
    freeTextTypeControl,
    customRegexControl,
  ]);
  late final AbstractControl<int> freeTextLengthMin = FormControl(
    value: freeTextLengthControl.value!.start.toInt(),
  );
  late final AbstractControl<int> freeTextLengthMax = FormControl(
    value: freeTextLengthControl.value!.end.toInt(),
  );
  late final FormControl<String> freeTextExampleTextControl =
      FormControl<String>(
        value: '',
        validators: [Validators.delegate(_validateFreeText)],
      );

  Map<String, dynamic>? _validateFreeText(AbstractControl<dynamic> control) {
    final List<Validator> validators = [];
    validators.add(Validators.minLength(freeTextLengthMin.value!));
    validators.add(Validators.maxLength(freeTextLengthMax.value!));
    switch (freeTextTypeControl.value) {
      case FreeTextQuestionType.any:
        break;
      case FreeTextQuestionType.alphanumeric:
        validators.add(Validators.pattern(alphanumericPattern));
      case FreeTextQuestionType.numeric:
        validators.add(Validators.number(allowNegatives: false));
      case FreeTextQuestionType.custom:
        if (customRegexControl.value != null) {
          validators.add(Validators.pattern('^${customRegexControl.value!}\$'));
        }
      case null:
        return {'null': "freeTextTypeControl.value is null"};
    }

    return Validators.compose(validators)(control);
  }

  static const int kDefaultFreeTextMinLength = 0;
  static const int kDefaultFreeTextMaxLength = 1000;

  late final FormControl<RangeValues> freeTextLengthControl =
      CustomFormControl<RangeValues>(
        value: RangeValues(
          kDefaultFreeTextMinLength.toDouble(),
          kDefaultFreeTextMaxLength.toDouble() / 2,
        ),
        onValueChanged: (_) => _onFreeTextLengthChanged(),
      );

  void _onFreeTextLengthChanged() {
    if (formMode == FormMode.readonly) {
      return; // prevent change listener from firing in readonly mode
    }
    freeTextLengthMin.value = freeTextLengthControl.value!.start.toInt();
    freeTextLengthMax.value = freeTextLengthControl.value!.end.toInt();
  }

  // Fitbit

  final Map<FitbitQuestionType, FormControl<bool>> fitbitQuestionTypesControl =
      Map.fromEntries(
        FitbitQuestionType.values.map(
          (e) => MapEntry(e, FormControl<bool>(value: false)),
        ),
      );

  late final FormArray fitbitResponseOptionsArray = FormArray(
    fitbitQuestionTypesControl.values.toList(),
  );

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
    SurveyQuestionType.image: FormGroup({
      'imageOptionsArray': imageResponseOptionsArray,
    }),
    SurveyQuestionType.audio: FormGroup({
      'audioOptionsArray': audioResponseOptionsArray,
      'maxRecordingDurationSeconds': maxRecordingDurationSecondsControl,
    }),
    SurveyQuestionType.freeText: FormGroup({
      'freeTextOptionsArray': freeTextResponseOptionsArray,
    }),
    SurveyQuestionType.fitbit: FormGroup({
      'fitbitOptionsArray': fitbitResponseOptionsArray,
    }),
    SurveyQuestionType.pain: FormGroup({
      'painOptionsArray': painResponseOptionsArray,
    }),
    SurveyQuestionType.date: FormGroup({
      'dateMin': dateMinControl,
      'dateMax': dateMaxControl,
      'dateFormatPreset': dateFormatPresetControl,
      'dateInitialValue': dateInitialValueControl,
    }),
  };

  late final FormValidationConfigSet _sharedValidationConfig = {
    StudyFormValidationSet.draft: [questionTextRequired],
    StudyFormValidationSet.publish: [questionTextRequired],
  };

  late final Map<SurveyQuestionType, FormValidationConfigSet>
  _validationConfigsByQuestionType = {
    SurveyQuestionType.choice: {
      StudyFormValidationSet.draft: [numValidChoiceOptions],
      StudyFormValidationSet.publish: [numValidChoiceOptions],
    },
    SurveyQuestionType.scale: {
      StudyFormValidationSet.draft: [scaleRangeValid],
      StudyFormValidationSet.publish: [scaleRangeValid],
    },
    SurveyQuestionType.audio: {
      StudyFormValidationSet.draft: [maxRecordingDurationValid],
      StudyFormValidationSet.publish: [maxRecordingDurationValid],
    },
    SurveyQuestionType.fitbit: {
      StudyFormValidationSet.draft: [fitbitTypeRequired],
      StudyFormValidationSet.publish: [fitbitTypeRequired],
    },
  };

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: _getValidationConfig(
      StudyFormValidationSet.draft,
    ),
    StudyFormValidationSet.publish: _getValidationConfig(
      StudyFormValidationSet.publish,
    ),
    StudyFormValidationSet.test: _getValidationConfig(
      StudyFormValidationSet.test,
    ),
  };

  List<FormControlValidation> _getValidationConfig(
    StudyFormValidationSet validationSet,
  ) {
    return [
      ..._sharedValidationConfig[validationSet] ?? [],
      ..._validationConfigsByQuestionType[questionType]?[validationSet] ?? [],
    ];
  }

  FormControlValidation get fitbitTypeRequired => FormControlValidation(
    control: fitbitResponseOptionsArray,
    validators: [
      CountWhereValidator<dynamic>(
        (dynamic value) => value == true,
        minCount: 1,
      ),
    ],
    validationMessages: {
      CountWhereValidator.kValidationMessageMinCount: (error) =>
          "At least one Fitbit type must be selected.", //TODO: translations
    },
  );

  FormControlValidation get questionTextRequired => FormControlValidation(
    control: questionTextControl,
    validators: [Validators.required, Validators.minLength(1)],
    validationMessages: {
      ValidationMessage.required: (error) => tr.form_field_question_required,
      ValidationMessage.minLength: (error) => tr.form_field_question_required,
    },
  );

  FormControlValidation get numValidChoiceOptions => FormControlValidation(
    control: choiceResponseOptionsArray,
    validators: [
      CountWhereValidator<dynamic>(
        (dynamic value) => value != null,
        minCount: customOptionsMin,
        maxCount: customOptionsMax,
      ),
    ],
    validationMessages: {
      CountWhereValidator.kValidationMessageMaxCount: (error) =>
          tr.form_array_response_options_choice_countmax(customOptionsMax),
      CountWhereValidator.kValidationMessageMinCount: (error) =>
          tr.form_array_response_options_choice_countmin(customOptionsMin),
    },
  );

  FormControlValidation get scaleRangeValid {
    const int scaleRangeValidMax = 1000;
    return FormControlValidation(
      control: _scaleRangeControl,
      validators: [Validators.min(1), Validators.max(scaleRangeValidMax)],
      validationMessages: {
        'min': (error) => tr.form_array_response_options_scale_rangevalid_min,
        'max': (error) => tr.form_array_response_options_scale_rangevalid_max(
          scaleRangeValidMax,
        ),
      },
    );
  }

  FormControlValidation get maxRecordingDurationValid {
    return FormControlValidation(
      control: maxRecordingDurationSecondsControl,
      validators: [
        Validators.number(allowNegatives: false),
        Validators.min(1),
        Validators.max(kMaxRecordingDurationSeconds),
      ],
      validationMessages: {
        ValidationMessage.min: (error) =>
            tr.audio_recording_max_duration_rangevalid_min,
        ValidationMessage.max: (error) =>
            tr.audio_recording_max_duration_rangevalid_max(
              QuestionFormViewModel.kMaxRecordingDurationSeconds,
            ),
        ValidationMessage.number: (error) => tr.free_text_validation_number,
      },
    );
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
    // Note: conditionalProperties.form.controls are excluded to prevent
    // transient conditional logic state from affecting isDirty checks
  });

  late final conditionalProperties = ConditionalQuestionFormViewModel(
    currentQuestionId: questionIdControl.value!,
    questionConditionalControl: questionConditionalControl,
  );

  void onQuestionTypeChanged(SurveyQuestionType? questionType) {
    _updateFormControls(questionType);
  }

  void onResponseOptionsChanged(List<AbstractControl> responseOptionControls) {
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

    questionConditionalControl.value = data.conditional;
    conditionalProperties.setControlsFrom(
      null,
    ); // Will read from questionConditionalControl

    // Type-specific controls
    switch (data.questionType) {
      case SurveyQuestionType.bool:
        break;
      case SurveyQuestionType.image:
        break;
      case SurveyQuestionType.audio:
        maxRecordingDurationSecondsControl.value =
            (data as AudioQuestionFormData).maxRecordingDurationSeconds;
      case SurveyQuestionType.choice:
        isMultipleChoiceControl.value =
            (data as ChoiceQuestionFormData).isMultipleChoice;
        // Unfortunately needed because of how [FormArray.updateValue] is implemented
        // Note: `formArray.value = []` does not remove any controls!
        answerOptionsArray.clear();
        answerOptionsArray.value = data.answerOptions;
      /*for (final option in data.answerOptions) {
          answerOptionsArray.add(FormControl<Choice>(value: option));
        }*/
      case SurveyQuestionType.scale:
        scaleMinValueControl.value = (data as ScaleQuestionFormData).minValue
            .toInt();
        scaleMaxValueControl.value = data.maxValue.toInt();
        scaleMinLabelControl.value = data.minLabel;
        scaleMaxLabelControl.value = data.maxLabel;
        scaleMidValueControls.clear();
        scaleMidValueControls.value = data.midValues
            .map((v) => v?.toInt())
            .toList();
        scaleMidLabelControls.clear();
        scaleMidLabelControls.value = data.midLabels;
        scaleMinColorControl.value = data.minColor != null
            ? SerializableColor(data.minColor!.toARGB32())
            : null;
        scaleMaxColorControl.value = data.maxColor != null
            ? SerializableColor(data.maxColor!.toARGB32())
            : null;
        _updateScaleMidValueControls();
      // TODO scaleInitialValueControl
      // TODO scaleStepSizeControl
      case SurveyQuestionType.freeText:
        freeTextLengthControl.value = RangeValues(
          (data as FreeTextQuestionFormData).textLengthRange.first.toDouble(),
          data.textLengthRange.last.toDouble(),
        );
        freeTextTypeControl.value = data.textType;
        customRegexControl.value = data.textTypeExpression;
      case SurveyQuestionType.fitbit:
        fitbitQuestionTypesControl.forEach((key, value) {
          value.value = (data as FitbitQuestionFormData).types.contains(key);
        });
      case SurveyQuestionType.pain:
        break;
      case SurveyQuestionType.date:
        dateMinControl.value = (data as DateQuestionFormData).minDate;
        dateMaxControl.value = data.maxDate;
        dateFormatPresetControl.value =
            data.dateFormatPreset ?? DateFormatPreset.isoDate;
        dateInitialValueControl.value = data.initialDate;
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
          conditional: questionConditionalControl.value,
        );
      case SurveyQuestionType.choice:
        return ChoiceQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!,
          // required
          questionType: questionTypeControl.value!,
          // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
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
          conditional: questionConditionalControl.value,
          minValue: scaleMinValueControl.value!.toDouble(),
          // non-empty formatter
          maxValue: scaleMaxValueControl.value!.toDouble(),
          // non-empty formatter
          minLabel: scaleMinLabelControl.value,
          maxLabel: scaleMaxLabelControl.value,
          midValues:
              scaleMidValueControls.value?.map((v) => v?.toDouble()).toList() ??
              [],
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
          conditional: questionConditionalControl.value,
          textLengthRange: [
            freeTextLengthControl.value!.start.toInt(),
            freeTextLengthControl.value!.end.toInt(),
          ], // required
          textType: freeTextTypeControl.value!,
          textTypeExpression: customRegexControl.value,
        );
      case SurveyQuestionType.image:
        return ImageQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
        );
      case SurveyQuestionType.audio:
        return AudioQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
          maxRecordingDurationSeconds:
              maxRecordingDurationSecondsControl.value!,
        );
      case SurveyQuestionType.fitbit:
        return FitbitQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
          types: fitbitQuestionTypesControl.entries
              .where((e) => e.value.value!)
              .map((e) => e.key)
              .toList(),
        );
      case SurveyQuestionType.pain:
        return PainQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
        );
      case SurveyQuestionType.date:
        return DateQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
          minDate: dateMinControl.value,
          maxDate: dateMaxControl.value,
          dateFormatPreset: dateFormatPresetControl.value,
          initialDate: dateInitialValueControl.value,
        );
    }
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create:
        _titles?[FormMode.create]?.call() ?? tr.form_question_create,
    FormMode.edit: _titles?[FormMode.edit]?.call() ?? tr.form_question_edit,
    FormMode.readonly:
        _titles?[FormMode.readonly]?.call() ?? tr.form_question_readonly,
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
    answerOptionsArray.add(FormControl<Choice>());
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
      choiceResponseOptionsArray.value != null &&
      choiceResponseOptionsArray.value!.length < customOptionsMax;

  // - IScaleQuestionFormViewModel

  bool get isMidValuesClearedInfoVisible =>
      prevMidValues != scaleMidValueControls.value;

  @override
  set formMode(FormMode mode) {
    super.formMode = mode;

    // Propagate form mode to conditional properties
    conditionalProperties.formMode = mode;
  }
}
