import 'package:equatable/equatable.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  static const defaultFilter = StudiesFilter.owned;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.studies = const [],
    this.studiesFilter = defaultFilter,
    required this.currentUser,
  });

  final DashboardStatus status;

  /// The list of studies that can be accessed by the current user
  final List<Study> studies;

  /// Currently selected filter to be applied to the list of studies
  /// in order to determine the [visibleStudies]
  final StudiesFilter studiesFilter;

  /// Currently authenticated user (used for filtering studies)
  final User currentUser;

  /// The currently visible list of studies as by the selected filter
  List<Study> get visibleStudies =>
      studiesFilter.apply(studies: studies, user: currentUser).toList();

  DashboardState copyWith({
    DashboardStatus Function()? status,
    List<Study> Function()? studies,
    StudiesFilter Function() ? studiesFilter,
    User Function() ? currentUser,
  }) {
    return DashboardState(
      status: status != null ? status() : this.status,
      studies: studies != null ? studies() : this.studies,
      studiesFilter: studiesFilter != null ? studiesFilter() : this.studiesFilter,
      currentUser: currentUser != null ? currentUser() : this.currentUser,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [status, studies, studiesFilter];
}
