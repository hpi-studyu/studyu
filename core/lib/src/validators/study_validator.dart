import 'package:studyu_core/src/models/observations/tasks/questionnaire_task.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/eligibility_consent_validator.dart';
import 'package:studyu_core/src/validators/validators/interventions_validator.dart';
import 'package:studyu_core/src/validators/validators/questionnaire_validator.dart';
import 'package:studyu_core/src/validators/validators/report_validator.dart';
import 'package:studyu_core/src/validators/validators/schedule_validator.dart';
import 'package:studyu_core/src/validators/validators/study_info_validator.dart';

export 'validation_result.dart';

ValidationResult validateStudy(Study study, ValidationLevel level) {
  // Validate the screener questionnaire
  final screenerResult = validateQuestionnaire(
    study.questionnaire,
    r'$.questionnaire',
    level,
  );

  // Validate each observation that has questions (QuestionnaireTask only)
  final obsResults = <ValidationResult>[];
  for (var i = 0; i < study.observations.length; i++) {
    final obs = study.observations[i];
    if (obs is QuestionnaireTask) {
      obsResults.add(validateQuestionnaire(
        obs.questions,
        r'$.observations[' + i.toString() + r'].questions',
        level,
      ));
    }
  }

  return ValidationResult.merge([
    validateStudyInfo(study, level),
    validateInterventions(study, level),
    screenerResult,
    ...obsResults,
    validateSchedule(study, level),
    validateReport(study, level),
    validateEligibilityConsent(study, level),
  ]);
}
