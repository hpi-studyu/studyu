import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class DashboardController extends StateNotifier<DashboardState>
    implements IModelActionProvider<Study> {
  /// References to the data repositories injected by Riverpod
  final IStudyRepository studyRepository;
  final IAuthRepository authRepository;
  final IUserRepository userRepository;

  /// Reference to services injected via Riverpod
  final GoRouter router;

  /// A subscription for synchronizing state between the repository and the controller
  StreamSubscription<List<WrappedModel<Study>>>? _studiesSubscription;

  final SearchController searchController = SearchController();

  DashboardController({
    required this.studyRepository,
    required this.authRepository,
    required this.userRepository,
    required this.router,
  }) : super(DashboardState(currentUser: authRepository.currentUser!)) {
    _subscribeStudies();
  }

  void _subscribeStudies() {
    _studiesSubscription = studyRepository.watchAll().listen(
      (wrappedModels) {
        print("studyRepository.update");
        // Update the controller's state when new studies are available in the repository
        final studies = wrappedModels.map((study) => study.model).toList();
        state = state.copyWith(
          studies: () => AsyncValue.data(studies),
        );
      },
      onError: (Object error) {
        state = state.copyWith(
          studies: () => AsyncValue.error(error, StackTrace.current),
        );
      },
    );
  }

  void setSearchText(String? text) {
    searchController.setText(text ?? state.query);
  }

  void setStudiesFilter(StudiesFilter? filter) {
    state = state.copyWith(
      studiesFilter: () => filter ?? DashboardState.defaultFilter,
    );
  }

  void onSelectStudy(Study study) {
    router.dispatch(RoutingIntents.studyEdit(study.id));
  }

  void onClickNewStudy() {
    router.dispatch(RoutingIntents.studyNew);
  }

  Future<void> pinStudy(String modelId) async {
    await userRepository.updatePreferences(PreferenceAction.pin, modelId);
    sortStudies();
  }

  Future<void> pinOffStudy(String modelId) async {
    await userRepository.updatePreferences(PreferenceAction.pinOff, modelId);
    sortStudies();
  }

  void setSorting(StudiesTableColumn sortByColumn, bool ascending) {
    state =
        state.copyWith(sortByColumn: sortByColumn, sortAscending: ascending);
  }

  Future<void> filterStudies(String? query) async {
    state = state.copyWith(
      query: query,
    );
  }

  Future<void> sortStudies() async {
    final studies = state.sort(
      pinnedStudies: userRepository.user.preferences.pinnedStudies,
    );
    state = state.copyWith(
      studies: () => AsyncValue.data(studies),
    );
  }

  bool isSortingActiveForColumn(StudiesTableColumn column) {
    return state.sortByColumn == column;
  }

  bool get isSortAscending => state.sortAscending;

  bool isPinned(Study study) {
    return userRepository.user.preferences.pinnedStudies.contains(study.id);
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
        isAvailable: !isPinned(model),
      ),
      ModelAction(
        type: StudyActionType.pinoff,
        label: StudyActionType.pinoff.string,
        onExecute: () async {
          await pinOffStudy(model.id);
        },
        isAvailable: isPinned(model),
      ),
    ].where((action) => action.isAvailable).toList();

    return withIcons(
      [...pinActions, ...studyRepository.availableActions(model)],
      studyActionIcons,
    );
  }

  @override
  void dispose() {
    _studiesSubscription?.cancel();
    super.dispose();
  }
}

final dashboardControllerProvider =
    StateNotifierProvider.autoDispose<DashboardController, DashboardState>(
        (ref) {
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
