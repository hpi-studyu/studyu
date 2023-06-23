import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

abstract class IUserRepository {
  StudyUUser get user;
  Future<StudyUUser> fetchUser();
  Future<StudyUUser> saveUser();
  void dispose();
}

class UserRepository implements IUserRepository {
  UserRepository(this.apiClient, this.ref);

  final StudyUApi apiClient;
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
  void dispose() {}
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final userRepository = UserRepository(apiClient, ref);
  return userRepository;
});
