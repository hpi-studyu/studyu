import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/common_views/qr_code_preview_dialog.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';

part 'invite_code_repository.g.dart';

abstract class IInviteCodeRepository implements ModelRepository<StudyInvite> {
  Future<bool> isCodeAlreadyUsed(String code);
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
    final scheme = env.appDeepLinkScheme ?? 'https://app.studyu.health';
    return '$scheme/invite/$code';
  }

  @override
  List<ModelAction> availableActions(StudyInvite model) {
    final deepLink = generateInviteDeepLink(model.code);

    final actions = [
      ModelAction(
        type: ModelActionType.share,
        label: ModelActionType.share.string,
        onExecute: ([BuildContext? context]) {
          if (context == null) return;
          _showSharePopup(context, deepLink, model.code);
        },
      ),
      ModelAction(
        type: ModelActionType.delete,
        label: ModelActionType.delete.string,
        onExecute: () async {
          return await delete(getKey(model))
              .then(
                (value) => ref
                    .read(routerProvider)
                    .dispatch(RoutingIntents.studyRecruit(model.studyId)),
              )
              .then(
                (value) => Future.delayed(
                  const Duration(milliseconds: 200),
                  () => ref
                      .read(notificationServiceProvider)
                      .show(Notifications.inviteCodeDeleted),
                ),
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
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        const PopupMenuItem<String>(
          value: 'copy_link',
          child: Row(
            children: [
              Icon(Icons.link_rounded, size: 20),
              SizedBox(width: 12),
              Text('Copy link'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'qr_code',
          child: Row(
            children: [
              Icon(Icons.qr_code_rounded, size: 20),
              SizedBox(width: 12),
              Text('QR Code'),
            ],
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

  @override
  void emitUpdate() {
    print("InviteCodeRepository.emitUpdate");
    super.emitUpdate();
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
    // Read directly from the study instead of fetching from the network
    return Future.value(study.getInvite(modelId));
  }

  @override
  Future<List<StudyInvite>> fetchAll() {
    // Read directly from the study instead of fetching from the network
    return Future.value(study.invites ?? []);
  }

  @override
  Future<StudyInvite> save(StudyInvite model) {
    study.invites ??= [];
    final prevInvites = [...study.invites!];

    final saveOperation = OptimisticUpdate(
      applyOptimistic: () {
        final inviteIdx = study.invites!.indexWhere(
          (i) => i.code == model.code,
        );
        if (inviteIdx == -1) {
          // add new code
          study.invites!.add(model);
        } else {
          // replace existing code
          study.invites![inviteIdx] = model;
        }
        studyRepository.upsertLocally(study);
      },
      apply: () async {
        await studyRepository.ensurePersisted(model.studyId);
        await apiClient.saveStudyInvite(model);
      },
      rollback: () {
        study.invites = prevInvites;
        studyRepository.upsertLocally(study);
      },
      onUpdate: () {
        print("saveOperation: studyRepository.emitUpdate()");
        studyRepository.emitUpdate();
      },
      rethrowErrors: true,
    );

    return saveOperation.execute().then((_) => model);
  }

  @override
  Future<void> delete(StudyInvite model) {
    assert(study.invites != null);
    assert(study.invites!.isNotEmpty);

    final prevInvites = [...study.invites!];
    final deleteOperation = OptimisticUpdate(
      applyOptimistic: () {
        study.invites!.remove(model);
        studyRepository.upsertLocally(study);
      },
      apply: () => apiClient.deleteStudyInvite(model),
      rollback: () {
        study.invites = prevInvites;
        studyRepository.upsertLocally(study);
      },
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
