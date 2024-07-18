import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/sync_indicator.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/features/study/study_scaffold.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

import 'package:studyu_designer_v2/utils/model_action.dart';

class StudyControllerState extends StudyControllerBaseState
    implements IStudyAppBarViewModel, ISyncIndicatorViewModel {
  const StudyControllerState({
    required super.studyId,
    required super.studyRepository,
    required super.router,
    required super.currentUser,
    super.studyWithMetadata,
    this.isDirty = false,
    this.syncState = const AsyncValue<void>.data(null),
    this.lastSynced,
  });

  bool get isPublished =>
      study.value != null && study.value!.status == StudyStatus.running;

  bool get isClosed =>
      study.value != null && study.value!.status == StudyStatus.closed;

  List<ModelAction> get studyActions {
    final studyVal = study.value;
    if (studyVal == null) {
      return [];
    }
    // filter out edit action since we are already editing the study
    return withIcons(
      studyRepository
          .availableActions(studyVal)
          .where((action) => action.type != StudyActionType.edit)
          .toList(),
      studyActionIcons,
    );
  }

  // - ISyncIndicatorViewModel

  @override
  final AsyncValue syncState;

  @override
  final bool isDirty;

  @override
  final DateTime? lastSynced;

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
  bool get isMonitorTabEnabled => isAnalyzeTabEnabled;

  @override
  bool get isAnalyzeTabEnabled =>
      study.value == null ||
      (study.value != null &&
          (study.value!.canEdit(super.currentUser) ||
              study.value!.publishedToRegistryResults));

  @override
  bool get isSettingsEnabled =>
      study.value != null && study.value!.canChangeSettings(super.currentUser!);

  // - IStudyAppBarViewModel

  @override
  bool get isStatusBadgeVisible =>
      studyStatus != null && studyStatus != StudyStatus.draft;

  @override
  bool get isSyncIndicatorVisible =>
      studyStatus != null && studyStatus == StudyStatus.draft;

  @override
  bool get isPublishVisible =>
      studyWithMetadata?.model.status == StudyStatus.draft;

  @override
  bool get isClosedVisible =>
      studyWithMetadata?.model.status == StudyStatus.running &&
      studyWithMetadata!.model.canEdit(super.currentUser);

  bool get isCreateNewSubstudyVisible =>
      studyWithMetadata?.model.status == StudyStatus.running &&
      studyWithMetadata?.model.isTemplate == true;

  StudyType get studyType =>
      studyWithMetadata?.model.type ?? StudyType.standalone;

  @override
  StudyStatus? get studyStatus => study.value?.status;

  @override
  Participation? get studyParticipation => study.value?.participation;

  // - Equatable

  @override
  List<Object?> get props => [...super.props, syncState, isDirty, lastSynced];

  @override
  StudyControllerState copyWith({
    WrappedModel<Study>? studyWithMetadata,
    bool? isDirty,
    AsyncValue? syncState,
    DateTime? lastSynced,
  }) {
    return StudyControllerState(
      studyId: studyId,
      studyRepository: studyRepository,
      router: router,
      currentUser: currentUser,
      studyWithMetadata: studyWithMetadata ?? super.studyWithMetadata,
      isDirty: isDirty ?? this.isDirty,
      syncState: syncState ?? this.syncState,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }
}

extension StudyControllerStateUnsafeProps on StudyControllerState {
  /// Make sure to only access these in an [AsyncWidget] so that [study.value]
  /// is available
  String get titleText => study.value!.title ?? "";
}
