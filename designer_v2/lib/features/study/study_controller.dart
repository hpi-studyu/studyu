import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/legacy/designer/app_state.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';


class StudyController extends StateNotifier<StudyControllerState>
    implements LegacyAppStateDelegate {
  /// Identifier of the study currently being edited / viewed
  /// Used to retrieve the [Study] object from the data layer
  final StudyID studyId;

  /// A subscription for synchronizing state between the repository & controller
  StreamSubscription<Study>? _studySubscription;

  /// The [FormViewModel] that is responsible for displaying & editing the
  /// survey design form. Its lifecycle is bound to the study controller.
  ///
  /// Note:This is not safe to access before the [StudyControllerState.study]
  /// is available
  late final StudyFormViewModel studyFormViewModel = StudyFormViewModel(
      router: router,
      studyRepository: studyRepository,
      formData: state.study.value!
  );

  /// Reference to the study repository injected via Riverpod
  final IStudyRepository studyRepository;

  /// Reference to [GoRouter] injected via Riverpod
  final GoRouter router;

  StudyController({
    required this.studyId,
    required this.studyRepository,
    required this.router,
  }) : super(const StudyControllerState()) {
    print("StudyController.constructor");
    _subscribeStudy(studyId);
  }

  _subscribeStudy(StudyID studyId) {
    if (_studySubscription != null) {
      _studySubscription!.cancel();
    }
    _studySubscription = studyRepository.watchStudy(studyId).listen(
        _onStudyUpdate,
        onError: (error) {
      // TODO: figure out a way to resolve data dependencies for the current page
      // during app initialization so that we don't need to render the loading state
      // if the study doesn't exist
      if (error is StudyNotFoundException) {
        router.dispatch(RoutingIntents.error(error));
      } else {
        state = state.copyWith(
          study: () => AsyncValue.error(error),
        );
      }
    });
  }

  _onStudyUpdate(Study study, {autoSave = false}) async {
    state = state.copyWith(
      study: () => AsyncValue.data(study),
    );
    studyFormViewModel.formData = study;

    if (autoSave) {
      await studyRepository.saveStudy(study);
    }

    _redirectToActualStudyID(study.id);
  }

  /// Redirect to the study-specific URL to avoid disposing a dirty controller
  /// when building subroutes
  _redirectToActualStudyID(StudyID actualStudyId) {
    if (studyId == Config.newModelId) {
      router.dispatch(RoutingIntents.study(actualStudyId));
    }
  }

  @override
  dispose() {
    studyFormViewModel.dispose();
    _studySubscription?.cancel();
    super.dispose();
  }

  List<ModelAction<StudyActionType>> get studyActions {
    final study = state.study.value;
    if (study == null) {
      return [];
    }
    // filter out edit action since we are already editing the study
    return withIcons(
        studyRepository.availableActions(study).where(
                (action) => action.type != StudyActionType.edit).toList(),
        studyActionIcons
    );
  }

  // - LegacyAppStateDelegate

  @override
  void onStudyUpdate(Study study) {
    print("APP STATE => CONTROLLER");
    _onStudyUpdate(study, autoSave: true);
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyController, StudyControllerState, StudyID>((ref, studyId) {
      print("studyControllerProvider($studyId)");
      ref.onDispose(() {
        print("studyControllerProvider($studyId).DISPOSE");
      });
      return StudyController(
        studyId: studyId,
        studyRepository: ref.watch(studyRepositoryProvider),
        router: ref.watch(routerProvider),
      );
});
