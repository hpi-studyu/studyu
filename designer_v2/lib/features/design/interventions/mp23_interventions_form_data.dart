import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/mp23_study_schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class MP23InterventionsFormData implements IStudyFormData {
  MP23InterventionsFormData(
      {required this.interventionsData, required this.studyScheduleData});

  final List<InterventionFormData> interventionsData;
  final MP23StudyScheduleFormData studyScheduleData;

  @override
  String get id =>
      throw UnimplementedError(); // not needed for top-level form data

  factory MP23InterventionsFormData.fromStudy(Study study) {
    return MP23InterventionsFormData(
      interventionsData: study.interventions
          .map((intervention) =>
              InterventionFormData.fromDomainModel(intervention))
          .toList(),
      studyScheduleData: MP23StudyScheduleFormData.fromDomainModel(
          study.mp23Schedule, study.interventions, study.observations),
    );
  }

  @override
  Study apply(Study study) {
    final List<Intervention> interventions =
        interventionsData.map((formData) => formData.toIntervention()).toList();
    study.interventions = interventions;

    studyScheduleData.apply(study);

    return study;
  }

  @override
  MP23InterventionsFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}
