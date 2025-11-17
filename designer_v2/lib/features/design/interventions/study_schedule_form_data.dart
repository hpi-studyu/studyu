import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class StudyScheduleFormData implements IStudyFormData {
  StudyScheduleFormData({
    required this.segments,
    required this.interventions,
    required this.observations,
  });

  final List<StudyScheduleSegment> segments;
  final List<Intervention> interventions;
  final List<Observation> observations;

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
    );
  }

  AdaptiveStudySchedule toAdaptiveStudySchedule() {
    return AdaptiveStudySchedule.withSegments(segments);
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
