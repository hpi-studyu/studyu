import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';

class StudyTestController extends StudyBaseController<StudyTestControllerState> {
  StudyTestController({
    required super.studyId,
    required super.studyRepository,
    required super.router,
    required this.authRepository,
  }) : super(const StudyTestControllerState()) {
    state = state.copyWith(
      serializedSession: () => authRepository.session?.persistSessionString ?? ''
    );
  }

  final IAuthRepository authRepository;
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyTestControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyTestController, StudyTestControllerState, StudyID>((ref, studyId) {
  return StudyTestController(
    studyId: studyId,
    studyRepository: ref.watch(studyRepositoryProvider),
    router: ref.watch(routerProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

final studyTestPlatformControllerProvider = Provider.autoDispose
    .family<PlatformController?, StudyID>((ref, studyId) {
  final state = ref.watch(studyTestControllerProvider(studyId));

  PlatformController platformController;
  if (!kIsWeb) {
    // Mobile could be built with the webview_flutter package
    platformController = MobileController(state.appUrl, studyId);
  } else {
    // Desktop and Web
    platformController = WebController(state.appUrl, studyId);
  }

  return platformController;
});
