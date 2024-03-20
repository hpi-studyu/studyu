import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_schedule.dart';
import 'package:studyu_designer_v2/features/design/interventions/mp23_study_schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/schedule_creator/schedule_creator.dart';
import 'package:studyu_designer_v2/features/design/interventions/mp23_study_schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

mixin MP23StudyScheduleControls {
  final FormArray segmentsControl = FormArray([]);

  // List<FormControlOption<PhaseSequence>> get sequenceTypeControlOptions =>
  //     PhaseSequence.values.map((v) => FormControlOption(v, v.string)).toList();

  late final studyScheduleControls = {
    'segments': segmentsControl,
  };

  FormValidationConfigSet get studyScheduleValidationConfig => {
        StudyFormValidationSet.draft: [],
        StudyFormValidationSet.publish: [],
        StudyFormValidationSet.test: [],
      };

  // static int kNumCyclesMin = 1;
  // static int kNumCyclesMax = 9;
  // get numCyclesRange => FormControlValidation(
  //       control: numCyclesControl,
  //       validators: [
  //         Validators.required,
  //         Validators.min(kNumCyclesMin),
  //         Validators.max(kNumCyclesMax),
  //       ],
  //       validationMessages: {
  //         ValidationMessage.required: (error) =>
  //             tr.form_field_crossover_schedule_num_cycles_range(
  //                 kNumCyclesMin, kNumCyclesMax),
  //         ValidationMessage.min: (error) =>
  //             tr.form_field_crossover_schedule_num_cycles_range(
  //                 kNumCyclesMin, kNumCyclesMax),
  //         ValidationMessage.max: (error) =>
  //             tr.form_field_crossover_schedule_num_cycles_range(
  //                 kNumCyclesMin, kNumCyclesMax),
  //       },
  //     );

  // static int kPhaseDurationMin = 1;
  // static int kPhaseDurationMax = 365;
  // get phaseDurationRange => FormControlValidation(
  //       control: phaseDurationControl,
  //       validators: [
  //         Validators.required,
  //         Validators.min(kPhaseDurationMin),
  //         Validators.max(kPhaseDurationMax)
  //       ],
  //       validationMessages: {
  //         ValidationMessage.required: (error) =>
  //             tr.form_field_crossover_schedule_phase_length_range(
  //                 kPhaseDurationMin, kPhaseDurationMax),
  //         ValidationMessage.min: (error) =>
  //             tr.form_field_crossover_schedule_phase_length_range(
  //                 kPhaseDurationMin, kPhaseDurationMax),
  //         ValidationMessage.max: (error) =>
  //             tr.form_field_crossover_schedule_phase_length_range(
  //                 kPhaseDurationMin, kPhaseDurationMax),
  //       },
  //     );

  // get customSequenceRequired =>
  //     FormControlValidation(control: sequenceTypeCustomControl, validators: [
  //       Validators.required
  //     ], validationMessages: {
  //       ValidationMessage.required: (error) =>
  //           'Custom sequence needs to be specified.',
  //     });

  void addFormGroupToSegments(FormGroup formGroup) {
    segmentsControl.add(formGroup);
  }

  FormGroup createBaselineFormGroup({int duration = 0}) {
    return FormGroup({
      'type': FormControl<String>(value: "baseline"),
      'duration': FormControl<int>(value: duration),
    });
  }

  FormGroup createThompsonSamplingFormGroup({
    int interventionDuration = 0,
    int interventionDrawAmount = 0,
  }) {
    return FormGroup({
      'type': FormControl<String>(value: "thompsonSampling"),
      'interventionDuration': FormControl<int>(value: interventionDuration),
      'interventionDrawAmount': FormControl<int>(value: interventionDrawAmount),
    });
  }

  FormGroup createAlternatingFormGroup({
    int interventionDuration = 0,
    int cycleAmount = 0,
  }) {
    return FormGroup({
      'type': FormControl<String>(value: "alternating"),
      'interventionDuration': FormControl<int>(value: interventionDuration),
      'cycleAmount': FormControl<int>(value: cycleAmount),
    });
  }

  void setStudyScheduleControlsFrom(MP23StudyScheduleFormData data) {
    segmentsControl.clear();
    for (var element in data.segments) {
      if (element is BaselineScheduleSegment) {
        addFormGroupToSegments(
            createBaselineFormGroup(duration: element.duration));
      } else if (element is AlternatingScheduleSegment) {
        addFormGroupToSegments(createAlternatingFormGroup(
          interventionDuration: element.interventionDuration,
          cycleAmount: element.cycleAmount,
        ));
      } else if (element is ThompsonSamplingScheduleSegment) {
        addFormGroupToSegments(createThompsonSamplingFormGroup(
          interventionDuration: element.interventionDuration,
          interventionDrawAmount: element.interventionDrawAmount,
        ));
      }
    }
  }

  MP23StudyScheduleFormData buildStudyScheduleFormData() {
    return MP23StudyScheduleFormData(
      segments: segmentsControl.controls.map((absSegment) {
        final segment = absSegment as FormGroup;
        switch (segment.control('type').value) {
          case "baseline":
            return BaselineScheduleSegment(segment.control('duration').value);
          case "alternating":
            return AlternatingScheduleSegment(
              segment.control('interventionDuration').value,
              segment.control('cycleAmount').value,
            );
          case "thompsonSampling":
            return ThompsonSamplingScheduleSegment(
              segment.control('interventionDuration').value,
              segment.control('interventionDrawAmount').value,
            );
          default:
            throw UnimplementedError();
        }
      }).toList(),
    );
  }
}
