import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/domain/study.dart';
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

import 'dashboard_state.dart';

class DashboardController extends StateNotifier<DashboardState> implements IModelActionProvider<StudyGroup> {
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

  setSearchText(String? text) {
    searchController.setText(text ?? state.query);
  }

  setStudiesFilter(StudiesFilter? filter) {
    state = state.copyWith(studiesFilter: () => filter ?? DashboardState.defaultFilter);
  }

  onSelectStudy(Study study) {
    router.dispatch(RoutingIntents.studyEdit(study.id));
  }

  onClickNewStudy(bool isTemplate) {
    router.dispatch(RoutingIntents.studyNew(isTemplate));
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
    state = state.copyWith(sortByColumn: sortByColumn, sortAscending: ascending);
  }

  void setCreateNewMenuOpen(bool open) {
    state = state.copyWith(createNewMenuOpen: open);
  }

  void filterStudies(String? query) async {
    state = state.copyWith(
      query: query,
    );
  }

  void sortStudies() async {
    final studies = state.sort(pinnedStudies: userRepository.user.preferences.pinnedStudies);
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
  List<ModelAction> availableActions(StudyGroup model) {
    return _availableActions(model.standaloneOrTemplate);
  }

  List<ModelAction> availableSubActions(StudyGroup model, int index) {
    final subStudy = model.subStudies[index];
    return _availableActions(subStudy);
  }

  List<ModelAction> _availableActions(Study study) {
    final pinActions = [
      ModelAction(
        type: StudyActionType.pin,
        label: StudyActionType.pin.string,
        onExecute: () async {
          await pinStudy(study.id);
        },
        isAvailable: !study.isSubStudy && !isPinned(study),
      ),
      ModelAction(
        type: StudyActionType.pinoff,
        label: StudyActionType.pinoff.string,
        onExecute: () async {
          await pinOffStudy(study.id);
        },
        isAvailable: !study.isSubStudy && isPinned(study),
      )
    ].where((action) => action.isAvailable).toList();

    return withIcons(
      [...pinActions, ...studyRepository.availableActions(study)],
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
