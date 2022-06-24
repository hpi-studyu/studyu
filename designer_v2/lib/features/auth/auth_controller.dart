import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

class AuthController extends StateNotifier<void> {
  static const initialState = null;

  /// Reference to the auth repository injected by Riverpod
  final IAuthRepository authRepository;

  AuthController({required this.authRepository}) : super(initialState);

  Future<void> signInWith(String email, String password) async {
    return await authRepository.signInWith(email: email, password: password);
  }

  Future<void> signOut() async{
    return await authRepository.signOut();
  }
}

final authControllerProvider = StateNotifierProvider.autoDispose<AuthController, void>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});