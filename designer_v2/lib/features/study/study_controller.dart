import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository_events.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

import '../../repositories/study_repository.dart';
import '../../routing/router.dart';

part 'study_controller.g.dart';

@riverpod
class StudyController extends _$StudyController {
  @override
  StudyControllerState build(StudyID studyId) {
    syncStudyStatus();
    ref.onDispose(() => _studyEventsSubscription?.cancel());
    return StudyControllerState(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser
    );
  }

  StreamSubscription<ModelEvent<Study>>? _studyEventsSubscription;

  void syncStudyStatus() {
    if (_studyEventsSubscription != null) {
      _studyEventsSubscription?.cancel();
    }
    _studyEventsSubscription = state.studyRepository.watchChanges(state.studyId).listen((event) {
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

  onStudySubscriptionUpdate(WrappedModel<Study> wrappedModel) {
    ref.watch(studyBaseControllerProvider(state.studyId).notifier).onStudySubscriptionUpdate(wrappedModel);
    final studyId = wrappedModel.model.id;
    _redirectNewToActualStudyID(studyId);
  }

  /// Redirect to the study-specific URL to avoid disposing a dirty controller
  /// when building subroutes
  void _redirectNewToActualStudyID(StudyID actualStudyId) {
    if (state.studyId == Config.newModelId) {
      state.router.dispatch(RoutingIntents.study(actualStudyId));
    }
  }

  Future publishStudy({bool toRegistry = false}) {
    final study = state.study.value!;
    study.registryPublished = toRegistry;
    return state.studyRepository.launch(study);
  }

  void onChangeStudyParticipation() {
    state.router.dispatch(RoutingIntents.studyEditEnrollment(state.studyId));
  }

  void onAddParticipants() {
    state.router.dispatch(RoutingIntents.studyRecruit(state.studyId));
  }

  void onSettingsPressed() {
    state.router.dispatch(RoutingIntents.studySettings(state.studyId));
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
/*final studyControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyController, StudyControllerState, StudyID>((ref, studyId) {
  print("studyControllerProvider($studyId)");
  final controller = StudyController(
    studyId: studyId,
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
});*/
