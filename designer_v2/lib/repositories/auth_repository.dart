import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

abstract class IAuthRepository extends IAppDelegate {
  // - Authentication
  User? get currentUser;
  bool get isLoggedIn;
  Stream<User?> watchAuthStateChanges();
  Future<void> signInWith({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPasswordForEmail({required String email});
  // - Lifecycle
  void dispose();
}

class AuthRepository implements IAuthRepository {
  /// The key used for persisting the user session in local storage
  static const PERSIST_SESSION_KEY = 'auth/session';

  /// Reference to the Supabase API client injected via Riverpod
  final SupabaseClient supabaseClient;

  /// Reference to shared preferences used for session storage
  final SharedPreferences sharedPreferences;

  /// A stream controller for broadcasting the currently logged in user
  /// Broadcasts null if the user is logged out
  final BehaviorSubject<User?> _authStateStreamController = BehaviorSubject
      .seeded(null);

  /// Private subscription for synchronizing with [SupabaseClient] auth state
  late final GotrueSubscription _authSubscription;

  GoTrueClient get authClient => supabaseClient.auth;

  Session? get session => authClient.session();

  AuthRepository({
    required this.supabaseClient,
    required this.sharedPreferences}) {
    _registerAuthListener();
  }

  /// Register as a listener on [SupabaseClient] to re-expose auth state
  /// changes on the repository's stream
  void _registerAuthListener() {
    _authSubscription = authClient.onAuthStateChange((event, session) {
      switch (event) {
        case AuthChangeEvent.signedIn:
        // Update stream with logged in user
          _authStateStreamController.add(authClient.currentUser);
          _persistSession();
          break;
        case AuthChangeEvent.signedOut:
        // Send null to indicate that no user is available (logged out)
          _authStateStreamController.add(null);
          _resetPersistedSession();
          break;
        case AuthChangeEvent.userUpdated:
        // Update stream with new user object
          _authStateStreamController.add(authClient.currentUser);
          _persistSession();
          break;
        case AuthChangeEvent.passwordRecovery:
          break; // don't care
        case AuthChangeEvent.tokenRefreshed:
          _persistSession();
          break;
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
  Future<void> signInWith(
      {required String email, required String password}) async {
    final res = await authClient.signIn(
        email: email, password: password);
    if (res.error != null) {
      // TODO propagate error to controller / UI
      print("login error");
    }
  }

  @override
  Future<void> signOut() async {
    final res = await authClient.signOut();
    if (res.error != null) {
      // TODO propagate error to controller / UI
      print("logout error");
    }
  }

  @override
  Future<void> resetPasswordForEmail({required String email}) async {
    final res = await authClient.api.resetPasswordForEmail(email);
    if (res.error != null) {
      // TODO propagate error to controller / UI
      print("reset password error");
    }
  }

  Future<void> _persistSession() async {
    if (session != null) {
      sharedPreferences.setString(
          PERSIST_SESSION_KEY, session!.persistSessionString
      );
      debugLog("Saving session key ${session!.persistSessionString}");
    }
  }

  Future<void> _resetPersistedSession() async {
    if (sharedPreferences.containsKey(PERSIST_SESSION_KEY)) {
      sharedPreferences.remove(PERSIST_SESSION_KEY);
    }
    debugLog("Reset session key");
  }

  Future<bool> _recoverSession() async {
    if (!sharedPreferences.containsKey(PERSIST_SESSION_KEY)) {
      return false;
    }
    final jsonStr = sharedPreferences.getString(PERSIST_SESSION_KEY)!;
    final response = await authClient.recoverSession(jsonStr);
    if (response.error != null) {
      debugLog('Failed to recover user session: ${response.error.toString()}');
      return false;
    }
    debugLog('Hydrated user session: ${response.user ?? 'None'}');
    return true;
  }

  @override
  void dispose() {
    _authStateStreamController.close();
  }

  // - IAppDelegate

  @override
  Future<bool> onAppStart() async {
    await _recoverSession();
    return true;
  }
}

final authRepositoryProvider = riverpod.Provider<IAuthRepository>((ref) {
  final authRepository = AuthRepository(
      supabaseClient: ref.watch(supabaseClientProvider),
      sharedPreferences: ref.watch(sharedPreferencesProvider)
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    authRepository.dispose();
  });
  return authRepository;
});
