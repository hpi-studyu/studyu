import 'dart:math';

import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/scale_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/color.dart';

class ScaleQuestionFormViewModel extends QuestionFormViewModel<ScaleQuestionFormData> {
  ScaleQuestionFormViewModel({
    ScaleQuestionFormData? super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
    titles,
  }) : _titleResources = titles;

  final Map<FormMode, LocalizedStringResolver>? _titleResources;

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
  late final FormArray<int> _responseOptionsArray = FormArray([...scaleAllValueControls]);

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
    responseOptionsArray.clear();
    responseOptionsArray.addAll(scaleAllValueControls);
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

  get validRange {
    const int scaleRangeValidMax = 1000;
    return FormControlValidation(control: _scaleRangeControl, validators: [
      Validators.min(1),
      Validators.max(scaleRangeValidMax),
    ], validationMessages: {
      'min': (error) => tr.form_array_response_options_scale_rangevalid_min,
      'max': (error) => tr.form_array_response_options_scale_rangevalid_max(scaleRangeValidMax),
    });
  }

  bool get isMidValuesClearedInfoVisible => prevMidValues != scaleMidValueControls.value;

  @override
  SurveyQuestionType get questionType => SurveyQuestionType.scale;

  @override
  Map<FormMode, LocalizedStringResolver>? get titleResources => _titleResources;

  @override
  FormArray<int> get responseOptionsArray => _responseOptionsArray;

  @override
  FormGroup get controls => FormGroup({
    'scaleMinValue': scaleMinValueControl,
    'scaleMaxValue': scaleMaxValueControl,
    '_scaleRange': _scaleRangeControl, // hidden, included for validation
    'scaleMinLabel': scaleMinLabelControl,
    'scaleMaxLabel': scaleMaxLabelControl,
    'scaleMidValues': scaleMidValueControls,
    'scaleMidLabels': scaleMidLabelControls,
    'scaleMinColor': scaleMinColorControl,
    'scaleMaxColor': scaleMaxColorControl,
  });

  @override
  FormValidationConfigSet? get validationConfigs => {
      StudyFormValidationSet.draft: [validRange],
      StudyFormValidationSet.publish: [validRange],
  };

  @override
  ScaleQuestionFormData buildFormData() => ScaleQuestionFormData(
    questionId: questionId,
    questionText: questionTextControl.value!,
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

  @override
  void initControls() {
      _updateScaleMidValueControls();
      super.initControls();
    }

  @override
  void setControlsFrom(ScaleQuestionFormData data) {
    super.setControlsFrom(data);
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
  }

  @override
  ScaleQuestionFormViewModel createDuplicate() {
    return ScaleQuestionFormViewModel(
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
      titles: _titleResources,
    );
  }
}
