import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_schedule.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

mixin StudyScheduleControls {
  static const defaultScheduleType = PhaseSequence.alternating;
  static const defaultNumCycles = 2;
  static const defaultPeriodLength = 7;

  final FormControl<PhaseSequence> sequenceTypeControl =
      FormControl(value: defaultScheduleType);
  final FormControl<int> phaseDurationControl =
      FormControl(value: defaultPeriodLength);
  final FormControl<int> numCyclesControl =
      FormControl(value: defaultNumCycles);
  final FormControl<bool> includeBaselineControl = FormControl(value: true);

  List<FormControlOption<PhaseSequence>> get sequenceTypeControlOptions =>
      PhaseSequence.values.map((v) => FormControlOption(v, v.string)).toList();

  late final studyScheduleControls = {
    'sequenceType': sequenceTypeControl,
    'numCycles': numCyclesControl,
    'phaseDuration': phaseDurationControl,
    'includeBaseline': includeBaselineControl,
  };

  FormValidationConfigSet get studyScheduleValidationConfig => {
        StudyFormValidationSet.draft: [],
        StudyFormValidationSet.publish: [numCyclesRange, phaseDurationRange],
        StudyFormValidationSet.test: [numCyclesRange, phaseDurationRange],
      };

  get numCyclesRange => FormControlValidation(
        control: numCyclesControl,
        validators: [Validators.required, Validators.min(1), Validators.max(9)],
        validationMessages: {
          ValidationMessage.required: (error) =>
              'The number of cycles in your study schedule must be between 1 and 9'
                  .hardcoded,
          ValidationMessage.min: (error) =>
              'The number of cycles in your study schedule must be between 1 and 9'
                  .hardcoded,
          ValidationMessage.max: (error) =>
              'The number of cycles in your study schedule must be between 1 and 9'
                  .hardcoded,
        },
      );

  get phaseDurationRange => FormControlValidation(
        control: phaseDurationControl,
        validators: [
          Validators.required,
          Validators.min(1),
          Validators.max(365)
        ],
        validationMessages: {
          ValidationMessage.required: (error) =>
              'Intervention phases must be between 1 and 365 days long'
                  .hardcoded,
          ValidationMessage.min: (error) =>
              'Intervention phases must be between 1 and 365 days long'
                  .hardcoded,
          ValidationMessage.max: (error) =>
              'Intervention phases must be between 1 and 365 days long'
                  .hardcoded,
        },
      );

  void setStudyScheduleControlsFrom(StudyScheduleFormData data) {
    sequenceTypeControl.value = data.sequenceType;
    numCyclesControl.value = data.numCycles;
    phaseDurationControl.value = data.phaseDuration;
    includeBaselineControl.value = data.includeBaseline;
  }

  StudyScheduleFormData buildStudyScheduleFormData() {
    return StudyScheduleFormData(
      sequenceType: sequenceTypeControl.value!, // required
      numCycles: numCyclesControl.value!, // required
      phaseDuration: phaseDurationControl.value!, // required
      includeBaseline: includeBaselineControl.value!, // required
    );
  }
}
