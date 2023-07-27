import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_logic_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

mixin ScreenerQuestionFormViewModelMixin<D extends QuestionFormData> on QuestionFormViewModel<D> implements IScreenerQuestionLogicFormViewModel {
  static const defaultResponseOptionValidity = true;

  late final FormArray responseOptionsDisabledArray =
      FormArray(_copyFormControls(responseOptionsControls), disabled: true);
  late final FormArray<bool> responseOptionsLogicControls = FormArray(
    List.generate(responseOptionsControls.length, (index) => FormControl(value: defaultResponseOptionValidity)),
  );
  late final FormArray<String> responseOptionsLogicDescriptionControls = FormArray(
    List.generate(responseOptionsControls.length, (index) => FormControl()),
  );

  List<AbstractControl> get responseOptionsDisabledControls => responseOptionsDisabledArray.controls;

  List<FormControlOption<bool>> get logicControlOptions => [
        FormControlOption(true, tr.form_screener_question_logic_qualify),
        FormControlOption(false, tr.form_screener_question_logic_disqualify)
      ];

  late final _questionBaseControls = {
    'responseOptionLogic': responseOptionsLogicControls,
    'responseOptionLogicDescriptions': responseOptionsLogicDescriptionControls,
  };

  late final FormGroup _form = FormGroup({ ..._questionBaseControls, ...controls.controls });
  @override
  FormGroup get form => _form;

  List<AbstractControl> prevResponseOptionControls = [];
  late List<dynamic> prevResponseOptionValues = [];

  onResponseOptionsChanged(List<AbstractControl> responseOptionControls) {
    if (formMode == FormMode.readonly) {
      return;
    }

    // Build new form arrays consolidated with previous values (if any)
    final newLogicControls = responseOptionControls.map((newControl) {
      // Consolidate with previous value (if any)
      final idx = prevResponseOptionControls.map((c) => c.value).toList().indexOf(newControl.value);
      final newValue = (idx != -1) ? responseOptionsLogicControls.controls[idx].value : defaultResponseOptionValidity;
      return FormControl<bool>(value: newValue);
    }).toList();
    final newLogicDescriptionControls = responseOptionControls.map((newControl) {
      // Consolidate with previous value (if any)
      final idx = prevResponseOptionControls.map((c) => c.value).toList().indexOf(newControl.value);
      final newValue = (idx != -1) ? responseOptionsLogicDescriptionControls.controls[idx].value : null;
      return FormControl<String>(value: newValue);
    }).toList();
    final newResponseOptionsControls = _copyFormControls(responseOptionControls);

    // Keep disabled controls in sync with actual response option controls
    responseOptionsDisabledArray.clear();
    responseOptionsDisabledArray.addAll(newResponseOptionsControls);
    responseOptionsDisabledArray.markAsDisabled();

    // Reset logic controls to new consolidated ones
    prevResponseOptionValues = prevResponseOptionControls.map((c) => c.value).toList();
    responseOptionsLogicControls.clear();
    responseOptionsLogicControls.addAll(newLogicControls);
    responseOptionsLogicDescriptionControls.clear();
    responseOptionsLogicDescriptionControls.addAll(newLogicDescriptionControls);

    prevResponseOptionControls = responseOptionControls;
  }

  @override
  void setControlsFrom(D data) {
    //prevResponseOptionControls = answerOptionsControls;
    onResponseOptionsChanged(responseOptionsControls);

    for (final entry in data.responseOptionsValidity.entries) {
      final responseOption = entry.key;
      final responseValidity = entry.value;
      final logicControl = _findAssociatedLogicControlFor(responseOption: responseOption);
      if (logicControl != null) {
        logicControl.value = responseValidity;
      }
    }
  }

  @override
  D buildFormData() {
    final data = super.buildFormData();

    final Map<dynamic, bool> responseOptionsValidity = {};
    for (var i = 0; i < responseOptionsControls.length; i++) {
      final optionControl = responseOptionsControls[i];
      final logicControl = responseOptionsLogicControls.controls[i];
      responseOptionsValidity[optionControl.value] = logicControl.value ?? defaultResponseOptionValidity;
    }
    data.responseOptionsValidity = responseOptionsValidity;

    return data;
  }

  List<FormControl> _copyFormControls(List<AbstractControl> controls) {
    return controls
        .map((control) => FormControl<String>(
              value: control.value?.toString() ?? '',
              disabled: control.disabled,
            ))
        .toList();
  }

  AbstractControl? _findAssociatedLogicControlFor({
    required dynamic responseOption,
  }) {
    return _findAssociatedControlFor(
      responseOption: responseOption,
      controls: responseOptionsLogicControls.controls,
    );
  }

  AbstractControl? _findAssociatedControlFor({
    required dynamic responseOption,
    required List<AbstractControl> controls,
  }) {
    for (var i = 0; i < controls.length; i++) {
      final optionControl = responseOptionsControls[i];
      final associatedControl = controls[i];
      if (optionControl.value == responseOption) {
        return associatedControl;
      }
    }
    return null;
  }

  // - IScreenerQuestionLogicFormViewModel
  @override
  bool get isDirtyOptionsBannerVisible =>
      !prevResponseOptionValues.equals(responseOptionsControls.map((c) => c.value).toList());
}
