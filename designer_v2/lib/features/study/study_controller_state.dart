import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class StudyControllerBaseState extends Equatable {
  const StudyControllerBaseState({
    this.study = const AsyncValue.loading(),
  });

  /// The currently selected study that is being viewed or edited wrapped in
  /// a [AsyncValue] for loading & error states
  ///
  /// May be incomplete (for new studies / drafts)
  final AsyncValue<Study> study;

  StudyControllerBaseState copyWith({
    AsyncValue<Study> Function()? study,
  }) {
    return StudyControllerBaseState(
      study: study != null ? study() : this.study,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [study];
}

class StudyControllerState extends StudyControllerBaseState {
  const StudyControllerState({
    this.studyWithMetadata,
  });

  final WrappedModel<Study>? studyWithMetadata;

  @override
  AsyncValue<Study> get study {
    if (studyWithMetadata == null) {
      return const AsyncValue.loading();
    }
    return studyWithMetadata!.asyncValue;
  }

  bool get isDirty => studyWithMetadata?.isDirty ?? false;
  DateTime? get lastSynced => studyWithMetadata?.lastSaved;

  @override
  StudyControllerState copyWith({
    WrappedModel<Study>? Function()? studyWithMetadata,
    AsyncValue<Study> Function()? study,
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
  String get statusText => "Status: ${study.value!.status.string}".hardcoded;
}
