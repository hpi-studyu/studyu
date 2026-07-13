import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

part 'study_recruit_controller.g.dart';

@riverpod
class StudyRecruitController extends _$StudyRecruitController
    implements IModelActionProvider<StudyInvite> {
  static const _searchDebounceDuration = Duration(milliseconds: 300);

  /// [inviteCodeRepository] Reference to the repository for invite codes (resolved dynamically via Riverpod when the [state.study] becomes available)
  @override
  StudyRecruitControllerState build(StudyID studyId) {
    state = StudyRecruitControllerState(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      studyWithMetadata: ref
          .watch(studyControllerProvider(studyId))
          .studyWithMetadata,
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser,
      inviteCodeRepository: ref.watch(inviteCodeRepositoryProvider(studyId)),
    );
    ref.onDispose(() {
      print("StudyRecruitController.dispose");
      _searchDebounce?.cancel();
    });
    Future.microtask(() => loadInviteCodePage(0));
    return state;
  }

  Timer? _searchDebounce;
  int _fetchToken = 0;

  Future<void> loadInviteCodePage(
    int pageIndex, {
    bool showLoading = true,
  }) async {
    if (pageIndex < 0) return;
    final token = ++_fetchToken;
    if (showLoading) {
      state = state.copyWith(invites: const AsyncValue.loading());
    }

    final query = state.inviteCodeSearchQuery.trim();
    final effectiveQuery = query.isEmpty ? null : query;
    final offset = pageIndex * state.inviteCodePageSize;

    try {
      final results = await Future.wait([
        state.inviteCodeRepository.fetchPage(
          offset: offset,
          limit: state.inviteCodePageSize,
          query: effectiveQuery,
        ),
        state.inviteCodeRepository.count(query: effectiveQuery),
      ]);

      if (token != _fetchToken) return;

      final invites = results[0] as List<StudyInvite>;
      final inviteCount = results[1] as int;
      state = state.copyWith(
        invites: AsyncValue.data(invites),
        inviteCodePageIndex: pageIndex,
        inviteCodeCount: inviteCount,
        hasNextInviteCodePage: offset + invites.length < inviteCount,
      );
    } catch (error, stackTrace) {
      if (token != _fetchToken) return;
      state = state.copyWith(
        invites: AsyncValue.error(error, stackTrace),
        inviteCodeCount: 0,
        hasNextInviteCodePage: false,
      );
    }
  }

  Future<void> setInviteCodeSearchQuery(String query) async {
    if (query == state.inviteCodeSearchQuery) return;
    state = state.copyWith(inviteCodeSearchQuery: query);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      unawaited(loadInviteCodePage(0));
    });
  }

  Future<void> showInviteCode(String code) async {
    _searchDebounce?.cancel();
    state = state.copyWith(inviteCodeSearchQuery: code);
    await loadInviteCodePage(0);
  }

  Future<void> showCreatedInviteCode(StudyInvite invite) async {
    _searchDebounce?.cancel();
    final currentInvites =
        state.invites is AsyncData<List<StudyInvite>?>
        ? (state.invites as AsyncData<List<StudyInvite>?>).value ??
              const <StudyInvite>[]
        : const <StudyInvite>[];
    final query = state.inviteCodeSearchQuery.trim().toLowerCase();
    final matchesCurrentQuery =
        query.isEmpty || invite.code.toLowerCase().contains(query);

    if (state.inviteCodePageIndex == 0 && matchesCurrentQuery) {
      final updatedInvites = [
        invite,
        ...currentInvites.where((item) => item.code != invite.code),
      ];
      final visibleInvites = updatedInvites.take(state.inviteCodePageSize).toList();
      state = state.copyWith(
        invites: AsyncValue.data(visibleInvites),
        inviteCodeCount: state.inviteCodeCount + 1,
        hasNextInviteCodePage: updatedInvites.length > state.inviteCodePageSize,
      );
    } else if (query.isEmpty) {
      state = state.copyWith(inviteCodeCount: state.inviteCodeCount + 1);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      unawaited(
        loadInviteCodePage(state.inviteCodePageIndex, showLoading: false),
      );
    });
  }

  Future<void> setInviteCodePageSize(int pageSize) async {
    if (pageSize == state.inviteCodePageSize) return;
    state = state.copyWith(inviteCodePageSize: pageSize);
    await loadInviteCodePage(0);
  }

  Future<void> loadNextInviteCodePage() async {
    if (!state.hasComputedNextInviteCodePage) return;
    await loadInviteCodePage(state.inviteCodePageIndex + 1);
  }

  Future<void> loadPreviousInviteCodePage() async {
    if (!state.hasPreviousInviteCodePage) return;
    await loadInviteCodePage(state.inviteCodePageIndex - 1);
  }

  Intervention? getIntervention(String interventionId) {
    return state.studyValueRequired.getIntervention(interventionId);
  }

  int getParticipantCountForInvite(StudyInvite invite) {
    return state.studyValueRequired.getParticipantCountForInvite(invite);
  }

  // - IModelActionProvider

  @override
  List<ModelAction> availableActions(StudyInvite model) {
    final actions = state.inviteCodeRepository
        .availableActions(model)
        .where((action) => action.type != ModelActionType.share)
        .map(_withPageRefresh)
        .toList();
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(StudyInvite model) {
    final actions = state.inviteCodeRepository
        .availableActions(model)
        .where((action) => action.type == ModelActionType.share)
        .toList();
    return withIcons(actions, modelActionIcons);
  }

  ModelAction _withPageRefresh(ModelAction action) {
    if (action.type != ModelActionType.delete) {
      return action;
    }
    return ModelAction(
      type: action.type,
      label: action.label,
      tooltip: action.tooltip,
      isAvailable: action.isAvailable,
      isDestructive: action.isDestructive,
      isChecked: action.isChecked,
      showBadge: action.showBadge,
      onExecute: () {
        action.onExecute();
        Future.delayed(
          const Duration(milliseconds: 300),
          () => unawaited(
            loadInviteCodePage(state.inviteCodePageIndex, showLoading: false),
          ),
        );
      },
    );
  }
}
