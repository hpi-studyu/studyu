import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

import '../../localization/locale_providers.dart';
import '../../repositories/study_repository.dart';
import '../../routing/router.dart';

part 'study_test_controller.g.dart';

@riverpod
class StudyTestController extends _$StudyTestController {
  @override
  StudyTestControllerState build(StudyID studyId) {
    ref.onDispose(() {
      // Reload the study after disposing the test controller so that any
      // data changes resulting from testing are reflected in the study for
      // other parts of the app (e.g. test data that was generated)
      //
      // Ideally, we would stream changes from the backend/database directly,
      // but this is a sufficient workaround for now
      ref.watch(studyRepositoryProvider).fetch(studyId);
    });
    return StudyTestControllerState(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser,
      serializedSession: ref.watch(authRepositoryProvider).serializedSession ?? '',
      languageCode: ref.watch(localeProvider).languageCode,
    );
  }
}

/// Provide a controller parametrized by [StudyID]

@riverpod
PlatformController studyTestPlatformController(StudyTestPlatformControllerRef ref, StudyID studyId) {
  final state = ref.watch(studyTestControllerProvider(studyId));
  PlatformController platformController;
  if (!kIsWeb) {
    // Mobile could be built with the webview_flutter package
    throw Exception("The StudyU designer only support the web platform".hardcoded);
  } else {
    // Desktop and Web
    platformController = WebController(state.appUrl, studyId);
  }
  return platformController;
}