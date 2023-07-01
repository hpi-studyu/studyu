import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

// todo implements ModelRepository<StudyUUser>
abstract class IUserRepository {
  StudyUUser get user;
  Future<StudyUUser> fetchUser();
  Future<StudyUUser> saveUser();
}

class UserRepository implements IUserRepository {
  UserRepository(
      {required this.authRepository,
      required this.apiClient,
      required this.ref}); //: super(UserRepositoryDelegate(apiClient: apiClient));

  final StudyUApi apiClient;
  final IAuthRepository authRepository;
  final Ref ref;
  @override
  late StudyUUser user;

  @override
  Future<StudyUUser> fetchUser() async {
    final userId = ref.read(authRepositoryProvider).currentUser!.id;
    user = await apiClient.fetchUser(userId);
    return user;
  }

  @override
  Future<StudyUUser> saveUser() async {
    user = await apiClient.saveUser(user);
    return user;

    /*final saveOperation = OptimisticUpdate(
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
        await studyRepository.ensurePersisted(model.id);
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

    return saveOperation.execute().then((_) => model);*/
  }
}

/*class UserRepositoryDelegate extends IModelRepositoryDelegate<StudyUUser> {
  UserRepositoryDelegate({ required this.apiClient }) {
    throw UnimplementedError();
  }

  final StudyUApi apiClient;

  @override
  Future<StudyUUser> fetch(ModelID modelId) {
    return Future.value(study.studyTags.firstWhere((element) => element.id == modelId));
  }

  @override
  Future<StudyUUser> save(StudyUUser model) async {
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
  Future<void> delete(StudyUUser model) {
    throw UnimplementedError();
  }

  @override
  onError(Object error, StackTrace? stackTrace) {
    return;
  }

  @override
  StudyUUser createDuplicate(StudyUUser model) {
    throw UnimplementedError(); // not available
  }

  @override
  StudyUUser createNewInstance() {
    throw UnimplementedError(); // not available
  }

  @override
  Future<List<StudyUUser>> fetchAll() {
    throw UnimplementedError(); // not available
  }
}*/

final userRepositoryProvider = Provider.autoDispose((ref) {
  print("userRepositoryProvider");
  final apiClient = ref.watch(apiClientProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return UserRepository(apiClient: apiClient, ref: ref, authRepository: authRepository);
});
