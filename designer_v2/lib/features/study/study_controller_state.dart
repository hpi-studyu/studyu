import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';


class StudyControllerState extends Equatable {
  const StudyControllerState({
    this.study = const AsyncValue.loading(),
    this.isDirty = false,
  });

  /// The currently selected study that is being viewed or edited wrapped in
  /// a [AsyncValue] for loading & error states
  ///
  /// May be incomplete (for new studies / drafts)
  final AsyncValue<Study> study;

  /// The list of invite codes (if any) for the currently selected study
  ///
  /// Wrapped in an [AsyncValue] that mirrors the [study]'s async states,
  /// so that it can be used with [AsyncValueWidget]
  AsyncValue<List<StudyInvite>?> get studyInvites {
    return study.when(
      data: (study) => AsyncValue.data(study.invites),
      error: (error, _) => AsyncValue.error(error),
      loading: () => const AsyncValue.loading(),
    );
  }

  /// Flag indicating whether the managed study has any unsaved changes
  final bool isDirty;

  StudyControllerState copyWith({
    AsyncValue<Study> Function()? study,
    bool Function()? isDirty,
  }) {
    return StudyControllerState(
      study: study != null ? study() : this.study,
      isDirty: isDirty != null ? isDirty() : this.isDirty,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [study, isDirty];
}

extension StudyControllerStateUnsafeProps on StudyControllerState {
  /// Make sure to only access these in an [AsyncWidget] so that [study.value]
  /// is available
  String get titleText => study.value!.title ?? "";
  String get statusText => "Status: ${study.value!.status.string}".hardcoded;
}
