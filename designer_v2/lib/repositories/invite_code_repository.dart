import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/common_views/qr_code_preview_dialog.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';

part 'invite_code_repository.g.dart';

const int defaultInviteCodePageSize = 50;

abstract class IInviteCodeRepository implements ModelRepository<StudyInvite> {
  Future<bool> isCodeAlreadyUsed(String code);

  Future<List<StudyInvite>> fetchPage({
    required int offset,
    required int limit,
    String? query,
    InviteCodesSortColumn sortBy = InviteCodesSortColumn.createdAt,
    bool ascending = false,
  });

  Future<int> count({String? query});
}

class InviteCodeRepository extends ModelRepository<StudyInvite>
    implements IInviteCodeRepository {
  InviteCodeRepository({
    required this.studyId,
    required this.apiClient,
    required this.authRepository,
    required this.studyRepository,
    required this.ref,
  }) : super(
         InviteCodeRepositoryDelegate(
           study: studyRepository.get(studyId)!.model,
           apiClient: apiClient,
           studyRepository: studyRepository,
         ),
       );

  /// The [Study] this repository operates on
  final StudyID studyId;
  Study get study => studyRepository.get(studyId)!.model;

  /// Reference to Riverpod's context to resolve dependencies in callbacks
  final Ref ref;

  final StudyUApi apiClient;
  final IAuthRepository authRepository;
  final IStudyRepository studyRepository;

  @override
  ModelID getKey(StudyInvite model) {
    return model.code;
  }

  @override
  Future<bool> isCodeAlreadyUsed(String code) async {
    try {
      await apiClient.fetchStudyFromInvite(code);
    } on StudyInviteNotFoundException {
      return false;
    } catch (e) {
      rethrow;
    }
    return true;
  }

  /// Generate the deep link URL for an invite code
  String generateInviteDeepLink(String code) {
    return env.generateAppDeepLink('invite/$code');
  }

  @override
  Future<List<StudyInvite>> fetchPage({
    required int offset,
    required int limit,
    String? query,
    InviteCodesSortColumn sortBy = InviteCodesSortColumn.createdAt,
    bool ascending = false,
  }) async {
    final invites = await apiClient.fetchStudyInvitesPage(
      studyId,
      offset: offset,
      limit: limit,
      query: query,
      sortBy: sortBy,
      ascending: ascending,
    );
    for (final invite in invites) {
      upsertLocally(invite);
    }
    emitUpdate();
    return invites;
  }

  @override
  Future<int> count({String? query}) {
    return apiClient.countStudyInvites(studyId, query: query);
  }

  @override
  List<ModelAction> availableActions(StudyInvite model) {
    final deepLink = generateInviteDeepLink(model.code);

    final actions = [
      ModelAction(
        type: ModelActionType.share,
        label: ModelActionType.share.string,
        onExecute: () {},
        onExecuteWithContext: (context) {
          _showSharePopup(context, deepLink, model.code);
        },
      ),
      ModelAction(
        type: ModelActionType.delete,
        label: ModelActionType.delete.string,
        confirmation: ModelActionConfirmations.delete(
          subject: tr.dialog_subject_invite_code,
        ),
        onExecute: () async {
          await delete(getKey(model));
          ref
              .read(routerProvider)
              .dispatch(RoutingIntents.studyRecruit(model.studyId));
          await Future.delayed(
            const Duration(milliseconds: 200),
            () => ref
                .read(notificationServiceProvider)
                .show(Notifications.inviteCodeDeleted),
          );
        },
        isAvailable: study.isOwner(authRepository.currentUser),
        isDestructive: true,
      ),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }

  void _showSharePopup(BuildContext context, String deepLink, String filename) {
    final effectiveContext = context;

    // Determine where to render the popup based on the clicked element
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final theme = Theme.of(context);
    final textTheme = theme.textTheme.labelMedium!;
    final iconColorDefault =
        theme.iconTheme.color?.withValues(alpha: 0.7) ?? Colors.grey;

    showMenu<String>(
      context: context,
      position: position,
      elevation: 5,
      items: [
        PopupMenuItem<String>(
          value: 'copy_link',
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            horizontalTitleGap: 4.0,
            leading: Icon(
              Icons.link_rounded,
              size: theme.iconTheme.size ?? 14.0,
              color: iconColorDefault,
            ),
            title: Text(ModelActionType.clipboard.string, style: textTheme),
          ),
        ),
        PopupMenuItem<String>(
          value: 'qr_code',
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            horizontalTitleGap: 4.0,
            leading: Icon(
              Icons.qr_code_rounded,
              size: theme.iconTheme.size ?? 14.0,
              color: iconColorDefault,
            ),
            title: Text(ModelActionType.qrCodeShow.string, style: textTheme),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'copy_link') {
        ref
            .read(clipboardServiceProvider)
            .copy(deepLink)
            .then(
              (_) => ref
                  .read(notificationServiceProvider)
                  .show(Notifications.inviteCodeClipped),
            );
      } else if (value == 'qr_code') {
        if (effectiveContext.mounted) {
          showDialog(
            context: effectiveContext,
            builder: (ctx) =>
                QrCodePreviewDialog(data: deepLink, filename: filename),
          );
        }
      }
    });
  }
}

