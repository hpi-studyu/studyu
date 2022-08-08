import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {

  /// Reference to the auth repository injected by Riverpod
  final IAuthRepository authRepository;

  AuthController({required this.authRepository}) : super(const AsyncValue.data(null));

  Future<bool> signUp(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.signUp(email: email, password: password);
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {
      state = const AsyncValue.data(null);
    }
    return false;
  }

  Future<bool> signInWith(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await authRepository.signInWith(email: email, password: password);
      return true;
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {
      state = const AsyncValue.data(null);
    }
    return false;
  }

  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();
      return authRepository.signOut();
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<bool> resetPasswordForEmail(String email) async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.resetPasswordForEmail(email: email);
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {
      state = const AsyncValue.data(null);
    }
    return false;
  }

  Future<bool> updateUser(String newPassword) async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.updateUser(newPassword: newPassword);
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {
      state = const AsyncValue.data(null);
    }
    return false;
  }
}

final authControllerProvider = StateNotifierProvider.autoDispose<AuthController, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});