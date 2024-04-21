import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class StudyRecruitControllerState extends StudyControllerBaseState {
  const StudyRecruitControllerState({
    required super.studyId,
    required super.studyRepository,
    required super.router,
    required super.currentUser,
    super.studyWithMetadata,
    required this.inviteCodeRepository,
    this.invites = const AsyncValue.loading(),
  });

  /// The list of invite codes (if any) for the currently selected study
  ///
  /// Wrapped in an [AsyncValue] that mirrors the [StudyController]'s current
  /// [Study] async states, so that it can be used with [AsyncValueWidget]
  final AsyncValue<List<StudyInvite>?> invites;

  final InviteCodeRepository inviteCodeRepository;

  @override
  StudyRecruitControllerState copyWith({
    WrappedModel<Study>? studyWithMetadata,
    AsyncValue<List<StudyInvite>>? invites,
  }) {
    return StudyRecruitControllerState(
      studyId: studyId,
      studyRepository: studyRepository,
      router: router,
      currentUser: currentUser,
      studyWithMetadata: studyWithMetadata ?? super.studyWithMetadata,
      inviteCodeRepository: inviteCodeRepository,
      invites: invites ?? this.invites,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [...super.props, invites];
}
