import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

import 'dashboard_state.dart';

class DashboardController extends StateNotifier<DashboardState> implements IModelActionProvider<Study> {
  /// References to the data repositories injected by Riverpod
  final IStudyRepository studyRepository;
  final IAuthRepository authRepository;
  final IUserRepository userRepository;

  /// Reference to services injected via Riverpod
  final GoRouter router;

  /// A subscription for synchronizing state between the repository and the controller
  StreamSubscription<List<WrappedModel<Study>>>? _studiesSubscription;

  DashboardController({
    required this.studyRepository,
    required this.authRepository,
    required this.userRepository,
    required this.router,
  }) : super(DashboardState(currentUser: authRepository.currentUser!)) {
    _subscribeStudies();
  }

  _subscribeStudies() {
    _studiesSubscription = studyRepository.watchAll().listen((wrappedModels) {
      print("studyRepository.update");
      // Update the controller's state when new studies are available in the repository
      final studies = wrappedModels.map((study) => study.model).toList();
      state = state.copyWith(
        studies: () => AsyncValue.data(studies),
      );
    }, onError: (error) {
      state = state.copyWith(
        studies: () => AsyncValue.error(error, StackTrace.current),
      );
    });
  }

  setStudiesFilter(StudiesFilter? filter) {
    state = state.copyWith(studiesFilter: () => filter ?? DashboardState.defaultFilter);
  }

  onSelectStudy(Study study) {
    router.dispatch(RoutingIntents.studyEdit(study.id));
  }

  onClickNewStudy() {
    router.dispatch(RoutingIntents.studyNew);
  }

  String? search(String query) {
    if (query.isEmpty) {
      return null;
    } else {
      return query.toLowerCase();
    }
  }

  Future<void> pinStudy(String modelId) async {
    userRepository.user.preferences.pinnedStudies.add(modelId);
    await userRepository.saveUser();
    sortStudies();
  }

  Future<void> pinOffStudy(String modelId) async {
    userRepository.user.preferences.pinnedStudies.remove(modelId);
    await userRepository.saveUser();
    sortStudies();
  }

  void sortStudies() async {
    final studies = state.sort(pinnedStudies: userRepository.user.preferences.pinnedStudies);
    state = state.copyWith(
      studies: () => AsyncValue.data(studies),
    );
  }

  @override
  List<ModelAction> availableActions(Study model) {
    final pinActions = [
      ModelAction(
        type: StudyActionType.pin,
        label: StudyActionType.pin.string,
        onExecute: () async {
          await pinStudy(model.id);
        },
        isAvailable: userRepository.user.preferences.pinnedStudies.contains(model.id),
      ),
      ModelAction(
        type: StudyActionType.pinoff,
        label: StudyActionType.pinoff.string,
        onExecute: () async {
          await pinOffStudy(model.id);
        },
        isAvailable: userRepository.user.preferences.pinnedStudies.contains(model.id),
      )
    ];
    return withIcons(
      [...pinActions, ...studyRepository.availableActions(model)],
      studyActionIcons,
    );
  }

  @override
  dispose() {
    _studiesSubscription?.cancel();
    super.dispose();
  }
}

final dashboardControllerProvider = StateNotifierProvider.autoDispose<DashboardController, DashboardState>((ref) {
  final dashboardController = DashboardController(
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
    router: ref.watch(routerProvider),
  );
  dashboardController.addListener((state) {
    print("dashboardController.state updated");
  });
  ref.onDispose(() {
    print("dashboardControllerProvider.DISPOSE");
  });
  return dashboardController;
});
