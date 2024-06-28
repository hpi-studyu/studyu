import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class StudyRecruitController
    extends StudyBaseController<StudyRecruitControllerState>
    implements IModelActionProvider<StudyInvite> {
  StudyRecruitController({
    required super.studyId,
    required super.studyRepository,
    required super.currentUser,
    required super.router,
    required this.inviteCodeRepository,
  }) : super(StudyRecruitControllerState(currentUser: currentUser)) {
    print("StudyRecruitController.constructor");
    _subscribeInvites();
  }

  /// Reference to the repository for invite codes (resolved dynamically via
  /// Riverpod when the [state.study] becomes available)
  final IInviteCodeRepository inviteCodeRepository;

  StreamSubscription<List<WrappedModel<StudyInvite>>>? _invitesSubscription;

  void _subscribeInvites() {
    print("StudyRecruitController.subscribe");
    _invitesSubscription =
        inviteCodeRepository.watchAll().listen((wrappedModels) {
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
    final actions = inviteCodeRepository
        .availableActions(model)
        .where((action) => action.type != ModelActionType.clipboard)
        .toList();
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(StudyInvite model) {
    final actions = inviteCodeRepository
        .availableActions(model)
        .where((action) => action.type == ModelActionType.clipboard)
        .toList();
    return withIcons(actions, modelActionIcons);
  }

  @override
  void dispose() {
    print("StudyRecruitController.dispose");
    _invitesSubscription?.cancel();
    super.dispose();
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyRecruitControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyRecruitController, StudyRecruitControllerState, StudyID>(
        (ref, studyId) {
  return StudyRecruitController(
    studyId: studyId,
    studyRepository: ref.watch(studyRepositoryProvider),
    currentUser: ref.watch(authRepositoryProvider).currentUser,
    router: ref.watch(routerProvider),
    inviteCodeRepository: ref.watch(inviteCodeRepositoryProvider(studyId)),
  );
});
