import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository_events.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class StudyController extends StudyBaseController<StudyControllerState> {
  StudyController({
    required super.studyCreationArgs,
    required super.studyRepository,
    required super.currentUser,
    required super.router,
    required this.notificationService,
  }) : super(StudyControllerState(currentUser: currentUser)) {
    syncStudyStatus();
  }

  final INotificationService notificationService;
  StreamSubscription<ModelEvent<Study>>? studyEventsSubscription;

  syncStudyStatus() {
    if (studyEventsSubscription != null) {
      studyEventsSubscription?.cancel();
    }
    studyEventsSubscription = studyRepository.watchChanges(studyId).listen((event) {
      if (event is IsSaving) {
        state = state.copyWith(
          syncState: const AsyncValue.loading(),
          isDirty: state.isDirty,
        );
      } else if (event is IsSaved) {
        state = state.copyWith(
          syncState: const AsyncValue.data(null),
          lastSynced: DateTime.now(),
          isDirty: false,
        );
      }
    });
  }

  @override
  onStudySubscriptionUpdate(WrappedModel<Study> wrappedModel) {
    super.onStudySubscriptionUpdate(wrappedModel);
    final studyId = wrappedModel.model.id;
    _redirectNewToActualStudyID(studyId);
  }

  /// Redirect to the study-specific URL to avoid disposing a dirty controller
  /// when building subroutes
  _redirectNewToActualStudyID(StudyID actualStudyId) {
    if (studyId == Config.newModelId) {
      router.dispatch(RoutingIntents.study(actualStudyId));
    }
  }

  List<ModelAction> get studyActions {
    final study = state.study.value;
    if (study == null) {
      return [];
    }
    // filter out edit action since we are already editing the study
    return withIcons(
        studyRepository.availableActions(study).where((action) => action.type != StudyActionType.edit).toList(),
        studyActionIcons);
  }

  StudyType get studyType => state.study.value?.type ?? StudyType.standalone;

  Future publishStudy({toRegistry = false}) {
    final study = state.study.value!;
    study.registryPublished = toRegistry;
    return studyRepository.launch(study);
  }

  void onChangeStudyParticipation() {
    router.dispatch(RoutingIntents.studyEditEnrollment(studyId));
  }

  void onAddParticipants() {
    router.dispatch(RoutingIntents.studyRecruit(studyId));
  }

  void onSettingsPressed() {
    router.dispatch(RoutingIntents.studySettings(studyId));
  }

  void onCreateNewTemplateTrial() {
    router.dispatch(RoutingIntents.templatetrialNew(state.study.value! as Template));
  }

  @override
  dispose() {
    studyEventsSubscription?.cancel();
    super.dispose();
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyController, StudyControllerState, StudyCreationArgs>((ref, studyCreationArgs) {
  final studyId = studyCreationArgs.studyID;
  print("studyControllerProvider($studyId)");
  final controller = StudyController(
    studyCreationArgs: studyCreationArgs,
    studyRepository: ref.watch(studyRepositoryProvider),
    currentUser: ref.watch(authRepositoryProvider).currentUser,
    router: ref.watch(routerProvider),
    notificationService: ref.watch(notificationServiceProvider),
    //ref: ref,
  );
  controller.addListener((state) {
    print("studyController.state updated");
  });
  ref.onDispose(() {
    print("studyControllerProvider($studyId).DISPOSE");
  });
  return controller;
});
