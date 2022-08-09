import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';


class StudyControllerState extends Equatable {
  const StudyControllerState({
    this.study = const AsyncValue.loading(),
  });

  /// The currently selected study that is being viewed or edited wrapped in
  /// a [AsyncValue] for loading & error states
  ///
  /// May be incomplete (for new studies / drafts)
  final AsyncValue<Study> study;

  StudyControllerState copyWith({
    AsyncValue<Study> Function()? study,
  }) {
    return StudyControllerState(
      study: study != null ? study() : this.study,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [study];
}

extension StudyControllerStateUnsafeProps on StudyControllerState {
  /// Make sure to only access these in an [AsyncWidget] so that [study.value]
  /// is available
  String get titleText => study.value!.title ?? "";
  String get statusText => "Status: ${study.value!.status.string}".hardcoded;
}
