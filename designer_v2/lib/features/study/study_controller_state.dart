import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/features/study/study_navbar.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class StudyControllerState extends StudyControllerBaseState
    implements IStudyNavViewModel {
  const StudyControllerState({
    required super.currentUser,
    super.studyWithMetadata,
  });

  bool get isPublishVisible =>
      studyWithMetadata?.model.status == StudyStatus.draft;

  bool get isPublished => study.value != null && study.value!.published;

  StudyStatus? get studyStatus => study.value?.status;
  Participation? get studyParticipation => study.value?.participation;

  bool get isStatusBadgeVisible =>
      studyStatus != null && studyStatus != StudyStatus.draft;

  @override
  StudyControllerState copyWith(
      {WrappedModel<Study>? Function()? studyWithMetadata}) {
    return StudyControllerState(
      studyWithMetadata: studyWithMetadata != null
          ? studyWithMetadata()
          : this.studyWithMetadata,
      currentUser: currentUser,
    );
  }

  // - IStudyNavViewModel

  @override
  bool get isEditTabEnabled =>
      study.value == null ||
      (study.value != null &&
          (study.value!.canEdit(super.currentUser) ||
              study.value!.publishedToRegistry ||
              study.value!.publishedToRegistryResults));

  @override
  bool get isTestTabEnabled => isEditTabEnabled;

  @override
  bool get isRecruitTabEnabled =>
      study.value == null ||
      (study.value != null && study.value!.canEdit(super.currentUser));

  @override
  bool get isMonitorTabEnabled => isRecruitTabEnabled;

  @override
  bool get isAnalyzeTabEnabled =>
      study.value == null ||
      (study.value != null &&
          (study.value!.canEdit(super.currentUser) ||
              study.value!.publishedToRegistryResults));
}

extension StudyControllerStateUnsafeProps on StudyControllerState {
  /// Make sure to only access these in an [AsyncWidget] so that [study.value]
  /// is available
  String get titleText => study.value!.title ?? "";
}
