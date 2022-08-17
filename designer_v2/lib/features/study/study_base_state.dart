import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class StudyControllerBaseState extends Equatable {
  const StudyControllerBaseState({
    this.studyWithMetadata,
  });

  /// The study that is currently being viewed or edited, wrapped in a
  /// [WrappedModel] for additional metadata
  final WrappedModel<Study>? studyWithMetadata;

  /// The study that is currently being viewed or edited, wrapped in a
  /// a [AsyncValue] for loading & error states
  AsyncValue<Study> get study {
    if (studyWithMetadata == null) {
      return const AsyncValue.loading();
    }
    return studyWithMetadata!.asyncValue;
  }

  bool get isDirty => studyWithMetadata?.isDirty ?? false;
  DateTime? get lastSynced => studyWithMetadata?.lastSaved;

  StudyControllerBaseState copyWith({
    WrappedModel<Study>? Function()? studyWithMetadata
  }) {
    return StudyControllerBaseState(
      studyWithMetadata: studyWithMetadata != null
          ? studyWithMetadata() : this.studyWithMetadata,
    );
  }

  @override
  List<Object?> get props => [study];
}

extension StudyControllerBaseStateUnsafeProps on StudyControllerBaseState {
  StudyID get studyId => study.value!.id;
}
