import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

class AuthController extends StateNotifier<AsyncValue<String>> {

  /// Reference to the auth repository injected by Riverpod
  final IAuthRepository authRepository;

  AuthController({required this.authRepository}) : super(const AsyncValue.data(''));

  Future<void> signUp(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.signUp(email: email, password: password);
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {
      state = AsyncValue.data("Signup successful".hardcoded);
    }
  }

  Future<void> signInWith(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.signInWith(email: email, password: password);
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {
      state = const AsyncValue.data('');
    }
  }

  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.signOut();
    } catch (e) {
      state = AsyncValue.error(e);
    }
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.resetPasswordForEmail(email: email);
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {

      state = AsyncValue.data('Reset password email sent'.hardcoded);
    }
  }

  Future<void> updateUser(String newPassword) async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.updateUser(newPassword: newPassword);
    } catch (e) {
      state = AsyncValue.error(e);
    } finally {
      state = AsyncValue.data('Reset password successful'.hardcoded);
    }
  }
}

final authControllerProvider = StateNotifierProvider.autoDispose<AuthController, AsyncValue<String>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});