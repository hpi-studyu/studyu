import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

abstract class IInviteCodeRepository
    implements IModelActionProvider<ModelActionType, StudyInvite> {
  // - StudyInvite
  Future<StudyInvite> saveStudyInvite(StudyInvite invite);
  Future<void> deleteStudyInvite(StudyInvite invite);
  Future<bool> isCodeAlreadyUsed(String code);
  List<ModelAction<ModelActionType>> availableActions(StudyInvite invite);
  // - Lifecycle
  void dispose();
}

abstract class IInviteCodeRepositoryDelegate {
  onDeletedStudyInvite(StudyInvite invite);
  onSavedStudyInvite(StudyInvite invite);
}

class InviteCodeRepository implements IInviteCodeRepository {
  InviteCodeRepository({
    required this.apiClient,
    required this.studyRepository,
    required this.authRepository,
    required this.ref,
  }) : delegate = studyRepository;

  final StudyUApi apiClient;
  final IStudyRepository studyRepository;
  final IAuthRepository authRepository;
  final IInviteCodeRepositoryDelegate? delegate;
  /// Reference to Riverpod's context to resolve dependencies in callbacks
  final ProviderRef ref;

  @override
  Future<bool> isCodeAlreadyUsed(String code) async {
    try {
      await apiClient.fetchStudyInvite(code);
    } on StudyInviteNotFoundException {
      return false;
    }
    return true;
  }

  @override
  Future<StudyInvite> saveStudyInvite(StudyInvite invite) async {
    // TODO proper optimistic mutation
    if (studyRepository.isLocalOnly(invite.studyId)) {
      final study = studyRepository.getStudy(invite.studyId)!;
      await studyRepository.saveStudy(study);
    }
    final savedStudyInvite = await apiClient.saveStudyInvite(invite);
    delegate?.onSavedStudyInvite(savedStudyInvite);
    return savedStudyInvite;
  }

  @override
  Future<void> deleteStudyInvite(StudyInvite invite) async {
    // TODO proper optimistic mutation
    await apiClient.deleteStudyInvite(invite);
    delegate?.onDeletedStudyInvite(invite);
  }

  @override
  List<ModelAction<ModelActionType>> availableActions(StudyInvite invite) {
    final study = studyRepository.getStudy(invite.studyId);
    if (study == null) {
      return [];
    }

    final actions = [
      ModelAction(
        type: ModelActionType.clipboard,
        label: ModelActionType.clipboard.string,
        onExecute: () => {
          ref.read(clipboardServiceProvider).copy(invite.code)
            .then((value) => ref.read(notificationServiceProvider)
              .show(Notifications.inviteCodeClipped))
        },
      ),
      ModelAction(
        type: ModelActionType.delete,
        label: ModelActionType.delete.string,
        onExecute: () {
          return deleteStudyInvite(invite)
              .then((value) => ref.read(routerProvider).dispatch(
                  RoutingIntents.studyRecruit(invite.studyId)))
              .then((value) => Future.delayed(
                  const Duration(milliseconds: 200),
                  () => ref.read(notificationServiceProvider).show(
                      Notifications.inviteCodeDeleted)
          ));
        },
        isAvailable: study.isOwner(authRepository.currentUser!),
        isDestructive: true
      ),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }

  @override
  void dispose() {
    return;
  }
}

final inviteCodeRepositoryProvider = Provider<IInviteCodeRepository>((ref) {
  final repository = InviteCodeRepository(
    apiClient: ref.watch(apiClientProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    repository.dispose();
  });
  return repository;
});
