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
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class StudyController extends StudyBaseController<StudyControllerState> {
  StudyController({
    required super.studyId,
    required super.studyRepository,
    required super.currentUser,
    required super.router,
    required this.notificationService,
    //required this.ref,
  }) : super(StudyControllerState(currentUser: currentUser)) {
    /*
    studyEventsSubscription =
        studyRepository.watchChanges(studyId).listen((event) {
      if (event is StudyLaunched) {
        final testController =
            ref.read(studyTestPlatformControllerProvider(studyId));
        testController?.reset();
        print("study launched");
      }
    });
     */
  }

  final INotificationService notificationService;
  //late final StreamSubscription<ModelEvent<Study>> studyEventsSubscription;
  //final Ref ref;

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

  List<ModelAction<StudyActionType>> get studyActions {
    final study = state.study.value;
    if (study == null) {
      return [];
    }
    // filter out edit action since we are already editing the study
    return withIcons(
        studyRepository
            .availableActions(study)
            .where((action) => action.type != StudyActionType.edit)
            .toList() as List<ModelAction<StudyActionType>>,
        studyActionIcons);
  }

  Future<void> publishStudy() {
    // TODO: save study repository form view model setting
    return studyRepository.launch(state.study.value!);
  }

  void onChangeStudyParticipation() {
    router.dispatch(RoutingIntents.studyEditEnrollment(studyId));
  }

  void onAddParticipants() {
    router.dispatch(RoutingIntents.studyRecruit(studyId));
  }

  @override
  dispose() {
    //studyEventsSubscription.cancel();
    super.dispose();
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyController, StudyControllerState, StudyID>((ref, studyId) {
  print("studyControllerProvider($studyId)");
  final controller = StudyController(
    studyId: studyId,
    studyRepository: ref.watch(studyRepositoryProvider),
    currentUser: ref.watch(currentUserProvider),
    router: ref.watch(routerProvider),
    notificationService: ref.watch(notificationServiceProvider),
    //ref: ref,
  );
  ref.onDispose(() {
    print("studyControllerProvider($studyId).DISPOSE");
  });
  return controller;
});
