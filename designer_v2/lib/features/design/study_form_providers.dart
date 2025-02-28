import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

part 'study_form_providers.g.dart';

// - Study Info

@riverpod
StudyInfoFormViewModel studyInfoFormViewModel(
  StudyInfoFormViewModelRef ref,
  StudyID studyId,
) {
  return ref.watch(studyFormViewModelProvider(studyId)).studyInfoFormViewModel;
}

// - Enrollment

@riverpod
EnrollmentFormViewModel enrollmentFormViewModel(
  EnrollmentFormViewModelRef ref,
  StudyID studyId,
) {
  return ref.watch(studyFormViewModelProvider(studyId)).enrollmentFormViewModel;
}

@riverpod
ScreenerQuestionFormViewModel screenerQuestionFormViewModel(
  ScreenerQuestionFormViewModelRef ref,
  ScreenerQuestionFormRouteArgs args,
) {
  return ref.watch(enrollmentFormViewModelProvider(args.studyId)).provide(args);
}

@riverpod
ConsentItemFormViewModel consentItemFormViewModel(
  ConsentItemFormViewModelRef ref,
  ConsentItemFormRouteArgs args,
) {
  return ref
      .watch(enrollmentFormViewModelProvider(args.studyId))
      .consentItemDelegate
      .provide(args);
}

// - Interventions

@riverpod
InterventionsFormViewModel interventionsFormViewModel(
  InterventionsFormViewModelRef ref,
  StudyID studyId,
) {
  return ref
      .watch(studyFormViewModelProvider(studyId))
      .interventionsFormViewModel;
}

@riverpod
InterventionFormViewModel interventionFormViewModel(
  InterventionFormViewModelRef ref,
  InterventionFormRouteArgs args,
) {
  return ref
      .watch(interventionsFormViewModelProvider(args.studyId))
      .provide(args);
}

@riverpod
InterventionTaskFormViewModel interventionTaskFormViewModel(
  InterventionTaskFormViewModelRef ref,
  InterventionTaskFormRouteArgs args,
) {
  return ref.watch(interventionFormViewModelProvider(args)).provide(args);
}

// - Measurements

@riverpod
MeasurementsFormViewModel measurementsFormViewModel(
  MeasurementsFormViewModelRef ref,
  StudyID studyId,
) {
  return ref
      .watch(studyFormViewModelProvider(studyId))
      .measurementsFormViewModel;
}

@riverpod
MeasurementSurveyFormViewModel surveyFormViewModel(
  SurveyFormViewModelRef ref,
  MeasurementFormRouteArgs args,
) {
  return ref
      .watch(measurementsFormViewModelProvider(args.studyId))
      .provide(args);
}

@riverpod
QuestionFormViewModel surveyQuestionFormViewModel(
  SurveyQuestionFormViewModelRef ref,
  SurveyQuestionFormRouteArgs args,
) {
  return ref.watch(surveyFormViewModelProvider(args)).provide(args);
}

// - Reports

@riverpod
ReportsFormViewModel reportsFormViewModel(
  ReportsFormViewModelRef ref,
  StudyID studyId,
) {
  return ref.watch(studyFormViewModelProvider(studyId)).reportsFormViewModel;
}

@riverpod
ReportItemFormViewModel reportItemFormViewModel(
  ReportItemFormViewModelRef ref,
  ReportItemFormRouteArgs args,
) {
  return ref
      .watch(reportsFormViewModelProvider(args.studyId))
      .reportItemDelegate
      .provide(args);
}

// - Validators

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.publish]
@riverpod
StudyFormViewModel studyPublishValidator(
  StudyPublishValidatorRef ref,
  StudyID studyId,
) {
  final state = ref.watch(studyControllerProvider(studyId));
  return StudyFormViewModel(
    router: ref.watch(routerProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    formData: state.study.value,
    validationSet: StudyFormValidationSet.publish,
  );
}

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.test]
@riverpod
StudyFormViewModel studyTestValidator(
  StudyTestValidatorRef ref,
  StudyID studyId,
) {
  final state = ref.watch(studyControllerProvider(studyId));
  return StudyFormViewModel(
    router: ref.watch(routerProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    formData: state.study.value,
  );
}
