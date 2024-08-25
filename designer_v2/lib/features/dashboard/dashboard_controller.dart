import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController
    implements IModelActionProvider<StudyGroup> {
  @override
  DashboardState build() {
    studyRepository = ref.watch(studyRepositoryProvider);
    authRepository = ref.watch(authRepositoryProvider);
    userRepository = ref.watch(userRepositoryProvider);
    router = ref.watch(routerProvider);

    ref.onDispose(() {
      print("dashboardControllerProvider.DISPOSE");
      _studiesSubscription?.cancel();
    });

    ref.listenSelf((previous, next) {
      print("dashboardController.state updated");
    });

    _subscribeStudies();
    return DashboardState(currentUser: authRepository.currentUser!);
  }

  /// References to the data repositories injected by Riverpod
  late final IStudyRepository studyRepository;
  late final IAuthRepository authRepository;
  late final IUserRepository userRepository;

  /// Reference to services injected via Riverpod
  late final GoRouter router;

  /// A subscription for synchronizing state between the repository and the controller
  StreamSubscription<List<WrappedModel<Study>>>? _studiesSubscription;

  final SearchController searchController = SearchController();

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

    void setColumnFilter(String filter) {
    state = state.copyWith(
      columnFilter: () => filter,
    );
  }

  void setPinnedStudies(Set<String> pinnedStudies) {
    state = state.copyWith(pinnedStudies: pinnedStudies);
  }

  void setExpandedStudies(Set<String> expandedStudies) {
    state = state.copyWith(expandedStudies: expandedStudies);
  }

  void onSelectStudy(Study study) {
    router.dispatch(RoutingIntents.studyEdit(study.id));
  }

  void onClickNewStudy(bool isTemplate) {
    router.dispatch(RoutingIntents.studyNew(isTemplate));
  }

  void onExpandStudy(Study study) {
    final expandedStudies = state.expandedStudies.contains(study.id)
        ? state.expandedStudies.difference({study.id})
        : state.expandedStudies.union({study.id});
    setExpandedStudies(expandedStudies);
  }

  Future<void> pinStudy(String modelId) async {
    await userRepository.updatePreferences(PreferenceAction.pin, modelId);
    setPinnedStudies(userRepository.user.preferences.pinnedStudies);
  }

  Future<void> pinOffStudy(String modelId) async {
    await userRepository.updatePreferences(PreferenceAction.pinOff, modelId);
    setPinnedStudies(userRepository.user.preferences.pinnedStudies);
  }

  void setSorting(StudiesTableColumn sortByColumn, bool ascending) {
    state =
        state.copyWith(sortByColumn: sortByColumn, sortAscending: ascending);
  }

  void setCreateNewMenuOpen(bool open) {
    state = state.copyWith(createNewMenuOpen: open);
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
      ),
    ].where((action) => action.isAvailable).toList();

    return withIcons(
      [...pinActions, ...studyRepository.availableActions(study)],
      studyActionIcons,
    );
  }
}
