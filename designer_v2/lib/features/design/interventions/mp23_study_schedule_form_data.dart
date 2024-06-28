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
    MP23StudySchedule schedule,
    List<Intervention> interventions,
    List<Observation> observations,
  ) {
    return MP23StudyScheduleFormData(
      // todo or user schedule.interventions, schedule.observations instead?
      segments: schedule.segments, interventions: interventions,
      observations: observations,
    );
  }

  MP23StudySchedule toMP23StudySchedule() {
    return MP23StudySchedule.withSegments(segments);
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
