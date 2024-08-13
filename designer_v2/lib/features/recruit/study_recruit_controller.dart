import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

part 'study_recruit_controller.g.dart';

@riverpod
class StudyRecruitController extends _$StudyRecruitController
    implements IModelActionProvider<StudyInvite> {
  /// [inviteCodeRepository] Reference to the repository for invite codes (resolved dynamically via Riverpod when the [state.study] becomes available)
  @override
  StudyRecruitControllerState build(StudyID studyId) {
    state = StudyRecruitControllerState(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      studyWithMetadata:
          ref.watch(studyControllerProvider(studyId)).studyWithMetadata,
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser,
      inviteCodeRepository: ref.watch(inviteCodeRepositoryProvider(studyId)),
    );
    ref.onDispose(() {
      print("StudyRecruitController.dispose");
      _invitesSubscription?.cancel();
    });
    _subscribeInvites();
    return state;
  }

  StreamSubscription<List<WrappedModel<StudyInvite>>>? _invitesSubscription;

  void _subscribeInvites() {
    print("StudyRecruitController.subscribe");
    _invitesSubscription =
        state.inviteCodeRepository.watchAll().listen((wrappedModels) {
      print("StudyRecruitController.listenUpdate");
      // Update the controller's state when new invites are available in the repository
      final invites = wrappedModels.map((invite) => invite.model).toList();
      // Sort invites alphabetically by code
      invites.sort((a, b) => a.code.compareTo(b.code));
      state = state.copyWith(
        invites: AsyncValue.data(invites),
      );
    }); // TODO onError
  }

  Intervention? getIntervention(String interventionId) {
    return state.study.value!.getIntervention(interventionId);
  }

  int getParticipantCountForInvite(StudyInvite invite) {
    return state.study.value!.getParticipantCountForInvite(invite);
  }

  // - IModelActionProvider

  @override
  List<ModelAction> availableActions(StudyInvite model) {
    final actions = state.inviteCodeRepository
        .availableActions(model)
        .where((action) => action.type != ModelActionType.clipboard)
        .toList();
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(StudyInvite model) {
    final actions = state.inviteCodeRepository
        .availableActions(model)
        .where((action) => action.type == ModelActionType.clipboard)
        .toList();
    return withIcons(actions, modelActionIcons);
  }
}
