import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
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
    implements IModelActionProvider<Study> {
  @override
  DashboardState build() {
    _studyRepository = ref.watch(studyRepositoryProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    _router = ref.watch(routerProvider);

    ref.onDispose(() {
      print("dashboardControllerProvider.DISPOSE");
      _studiesSubscription?.cancel();
    });

    listenSelf((previous, next) {
      print("dashboardController.state updated");
    });

    _subscribeStudies();
    _loadUserPreferences();

    return DashboardState(
      currentUser: _authRepository.currentUser!,
      searchController: SearchController(),
    );
  }

  /// References to the data repositories injected by Riverpod
  late final IStudyRepository _studyRepository;
  late final IAuthRepository _authRepository;
  late final IUserRepository _userRepository;

  /// Reference to services injected via Riverpod
  late final GoRouter _router;

  /// A subscription for synchronizing state between the repository and the controller
  StreamSubscription<List<WrappedModel<Study>>>? _studiesSubscription;

  Future<void> _loadUserPreferences() async {
    try {
      await _userRepository.fetchUser();

      final savedFilters = _userRepository.getCustomPresets();
      const defaultFilter = DashboardState.defaultFilter;
      final pageKey = _getPageKey(defaultFilter);
      final active = _userRepository.getActiveFilter(pageKey);

      state = state.copyWith(
        savedFilters: () => savedFilters,
        activeFilter: () => active.filterGroup,
        selectedSavedFilterId: () => active.presetId,
      );
    } catch (e) {
      print("Failed to load user preferences: $e");
    }
  }

  void _subscribeStudies() {
    _studiesSubscription = _studyRepository.watchAll().listen(
      (wrappedModels) {
        print("studyRepository.update");
        // Update the controller's state when new studies are available in the repository
        final studies = wrappedModels.map((study) => study.model).toList();
        state = state.copyWith(studies: () => AsyncValue.data(studies));
      },
      onError: (Object error) {
        state = state.copyWith(
          studies: () => AsyncValue.error(error, StackTrace.current),
        );
      },
    );
  }

  void setSearchText(String? text) {
    state.searchController.setText(text ?? state.query);
  }

  Future<void> setStudiesFilter(StudiesFilter? filter) async {
    await _userRepository.fetchUser();
    final newFilter = filter ?? DashboardState.defaultFilter;
    final pageKey = _getPageKey(newFilter);
    final active = _userRepository.getActiveFilter(pageKey);

    state = state.copyWith(
      studiesFilter: () => newFilter,
      activeFilter: () => active.filterGroup,
      selectedSavedFilterId: () => active.presetId,
    );
  }

  void updateFilter(FilterGroup filter, {String? presetId}) {
    state = state.copyWith(
      activeFilter: () => filter,
      selectedSavedFilterId: () => presetId,
    );
    // Persist change
    final pageKey = _getPageKey(state.studiesFilter);
    _userRepository.saveActiveFilter(
      page: pageKey,
      presetId: presetId,
      filterGroup: filter,
    );
  }

  Future<void> saveFilter(SavedFilter filter) async {
    await _userRepository.saveCustomPreset(filter);
    // Reload to reflect changes
    state = state.copyWith(
      savedFilters: () => _userRepository.getCustomPresets(),
    );
  }

  Future<void> deleteFilter(String id) async {
    await _userRepository.deleteCustomPreset(id);
    state = state.copyWith(
      savedFilters: () => _userRepository.getCustomPresets(),
    );
  }

  String _getPageKey(StudiesFilter? filter) {
    return switch (filter) {
      StudiesFilter.owned => 'my_studies',
      StudiesFilter.shared => 'shared_studies',
      StudiesFilter.public => 'public_studies',
      StudiesFilter.all => 'all_studies',
      null => 'my_studies', // Default
    };
  }

  void onSelectStudy(Study study) {
    _router.dispatch(RoutingIntents.studyEdit(study.id));
  }

  void onClickNewStudy() {
    final Study newStudy = _studyRepository.delegate.createNewInstance();
    newStudy.save();
    _router.dispatch(RoutingIntents.studyEdit(newStudy.id));
  }

  Future<void> pinStudy(String modelId) async {
    await _userRepository.updatePreferences(PreferenceAction.pin, modelId);
    sortStudies();
  }

  Future<void> pinOffStudy(String modelId) async {
    await _userRepository.updatePreferences(PreferenceAction.pinOff, modelId);
    sortStudies();
  }

  void setSorting(StudiesTableColumn sortByColumn, bool ascending) {
    state = state.copyWith(
      sortByColumn: sortByColumn,
      sortAscending: ascending,
    );
  }

  Future<void> filterStudies(String? query) async {
    state = state.copyWith(query: query);
  }

  Future<void> sortStudies() async {
    final studies = state.sort(
      pinnedStudies: _userRepository.user.preferences.pinnedStudies,
    );
    state = state.copyWith(studies: () => AsyncValue.data(studies));
  }

  bool isSortingActiveForColumn(StudiesTableColumn column) {
    return state.sortByColumn == column;
  }

  bool isSortAscending() {
    return state.sortAscending;
  }

  bool isPinned(Study study) {
    return _userRepository.user.preferences.pinnedStudies.contains(study.id);
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

    final studyActions = _studyRepository
        .availableActions(model)
        .where((action) => action.type != StudyActionType.exportDefinition)
        .toList();

    return withIcons([...pinActions, ...studyActions], studyActionIcons);
  }
}
