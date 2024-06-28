import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/mp23_interventions_form_controller.dart';
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

// - Study Info

final studyInfoFormViewModelProvider = Provider.autoDispose
    .family<StudyInfoFormViewModel, StudyID>((ref, studyId) {
  return ref.watch(studyFormViewModelProvider(studyId)).studyInfoFormViewModel;
});

// - Enrollment

final enrollmentFormViewModelProvider = Provider.autoDispose
    .family<EnrollmentFormViewModel, StudyID>((ref, studyId) {
  return ref.watch(studyFormViewModelProvider(studyId)).enrollmentFormViewModel;
});

final screenerQuestionFormViewModelProvider = Provider.autoDispose
    .family<ScreenerQuestionFormViewModel, ScreenerQuestionFormRouteArgs>(
        (ref, args) {
  final owner = ref.watch(enrollmentFormViewModelProvider(args.studyId));
  return owner.provide(args);
});

final consentItemFormViewModelProvider = Provider.autoDispose
    .family<ConsentItemFormViewModel, ConsentItemFormRouteArgs>((ref, args) {
  final owner = ref.watch(enrollmentFormViewModelProvider(args.studyId));
  return owner.consentItemDelegate.provide(args);
});

// - Interventions

final interventionsFormViewModelProvider = Provider.autoDispose
    .family<MP23InterventionsFormViewModel, StudyID>((ref, studyId) {
  return ref
      .watch(studyFormViewModelProvider(studyId))
      .interventionsFormViewModel;
});

final interventionFormViewModelProvider = Provider.autoDispose
    .family<InterventionFormViewModel, InterventionFormRouteArgs>((ref, args) {
  final owner = ref.watch(interventionsFormViewModelProvider(args.studyId));
  return owner.provide(args);
});

final interventionTaskFormViewModelProvider = Provider.autoDispose
    .family<InterventionTaskFormViewModel, InterventionTaskFormRouteArgs>(
        (ref, args) {
  final owner = ref.watch(interventionFormViewModelProvider(args));
  return owner.provide(args);
});

// - Measurements

final measurementsFormViewModelProvider = Provider.autoDispose
    .family<MeasurementsFormViewModel, StudyID>((ref, studyId) {
  return ref
      .watch(studyFormViewModelProvider(studyId))
      .measurementsFormViewModel;
});

final surveyFormViewModelProvider = Provider.autoDispose
    .family<MeasurementSurveyFormViewModel, MeasurementFormRouteArgs>(
        (ref, args) {
  final owner = ref.watch(measurementsFormViewModelProvider(args.studyId));
  return owner.provide(args);
});

final surveyQuestionFormViewModelProvider = Provider.autoDispose
    .family<QuestionFormViewModel, SurveyQuestionFormRouteArgs>((ref, args) {
  final owner = ref.watch(surveyFormViewModelProvider(args));
  return owner.provide(args);
});

// - Reports

final reportsFormViewModelProvider =
    Provider.autoDispose.family<ReportsFormViewModel, StudyID>((ref, studyId) {
  return ref.watch(studyFormViewModelProvider(studyId)).reportsFormViewModel;
});

final reportItemFormViewModelProvider = Provider.autoDispose
    .family<ReportItemFormViewModel, ReportItemFormRouteArgs>((ref, args) {
  final owner = ref.watch(reportsFormViewModelProvider(args.studyId));
  return owner.reportItemDelegate.provide(args);
});

// - Validators

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.publish]
final studyPublishValidatorProvider =
    Provider.autoDispose.family<StudyFormViewModel, StudyID>((ref, studyId) {
  final state = ref.watch(studyControllerProvider(studyId));
  final formViewModel = StudyFormViewModel(
    router: ref.watch(routerProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    formData: state.study.value,
    validationSet: StudyFormValidationSet.publish,
  );
  ref.onDispose(() {
    formViewModel.dispose();
  });
  return formViewModel;
});

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.test]
final studyTestValidatorProvider =
    Provider.autoDispose.family<StudyFormViewModel, StudyID>((ref, studyId) {
  final state = ref.watch(studyControllerProvider(studyId));
  final formViewModel = StudyFormViewModel(
    router: ref.watch(routerProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    formData: state.study.value,
    validationSet: StudyFormValidationSet.test,
  );
  ref.onDispose(() {
    formViewModel.dispose();
  });
  return formViewModel;
});
