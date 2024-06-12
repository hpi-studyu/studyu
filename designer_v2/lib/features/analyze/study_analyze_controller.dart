import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/features/analyze/study_analyze_controller_state.dart';
import 'package:studyu_designer_v2/features/analyze/study_export_zip.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

class StudyAnalyzeController
    extends StudyBaseController<StudyAnalyzeControllerState> {
  StudyAnalyzeController({
    required super.studyId,
    required super.currentUser,
    required super.studyRepository,
    required super.router,
  }) : super(StudyAnalyzeControllerState(currentUser: currentUser)) {
    // Reload the study in case some data was generated meanwhile
    // studyRepository.fetch(studyId);
  }

  Future<void> onExport() {
    final study = state.study.value!;
    return runAsync(() => study.exportData.downloadAsZip());
  }
}

final studyAnalyzeControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyAnalyzeController, StudyAnalyzeControllerState, StudyID>(
        (ref, studyId) {
  return StudyAnalyzeController(
    studyId: studyId,
    currentUser: ref.watch(authRepositoryProvider).currentUser,
    studyRepository: ref.watch(studyRepositoryProvider),
    router: ref.watch(routerProvider),
  );
});
