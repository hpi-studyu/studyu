import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class MP23StudyScheduleFormData implements IStudyFormData {
  MP23StudyScheduleFormData({
    required this.segments,
  });

  final List<StudyScheduleSegment> segments;

  factory MP23StudyScheduleFormData.fromDomainModel(
      MP23StudySchedule schedule) {
    return MP23StudyScheduleFormData(
      segments: schedule.segments,
    );
  }

  MP23StudySchedule toMP23StudySchedule() {
    final schedule = MP23StudySchedule([]);
    schedule.segments = segments;
    return schedule;
  }

  @override
  Study apply(Study study) {
    print("Apply MP23StudyScheduleFormData");
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
