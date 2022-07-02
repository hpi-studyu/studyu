import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/legacy/designer/app_state.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';


class StudyController extends StateNotifier<StudyControllerState>
    implements LegacyAppStateDelegate {
  /// References to the data repositories injected by Riverpod
  final IStudyRepository studyRepository;
  final IAuthRepository authRepository;

  final GoRouter router;
  final INotificationService notificationService;

  /// Identifier of the study currently being edited / viewed
  /// Used to retrieve the [Study] object from the data layer
  final StudyID studyId;

  /// A subscription for synchronizing state between the repository & controller
  StreamSubscription<Study>? _studySubscription;

  StudyController({
    required this.studyId,
    required this.studyRepository,
    required this.authRepository,
    required this.router,
    required this.notificationService
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
        router.dispatch(RoutingIntents.error(error));
      } else {
        state = state.copyWith(
          study: () => AsyncValue.error(error),
        );
      }
    });
  }

  _updateCurrentStudy(Study study, {autoSave = false}) {
    state = state.copyWith(
      study: () => AsyncValue.data(study),
    );
    if (autoSave) {
      studyRepository.saveStudy(study);
    }
  }

  _initWithNewStudy() {
    final newDraft = Study.withId(authRepository.currentUser!.id);
    newDraft.title = "Unnamed study".hardcoded;
    newDraft.description = "Lorem ipsum".hardcoded;
    _updateCurrentStudy(newDraft, autoSave: true);
  }

  @override
  dispose() {
    _studySubscription?.cancel();
    super.dispose();
  }

  List<ModelAction<StudyActionType>> get studyActions {
    return [
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: "Add collaborator".hardcoded,
        onExecute: () {
          // TODO open modal to add collaborator
        },
      ),
      ModelAction(
        type: StudyActionType.export,
        label: "Export results".hardcoded,
        onExecute: () {
          // TODO trigger download of results
        },
      ),
      ModelAction(
        type: StudyActionType.delete,
        label: "Delete".hardcoded,
        onExecute: () {
          final study = state.study.value;
          if (study != null) {
            studyRepository.deleteStudy(study.id)
                .then((value) => router.dispatch(RoutingIntents.studies))
                .then((value) => Future.delayed(
                    const Duration(milliseconds: 200),
                    () => notificationService.show(Notifications.studyDeleted))
            );
          }
        },
        isAvailable: state.study.value?.published ?? false,
        isDestructive: true),
    ];
  }

  // - LegacyAppStateDelegate

  @override
  void onStudyUpdate(Study study) {
    print("APP STATE => CONTROLLER");
    _updateCurrentStudy(study, autoSave: true);
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyController, StudyControllerState, StudyID>((ref, studyId) =>
      StudyController(
        studyId: studyId,
        studyRepository: ref.watch(studyRepositoryProvider),
        authRepository: ref.watch(authRepositoryProvider),
        router: ref.watch(routerProvider),
        notificationService: ref.watch(notificationServiceProvider),
      )
);
