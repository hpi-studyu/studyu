import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardState extends Equatable {
  static const defaultFilter = StudiesFilter.owned;
  static const pageSize = 25;

  const DashboardState({
    this.loadedStudies = const [],
    this.pinnedStudiesList = const [],
    this.totalCount = 0,
    this.isLoadingInitial = true,
    this.isLoadingMore = false,
    this.isLoadingPinned = false,
    this.hasMore = true,
    this.loadError,
    this.studiesFilter = defaultFilter,
    this.activeFilter,
    this.advancedFilterUnsupported = false,
    this.query = '',
    this.sortByColumn = StudiesTableColumn.createdAt,
    this.sortAscending = false,
    this.savedFilters = const [],
    this.selectedSavedFilterId,
    required this.currentUser,
    required this.searchController,
  });

  /// Paginated studies fetched so far (excludes pinned, which render above).
  final List<Study> loadedStudies;

  /// Pinned studies fetched separately, always shown above the paginated list.
  final List<Study> pinnedStudiesList;

  /// Total number of studies that match the current query (from PostgREST
  /// exact count). Used to know when [hasMore] should flip to false.
  final int totalCount;

  /// True while the first page (and pinned set) is loading.
  final bool isLoadingInitial;

  /// True while a "load more" page is in flight.
  final bool isLoadingMore;

  /// True while pinned studies are being refreshed.
  final bool isLoadingPinned;

  /// Whether more pages remain on the server.
  final bool hasMore;

  /// Last error from a fetch attempt, or null.
  final Object? loadError;

  /// True if the current [activeFilter] contains a condition that cannot be
  /// expressed in PostgREST (e.g. [StudyProperty.missedDays]). When true the
  /// list is empty and the UI should show a "filter not supported" message
  /// rather than silently dropping rows.
  final bool advancedFilterUnsupported;

  /// Currently selected filter preset (e.g. Owned, Shared, Public)
  /// Used for UI highlighting. If null, a custom filter is active.
  final StudiesFilter? studiesFilter;

  /// The ID of the currently selected saved filter preset
  final String? selectedSavedFilterId;

  /// The actual filter logic to be applied.
  /// If null, it falls back to the [studiesFilter] logic.
  final FilterGroup? activeFilter;

  /// List of saved custom filters
  final List<SavedFilter> savedFilters;

  /// Currently selected sort column applied server-side.
  final StudiesTableColumn sortByColumn;

  /// Currently selected sort direction applied server-side.
  final bool sortAscending;

  /// Currently authenticated user (used for filtering studies)
  final User currentUser;

  final String query;

  /// Search controller for managing search functionality
  final SearchController searchController;

  /// Studies actually rendered: pinned first, then the paginated list.
  /// Wrapped in [AsyncValue] for backwards-compatible UI scaffolding that
  /// expects a loading/error/data tri-state for the initial fetch.
  AsyncValue<List<Study>> get displayedStudies {
    if (loadError != null && loadedStudies.isEmpty && pinnedStudiesList.isEmpty) {
      return AsyncValue.error(loadError!, StackTrace.current);
    }
    if (isLoadingInitial && loadedStudies.isEmpty && pinnedStudiesList.isEmpty) {
      return const AsyncValue.loading();
    }
    return AsyncValue.data([...pinnedStudiesList, ...loadedStudies]);
  }

  DashboardState copyWith({
    List<Study> Function()? loadedStudies,
    List<Study> Function()? pinnedStudiesList,
    int? totalCount,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? isLoadingPinned,
    bool? hasMore,
    Object? Function()? loadError,
    bool? advancedFilterUnsupported,
    StudiesFilter? Function()? studiesFilter,
    FilterGroup? Function()? activeFilter,
    List<SavedFilter> Function()? savedFilters,
    User Function()? currentUser,
    String? query,
    StudiesTableColumn? sortByColumn,
    bool? sortAscending,
    SearchController? searchController,
    String? Function()? selectedSavedFilterId,
  }) {
    return DashboardState(
      loadedStudies: loadedStudies != null
          ? loadedStudies()
          : this.loadedStudies,
      pinnedStudiesList: pinnedStudiesList != null
          ? pinnedStudiesList()
          : this.pinnedStudiesList,
      totalCount: totalCount ?? this.totalCount,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingPinned: isLoadingPinned ?? this.isLoadingPinned,
      hasMore: hasMore ?? this.hasMore,
      loadError: loadError != null ? loadError() : this.loadError,
      advancedFilterUnsupported:
          advancedFilterUnsupported ?? this.advancedFilterUnsupported,
      studiesFilter: studiesFilter != null
          ? studiesFilter()
          : this.studiesFilter,
      activeFilter: activeFilter != null ? activeFilter() : this.activeFilter,
      savedFilters: savedFilters != null ? savedFilters() : this.savedFilters,
      currentUser: currentUser != null ? currentUser() : this.currentUser,
      query: query ?? this.query,
      sortByColumn: sortByColumn ?? this.sortByColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      searchController: searchController ?? this.searchController,
      selectedSavedFilterId: selectedSavedFilterId != null
          ? selectedSavedFilterId()
          : this.selectedSavedFilterId,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [
    loadedStudies,
    pinnedStudiesList,
    totalCount,
    isLoadingInitial,
    isLoadingMore,
    isLoadingPinned,
    hasMore,
    loadError,
    advancedFilterUnsupported,
    studiesFilter,
    activeFilter,
    savedFilters,
    query,
    sortByColumn,
    sortAscending,
    selectedSavedFilterId,
  ];
}

extension DashboardStateSafeViewProps on DashboardState {
  String get visibleListTitle {
    switch (studiesFilter) {
      case StudiesFilter.public:
        return tr.navlink_public_studies;
      case StudiesFilter.owned:
        return tr.navlink_my_studies;
      case StudiesFilter.shared:
        return tr.navlink_shared_studies;
      case StudiesFilter.all:
        return "All Studies".hardcoded;
      case null:
        return tr.navlink_my_studies;
    }
  }
}
