import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudyControllerBaseState extends Equatable {
  const StudyControllerBaseState(
      {required this.currentUser, this.studyWithMetadata, this.parentTemplateWithMetadata});

  final User? currentUser;

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

  /// The parent template that is currently being viewed or edited, wrapped in a
  /// [WrappedModel] for additional metadata
  final WrappedModel<Study>? parentTemplateWithMetadata;

  /// The study that is currently being viewed or edited, wrapped in a
  /// a [AsyncValue] for loading & error states
  AsyncValue<Study> get parentTemplate {
    if (parentTemplateWithMetadata == null) {
      return const AsyncValue.loading();
    }
    return parentTemplateWithMetadata!.asyncValue;
  }

  bool get isDraft => study.value?.status == StudyStatus.draft;

  StudyControllerBaseState copyWith(
      {WrappedModel<Study>? studyWithMetadata, WrappedModel<Study>? parentTemplateWithMetadata}) {
    return StudyControllerBaseState(
      studyWithMetadata: studyWithMetadata ?? this.studyWithMetadata,
      parentTemplateWithMetadata: parentTemplateWithMetadata ?? this.parentTemplateWithMetadata,
      currentUser: currentUser,
    );
  }

  @override
  List<Object?> get props => [study];
}

extension StudyControllerBaseStateUnsafeProps on StudyControllerBaseState {
  StudyID get studyId => study.value!.id;
}
