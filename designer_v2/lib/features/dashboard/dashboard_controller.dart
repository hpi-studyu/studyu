import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_navigation.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_to_postgrest.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
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
    _dispatch = ref.watch(dashboardDispatchProvider);

    ref.onDispose(() {
      _searchDebounce?.cancel();
    });

    _loadInitial();

    return DashboardState(
      currentUser: _authRepository.currentUser!,
      searchController: SearchController(),
    );
  }

  late final IStudyRepository _studyRepository;
  late final IAuthRepository _authRepository;
  late final IUserRepository _userRepository;
  late final DashboardDispatch _dispatch;

  Timer? _searchDebounce;
  static const _searchDebounceDuration = Duration(milliseconds: 300);

  /// Monotonic counter used to discard responses from stale fetches when the
  /// user changes filter/sort/search faster than the network responds.
  int _fetchToken = 0;

  Future<void> _loadInitial() async {
    await _loadUserPreferences();
    await _resetAndReload();
  }

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
      // ignore: avoid_print
      print("Failed to load user preferences: $e");
    }
  }

  Future<void> _resetAndReload() async {
    final token = ++_fetchToken;
    state = state.copyWith(
      loadedStudies: () => const [],
      pinnedStudiesList: () => const [],
      totalCount: 0,
      isLoadingInitial: true,
      isLoadingMore: false,
      isLoadingPinned: true,
      hasMore: true,
      loadError: () => null,
      advancedFilterUnsupported: false,
    );

    final pinnedFuture = _fetchPinnedFor(token);
    final pageFuture = _fetchPage(token, isInitial: true);
    await Future.wait([pinnedFuture, pageFuture]);
  }

  Future<void> _fetchPinnedFor(int token) async {
    final pinnedIds = _userRepository.user.preferences.pinnedStudies;
    if (pinnedIds.isEmpty) {
      if (token != _fetchToken) return;
      state = state.copyWith(
        pinnedStudiesList: () => const [],
        isLoadingPinned: false,
      );
      return;
    }
    try {
      final pinned = await _studyRepository.fetchPinned(pinnedIds.toSet());
      if (token != _fetchToken) return;
      state = state.copyWith(
        pinnedStudiesList: () => pinned,
        isLoadingPinned: false,
      );
    } catch (e) {
      if (token != _fetchToken) return;
      state = state.copyWith(isLoadingPinned: false);
    }
  }

  Future<void> _fetchPage(int token, {required bool isInitial}) async {
    try {
      final pinnedIds = _userRepository.user.preferences.pinnedStudies;
      final offset = isInitial ? 0 : state.loadedStudies.length;

      final page = await _studyRepository.fetchPage(
        offset: offset,
        limit: DashboardState.pageSize,
        sortBy: state.sortByColumn,
        ascending: state.sortAscending,
        preset: state.studiesFilter ?? DashboardState.defaultFilter,
        currentUser: state.currentUser,
        searchQuery: state.query,
        advancedFilter: state.activeFilter,
        excludeIds: pinnedIds.toList(),
      );

      if (token != _fetchToken) return;

      final updatedLoaded = isInitial
          ? page.studies
          : [...state.loadedStudies, ...page.studies];
      final hasMore = updatedLoaded.length < page.totalCount;

      state = state.copyWith(
        loadedStudies: () => updatedLoaded,
        totalCount: page.totalCount,
        isLoadingInitial: false,
        isLoadingMore: false,
        hasMore: hasMore,
        loadError: () => null,
        advancedFilterUnsupported: false,
      );
    } on UnsupportedFilterException catch (e) {
      if (token != _fetchToken) return;
      state = state.copyWith(
        loadedStudies: () => const [],
        totalCount: 0,
        isLoadingInitial: false,
        isLoadingMore: false,
        hasMore: false,
        loadError: () => e,
        advancedFilterUnsupported: true,
      );
    } catch (e) {
      if (token != _fetchToken) return;
      state = state.copyWith(
        isLoadingInitial: false,
        isLoadingMore: false,
        loadError: () => e,
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoadingInitial) return;
    state = state.copyWith(isLoadingMore: true);
    await _fetchPage(_fetchToken, isInitial: false);
  }

  Future<void> retry() async {
    await _resetAndReload();
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
    await _resetAndReload();
  }

  Future<void> updateFilter(FilterGroup filter, {String? presetId}) async {
    state = state.copyWith(
      activeFilter: () => filter,
      selectedSavedFilterId: () => presetId,
    );
    final pageKey = _getPageKey(state.studiesFilter);
    _userRepository.saveActiveFilter(
      page: pageKey,
      presetId: presetId,
      filterGroup: filter,
    );
    await _resetAndReload();
  }

  Future<void> saveFilter(SavedFilter filter) async {
    await _userRepository.saveCustomPreset(filter);
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
      null => 'my_studies',
    };
  }

  void onSelectStudy(Study study) {
    _dispatch(study.id);
  }

  void onClickNewStudy() {
    final Study newStudy = _studyRepository.delegate.createNewInstance();
    newStudy.save();
    _dispatch(newStudy.id);
  }

  Future<void> pinStudy(String modelId) async {
    await _userRepository.updatePreferences(PreferenceAction.pin, modelId);
    final fromLoaded = state.loadedStudies.firstWhere(
      (s) => s.id == modelId,
      orElse: () => state.pinnedStudiesList.firstWhere(
        (s) => s.id == modelId,
        orElse: () => Study('', ''),
      ),
    );
    if (fromLoaded.id.isEmpty) return;
    final newLoaded = state.loadedStudies
        .where((s) => s.id != modelId)
        .toList();
    final alreadyPinned = state.pinnedStudiesList.any((s) => s.id == modelId);
    final newPinned = alreadyPinned
        ? state.pinnedStudiesList
        : [...state.pinnedStudiesList, fromLoaded];
    state = state.copyWith(
      loadedStudies: () => newLoaded,
      pinnedStudiesList: () => newPinned,
    );
  }

  Future<void> pinOffStudy(String modelId) async {
    await _userRepository.updatePreferences(PreferenceAction.pinOff, modelId);
    final pinned = state.pinnedStudiesList.firstWhere(
      (s) => s.id == modelId,
      orElse: () => Study('', ''),
    );
    if (pinned.id.isEmpty) return;
    final newPinned = state.pinnedStudiesList
        .where((s) => s.id != modelId)
        .toList();
    final alreadyLoaded = state.loadedStudies.any((s) => s.id == modelId);
    final newLoaded = alreadyLoaded
        ? state.loadedStudies
        : [pinned, ...state.loadedStudies];
    state = state.copyWith(
      pinnedStudiesList: () => newPinned,
      loadedStudies: () => newLoaded,
    );
  }

  void setSorting(StudiesTableColumn sortByColumn, bool ascending) {
    state = state.copyWith(
      sortByColumn: sortByColumn,
      sortAscending: ascending,
    );
    unawaited(_resetAndReload());
  }

  Future<void> filterStudies(String? query) async {
    final newQuery = query ?? '';
    if (newQuery == state.query) return;
    state = state.copyWith(query: newQuery);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      unawaited(_resetAndReload());
    });
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
