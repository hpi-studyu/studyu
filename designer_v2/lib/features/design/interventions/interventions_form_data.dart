import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class InterventionsFormData implements IStudyFormData {
  InterventionsFormData({
    required this.interventionsData,
    required this.studyScheduleData
  });

  final List<InterventionFormData> interventionsData;
  final StudyScheduleFormData studyScheduleData;

  @override
  String get id =>
      throw UnimplementedError(); // not needed for top-level form data

  factory InterventionsFormData.fromStudy(Study study) {
    return InterventionsFormData(
      interventionsData: study.interventions
          .map((intervention) =>
              InterventionFormData.fromDomainModel(intervention))
          .toList(),
      studyScheduleData: StudyScheduleFormData.fromDomainModel(study.schedule),
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
  InterventionsFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}
