import 'package:rxdart/subjects.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

abstract class IAuthRepository {
  // - Authentication
  User? get currentUser;
  bool get isLoggedIn;
  Stream<User?> watchAuthStateChanges();
  Future<void> signInWith({required String email, required String password});
  Future<void> signOut();
  // - Lifecycle
  void dispose();
}

class AuthRepository implements IAuthRepository {
  /// A reference to the Supabase API client injected via Riverpod
  final SupabaseClient supabaseClient;

  /// A stream controller for broadcasting the currently logged in user
  /// Broadcasts null if the user is logged out
  final BehaviorSubject<User?> _authStateStreamController = BehaviorSubject.seeded(null);

  /// Private subscription for synchronizing with [SupabaseClient] auth state
  late final GotrueSubscription _authSubscription;

  AuthRepository({required this.supabaseClient}) {
    _registerAuthListener();
  }

  /// Register as a listener on [SupabaseClient] to re-expose auth state
  /// changes on the repository's stream
  void _registerAuthListener() {
    _authSubscription = supabaseClient.auth.onAuthStateChange((event, session) {
      switch (event) {
        case AuthChangeEvent.signedIn:
          // Update stream with logged in user
          _authStateStreamController.add(supabaseClient.auth.currentUser);
          break;
        case AuthChangeEvent.signedOut:
          // Send null to indicate that no user is available (logged out)
          _authStateStreamController.add(null);
          break;
        case AuthChangeEvent.userUpdated:
          // Update stream with new user object
          _authStateStreamController.add(supabaseClient.auth.currentUser);
          break;
        case AuthChangeEvent.passwordRecovery:
          break; // don't care
        case AuthChangeEvent.tokenRefreshed:
          break; // don't care
      }
    });
  }

  @override
  User? get currentUser => _authStateStreamController.value;

  @override
  bool get isLoggedIn => currentUser != null;

  @override
  Stream<User?> watchAuthStateChanges() => _authStateStreamController.stream;

  @override
  Future<void> signInWith({required String email, required String password}) async {
    final res = await supabaseClient.auth.signIn(
        email: email, password: password);
    if (res.error != null) {
      // TODO propagate error to controller / UI
      print("login error");
    }
  }

  @override
  Future<void> signOut() async {
    final res = await supabaseClient.auth.signOut();
    if (res.error != null) {
      // TODO propagate error to controller / UI
      print("logout error");
    }
  }

  @override
  void dispose() {
    _authStateStreamController.close();
  }
}

final authRepositoryProvider = riverpod.Provider<IAuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final authRepository = AuthRepository(supabaseClient: supabaseClient);
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    authRepository.dispose();
  });
  return authRepository;
});
