import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

// - Study Info

final studyInfoFormViewModelProvider = Provider.autoDispose
    .family<StudyInfoFormViewModel, StudyID>((ref, studyId) {
  return ref.watch(studyFormViewModelProvider(studyId)).studyInfoFormViewModel;
});

// - Enrollment

final enrollmentFormViewModelProvider = Provider.autoDispose
    .family<EnrollmentFormViewModel, StudyID>((ref, studyId) {
  return ref
      .watch(studyFormViewModelProvider(studyId))
      .enrollmentFormViewModel;
});

final screenerQuestionFormViewModelProvider = Provider.autoDispose
    .family<QuestionFormViewModel, ScreenerQuestionFormRouteArgs>((ref, args) {
  final owner = ref.watch(enrollmentFormViewModelProvider(args.studyId));
  return owner.provide(args);
});

// - Interventions

final interventionsFormViewModelProvider = Provider.autoDispose
    .family<InterventionsFormViewModel, StudyID>((ref, studyId) {
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
  return ref.watch(
      studyFormViewModelProvider(studyId)).measurementsFormViewModel;
});

final surveyFormViewModelProvider = Provider.autoDispose
    .family<MeasurementSurveyFormViewModel,MeasurementFormRouteArgs>((ref, args) {
  final owner = ref.watch(measurementsFormViewModelProvider(args.studyId));
  return owner.provide(args);
});

final surveyQuestionFormViewModelProvider = Provider.autoDispose
    .family<QuestionFormViewModel,SurveyQuestionFormRouteArgs>((ref, args) {
  final owner = ref.watch(surveyFormViewModelProvider(args));
  return owner.provide(args);
});
