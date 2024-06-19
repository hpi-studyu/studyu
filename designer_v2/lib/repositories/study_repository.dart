import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/features/analyze/study_export_zip.dart';
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
  Future<void> close(Study study);
  // Future<void> deleteProgress(Study study);
}

class StudyRepository extends ModelRepository<Study>
    implements IStudyRepository {
  StudyRepository({
    this.sortCallback,
    required this.apiClient,
    required this.authRepository,
    required this.ref,
  }) : super(
          StudyRepositoryDelegate(
            apiClient: apiClient,
            authRepository: authRepository,
          ),
        );

  /// Reference to the StudyU API injected via Riverpod
  final StudyUApi apiClient;

  /// Reference to the auth repository injected via Riverpod
  final IAuthRepository authRepository;

  /// Reference to Riverpod's context to resolve dependencies in callbacks
  final ProviderRef ref;

  final VoidCallback? sortCallback;

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

    final List<StudySubject> participants = [...study.participants ?? []];

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

    deleteParticipants(study);
    return publishOperation.execute();
  }

  /// This method fetches the full study object, duplicates it and saves it as a draft.
  /// Since the Study object in the dashboard is fetched with limited columns (no intervention or measurement data),
  /// we need to fetch the full columns in order to duplicate it correctly.
  @override
  Future<void> duplicateAndSave(Study model) async {
    final Study completeModel = await apiClient.fetchStudy(model.id);
    final duplicate =
        completeModel.duplicateAsDraft(authRepository.currentUser!.id);
    await save(duplicate);
  }

  @override
  Future<void> close(Study study) async {
    final wrappedModel = get(study.id);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }
    study.status = StudyStatus.closed;

    final publishOperation = OptimisticUpdate(
      applyOptimistic: () => {}, // nothing to do here
      apply: () => save(study, runOptimistically: false),
      rollback: () {}, // nothing to do here
      onUpdate: () => emitUpdate(),
      onError: (e, stackTrace) {
        emitError(modelStreamControllers[study.id], e, stackTrace);
      },
    );

    return publishOperation.execute();
  }

  @override
  List<ModelAction> availableActions(Study model) {
    Future<void> onDeleteCallback() {
      return delete(model.id)
          .then(
            (value) =>
                ref.read(routerProvider).dispatch(RoutingIntents.studies),
          )
          .then(
            (value) => Future.delayed(
              const Duration(milliseconds: 200),
              () => ref
                  .read(notificationServiceProvider)
                  .show(Notifications.studyDeleted),
            ),
          );
    }

    final currentUser = authRepository.currentUser;
    if (currentUser == null) return [];

    // TODO: review Postgres policies to match [ModelAction.isAvailable]
    final actions = [
      ModelAction(
        type: StudyActionType.edit,
        label: StudyActionType.edit.string,
        onExecute: () {
          ref.read(routerProvider).dispatch(RoutingIntents.studyEdit(model.id));
        },
        isAvailable: model.canEditDraft(currentUser),
      ),
      ModelAction(
        // same as "Copy" but for non-drafts
        type: StudyActionType.duplicateDraft,
        label: StudyActionType.duplicateDraft.string,
        onExecute: () {
          return duplicateAndSave(model).then(
            (value) =>
                ref.read(routerProvider).dispatch(RoutingIntents.studies),
          );
        },
        isAvailable:
            model.status != StudyStatus.draft && model.canCopy(currentUser),
      ),
      ModelAction(
        type: StudyActionType.duplicate,
        label: StudyActionType.duplicate.string,
        onExecute: () {
          return duplicateAndSave(model).then(
            (value) =>
                ref.read(routerProvider).dispatch(RoutingIntents.studies),
          );
        },
        isAvailable:
            model.status == StudyStatus.draft && model.canCopy(currentUser),
      ),
      /*
      TODO re-implement this properly
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: "Add collaborator".hardcoded,
        onExecute: () {
          print("Adding collaborator: ${study.title ?? ''}");
        },
        isAvailable: study.isOwner(authRepository.currentUser!),
      ),
       */
      ModelAction(
        type: StudyActionType.export,
        label: StudyActionType.export.string,
        onExecute: () {
          runAsync(() => model.exportData.downloadAsZip());
        },
        isAvailable: model.canExport(currentUser),
      ),
      if (model.canDelete(currentUser)) ModelAction.addSeparator(),
      ModelAction(
        type: StudyActionType.delete,
        label: StudyActionType.delete.string,
        onExecute: () {
          return ref.read(notificationServiceProvider).show(
            Notifications
                .studyDeleteConfirmation, // TODO: more severe confirmation for running studies
            actions: [
              NotificationAction(
                label: StudyActionType.delete.string,
                onSelect: onDeleteCallback,
                isDestructive: true,
              ),
            ],
          );
        },
        isAvailable: model.canDelete(currentUser),
        isDestructive: true,
      ),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }
}

class StudyRepositoryDelegate extends IModelRepositoryDelegate<Study> {
  StudyRepositoryDelegate({
    required this.apiClient,
    required this.authRepository,
  });

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
  void onError(Object error, StackTrace? stackTrace) {
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
