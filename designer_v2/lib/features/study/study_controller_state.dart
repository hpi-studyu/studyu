import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
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
  /// TODO: null value = 404?
  final AsyncValue<Study?> study;

  /// Flag indicating whether the managed study has any unsaved changes
  final bool isDirty;

  StudyControllerState copyWith({
    AsyncValue<Study?> Function()? study,
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

extension StudyControllerStateX on StudyControllerState {
  String get titleText => study.value?.title ?? "Unnamed study".hardcoded;
  String get statusText => "Status: ${study.value?.status.string ?? ""}".hardcoded;
}