import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';


class StudyRecruitController extends StateNotifier<StudyControllerState>
    implements IModelActionProvider<ModelActionType, StudyInvite> {

  StudyRecruitController({
    required this.inviteCodeRepository,
    required this.studyControllerState,
  }) :  super(studyControllerState);

  final IInviteCodeRepository inviteCodeRepository;

  final StudyControllerState studyControllerState;

  Intervention? getIntervention(String interventionId) {
    return state.study.value!.getIntervention(interventionId);
  }

  // - IModelActionProvider

  @override
  List<ModelAction<ModelActionType>> availableActions(StudyInvite model) {
    final actions = inviteCodeRepository.availableActions(model)
        .where((action) => action.type != ModelActionType.clipboard).toList();
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction<ModelActionType>> availableInlineActions(StudyInvite model) {
    final actions = inviteCodeRepository.availableActions(model)
        .where((action) => action.type == ModelActionType.clipboard).toList();
    return withIcons(actions, modelActionIcons);
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyRecruitControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyRecruitController, StudyControllerState, StudyID>((ref, studyId) {
      print("studyRecruitControllerProvider");
      return StudyRecruitController(
        inviteCodeRepository: ref.watch(inviteCodeRepositoryProvider),
        // Bind to parent controller's state & rebuild when it changes
        studyControllerState: ref.watch(studyControllerProvider(studyId)),
      );
});
