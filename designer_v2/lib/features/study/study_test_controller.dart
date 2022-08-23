import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class StudyTestController extends StudyBaseController<StudyTestControllerState> {
  StudyTestController({
    required super.studyId,
    required super.studyRepository,
    required super.currentUser,
    required super.router,
    required this.authRepository,
  }) : super(StudyTestControllerState(currentUser: currentUser)) {
    state = state.copyWith(
      serializedSession: () => authRepository.session?.persistSessionString ?? ''
    );
  }

  final IAuthRepository authRepository;
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyTestControllerProvider = StateNotifierProvider
    .family<StudyTestController, StudyTestControllerState, StudyID>((ref, studyId) {
  final studyRepository = ref.watch(studyRepositoryProvider);
  final controller = StudyTestController(
    studyId: studyId,
    studyRepository: studyRepository,
    currentUser: ref.watch(currentUserProvider),
    router: ref.watch(routerProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
  ref.onDispose(() {
    // Reload the study after disposing the test controller so that any
    // data changes resulting from testing are reflected in the study for
    // other parts of the app (e.g. test data that was generated)
    //
    // Ideally, we would stream changes from the backend/database directly,
    // but this is a sufficient workaround for now
    studyRepository.fetch(studyId);
  });
  return controller;
});

class TestArgs {
  final String studyId;
  final StudyFormRouteArgs? routeArgs;

  TestArgs(this.studyId, this.routeArgs);
}

final studyTestPlatformControllerProvider = Provider
    .family<PlatformController?, TestArgs>((ref, testArgs) {
  final state = ref.watch(studyTestControllerProvider(testArgs.studyId));

  PlatformController platformController;
  if (!kIsWeb) {
    // Mobile could be built with the webview_flutter package
    throw Exception(
        "The StudyU designer only support the web platform".hardcoded);
  } else {
    // Desktop and Web
    platformController = WebController(state.appUrl, testArgs.studyId);
  }

  return platformController;
});
