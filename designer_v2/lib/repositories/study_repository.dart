import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/features/analyze/study_export_zip.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

abstract class IStudyRepository implements ModelRepository<Study> {
  Future<void> launch(Study study);
  Future<void> deleteParticipants(Study study);
//Future<void> deleteProgress(Study study);
}

class StudyRepository extends ModelRepository<Study>
    implements IStudyRepository {
  StudyRepository({
    required this.apiClient,
    required this.authRepository,
    required this.ref,
  }) : super(StudyRepositoryDelegate(
            apiClient: apiClient, authRepository: authRepository));

  /// Reference to the StudyU API injected via Riverpod
  final StudyUApi apiClient;

  /// Reference to the auth repository injected via Riverpod
  final IAuthRepository authRepository;

  /// Reference to Riverpod's context to resolve dependencies in callbacks
  final ProviderRef ref;

  @override
  ModelID getKey(Study model) {
    return model.id;
  }

  @override
  Future<void> deleteParticipants(Study study) async {
    final wrappedModel = get(study.id);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }

    final List<StudySubject> participants = [...(study.participants ?? [])];

    final deleteParticipantsOperation = OptimisticUpdate(
      applyOptimistic: () => study.participants = [],
      apply: () async {
        await apiClient.deleteParticipants(study, participants);
        upsertLocally(study);
      },
      rollback: () => study.participants = participants,
      onUpdate: () => emitUpdate(),
      onError: (e, stackTrace) {
        get(study.id)?.markWithError(e);
        emitError(modelStreamControllers[study.id], e, stackTrace);
      },
      rethrowErrors: true,
    );

    return deleteParticipantsOperation.execute();
  }

  @override
  Future<void> launch(Study study) async {
    final wrappedModel = get(study.id);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }

    final publishedCopy = study.asNewlyPublished();

    final publishOperation = OptimisticUpdate(
        applyOptimistic: () => {}, // nothing to do here
        apply: () => save(publishedCopy, runOptimistically: false),
        rollback: () {}, // nothing to do here
        onUpdate: () => emitUpdate(),
        onError: (e, stackTrace) {
          emitError(modelStreamControllers[study.id], e, stackTrace);
        },
    );

    return publishOperation.execute();
  }

  @override
  List<ModelAction> availableActions(Study study) {
    Future<void> onDeleteCallback() {
      return delete(study.id)
          .then((value) =>
              ref.read(routerProvider).dispatch(RoutingIntents.studies))
          .then((value) => Future.delayed(
              const Duration(milliseconds: 200),
              () => ref
                  .read(notificationServiceProvider)
                  .show(Notifications.studyDeleted)));
    }

    final currentUser = authRepository.currentUser!;

    // TODO: review Postgres policies to match [ModelAction.isAvailable]
    final actions = [
      ModelAction(
        type: StudyActionType.edit,
        label: tr.edit,
        onExecute: () {
          ref.read(routerProvider).dispatch(RoutingIntents.studyEdit(study.id));
        },
        isAvailable: study.canEditDraft(currentUser),
      ),
      ModelAction( // same as "Copy" but for non-drafts
        type: StudyActionType.duplicate,
        label: "Copy as draft".hardcoded,
        onExecute: () {
          return duplicateAndSave(study).then((value) =>
              ref.read(routerProvider).dispatch(RoutingIntents.studies));
        },
        isAvailable: study.status != StudyStatus.draft && study.canCopy(currentUser),
      ),
      ModelAction(
        type: StudyActionType.duplicate,
        label: "Copy".hardcoded,
        //label: tr.copy_draft, .hardcoded
        onExecute: () {
          return duplicateAndSave(study).then((value) =>
              ref.read(routerProvider).dispatch(RoutingIntents.studies));
        },
        isAvailable: study.status == StudyStatus.draft && study.canCopy(currentUser),
      ),
      /*
      TODO re-implement this properly
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: tr.add_collaborator,
        onExecute: () {
          print("Adding collaborator: ${study.title ?? ''}");
        },
        isAvailable: study.isOwner(authRepository.currentUser!),
      ),
       */
      ModelAction(
        type: StudyActionType.export,
        label: tr.export_results,
        onExecute: () {
          runAsync(() => study.exportData.downloadAsZip());
        },
        isAvailable: study.canExport(currentUser),
      ),
      ModelAction(
          type: StudyActionType.delete,
          label: tr.delete,
          onExecute: () {
            return ref.read(notificationServiceProvider).show(
                Notifications
                    .studyDeleteConfirmation, // TODO: more severe confirmation for running studies
                actions: [
                  NotificationAction(
                      label: tr.delete,
                      onSelect: onDeleteCallback,
                      isDestructive: true),
                ]);
          },
          isAvailable: study.canDelete(currentUser),
          isDestructive: true,
      ),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }
}

class StudyRepositoryDelegate extends IModelRepositoryDelegate<Study> {
  StudyRepositoryDelegate(
      {required this.apiClient, required this.authRepository});

  final StudyUApi apiClient;
  final IAuthRepository authRepository;

  @override
  Future<List<Study>> fetchAll() {
    return apiClient.getUserStudies();
  }

  @override
  Future<Study> fetch(ModelID modelId) {
    return apiClient.fetchStudy(modelId);
  }

  @override
  Future<Study> save(Study model) {
    return apiClient.saveStudy(model);
  }

  @override
  Future<void> delete(Study model) {
    return apiClient.deleteStudy(model);
  }

  @override
  onError(Object error, StackTrace? stackTrace) {
    return; // TODO
  }

  @override
  Study createNewInstance() {
    return StudyTemplates.emptyDraft(authRepository.currentUser!.id);
  }

  @override
  Study createDuplicate(Study model) {
    return model.duplicateAsDraft(authRepository.currentUser!.id);
  }
}

final studyRepositoryProvider = Provider<IStudyRepository>((ref) {
  final studyRepository = StudyRepository(
    apiClient: ref.watch(apiClientProvider),
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    studyRepository.dispose();
  });
  return studyRepository;
});
