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
    });
    Future.microtask(() => loadInviteCodePage(0));
    return state;
  }

  Future<void> loadInviteCodePage(int pageIndex) async {
    if (pageIndex < 0) return;

    state = state.copyWith(
      invites: const AsyncValue.loading(),
      inviteCodePageIndex: pageIndex,
    );

    try {
      final fetchLimit = state.inviteCodePageSize + 1;
      final offset = pageIndex * state.inviteCodePageSize;
      final fetchedInvites = await state.inviteCodeRepository.fetchPage(
        offset: offset,
        limit: fetchLimit,
        query: state.inviteCodeSearchQuery,
      );
      final inviteCount = await state.inviteCodeRepository.count(
        query: state.inviteCodeSearchQuery,
      );
      final hasNextPage = fetchedInvites.length > state.inviteCodePageSize;
      final visibleInvites = fetchedInvites
          .take(state.inviteCodePageSize)
          .toList();

      state = state.copyWith(
        invites: AsyncValue.data(visibleInvites),
        inviteCodePageIndex: pageIndex,
        inviteCodeCount: inviteCount,
        hasNextInviteCodePage: hasNextPage,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        invites: AsyncValue.error(error, stackTrace),
        inviteCodePageIndex: pageIndex,
      );
    }
  }

  Future<void> loadPreviousInviteCodePage() {
    return loadInviteCodePage(state.inviteCodePageIndex - 1);
  }

  Future<void> loadNextInviteCodePage() {
    if (!state.hasNextInviteCodePage) return Future.value();
    return loadInviteCodePage(state.inviteCodePageIndex + 1);
  }

  Future<void> setInviteCodeSearchQuery(String query) {
    state = state.copyWith(inviteCodeSearchQuery: query);
    return loadInviteCodePage(0);
  }

  Future<void> setInviteCodePageSize(int pageSize) {
    state = state.copyWith(inviteCodePageSize: pageSize);
    return loadInviteCodePage(0);
  }

  void upsertInviteOnCurrentPage(StudyInvite invite) {
    final currentInvites = state.invites.value ?? [];
    final updatedInvites = [
      invite,
      ...currentInvites.where((current) => current.code != invite.code),
    ]..sort((a, b) => a.code.compareTo(b.code));

    final visibleInvites = updatedInvites
        .take(state.inviteCodePageSize)
        .toList();
    state = state.copyWith(
      invites: AsyncValue.data(visibleInvites),
      hasNextInviteCodePage:
          state.hasNextInviteCodePage ||
          updatedInvites.length > state.inviteCodePageSize,
    );
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
        .where((action) => action.type != ModelActionType.clipboard)
        .map(_withPageRefresh)
        .toList();
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(StudyInvite model) {
    final actions = state.inviteCodeRepository
        .availableActions(model)
        .where((action) => action.type == ModelActionType.clipboard)
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
          () => loadInviteCodePage(state.inviteCodePageIndex),
        );
      },
    );
  }
}
