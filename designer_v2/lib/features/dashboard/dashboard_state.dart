import 'package:equatable/equatable.dart';
import 'package:studyu_core/core.dart' as core;

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.studies = const [],
  });

  final DashboardStatus status;

  /// The list of studies that can be accessed by the current user
  final List<core.Study> studies;

  /// The list of studies owned by the current user
  /// TODO: filtering logic for owned studies
  List<core.Study> get userStudies => studies;

  /// The list of studies owned by the current user
  /// TODO: filtering logic for shared studies
  List<core.Study> get sharedStudies => studies;

  DashboardState copyWith({
    DashboardStatus Function()? status,
    List<core.Study> Function()? studies,
  }) {
    return DashboardState(
      status: status != null ? status() : this.status,
      studies: studies != null ? studies() : this.studies,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [
    status,
    studies
  ];
}