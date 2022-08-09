import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';


class StudyRecruitControllerState extends StudyControllerBaseState {
  const StudyRecruitControllerState({
    super.study,
    this.invites = const AsyncValue.loading(),
  });

  /// The list of invite codes (if any) for the currently selected study
  ///
  /// Wrapped in an [AsyncValue] that mirrors the [StudyController]'s current
  /// [Study] async states, so that it can be used with [AsyncValueWidget]
  final AsyncValue<List<StudyInvite>?> invites;

  @override
  StudyRecruitControllerState copyWith({
    AsyncValue<Study> Function()? study,
    AsyncValue<List<StudyInvite>> Function()? invites,
  }) {
    return StudyRecruitControllerState(
      study: (study != null) ? study() : this.study,
      invites: (invites != null) ? invites() : this.invites,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [invites];
}
