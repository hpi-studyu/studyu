import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

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
