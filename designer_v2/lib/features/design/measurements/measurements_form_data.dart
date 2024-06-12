import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class MeasurementsFormData implements IStudyFormData {
  MeasurementsFormData({required this.surveyMeasurements});

  final List<MeasurementSurveyFormData> surveyMeasurements;

  @override
  String get id =>
      throw UnimplementedError(); // not needed for top-level form data

  factory MeasurementsFormData.fromStudy(Study study) {
    return MeasurementsFormData(
      surveyMeasurements: study.observations
          .map(
            (observation) => MeasurementSurveyFormData.fromDomainModel(
              observation as QuestionnaireTask,
            ),
          )
          .toList(),
    );
  }

  @override
  Study apply(Study study) {
    final List<QuestionnaireTask> surveys = surveyMeasurements
        .map((formData) => formData.toQuestionnaireTask())
        .toList();
    study.observations = surveys;
    return study;
  }

  @override
  MeasurementsFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}
