// ignore_for_file: join_return_with_assignment

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

part 'user_repository.g.dart';

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
  });

  final StudyUApi apiClient;
  final IAuthRepository authRepository;
  final Ref ref;
  StudyUUser? _user;
  @override
  StudyUUser get user => _user!;

  @override
  Future<StudyUUser> fetchUser() async {
    if (_user != null) return user;
    final userId = ref.read(authRepositoryProvider).currentUser!.id;
    _user = await apiClient.fetchUser(userId);
    return user;
  }

  @override
  Future<StudyUUser> saveUser() async {
    _user = await apiClient.saveUser(user);
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

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository(
    authRepository: ref.watch(authRepositoryProvider),
    apiClient: ref.watch(apiClientProvider),
    ref: ref,
  );
}
