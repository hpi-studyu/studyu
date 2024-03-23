import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class MP23StudyScheduleFormData implements IStudyFormData {
  MP23StudyScheduleFormData({
    required this.segments,
    required this.interventions,
    required this.observations,
  });

  final List<StudyScheduleSegment> segments;
  final List<Intervention> interventions;
  final List<Observation> observations;

  factory MP23StudyScheduleFormData.fromDomainModel(
      MP23StudySchedule schedule, List<Intervention> interventions, List<Observation> observations) {
    return MP23StudyScheduleFormData(
        segments: schedule.segments, interventions: schedule.interventions, observations: schedule.observations);
  }

  MP23StudySchedule toMP23StudySchedule() {
    final schedule = MP23StudySchedule([], []);
    schedule.segments = segments;
    return schedule;
  }

  @override
  Study apply(Study study) {
    study.mp23Schedule = toMP23StudySchedule();
    return study;
  }

  @override
  MP23StudyScheduleFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }

  @override
  FormDataID get id =>
      throw UnimplementedError(); // not needed for top-level form data
}
