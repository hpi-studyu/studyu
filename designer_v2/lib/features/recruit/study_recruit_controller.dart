import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';


class StudyRecruitController extends StateNotifier<StudyRecruitControllerState>
    implements IModelActionProvider<StudyInvite> {

  StudyRecruitController({
    required study,
    required this.inviteCodeRepository,
  }) :  super(StudyRecruitControllerState(study: study)) {
    if (study.hasValue && study.value != null) {
      _subscribeInvites();
    }
  }

  /// Reference to the invite code repository injected via Riverpod
  /// Note: null until the [study] is fully loaded
  final IInviteCodeRepository? inviteCodeRepository;

  StreamSubscription<List<WrappedModel<StudyInvite>>>? _invitesSubscription;

  _subscribeInvites() {
    print("StudyRecruitController.subscribe");
    _invitesSubscription = inviteCodeRepository!.watchAll().listen((wrappedModels) {
      print("StudyRecruitController.listenUpdate");
      // Update the controller's state when new invites are available in the repository
      final invites = wrappedModels.map((invite) => invite.model).toList();
      print(invites);
      state = state.copyWith(
        invites: () => AsyncValue.data(invites),
      );
    }); // TODO onError
  }

  Intervention? getIntervention(String interventionId) {
    return state.study.value!.getIntervention(interventionId);
  }

  // - IModelActionProvider

  @override
  List<ModelAction> availableActions(StudyInvite model) {
    final actions = inviteCodeRepository!.availableActions(model)
        .where((action) => action.type != ModelActionType.clipboard).toList();
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(StudyInvite model) {
    final actions = inviteCodeRepository!.availableActions(model)
        .where((action) => action.type == ModelActionType.clipboard).toList();
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
  .family<StudyRecruitController, StudyRecruitControllerState, StudyID>((ref, studyId) {
    // Reactively bind to & obtain [StudyController]'s current study
    final study = ref.watch(
        studyControllerProvider(studyId).select((state) => state.study));
    final inviteCodeRepository = (study.hasValue && study.value != null)
        ? ref.watch(inviteCodeRepositoryProvider(study.value!)) : null;
    return StudyRecruitController(
        study: study,
        inviteCodeRepository: inviteCodeRepository
    );
});
