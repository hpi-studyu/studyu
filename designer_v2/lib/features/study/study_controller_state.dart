import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class StudyControllerState extends StudyControllerBaseState {
  const StudyControllerState({
    super.studyWithMetadata,
  });

  bool get isPublishVisible =>
      studyWithMetadata?.model.status == StudyStatus.draft;

  bool get isPublished => study.value != null && study.value!.published;

  StudyStatus? get studyStatus => study.value?.status;
  Participation? get studyParticipation => study.value?.participation;

  bool get isStatusBadgeVisible => studyStatus != null &&
      studyStatus != StudyStatus.draft;

  @override
  StudyControllerState copyWith({
    WrappedModel<Study>? Function()? studyWithMetadata
  }) {
    return StudyControllerState(
      studyWithMetadata: studyWithMetadata != null
          ? studyWithMetadata() : this.studyWithMetadata,
    );
  }
}

extension StudyControllerStateUnsafeProps on StudyControllerState {
  /// Make sure to only access these in an [AsyncWidget] so that [study.value]
  /// is available
  String get titleText => study.value!.title ?? "";
}
