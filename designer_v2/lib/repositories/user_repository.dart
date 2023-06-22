import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

abstract class IUserRepository {
  Future<StudyUUser> fetchUser();
  Future<StudyUUser> saveUser(StudyUUser user);
  Preferences fetchPreferences();
  Future<StudyUUser> savePreferences(Preferences preferences);
  void dispose();
}

class UserRepository implements IUserRepository {
  UserRepository(this.apiClient, this.ref);

  final StudyUApi apiClient;
  final Ref ref;
  late StudyUUser user;

  @override
  Future<StudyUUser> fetchUser() async {
    final userId = ref.read(authRepositoryProvider).currentUser!.id;
    user = await apiClient.fetchUser(userId);
    return user;
  }

  @override
  Future<StudyUUser> saveUser(StudyUUser saveUser) async {
    user = await apiClient.saveUser(saveUser);
    return user;
  }

  @override
  Preferences fetchPreferences() {
    return user.preferences;
  }

  @override
  Future<StudyUUser> savePreferences(Preferences preferences) async {
    user.preferences = preferences;
    return await saveUser(user);
  }

  @override
  void dispose() {}
}

final userProvider = FutureProvider.autoDispose<UserRepository>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final userRepository = UserRepository(apiClient, ref);
  await userRepository.fetchUser();
  return userRepository;
});
