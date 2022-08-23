import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

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

  ref.onDispose(() {
    print("studyTestControllerProvider.DISPOSE");
  });

  return StudyTestController(
    studyId: studyId,
    studyRepository: ref.watch(studyRepositoryProvider),
    router: ref.watch(routerProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

class TestArgs {
  final String studyId;
  final StudyFormRouteArgs? routeArgs;

  TestArgs(this.studyId, this.routeArgs);
}

final studyTestPlatformControllerProvider = Provider.autoDispose
    .family<PlatformController, TestArgs>((ref, testArgs) {
  final state = ref.watch(studyTestControllerProvider(testArgs.studyId));

  PlatformController platformController;
  if (!kIsWeb) {
    // Mobile could be built with the webview_flutter package
    platformController = MobileController(state.appUrl, testArgs.studyId);
  } else {
    // Desktop and Web
    platformController = WebController(state.appUrl, testArgs.studyId);
  }

  if (testArgs.routeArgs is InterventionFormRouteArgs ) {
    final extra = testArgs.routeArgs as InterventionFormRouteArgs;
    print("NAVIGATE TO INTERVENTION");
    platformController.navigatePage('intervention', extra: extra.interventionId);
  } else if (testArgs.routeArgs is MeasurementFormRouteArgs) {
    final extra = testArgs.routeArgs as MeasurementFormRouteArgs;
    print("NAVIGATE TO OBSERVATION");
    platformController.navigatePage('observation', extra: extra.measurementId);
  }

  ref.onDispose(() {
    print("studyTestPlatformControllerProvider.DISPOSE");
  });

  return platformController;
});
