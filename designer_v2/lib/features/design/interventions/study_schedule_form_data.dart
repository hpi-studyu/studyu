import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class StudyScheduleFormData implements IStudyFormData {
  StudyScheduleFormData({
    required this.segments,
    required this.interventions,
    required this.observations,
    this.numberOfInterventionsToSelect = 2,
    this.selectedInterventions = const [],
  });

  final List<StudyScheduleSegment> segments;
  final List<Intervention> interventions;
  final List<Observation> observations;
  final int numberOfInterventionsToSelect;
  final List<String> selectedInterventions;

  factory StudyScheduleFormData.fromDomainModel(
    AdaptiveStudySchedule schedule,
    List<Intervention> interventions,
    List<Observation> observations,
  ) {
    return StudyScheduleFormData(
      // todo or user schedule.interventions, schedule.observations instead?
      segments: schedule.segments,
      interventions: interventions,
      observations: observations,
      numberOfInterventionsToSelect: schedule.numberOfInterventionsToSelect,
      selectedInterventions: schedule.selectedInterventions,
    );
  }

  AdaptiveStudySchedule toAdaptiveStudySchedule() {
    return AdaptiveStudySchedule.withSegments(
      segments,
      numberOfInterventionsToSelect: numberOfInterventionsToSelect,
      selectedInterventions: selectedInterventions,
    );
  }

  @override
  Study apply(Study study) {
    study.adaptiveSchedule = toAdaptiveStudySchedule();
    return study;
  }

  @override
  StudyScheduleFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }

  @override
  FormDataID get id => throw UnimplementedError(); // not needed for top-level form data
}
