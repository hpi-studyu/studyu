// ignore_for_file: join_return_with_assignment

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

// todo implements ModelRepository<StudyUUser>
abstract class IUserRepository {
  StudyUUser get user;
  Future<StudyUUser> fetchUser();
  Future<StudyUUser> saveUser();
  Future<StudyUUser> updatePreferences(
    PreferenceAction pinAction,
    String modelId,
  );
}

enum PreferenceAction { pin, pinOff }

class UserRepository implements IUserRepository {
  UserRepository({
    required this.authRepository,
    required this.apiClient,
    required this.ref,
  }); //: super(UserRepositoryDelegate(apiClient: apiClient));

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
  }

  @override
  Future<StudyUUser> updatePreferences(
    PreferenceAction pinAction,
    String modelId,
  ) async {
    final newPinnedStudies = Set<String>.from(user.preferences.pinnedStudies);
    switch (pinAction) {
      case PreferenceAction.pin:
        newPinnedStudies.add(modelId);
      case PreferenceAction.pinOff:
        newPinnedStudies.remove(modelId);
    }
    user.preferences.pinnedStudies = newPinnedStudies;
    return saveUser();
  }
}

final userRepositoryProvider = Provider.autoDispose((ref) {
  print("userRepositoryProvider");
  final apiClient = ref.watch(apiClientProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return UserRepository(
    apiClient: apiClient,
    ref: ref,
    authRepository: authRepository,
  );
});
