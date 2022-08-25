import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_schedule.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';

mixin StudyScheduleControls {
  static const defaultScheduleType = PhaseSequence.alternating;
  static const defaultNumCycles = 2;
  static const defaultPeriodLength = 7;

  final FormControl<PhaseSequence> sequenceTypeControl = FormControl(
      validators: [Validators.required], value: defaultScheduleType);
  final FormControl<int> phaseDurationControl = FormControl(
      validators: [Validators.required], value: defaultPeriodLength);
  final FormControl<int> numCyclesControl = FormControl(
      validators: [Validators.required], value: defaultNumCycles);
  final FormControl<bool> includeBaselineControl = FormControl(
      validators: [Validators.required], value: true);

  List<FormControlOption<PhaseSequence>> get sequenceTypeControlOptions =>
      PhaseSequence.values
          .map((v) => FormControlOption(v, v.string))
          .toList();

  late final studyScheduleControls = {
    'sequenceType': sequenceTypeControl,
    'numCycles': numCyclesControl,
    'phaseDuration': phaseDurationControl,
    'includeBaseline': includeBaselineControl,
  };

  void setStudyScheduleControlsFrom(StudyScheduleFormData data) {
    sequenceTypeControl.value = data.sequenceType;
    numCyclesControl.value = data.numCycles;
    phaseDurationControl.value = data.phaseDuration;
    includeBaselineControl.value = data.includeBaseline;
  }

  StudyScheduleFormData buildStudyScheduleFormData() {
    return StudyScheduleFormData(
        sequenceType: sequenceTypeControl.value!, // required
        numCycles:  numCyclesControl.value!, // required
        phaseDuration: phaseDurationControl.value!, // required
        includeBaseline: includeBaselineControl.value!, // required
    );
  }
}
