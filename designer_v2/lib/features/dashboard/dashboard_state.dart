import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardState extends Equatable {
  static const defaultFilter = StudiesFilter.owned;

  const DashboardState({
    this.studies = const AsyncValue.loading(),
    this.studiesFilter = defaultFilter,
    this.query = '',
    this.sortByColumn = StudiesTableColumn.title,
    this.sortAscending = true,
    this.createNewMenuOpen = false,
    this.pinnedStudies = const {},
    this.expandedStudies = const {},
    required this.currentUser,
  });

  /// The list of studies that can be accessed by the current user
  /// Wrapped in an [AsyncValue] to represent loading / error states
  final AsyncValue<List<Study>> studies;

  /// Currently selected filter to be applied to the list of studies
  /// in order to determine the [displayedStudies]
  final StudiesFilter studiesFilter;

  /// Currently selected sort column to be applied to the list of studies
  /// in order to determine the [displayedStudies]
  final StudiesTableColumn sortByColumn;

  /// Currently selected sort direction to be applied to the list of studies
  /// in order to determine the [displayedStudies]
  final bool sortAscending;

  /// Currently authenticated user (used for filtering studies)
  final User currentUser;

  final String query;

  final bool createNewMenuOpen;

  final Set<String> pinnedStudies;

  final Set<String> expandedStudies;

  /// The currently displayed list of studies as by the selected filter,
  /// selected sort column, and selected sort direction
  ///
  /// Wrapped in an [AsyncValue] that mirrors the [studies]' async states,
  /// but resolves to a different subset of studies based on the [studiesFilter]
  AsyncValue<List<StudyGroup>> displayedStudies({Set<String>? pinnedStudies}) {
    final localPinnedStudies = pinnedStudies ?? this.pinnedStudies;
    return studies.when(
      data: (studies) {
        List<Study> updatedStudies = studiesFilter.apply(studies: studies, user: currentUser).toList();
        updatedStudies = filter(studiesToFilter: updatedStudies);
        updatedStudies = sort(pinnedStudies: localPinnedStudies, studiesToSort: updatedStudies);
        return AsyncValue.data(group(updatedStudies));
      },
      error: (error, _) => AsyncValue.error(error, StackTrace.current),
      loading: () => const AsyncValue.loading(),
    );
  }

  List<StudyGroup> group(List<Study> studies) {
    List<StudyGroup> result = [];

    for (final study in studies) {
      switch (study.type) {
        case StudyType.standalone:
          result.add(StudyGroup.standalone(study));
          break;
        case StudyType.template:
          final List<Study> subStudies = studies.where((s) => s.parentTemplateId == study.id).toList();
          result.add(StudyGroup.template(study as Template, subStudies));
        case StudyType.subStudy:
          break;
      }
    }

    return result;
  }

  List<Study> filter({List<Study>? studiesToFilter}) {
    studiesToFilter = studiesToFilter ?? studies.value!;
    if (query.isEmpty) return studiesToFilter;

    final filteredStudies = studiesToFilter.where((s) => s.title!.toLowerCase().contains(query)).toList();
    // Add removed parent templates again
    for (final study in filteredStudies) {
      if (study.isSubStudy && !filteredStudies.any((s) => s.isTemplate && s.id == study.parentTemplateId)) {
        final parentTemplate = studiesToFilter.firstWhere((s) => s.isTemplate && s.id == study.parentTemplateId);
        filteredStudies.add(parentTemplate);
      }
    }

    return filteredStudies;
  }

  List<Study> sort({required Set<String> pinnedStudies, List<Study>? studiesToSort}) {
    final sortedStudies = studiesToSort ?? studies.value!;
    switch (sortByColumn) {
      case StudiesTableColumn.title:
        if (sortAscending) {
          sortedStudies.sort((study, other) => study.title!.compareTo(other.title!));
        } else {
          sortedStudies.sort((study, other) => other.title!.compareTo(study.title!));
        }
        break;
      case StudiesTableColumn.type:
        if (sortAscending) {
          sortedStudies.sort((study, other) => study.type.index.compareTo(other.type.index));
        } else {
          sortedStudies.sort((study, other) => other.type.index.compareTo(study.type.index));
        }
        break;
      case StudiesTableColumn.status:
        if (sortAscending) {
          sortedStudies.sort((study, other) => study.status.index.compareTo(other.status.index));
        } else {
          sortedStudies.sort((study, other) => other.status.index.compareTo(study.status.index));
        }
        break;
      case StudiesTableColumn.participation:
        if (sortAscending) {
          sortedStudies.sort((study, other) => study.participation.index.compareTo(other.participation.index));
        } else {
          sortedStudies.sort((study, other) => other.participation.index.compareTo(study.participation.index));
        }
        break;
      case StudiesTableColumn.createdAt:
        if (sortAscending) {
          sortedStudies.sort((study, other) => study.createdAt!.compareTo(other.createdAt!));
        } else {
          sortedStudies.sort((study, other) => other.createdAt!.compareTo(study.createdAt!));
        }
        break;
      case StudiesTableColumn.enrolled:
        if (sortAscending) {
          sortedStudies.sort((study, other) => study.participantCount.compareTo(other.participantCount));
        } else {
          sortedStudies.sort((study, other) => other.participantCount.compareTo(study.participantCount));
        }
        break;
      case StudiesTableColumn.active:
        if (sortAscending) {
          sortedStudies.sort((study, other) => study.activeSubjectCount.compareTo(other.activeSubjectCount));
        } else {
          sortedStudies.sort((study, other) => other.activeSubjectCount.compareTo(study.activeSubjectCount));
        }
        break;
      case StudiesTableColumn.completed:
        if (sortAscending) {
          sortedStudies.sort((study, other) => study.endedCount.compareTo(other.endedCount));
        } else {
          sortedStudies.sort((study, other) => other.endedCount.compareTo(study.endedCount));
        }
        break;
      case StudiesTableColumn.expand:
      case StudiesTableColumn.action:
        break;
    }

    if (pinnedStudies.isNotEmpty) {
      // Extract pinned studies and remove them from filteredStudies
      final List<Study> pinned = [];
      sortedStudies.removeWhere((study) {
        if (pinnedStudies.contains(study.id)) {
          pinned.add(study);
          return true;
        }
        return false;
      });

      // Insert pinned studies at the beginning of the filteredStudies list
      sortedStudies.insertAll(0, pinned);
    }
    return sortedStudies;
  }

  DashboardState copyWith({
    AsyncValue<List<Study>> Function()? studies,
    StudiesFilter Function()? studiesFilter,
    User Function()? currentUser,
    String? query,
    StudiesTableColumn? sortByColumn,
    bool? sortAscending,
    bool? createNewMenuOpen,
    Set<String>? pinnedStudies,
    Set<String>? expandedStudies,
  }) {
    return DashboardState(
        studies: studies != null ? studies() : this.studies,
        studiesFilter: studiesFilter != null ? studiesFilter() : this.studiesFilter,
        currentUser: currentUser != null ? currentUser() : this.currentUser,
        query: query ?? this.query,
        sortByColumn: sortByColumn ?? this.sortByColumn,
        sortAscending: sortAscending ?? this.sortAscending,
        createNewMenuOpen: createNewMenuOpen ?? this.createNewMenuOpen,
        pinnedStudies: pinnedStudies ?? this.pinnedStudies,
        expandedStudies: expandedStudies ?? this.expandedStudies);
  }

  // - Equatable

  @override
  List<Object?> get props => [studies, studiesFilter];
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
        return "[StudiesFilter.all]"; // not available in UI
    }
  }
}
