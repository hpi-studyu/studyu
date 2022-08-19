import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
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

abstract class IStudyRepository implements ModelRepository<Study> {
  Future<void> publish(Study study);
}

class StudyRepository extends ModelRepository<Study> implements IStudyRepository {
  StudyRepository({
    required this.apiClient,
    required this.authRepository,
    required this.ref,
  }) : super(StudyRepositoryDelegate(
      apiClient: apiClient, authRepository: authRepository
  ));

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
  Future<void> publish(Study study) async {
    final wrappedModel = get(study.id);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }

    final publishedCopy = study.asNewlyPublished();

    final publishOperation = OptimisticUpdate(
      applyOptimistic: () => {}, // nothing to do here
      apply: () async {
        await save(publishedCopy, runOptimistically: false);
        // TODO clear study subjects + progress
      },
      rollback: () { }, // nothing to do here
      onUpdate: () => emitUpdate(),
      onError: (e, stackTrace) {
        emitError(modelStreamControllers[study.id], e, stackTrace);
      }
    );

    return publishOperation.execute();
  }

  @override
  List<ModelAction<StudyActionType>> availableActions(Study study) {
    Future<void> onDeleteCallback() {
      return delete(study.id)
        .then((value) => ref.read(routerProvider).dispatch(RoutingIntents.studies))
        .then((value) => Future.delayed(
            const Duration(milliseconds: 200),
            () => ref.read(notificationServiceProvider).show(
                Notifications.studyDeleted)
        ));
    }

    // TODO: review Postgres policies to match [ModelAction.isAvailable]
    final actions = [
      ModelAction(
        type: StudyActionType.edit,
        label: "Edit".hardcoded,
        onExecute: () {
          ref.read(routerProvider)
              .dispatch(RoutingIntents.studyEdit(study.id));
        },
        isAvailable: study.isOwner(authRepository.currentUser!)
            && study.status == StudyStatus.draft,
      ),
      ModelAction(
        type: StudyActionType.duplicate,
        label: "Copy draft".hardcoded,
        onExecute: () {
          return duplicateAndSave(study)
              .then((value) => ref.read(routerProvider).dispatch(RoutingIntents.studies));
        },
        isAvailable: study.isOwner(authRepository.currentUser!),
      ),
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: "Add collaborator".hardcoded,
        onExecute: () {
          // TODO open modal to add collaborator
          print("Adding collaborator: ${study.title ?? ''}");
        },
        isAvailable: study.isOwner(authRepository.currentUser!),
      ),
      ModelAction(
        type: StudyActionType.recruit,
        label: "Recruit participants".hardcoded,
        onExecute: () {
          ref.read(routerProvider)
              .dispatch(RoutingIntents.studyRecruit(study.id));
        },
        isAvailable: study.isOwner(authRepository.currentUser!)
            && study.status == StudyStatus.running,
      ),
      ModelAction(
        type: StudyActionType.export,
        label: "Export results".hardcoded,
        onExecute: () {
          // TODO trigger download of results
          print("Export results: ${study.title ?? ''}");
        },
        isAvailable: study.results.isNotEmpty
            && (study.isOwner(authRepository.currentUser!) ||
                study.isEditor(authRepository.currentUser!) ||
                study.resultSharing == ResultSharing.public),
      ),
      ModelAction(
        type: StudyActionType.delete,
        label: "Delete".hardcoded,
        onExecute: () {
          return ref.read(notificationServiceProvider).show(
            Notifications.studyDeleteConfirmation, // TODO: more severe confirmation for running studies
            actions: [
              NotificationAction(
                label: "Delete".hardcoded,
                onSelect: onDeleteCallback,
                isDestructive: true
              ),
            ]
          );
        },
        isAvailable: study.isOwner(authRepository.currentUser!)
            && !study.published,
        isDestructive: true
      ),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }
}

class StudyRepositoryDelegate extends IModelRepositoryDelegate<Study> {
  StudyRepositoryDelegate({
    required this.apiClient, required this.authRepository});

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

final studyProvider = StreamProvider.autoDispose
    .family<WrappedModel<Study>, StudyID>((ref, studyId) {
  final studyRepository = ref.watch(studyRepositoryProvider);
  return studyRepository.watch(studyId);
});
