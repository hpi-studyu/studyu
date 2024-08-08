import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/features/analyze/study_analyze_controller_state.dart';
import 'package:studyu_designer_v2/features/analyze/study_export_zip.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

part 'study_analyze_controller.g.dart';

@riverpod
class StudyAnalyzeController extends _$StudyAnalyzeController {
  @override
  StudyAnalyzeControllerState build(StudyCreationArgs studyCreationArgs) {
    return StudyAnalyzeControllerState(
      studyId: studyCreationArgs.studyID,
      studyRepository: ref.watch(studyRepositoryProvider),
      studyWithMetadata: ref
          .watch(studyBaseControllerProvider(studyCreationArgs))
          .studyWithMetadata,
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser,
    );
    // Reload the study in case some data was generated meanwhile
    // studyRepository.fetch(studyId);
  }

  Future<void> onExport() {
    final study = state.study.value!;
    return runAsync(() => study.exportData.downloadAsZip());
  }
}
