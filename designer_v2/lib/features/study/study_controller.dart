import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository_events.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

part 'study_controller.g.dart';

@riverpod
class StudyController extends _$StudyController {
  @override
  StudyControllerState build(StudyCreationArgs studyCreationArgs) {
    state = StudyControllerState(
      studyId: studyCreationArgs.studyID,
      studyRepository: ref.watch(studyRepositoryProvider),
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser,
      studyWithMetadata: ref
          .watch(studyBaseControllerProvider(studyCreationArgs))
          .studyWithMetadata,
    );
    ref.onDispose(() => _studyEventsSubscription?.cancel());
    syncStudyStatus();
    return state;
  }

  StreamSubscription<ModelEvent<Study>>? _studyEventsSubscription;

  void syncStudyStatus() {
    if (_studyEventsSubscription != null) {
      _studyEventsSubscription?.cancel();
    }
    _studyEventsSubscription =
        state.studyRepository.watchChanges(state.studyId).listen((event) {
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

  StudyType get studyType => state.study.value?.type ?? StudyType.standalone;

  Future publishStudy({bool toRegistry = false}) {
    final study = state.study.value!;
    study.registryPublished = toRegistry;
    return state.studyRepository.launch(study);
  }

  Future closeStudy() {
    final study = state.study.value!;
    return ref.read(studyRepositoryProvider).close(study);
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

  void onCreateNewSubstudy() {
    state.router
        .dispatch(RoutingIntents.substudyNew(state.study.value! as Template));
  }
}
