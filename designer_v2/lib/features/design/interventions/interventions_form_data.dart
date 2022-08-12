import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class InterventionsFormData implements IStudyFormData {
  InterventionsFormData({required this.interventionsData});

  final List<InterventionFormData> interventionsData;
  // TODO phase scheduling

  @override
  String get id =>
      throw UnimplementedError(); // not needed for top-level form data

  factory InterventionsFormData.fromStudy(Study study) {
    return InterventionsFormData(
      interventionsData: study.interventions
          .map((intervention) =>
              InterventionFormData.fromDomainModel(intervention))
          .toList(),
    );
  }

  @override
  Study apply(Study study) {
    final List<Intervention> interventions =
        interventionsData.map((formData) => formData.toIntervention()).toList();
    study.interventions = interventions;
    return study;
  }

  @override
  InterventionsFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}
