import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class StudyScheduleFormData implements IStudyFormData {
  StudyScheduleFormData(
      {required this.sequenceType,
      required this.sequenceTypeCustom,
      required this.numCycles,
      required this.phaseDuration,
      required this.includeBaseline,
      
      
      });

  final PhaseSequence sequenceType;
  final String sequenceTypeCustom;
  final int numCycles;
  final int phaseDuration;
  final bool includeBaseline;




  factory StudyScheduleFormData.fromDomainModel(StudySchedule schedule) {
    return StudyScheduleFormData(
      sequenceType: schedule.sequence,
      sequenceTypeCustom: schedule.sequenceCustom,
      numCycles: schedule.numberOfCycles,
      phaseDuration: schedule.phaseDuration,
      includeBaseline: schedule.includeBaseline,
    );
  }

  StudySchedule toStudySchedule() {
    final schedule = StudySchedule();
    schedule.sequence = sequenceType;
    schedule.sequenceCustom = sequenceTypeCustom;
    schedule.numberOfCycles = numCycles;
    schedule.phaseDuration = phaseDuration;
    schedule.includeBaseline = includeBaseline;
    return schedule;
  }

  @override
  Study apply(Study study) {
    study.schedule = toStudySchedule();
    return study;
  }

  @override
  StudyScheduleFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }

  @override
  FormDataID get id => throw UnimplementedError(); // not needed for top-level form data
}
