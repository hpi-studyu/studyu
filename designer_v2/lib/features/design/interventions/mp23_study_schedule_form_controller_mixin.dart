import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/interventions/mp23_study_schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';

mixin MP23StudyScheduleControls {
  final FormArray segmentsControl = FormArray([]);
  final List<StudyScheduleSegment> segments = [];
  final List<Intervention> interventions = [];
  final List<Observation> observations = [];

  late final studyScheduleControls = {
    'segments': segmentsControl,
  };

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

  void addFormGroupToSegments(FormGroup formGroup) {
    segmentsControl.add(formGroup);
  }

  FormGroup createFormGroup(StudyScheduleSegmentType segmentType) {
    switch (segmentType) {
      case StudyScheduleSegmentType.baseline:
        return createBaselineFormGroup();
      case StudyScheduleSegmentType.alternating:
        return createAlternatingFormGroup();
      case StudyScheduleSegmentType.thompsonSampling:
        return createThompsonSamplingFormGroup();
      default:
        throw UnimplementedError();
    }
  }

  FormGroup createBaselineFormGroup({int duration = 0}) {
    return FormGroup({
      'type': FormControl<StudyScheduleSegmentType>(
        value: StudyScheduleSegmentType.baseline,
      ),
      'duration': FormControl<int>(value: duration),
    });
  }

  FormGroup createThompsonSamplingFormGroup({
    int interventionDuration = 0,
    int interventionDrawAmount = 0,
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
    int interventionDuration = 0,
    int cycleAmount = 0,
  }) {
    return FormGroup({
      'type': FormControl<StudyScheduleSegmentType>(
        value: StudyScheduleSegmentType.alternating,
      ),
      'interventionDuration': FormControl<int>(value: interventionDuration),
      'cycleAmount': FormControl<int>(value: cycleAmount),
    });
  }

  void updateSegmentsFromSegmentsControl() {
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
        default:
          throw UnimplementedError();
      }
    }
  }

  void setStudyScheduleControlsFrom(MP23StudyScheduleFormData data) {
    segmentsControl.clear();
    interventions.clear();
    observations.clear();
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
      }
    }
    interventions.addAll(data.interventions);
    observations.addAll(data.observations);
    updateSegmentsFromSegmentsControl();
  }

  MP23StudyScheduleFormData buildStudyScheduleFormData() {
    return MP23StudyScheduleFormData(
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
            );
          case StudyScheduleSegmentType.thompsonSampling:
            return ThompsonSamplingScheduleSegment(
              segment.control('interventionDuration').value as int,
              segment.control('interventionDrawAmount').value as int,
              segment.control('observationId').value as String,
              segment.control('questionId').value as String,
            );
          default:
            throw UnimplementedError();
        }
      }).toList(),
      interventions: interventions,
      observations: observations,
    );
  }
}
