import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/analyze/study_export_zip.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class StudyAnalyzeControllerState extends StudyControllerBaseState {
  const StudyAnalyzeControllerState({
    required super.currentUser,
    super.studyWithMetadata,
    super.parentTemplateWithMetadata,
  });

  bool get canExport => study.value?.canExport(currentUser!) ?? false;

  String get exportDisabledReason => study.value?.exportDisabledReason(currentUser!) ?? '';

  @override
  StudyAnalyzeControllerState copyWith(
      {WrappedModel<Study>? studyWithMetadata, WrappedModel<Study>? parentTemplateWithMetadata}) {
    return StudyAnalyzeControllerState(
      studyWithMetadata: studyWithMetadata ?? super.studyWithMetadata,
      parentTemplateWithMetadata: parentTemplateWithMetadata ?? super.parentTemplateWithMetadata,
      currentUser: currentUser,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [...super.props, canExport];
}
