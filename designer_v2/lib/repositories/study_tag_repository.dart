import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';

abstract class IStudyTagRepository implements ModelRepository<StudyTag> {
  List<Future> updateStudyTags(List<Tag> tagsToUpdate);
}

class StudyTagRepository extends ModelRepository<StudyTag> implements IStudyTagRepository {
  StudyTagRepository({
    required this.studyId,
    required this.apiClient,
    required this.authRepository,
    required this.studyRepository,
    required this.ref,
  }) : super(StudyTagRepositoryDelegate(
            study: studyRepository.get(studyId)!.model, apiClient: apiClient, studyRepository: studyRepository));

  /// The [Study] this repository operates on
  final StudyID studyId;

  Study get study => studyRepository.get(studyId)!.model;

  /// Reference to Riverpod's context to resolve dependencies in callbacks
  final ProviderRef ref;

  final StudyUApi apiClient;
  final IAuthRepository authRepository;
  final IStudyRepository studyRepository;

  @override
  ModelID getKey(StudyTag model) {
    return model.id;
  }

  @override
  List<Future> updateStudyTags(List<Tag> tagsToUpdate) {
    final currentTags = study.studyTags.toTagList().toSet();
    final futureTags = tagsToUpdate.toSet();
    final addFutures = futureTags
        .difference(currentTags)
        .map((e) => delegate.save(StudyTag.fromTag(tag: e, studyId: study.id)))
        .toList();
    final deleteFutures = currentTags
        .difference(futureTags)
        .map((e) => delegate.delete(StudyTag.fromTag(tag: e, studyId: study.id)))
        .toList();
    return [...addFutures, ...deleteFutures];
  }

  /*@override
  List<ModelAction> availableActions(Tag model) {
    final actions = [
      ModelAction(
        type: ModelActionType.clipboard,
        label: ModelActionType.clipboard.string,
        onExecute: () => {
          ref
              .read(clipboardServiceProvider)
              .copy(model.id)
              .then((value) => ref.read(notificationServiceProvider).show(Notifications.StudyTagClipped))
        },
      ),
      ModelAction(
          type: ModelActionType.delete,
          label: ModelActionType.delete.string,
          onExecute: () {
            return delete(getKey(model))
                .then((value) => ref.read(routerProvider).dispatch(RoutingIntents.studyRecruit(model.studyId)))
                .then((value) => Future.delayed(const Duration(milliseconds: 200),
                    () => ref.read(notificationServiceProvider).show(Notifications.StudyTagDeleted)));
          },
          isAvailable: study.isOwner(authRepository.currentUser!),
          isDestructive: true),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }*/

  @override
  emitUpdate() {
    print("StudyTagRepository.emitUpdate");
    super.emitUpdate();
  }
}

class StudyTagRepositoryDelegate extends IModelRepositoryDelegate<StudyTag> {
  StudyTagRepositoryDelegate({
    required this.study,
    required this.apiClient,
    required this.studyRepository,
  });

  final Study study;
  final StudyUApi apiClient;
  final IStudyRepository studyRepository;

  @override
  Future<StudyTag> fetch(ModelID modelId) {
    return Future.value(study.studyTags.firstWhere((element) => element.id == modelId));
  }

  @override
  Future<List<StudyTag>> fetchAll() {
    return Future.value(study.studyTags);
  }

  @override
  Future<StudyTag> save(StudyTag model) async {
    final saveOperation = OptimisticUpdate(
      applyOptimistic: () {
        final idx = study.studyTags.indexWhere((i) => i.id == model.id);
        if (idx == -1) {
          study.studyTags.add(model);
        } else {
          study.studyTags[idx] = model;
        }
        studyRepository.upsertLocally(study);
      },
      apply: () async {
        //await studyRepository.ensurePersisted(model.id);
        await apiClient.saveStudyTag(model);
      },
      rollback: () {
        study.studyTags.remove(model);
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
  Future<void> delete(StudyTag model) {
    final prevStudyTags = [...study.studyTags];
    final deleteOperation = OptimisticUpdate(
      applyOptimistic: () {
        study.studyTags.remove(model);
        studyRepository.upsertLocally(study);
      },
      apply: () => apiClient.deleteStudyTag(model),
      rollback: () {
        study.studyTags = prevStudyTags;
        studyRepository.upsertLocally(study);
      },
      onUpdate: studyRepository.emitUpdate,
      rethrowErrors: true,
    );

    return deleteOperation.execute();
  }

  @override
  onError(Object error, StackTrace? stackTrace) {
    return; // TODO
  }

  @override
  StudyTag createDuplicate(StudyTag model) {
    throw UnimplementedError(); // not available
  }

  @override
  StudyTag createNewInstance() {
    throw UnimplementedError(); // not available
  }
}

final studyTagRepositoryProvider = Provider.autoDispose.family<IStudyTagRepository, StudyID>((ref, studyId) {
  print("studyTagRepositoryProvider($studyId");
  // Initialize repository for a given study
  final repository = StudyTagRepository(
    studyId: studyId,
    apiClient: ref.watch(apiClientProvider),
    authRepository: ref.watch(authRepositoryProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    ref: ref,
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    print("studyTagRepositoryProvider($studyId.DISPOSE");
    repository.dispose();
  });
  return repository;
});
