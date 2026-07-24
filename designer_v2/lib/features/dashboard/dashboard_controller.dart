import 'dart:async';
import 'dart:math';

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
    await _loadSavedFilters();
    // Note: page-specific active filter / sort and the first list fetch are
    // driven by setStudiesFilter(widget.filter) from DashboardScreen.initState.
    // We deliberately do NOT call _resetAndReload here, otherwise we would
    // race against that path and fire two redundant HTTP fetches per nav.
  }

  /// Loads only page-agnostic UI metadata: the user record (so getActiveFilter
  /// has data to read later) and the saved-preset list (which is shared across
  /// all dashboard page-keys). Per-page active filter + sort restoration lives
  /// in [setStudiesFilter] so it always matches the route the widget mounted.
  Future<void> _loadSavedFilters() async {
    try {
      await _userRepository.fetchUser();
      final savedFilters = _userRepository.getCustomPresets();
      state = state.copyWith(savedFilters: () => savedFilters);
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
      pageTotalCount: 0,
      isLoadingInitial: true,
      isLoadingMore: false,
      isLoadingPinned: true,
      hasMore: true,
      loadError: () => null,
      advancedFilterUnsupported: false,
    );

    final pinnedFuture = _fetchPinnedFor(token);
    final pageFuture = _fetchPage(token, isInitial: true);
    final pageTotalFuture = _fetchPageTotalCount(token);
    await Future.wait([pinnedFuture, pageFuture, pageTotalFuture]);
    if (token != _fetchToken) return;
    state = state.copyWith(isLoadingInitial: false);
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
    await _fetchPageWithLimit(token, isInitial: isInitial);
  }

  Future<void> _fetchPageWithLimit(
    int token, {
    required bool isInitial,
    int? limit,
  }) async {
    try {
      final pinnedIds = _userRepository.user.preferences.pinnedStudies;
      final offset = isInitial ? 0 : state.loadedStudies.length;
      final fetchLimit = limit ?? DashboardState.pageSize;

      final page = await _studyRepository.fetchPage(
        offset: offset,
        limit: fetchLimit,
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
        isLoadingMore: false,
        hasMore: false,
        loadError: () => e,
        advancedFilterUnsupported: true,
      );
    } catch (e) {
      if (token != _fetchToken) return;
      state = state.copyWith(
        isLoadingMore: false,
        hasMore: false,
        loadError: () => e,
      );
    }
  }

  Future<void> _refreshAfterMutation({int? targetLoadedStudyCount}) async {
    final token = ++_fetchToken;
    final refreshLimit = max(
      targetLoadedStudyCount ?? state.loadedStudies.length,
      DashboardState.pageSize,
    );

    state = state.copyWith(
      isLoadingMore: false,
      isLoadingPinned: true,
      loadError: () => null,
      advancedFilterUnsupported: false,
    );

    final pinnedFuture = _fetchPinnedFor(token);
    final pageFuture = _fetchPageWithLimit(
      token,
      isInitial: true,
      limit: refreshLimit,
    );
    final pageTotalFuture = _fetchPageTotalCount(token);
    await Future.wait([pinnedFuture, pageFuture, pageTotalFuture]);
    if (token != _fetchToken) return;
    state = state.copyWith(
      isLoadingInitial: false,
      isLoadingMore: false,
      isLoadingPinned: false,
    );
  }

  void _removeStudyLocally(String studyId) {
    final updatedPinnedStudies = [
      for (final study in state.pinnedStudiesList)
        if (study.id != studyId) study,
    ];
    final updatedLoadedStudies = [
      for (final study in state.loadedStudies)
        if (study.id != studyId) study,
    ];

    final removedPinnedCount =
        state.pinnedStudiesList.length - updatedPinnedStudies.length;
    final removedLoadedCount =
        state.loadedStudies.length - updatedLoadedStudies.length;
    final removedCount = removedPinnedCount + removedLoadedCount;

    if (removedCount == 0) return;

    final updatedTotalCount = max(state.totalCount - removedCount, 0);
    final updatedPageTotalCount = max(state.pageTotalCount - removedCount, 0);

    state = state.copyWith(
      pinnedStudiesList: () => updatedPinnedStudies,
      loadedStudies: () => updatedLoadedStudies,
      totalCount: updatedTotalCount,
      pageTotalCount: updatedPageTotalCount,
      hasMore: updatedLoadedStudies.length < updatedTotalCount,
      loadError: () => null,
    );
  }

  Future<void> _fetchPageTotalCount(int token) async {
    try {
      final pinnedIds = _userRepository.user.preferences.pinnedStudies;
      final page = await _studyRepository.fetchPage(
        offset: 0,
        limit: 1,
        sortBy: state.sortByColumn,
        ascending: state.sortAscending,
        preset: state.studiesFilter ?? DashboardState.defaultFilter,
        currentUser: state.currentUser,
        excludeIds: pinnedIds.toList(),
      );

      if (token != _fetchToken) return;

      state = state.copyWith(pageTotalCount: page.totalCount);
    } catch (_) {
      if (token != _fetchToken) return;
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
    final activeSort = _resolveActiveSort(pageKey);

    state = state.copyWith(
      studiesFilter: () => newFilter,
      activeFilter: () => active.filterGroup,
      selectedSavedFilterId: () => active.presetId,
      sortByColumn: activeSort.sortByColumn,
      sortAscending: activeSort.sortAscending,
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
    final wasUnpinned = !_userRepository.user.preferences.pinnedStudies
        .contains(modelId);
    final wasLoading =
        state.isLoadingInitial || state.isLoadingMore || state.isLoadingPinned;
    final wasLoaded = state.loadedStudies.any((study) => study.id == modelId);
    await _userRepository.updatePreferences(PreferenceAction.pin, modelId);

    final studyIndex = state.loadedStudies.indexWhere(
      (study) => study.id == modelId,
    );
    final canUpdateLocally =
        wasUnpinned &&
        wasLoaded &&
        !wasLoading &&
        !state.isLoadingInitial &&
        !state.isLoadingMore &&
        !state.isLoadingPinned &&
        studyIndex != -1;
    if (!canUpdateLocally) {
      await _resetAndReload();
      return;
    }

    final updatedLoaded = [...state.loadedStudies]..removeAt(studyIndex);
    final updatedTotalCount = state.totalCount > 0 ? state.totalCount - 1 : 0;
    final updatedPageTotalCount = state.pageTotalCount > 0
        ? state.pageTotalCount - 1
        : 0;
    state = state.copyWith(
      loadedStudies: () => updatedLoaded,
      pinnedStudiesList: () => [
        ...state.pinnedStudiesList,
        state.loadedStudies[studyIndex],
      ],
      totalCount: updatedTotalCount,
      pageTotalCount: updatedPageTotalCount,
      hasMore: updatedLoaded.length < updatedTotalCount,
    );
  }

  Future<void> pinOffStudy(String modelId) async {
    await _userRepository.updatePreferences(PreferenceAction.pinOff, modelId);
    await _resetAndReload();
  }

  void setSorting(StudiesTableColumn sortByColumn, bool ascending) {
    state = state.copyWith(
      sortByColumn: sortByColumn,
      sortAscending: ascending,
    );
    final pageKey = _getPageKey(state.studiesFilter);
    // Fire-and-forget: persistence failure should not block UI updates.
    unawaited(
      _userRepository.saveActiveSort(
        page: pageKey,
        sortColumn: sortByColumn.name,
        sortAscending: ascending,
      ),
    );
    unawaited(_resetAndReload());
  }

  /// Resolves the persisted sort for [pageKey] back to typed values, falling
  /// back to [DashboardState] defaults when nothing is stored or when the
  /// stored column name no longer maps to a known [StudiesTableColumn] (e.g.
  /// after an enum rename). When the column falls back, the direction falls
  /// back too — a stored direction is meaningless without its column.
  ({StudiesTableColumn sortByColumn, bool sortAscending}) _resolveActiveSort(
    String pageKey,
  ) {
    const defaultColumn = StudiesTableColumn.createdAt;
    const defaultAscending = false;
    final stored = _userRepository.getActiveSort(pageKey);
    final column = StudiesTableColumn.values.asNameMap()[stored.sortColumn];
    if (column == null) {
      return (sortByColumn: defaultColumn, sortAscending: defaultAscending);
    }
    return (
      sortByColumn: column,
      sortAscending: stored.sortAscending ?? defaultAscending,
    );
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

    final repoActions = _studyRepository
        .availableActions(model)
        .where((action) => action.type != StudyActionType.exportDefinition)
        .toList();

    // Wrap mutating actions so the paginated state refreshes after success
    // and delete errors are surfaced instead of silently swallowed.
    final studyActions = repoActions.map((action) {
      final type = action.type as StudyActionType?;
      if (type == StudyActionType.delete) {
        return ModelAction(
          type: action.type,
          label: action.label,
          icon: action.icon,
          tooltip: action.tooltip,
          confirmation: action.confirmation,
          isAvailable: action.isAvailable,
          isDestructive: action.isDestructive,
          isSeparator: action.isSeparator,
          isHeader: action.isHeader,
          isChecked: action.isChecked,
          showBadge: action.showBadge,
          onExecute: () async {
            final loadedStudyCountBeforeDelete = state.loadedStudies.length;
            try {
              await action.onExecute();
              _removeStudyLocally(model.id);
              await _refreshAfterMutation(
                targetLoadedStudyCount: loadedStudyCountBeforeDelete,
              );
            } catch (e) {
              state = state.copyWith(loadError: () => e);
            }
          },
        );
      }
      if (type == StudyActionType.duplicate ||
          type == StudyActionType.duplicateDraft ||
          type == StudyActionType.close) {
        return ModelAction(
          type: action.type,
          label: action.label,
          icon: action.icon,
          tooltip: action.tooltip,
          confirmation: action.confirmation,
          isAvailable: action.isAvailable,
          isDestructive: action.isDestructive,
          isSeparator: action.isSeparator,
          isHeader: action.isHeader,
          isChecked: action.isChecked,
          showBadge: action.showBadge,
          onExecute: () async {
            final loadedStudyCountBeforeRefresh = state.loadedStudies.length;
            await action.onExecute();
            await _refreshAfterMutation(
              targetLoadedStudyCount: loadedStudyCountBeforeRefresh,
            );
          },
        );
      }
      return action;
    }).toList();

    return withIcons([...pinActions, ...studyActions], studyActionIcons);
  }
}
