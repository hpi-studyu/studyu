import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

enum InviteCodePaginationStatus { idle, loading, error }

class StudyRecruitControllerState extends StudyControllerBaseState {
  const StudyRecruitControllerState({
    required super.studyId,
    required super.studyRepository,
    required super.router,
    required super.currentUser,
    required super.studyWithMetadata,
    required this.inviteCodeRepository,
    this.invites = const AsyncValue.loading(),
    this.inviteCodePageIndex = 0,
    this.inviteCodePageSize = defaultInviteCodePageSize,
    this.inviteCodeSearchQuery = '',
    this.inviteCodeFilters = const InviteCodeFilters(),
    this.inviteCodeCount = 0,
    this.hasNextInviteCodePage = false,
    this.inviteCodeSortColumn = InviteCodesSortColumn.code,
    this.inviteCodeSortAscending = true,
    this.paginationStatus = InviteCodePaginationStatus.idle,
    this.pendingInviteCodePageIndex,
    this.paginationError,
  });

  /// The list of invite codes (if any) for the currently selected study
  ///
  /// Wrapped in an [AsyncValue] that mirrors the [StudyController]'s current
  /// [Study] async states, so that it can be used with [AsyncValueWidget]
  final AsyncValue<List<StudyInvite>?> invites;

  final InviteCodeRepository inviteCodeRepository;

  final int inviteCodePageIndex;

  final int inviteCodePageSize;

  final String inviteCodeSearchQuery;

  final InviteCodeFilters inviteCodeFilters;

  final int inviteCodeCount;

  final bool hasNextInviteCodePage;

  final InviteCodesSortColumn inviteCodeSortColumn;

  final bool inviteCodeSortAscending;

  final InviteCodePaginationStatus paginationStatus;

  final int? pendingInviteCodePageIndex;

  final Object? paginationError;

  bool get hasPreviousInviteCodePage => inviteCodePageIndex > 0;

  bool get hasComputedNextInviteCodePage =>
      inviteCodeCount > ((inviteCodePageIndex + 1) * inviteCodePageSize);

  bool get isPageTransitionLoading =>
      paginationStatus == InviteCodePaginationStatus.loading;

  bool get hasPaginationError =>
      paginationStatus == InviteCodePaginationStatus.error;

  int get inviteCodeTotalPages => inviteCodeCount == 0
      ? 1
      : ((inviteCodeCount - 1) ~/ inviteCodePageSize) + 1;

  int get inviteCodeFirstRowNumber => rangeStartForPage(inviteCodePageIndex);

  int get inviteCodeRangeStart => rangeStartForPage(inviteCodePageIndex);

  int get inviteCodeRangeEnd => rangeEndForPage(inviteCodePageIndex);

  int get pendingInviteCodeRangeStart =>
      rangeStartForPage(pendingInviteCodePageIndex ?? inviteCodePageIndex);

  int get pendingInviteCodeRangeEnd =>
      rangeEndForPage(pendingInviteCodePageIndex ?? inviteCodePageIndex);

  int rangeStartForPage(int pageIndex) {
    if (inviteCodeCount == 0) {
      return 0;
    }
    return (pageIndex * inviteCodePageSize) + 1;
  }

  int rangeEndForPage(int pageIndex) {
    if (inviteCodeCount == 0) {
      return 0;
    }
    final start = rangeStartForPage(pageIndex);
    return math.min(inviteCodeCount, start + inviteCodePageSize - 1);
  }

  @override
  StudyRecruitControllerState copyWith({
    WrappedModel<Study>? studyWithMetadata,
    AsyncValue<List<StudyInvite>?>? invites,
    int? inviteCodePageIndex,
    int? inviteCodePageSize,
    String? inviteCodeSearchQuery,
    InviteCodeFilters? inviteCodeFilters,
    int? inviteCodeCount,
    bool? hasNextInviteCodePage,
    InviteCodesSortColumn? inviteCodeSortColumn,
    bool? inviteCodeSortAscending,
    InviteCodePaginationStatus? paginationStatus,
    int? pendingInviteCodePageIndex,
    bool clearPendingInviteCodePageIndex = false,
    Object? paginationError,
    bool clearPaginationError = false,
  }) {
    return StudyRecruitControllerState(
      studyId: studyId,
      studyRepository: studyRepository,
      router: router,
      currentUser: currentUser,
      studyWithMetadata: studyWithMetadata ?? super.studyWithMetadata,
      inviteCodeRepository: inviteCodeRepository,
      invites: invites ?? this.invites,
      inviteCodePageIndex: inviteCodePageIndex ?? this.inviteCodePageIndex,
      inviteCodePageSize: inviteCodePageSize ?? this.inviteCodePageSize,
      inviteCodeSearchQuery:
          inviteCodeSearchQuery ?? this.inviteCodeSearchQuery,
      inviteCodeFilters: inviteCodeFilters ?? this.inviteCodeFilters,
      inviteCodeCount: inviteCodeCount ?? this.inviteCodeCount,
      hasNextInviteCodePage:
          hasNextInviteCodePage ?? this.hasNextInviteCodePage,
      inviteCodeSortColumn: inviteCodeSortColumn ?? this.inviteCodeSortColumn,
      inviteCodeSortAscending:
          inviteCodeSortAscending ?? this.inviteCodeSortAscending,
      paginationStatus: paginationStatus ?? this.paginationStatus,
      pendingInviteCodePageIndex: clearPendingInviteCodePageIndex
          ? null
          : (pendingInviteCodePageIndex ?? this.pendingInviteCodePageIndex),
      paginationError: clearPaginationError
          ? null
          : (paginationError ?? this.paginationError),
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [
    ...super.props,
    invites,
    inviteCodePageIndex,
    inviteCodePageSize,
    inviteCodeSearchQuery,
    inviteCodeFilters,
    inviteCodeCount,
    hasNextInviteCodePage,
    inviteCodeSortColumn,
    inviteCodeSortAscending,
    paginationStatus,
    pendingInviteCodePageIndex,
    paginationError,
  ];
}
