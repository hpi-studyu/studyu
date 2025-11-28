import 'dart:async';

import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';

mixin StudyScheduleControls {
  final FormArray segmentsControl = FormArray([]);
  final FormControl<int> numberOfInterventionsToSelectControl =
      FormControl<int>(value: 2);
  final FormControl<int> minInterventionsToSelectControl = FormControl<int>(
    value: 2,
  );
  final FormControl<int> maxInterventionsToSelectControl = FormControl<int>(
    value: 2,
  );
  final List<StudyScheduleSegment> segments = [];
  final List<Intervention> interventions = [];
  final List<Observation> observations = [];

  late final Map<String, AbstractControl<dynamic>> studyScheduleControls = {
    'segments': segmentsControl,
    'numberOfInterventionsToSelect': numberOfInterventionsToSelectControl,
    'minInterventionsToSelect': minInterventionsToSelectControl,
    'maxInterventionsToSelect': maxInterventionsToSelectControl,
  };

  StreamSubscription<dynamic>? _selectionCountSubscription;

  void initializeStudyScheduleControls() {
    _selectionCountSubscription ??= numberOfInterventionsToSelectControl
        .valueChanges
        .listen((_) {
          _applyInterventionIndexConstraints();
          updateSegmentsFromSegmentsControl();
        });
  }

  void disposeStudyScheduleControls() {
    _selectionCountSubscription?.cancel();
    _selectionCountSubscription = null;
  }

  int get allowedInterventionCount {
    final total = interventions.length;
    if (total == 0) {
      return 0;
    }
    if (total == 1) {
      return 1;
    }
    final desired = numberOfInterventionsToSelectControl.value ?? 2;
    return desired.clamp(2, total);
  }

  FormValidationConfigSet get studyScheduleValidationConfig => {
    StudyFormValidationSet.draft: [],
    StudyFormValidationSet.publish: [],
    StudyFormValidationSet.test: [],
  };

  int getTotalDuration() {
    int totalDuration = 0;
    for (final segment in segments) {
      totalDuration += segment.getDuration(interventions);
    }
    return totalDuration;
  }

  void deleteSegment(int index) {
    segmentsControl.removeAt(index);
    updateSegmentsFromSegmentsControl();
  }

  void swapSegmentType(int index, StudyScheduleSegmentType newType) {
    final currentFormGroup = segmentsControl.controls[index] as FormGroup;
    final currentType =
        currentFormGroup.control('type').value as StudyScheduleSegmentType;

    if (currentType == newType) {
      return; // No change needed
    }

    // Create a new form group of the target type
    FormGroup newFormGroup;
    switch (newType) {
      case StudyScheduleSegmentType.baseline:
        // Try to preserve duration if coming from alternating
        int duration = 0;
        if (currentType == StudyScheduleSegmentType.alternating) {
          final interventionDuration =
              currentFormGroup.control('interventionDuration').value as int? ??
              0;
          final cycleAmount =
              currentFormGroup.control('cycleAmount').value as int? ?? 0;
          duration = interventionDuration * cycleAmount * interventions.length;
        } else if (currentType == StudyScheduleSegmentType.thompsonSampling) {
          final interventionDuration =
              currentFormGroup.control('interventionDuration').value as int? ??
              0;
          final drawAmount =
              currentFormGroup.control('interventionDrawAmount').value
                  as int? ??
              0;
          duration = interventionDuration * drawAmount;
        }
        newFormGroup = createBaselineFormGroup(duration: duration);
      case StudyScheduleSegmentType.alternating:
        // Try to preserve duration info
        int interventionDuration = 0;
        if (currentType == StudyScheduleSegmentType.baseline) {
          final totalDuration =
              currentFormGroup.control('duration').value as int? ?? 0;
          interventionDuration =
              totalDuration ~/
              (interventions.isNotEmpty ? interventions.length : 1);
        } else if (currentType == StudyScheduleSegmentType.thompsonSampling) {
          interventionDuration =
              currentFormGroup.control('interventionDuration').value as int? ??
              0;
        }
        newFormGroup = createAlternatingFormGroup(
          interventionDuration: interventionDuration,
        );
      case StudyScheduleSegmentType.counterBalanced:
        // Try to preserve duration info
        int interventionDuration = 0;
        if (currentType == StudyScheduleSegmentType.baseline) {
          final totalDuration =
              currentFormGroup.control('duration').value as int? ?? 0;
          interventionDuration =
              totalDuration ~/
              (interventions.isNotEmpty ? interventions.length : 1);
        } else if (currentType == StudyScheduleSegmentType.thompsonSampling) {
          interventionDuration =
              currentFormGroup.control('interventionDuration').value as int? ??
              0;
        } else if (currentType == StudyScheduleSegmentType.alternating) {
          interventionDuration =
              currentFormGroup.control('interventionDuration').value as int? ??
              0;
        }
        newFormGroup = createCounterBalancedFormGroup(
          interventionDuration: interventionDuration,
        );
      case StudyScheduleSegmentType.thompsonSampling:
        // Try to preserve duration info
        int interventionDuration = 0;
        if (currentType == StudyScheduleSegmentType.baseline) {
          final totalDuration =
              currentFormGroup.control('duration').value as int? ?? 0;
          interventionDuration =
              totalDuration ~/
              (interventions.isNotEmpty ? interventions.length : 1);
        } else if (currentType == StudyScheduleSegmentType.alternating) {
          interventionDuration =
              currentFormGroup.control('interventionDuration').value as int? ??
              0;
        } else if (currentType == StudyScheduleSegmentType.counterBalanced) {
          interventionDuration =
              currentFormGroup.control('interventionDuration').value as int? ??
              0;
        }
        newFormGroup = createThompsonSamplingFormGroup(
          interventionDuration: interventionDuration,
        );
      case StudyScheduleSegmentType.singleIntervention:
        newFormGroup = createSingleInterventionFormGroup();
    }

    // Replace the form group at the index
    segmentsControl.removeAt(index);
    segmentsControl.insert(index, newFormGroup);
    updateSegmentsFromSegmentsControl();
  }

  void addFormGroupToSegments(FormGroup formGroup) {
    segmentsControl.add(formGroup);
    updateSegmentsFromSegmentsControl();
  }

  FormGroup createFormGroup(StudyScheduleSegmentType segmentType) {
    switch (segmentType) {
      case StudyScheduleSegmentType.baseline:
        return createBaselineFormGroup();
      case StudyScheduleSegmentType.alternating:
        return createAlternatingFormGroup();
      case StudyScheduleSegmentType.counterBalanced:
        return createCounterBalancedFormGroup();
      case StudyScheduleSegmentType.thompsonSampling:
        return createThompsonSamplingFormGroup();
      case StudyScheduleSegmentType.singleIntervention:
        return createSingleInterventionFormGroup();
    }
  }

  FormGroup createBaselineFormGroup({int duration = 7}) {
    return FormGroup({
      'type': FormControl<StudyScheduleSegmentType>(
        value: StudyScheduleSegmentType.baseline,
      ),
      'duration': FormControl<int>(value: duration),
    });
  }

  FormGroup createThompsonSamplingFormGroup({
    int interventionDuration = 7,
    int interventionDrawAmount = 1,
    String observationId = '',
    String questionId = '',
  }) {
    return FormGroup({
      'type': FormControl<StudyScheduleSegmentType>(
        value: StudyScheduleSegmentType.thompsonSampling,
      ),
      'interventionDuration': FormControl<int>(value: interventionDuration),
      'interventionDrawAmount': FormControl<int>(value: interventionDrawAmount),
      'observationId': FormControl<String>(value: observationId),
      'questionId': FormControl<String>(value: questionId),
    });
  }

  FormGroup createAlternatingFormGroup({
    int interventionDuration = 7,
    int cycleAmount = 1,
    List<String>? interventionIds,
    bool balanceFirstIntervention = false,
    double balanceRatio = 0.5,
  }) {
    return FormGroup({
      'type': FormControl<StudyScheduleSegmentType>(
        value: StudyScheduleSegmentType.alternating,
      ),
      'interventionDuration': FormControl<int>(value: interventionDuration),
      'cycleAmount': FormControl<int>(value: cycleAmount),
      'interventionIds': FormControl<List<String>>(value: interventionIds),
      'balanceFirstIntervention': FormControl<bool>(
        value: balanceFirstIntervention,
      ),
      'balanceRatio': FormControl<double>(value: balanceRatio),
    });
  }

  FormGroup createCounterBalancedFormGroup({
    int interventionDuration = 7,
    int cycleAmount = 1,
    List<String>? interventionIds,
    bool balanceFirstIntervention = false,
    double balanceRatio = 0.5,
  }) {
    return FormGroup({
      'type': FormControl<StudyScheduleSegmentType>(
        value: StudyScheduleSegmentType.counterBalanced,
      ),
      'interventionDuration': FormControl<int>(value: interventionDuration),
      'cycleAmount': FormControl<int>(value: cycleAmount),
      'interventionIds': FormControl<List<String>>(value: interventionIds),
      'balanceFirstIntervention': FormControl<bool>(
        value: balanceFirstIntervention,
      ),
      'balanceRatio': FormControl<double>(value: balanceRatio),
    });
  }

  FormGroup createSingleInterventionFormGroup({
    int interventionIndex = 0,
    int duration = 7,
  }) {
    return FormGroup({
      'type': FormControl<StudyScheduleSegmentType>(
        value: StudyScheduleSegmentType.singleIntervention,
      ),
      'interventionIndex': FormControl<int>(value: interventionIndex),
      'duration': FormControl<int>(value: duration),
    });
  }

  void updateSegmentsFromSegmentsControl() {
    _applyInterventionIndexConstraints();
    segments.clear();
    for (final segmentControl in segmentsControl.controls) {
      final segment = segmentControl as FormGroup;
      switch (segment.control('type').value) {
        case StudyScheduleSegmentType.baseline:
          segments.add(
            BaselineScheduleSegment(segment.control('duration').value as int),
          );
        case StudyScheduleSegmentType.alternating:
          segments.add(
            AlternatingScheduleSegment(
              segment.control('interventionDuration').value as int,
              segment.control('cycleAmount').value as int,
              interventionIds:
                  segment.control('interventionIds').value as List<String>?,
              balanceFirstIntervention:
                  segment.control('balanceFirstIntervention').value as bool? ??
                  false,
              balanceRatio:
                  segment.control('balanceRatio').value as double? ?? 0.5,
            ),
          );
        case StudyScheduleSegmentType.counterBalanced:
          segments.add(
            CounterBalancedScheduleSegment(
              segment.control('interventionDuration').value as int,
              segment.control('cycleAmount').value as int,
              interventionIds:
                  segment.control('interventionIds').value as List<String>?,
              balanceFirstIntervention:
                  segment.control('balanceFirstIntervention').value as bool? ??
                  false,
              balanceRatio:
                  segment.control('balanceRatio').value as double? ?? 0.5,
            ),
          );
        case StudyScheduleSegmentType.thompsonSampling:
          segments.add(
            ThompsonSamplingScheduleSegment(
              segment.control('interventionDuration').value as int,
              segment.control('interventionDrawAmount').value as int,
              segment.control('observationId').value as String,
              segment.control('questionId').value as String,
            ),
          );
        case StudyScheduleSegmentType.singleIntervention:
          segments.add(
            SingleInterventionScheduleSegment(
              segment.control('interventionIndex').value as int,
              segment.control('duration').value as int,
            ),
          );
        default:
          throw UnimplementedError();
      }
    }
  }

  void setStudyScheduleControlsFrom(StudyScheduleFormData data) {
    segmentsControl.clear();
    interventions.clear();
    observations.clear();
    // Populate segments
    for (final element in data.segments) {
      if (element is BaselineScheduleSegment) {
        addFormGroupToSegments(
          createBaselineFormGroup(duration: element.duration),
        );
      } else if (element is AlternatingScheduleSegment) {
        addFormGroupToSegments(
          createAlternatingFormGroup(
            interventionDuration: element.interventionDuration,
            cycleAmount: element.cycleAmount,
            interventionIds: element.interventionIds,
            balanceFirstIntervention: element.balanceFirstIntervention,
            balanceRatio: element.balanceRatio,
          ),
        );
      } else if (element is CounterBalancedScheduleSegment) {
        addFormGroupToSegments(
          createCounterBalancedFormGroup(
            interventionDuration: element.interventionDuration,
            cycleAmount: element.cycleAmount,
            interventionIds: element.interventionIds,
            balanceFirstIntervention: element.balanceFirstIntervention,
            balanceRatio: element.balanceRatio,
          ),
        );
      } else if (element is ThompsonSamplingScheduleSegment) {
        addFormGroupToSegments(
          createThompsonSamplingFormGroup(
            interventionDuration: element.interventionDuration,
            interventionDrawAmount: element.interventionDrawAmount,
            observationId: element.observationId,
            questionId: element.questionId,
          ),
        );
      } else if (element is SingleInterventionScheduleSegment) {
        addFormGroupToSegments(
          createSingleInterventionFormGroup(
            interventionIndex: element.interventionIndex,
            duration: element.duration,
          ),
        );
      }
    }
    // Now set interventions/observations and clamp the number selection
    interventions.addAll(data.interventions);
    observations.addAll(data.observations);

    // Initialize min/max controls based on total interventions
    final totalCount = interventions.length;
    minInterventionsToSelectControl.value = totalCount >= 2 ? 2 : totalCount;
    maxInterventionsToSelectControl.value = totalCount;

    // Ensure the numberOfInterventionsToSelectControl is within valid bounds
    final int total = interventions.length;
    const int minValue = 2;
    final int maxValue = total >= 2 ? total : minValue;
    int desired = data.numberOfInterventionsToSelect;
    if (desired < minValue) desired = minValue;
    if (desired > maxValue) desired = maxValue;
    numberOfInterventionsToSelectControl.value = desired;

    updateSegmentsFromSegmentsControl();
  }

  StudyScheduleFormData buildStudyScheduleFormData() {
    // Clamp saved value as a final guard
    int selected = numberOfInterventionsToSelectControl.value ?? 2;
    final int total = interventions.length;
    const int minValue = 2;
    final int maxValue = total >= 2 ? total : minValue;
    if (selected < minValue) selected = minValue;
    if (selected > maxValue) selected = maxValue;

    return StudyScheduleFormData(
      segments: segmentsControl.controls.map((absSegment) {
        final segment = absSegment as FormGroup;
        switch (segment.control('type').value) {
          case StudyScheduleSegmentType.baseline:
            return BaselineScheduleSegment(
              segment.control('duration').value as int,
            );
          case StudyScheduleSegmentType.alternating:
            return AlternatingScheduleSegment(
              segment.control('interventionDuration').value as int,
              segment.control('cycleAmount').value as int,
              interventionIds:
                  segment.control('interventionIds').value as List<String>?,
              balanceFirstIntervention:
                  segment.control('balanceFirstIntervention').value as bool? ??
                  false,
              balanceRatio:
                  segment.control('balanceRatio').value as double? ?? 0.5,
            );
          case StudyScheduleSegmentType.counterBalanced:
            return CounterBalancedScheduleSegment(
              segment.control('interventionDuration').value as int,
              segment.control('cycleAmount').value as int,
              interventionIds:
                  segment.control('interventionIds').value as List<String>?,
              balanceFirstIntervention:
                  segment.control('balanceFirstIntervention').value as bool? ??
                  false,
              balanceRatio:
                  segment.control('balanceRatio').value as double? ?? 0.5,
            );
          case StudyScheduleSegmentType.thompsonSampling:
            return ThompsonSamplingScheduleSegment(
              segment.control('interventionDuration').value as int,
              segment.control('interventionDrawAmount').value as int,
              segment.control('observationId').value as String,
              segment.control('questionId').value as String,
            );
          case StudyScheduleSegmentType.singleIntervention:
            return SingleInterventionScheduleSegment(
              segment.control('interventionIndex').value as int,
              segment.control('duration').value as int,
            );
          default:
            throw UnimplementedError();
        }
      }).toList(),
      interventions: interventions,
      observations: observations,
      numberOfInterventionsToSelect: selected,
      selectedInterventions: interventions.map((i) => i.id).toList(),
    );
  }

  void _applyInterventionIndexConstraints() {
    // No constraints needed - participants can select from any available choices
  }
}
