import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class MeasurementsFormData implements IStudyFormData {
  MeasurementsFormData({required this.measurements});

  final List<IFormDataWithSchedule> measurements;

  @override
  String get id => throw UnimplementedError(); // not needed for top-level form data

  factory MeasurementsFormData.fromStudy(Study study) {
    return MeasurementsFormData(
      measurements: study.observations.map((observation) {
        if (observation is QuestionnaireTask) {
          return MeasurementSurveyFormData.fromDomainModel(observation);
        } else if (observation is NutritionTask) {
          return NutritionFormData.fromDomainModel(observation);
        }
        throw UnimplementedError(
          'Unknown observation type: ${observation.runtimeType}',
        );
      }).toList(),
    );
  }

  @override
  Study apply(Study study) {
    final List<Observation> observations = measurements.map((formData) {
      if (formData is MeasurementSurveyFormData) {
        return formData.toQuestionnaireTask();
      } else if (formData is NutritionFormData) {
        return formData.toNutritionTask();
      }
      throw UnimplementedError(
        'Unknown form data type: ${formData.runtimeType}',
      );
    }).toList();

    study.observations = observations;
    return study;
  }

  @override
  MeasurementsFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}