class InviteCodeRepositoryDelegate
    extends IModelRepositoryDelegate<StudyInvite> {
  InviteCodeRepositoryDelegate({
    required this.study,
    required this.apiClient,
    required this.studyRepository,
  });

  final Study study;
  final StudyUApi apiClient;
  final IStudyRepository studyRepository;

  @override
  Future<StudyInvite> fetch(ModelID modelId) {
    return apiClient.fetchStudyInvite(modelId);
  }

  @override
  Future<List<StudyInvite>> fetchAll() {
    return apiClient.fetchStudyInvitesPage(
      study.id,
      offset: 0,
      limit: defaultInviteCodePageSize,
    );
  }

  @override
  Future<StudyInvite> save(StudyInvite model) {
    final prevInvites = [...?study.invites];
    final saveOperation = OptimisticUpdate(
      applyOptimistic: () {},
      apply: () async {
        await studyRepository.ensurePersisted(model.studyId);
        await apiClient.saveStudyInvite(model);
      },
      rollback: () {
        study.invites = prevInvites;
        studyRepository.upsertLocally(study);
      },
      onUpdate: studyRepository.emitUpdate,
      rethrowErrors: true,
    );

    return saveOperation.execute().then((_) => model);
  }

  @override
  Future<void> delete(StudyInvite model) {
    final deleteOperation = OptimisticUpdate(
      applyOptimistic: () {
        study.invites!.remove(model);
        /*study.invites!.removeWhere((i) => i.code == model.code);*/
        studyRepository.upsertLocally(study);
      },
      apply: () => apiClient.deleteStudyInvite(model),
      rollback: () {},
      onUpdate: studyRepository.emitUpdate,
      rethrowErrors: true,
    );

    return deleteOperation.execute();
  }

  @override
  void onError(Object error, StackTrace? stackTrace) {
    return; // TODO
  }

  @override
  StudyInvite createDuplicate(StudyInvite model) {
    throw UnimplementedError(); // not available
  }

  @override
  StudyInvite createNewInstance() {
    throw UnimplementedError(); // not available
  }
}

@riverpod
InviteCodeRepository inviteCodeRepository(Ref ref, StudyID studyId) {
  print("inviteCodeRepositoryProvider($studyId");
  // Initialize repository for a given study
  final repository = InviteCodeRepository(
    studyId: studyId,
    apiClient: ref.watch(apiClientProvider),
    authRepository: ref.watch(authRepositoryProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    ref: ref,
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    print("inviteCodeRepositoryProvider($studyId.DISPOSE");
    repository.dispose();
  });
  return repository;
}
