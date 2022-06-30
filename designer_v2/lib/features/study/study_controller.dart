import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/navigation_service.dart';


class StudyController extends StateNotifier<StudyControllerState> {
  /// References to the data repositories injected by Riverpod
  final IStudyRepository studyRepository;
  final IAuthRepository authRepository;

  final INavigationService navigationService;

  /// Identifier of the study currently being edited / viewed
  /// Used to retrieve the [Study] object from the data layer
  final StudyID studyId;

  /// A subscription for synchronizing state between the repository & controller
  StreamSubscription<Study>? _studySubscription;

  StudyController({
    required this.studyId,
    required this.studyRepository,
    required this.authRepository,
    required this.navigationService
  })
      : super(const StudyControllerState()) {
    if (studyId != Config.newStudyId) {
      _subscribeStudy(studyId);
    } else {
      _initWithNewStudy();
    }
  }

  _subscribeStudy(StudyID studyId) {
    _studySubscription = studyRepository.watchStudy(studyId).listen((study) {
      // Update the controller's state when new studies are available in the repository
      state = state.copyWith(
        study: () => AsyncValue.data(study),
      );
    }, onError: (error) {
      // TODO: figure out a way to resolve data dependencies for the current page
      // during app initialization so that we don't need to render the loading state
      // if the study doesn't exist
      if (error is StudyNotFoundException) {
        navigationService.goToErrorPage(error);
      } else {
        state = state.copyWith(
          study: () => AsyncValue.error(error),
        );
      }
    });
  }

  _initWithNewStudy() {
    final newDraft = Study.withId(authRepository.currentUser!.id);
    state = state.copyWith(
        study: () => AsyncValue.data(newDraft)
    );
  }

  @override
  dispose() {
    _studySubscription?.cancel();
    super.dispose();
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyController, StudyControllerState, StudyID>((ref, studyId) =>
      StudyController(
        studyId: studyId,
        studyRepository: ref.watch(studyRepositoryProvider),
        authRepository: ref.watch(authRepositoryProvider),
        navigationService: ref.watch(navigationServiceProvider)
      )
);
