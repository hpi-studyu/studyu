import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';


class StudyRecruitController extends StateNotifier<StudyControllerState> {
  /// References to the data repositories injected by Riverpod
  final IStudyRepository studyRepository;

  final StudyControllerState studyControllerState;

  /// Identifier of the study currently being edited / viewed
  /// Used to retrieve the [Study] object from the data layer
  final StudyID studyId;

  StudyRecruitController({
    required this.studyId,
    required this.studyRepository,
    required this.studyControllerState,
  }) :  super(studyControllerState);

  onSelectInvite(StudyInvite invite) {
    print("selected invite");
  }

  List<ModelAction> getActionsForInvite(StudyInvite invite) {
    return [];
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyRecruitControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyRecruitController, StudyControllerState, StudyID>((ref, studyId) =>
    StudyRecruitController(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      // Bind to parent controller's state & rebuild when it changes
      studyControllerState: ref.watch(studyControllerProvider(studyId)),
    )
);
