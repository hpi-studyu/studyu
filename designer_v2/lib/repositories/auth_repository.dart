import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';
import 'package:studyu_designer_v2/utils/behaviour_subject.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';
import 'package:studyu_designer_v2/utils/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:studyu_core/env.dart' as env;

abstract class IAuthRepository extends IAppDelegate {
  // - Authentication
  User? get currentUser;
  bool get isLoggedIn;
  Session? get session;
  late bool allowPasswordReset = false;
  Stream<User?> watchAuthStateChanges({bool emitLastEvent});
  Future<bool> signUp({required String email, required String password});
  Future<bool> signInWith({required String email, required String password});
  Future<void> signOut();
  Future<bool> resetPasswordForEmail({required String email});
  Future<bool> updateUser({required String newPassword});
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
  final BehaviorSubject<User?> _authStateStreamController =
      BehaviorSubject.seeded(null);
  late final _authStateSuppressedController =
      SuppressedBehaviorSubject(_authStateStreamController);

  /// Private subscription for synchronizing with [SupabaseClient] auth state
  late final GotrueSubscription _authSubscription;

  GoTrueClient get authClient => supabaseClient.auth;

  @override
  Session? get session => authClient.session();

  AuthRepository({
    required this.supabaseClient,
    required this.sharedPreferences,
  }) {
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
          //router.dispatch(RoutingIntents.passwordRecovery);
          allowPasswordReset = true;
          break;
        case AuthChangeEvent.tokenRefreshed:
          _persistSession();
          break;
      }
    });
  }

  @override
  bool allowPasswordReset = false;

  @override
  User? get currentUser => _authStateStreamController.value;

  @override
  bool get isLoggedIn => currentUser != null;

  @override
  Stream<User?> watchAuthStateChanges({emitLastEvent = true}) =>
      (emitLastEvent)
          ? _authStateStreamController.stream
          : _authStateSuppressedController.stream;

  @override
  Future<bool> signUp({required String email, required String password}) async {
    final res = await authClient.signUp(email, password);
    if (res.error != null) {
      throw StudyUException(res.error!.message);
    }
    return true;
  }

  @override
  Future<bool> signInWith(
      {required String email, required String password}) async {
    final res = await authClient.signIn(email: email, password: password);
    if (res.error != null) {
      throw StudyUException(res.error!.message);
    }
    return true;
  }

  @override
  Future<bool> signOut() async {
    final res = await authClient.signOut();
    if (res.error != null) {
      throw StudyUException(res.error!.message);
    }
    return true;
  }

  @override
  Future<bool> resetPasswordForEmail({required String email}) async {
    final res = await authClient.api.resetPasswordForEmail(email,
        options: AuthOptions(redirectTo: env.designerUrl));
    if (res.error != null) {
      throw StudyUException(res.error!.message);
    }
    return true;
  }

  @override
  Future<bool> updateUser({required String newPassword}) async {
    if (session != null) {
      final res = await authClient.api.updateUser(
          session!.accessToken, UserAttributes(password: newPassword));
      if (res.error != null) {
        throw StudyUException(res.error!.message);
      }
      return true;
    }
    return false;
  }

  Future<void> _persistSession() async {
    if (session != null) {
      sharedPreferences.setString(
          PERSIST_SESSION_KEY, session!.persistSessionString);
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
    _authStateSuppressedController.close();
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
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    authRepository.dispose();
  });
  return authRepository;
});

final currentUserProvider = riverpod.Provider<User?>((ref) {
  print("currentUserProvider");
  final authRepository = ref.watch(authRepositoryProvider);
  authRepository
      .watchAuthStateChanges(emitLastEvent: false)
      .listen((event) {
    print("currentUserProvider.dispose");
    ref.invalidateSelf();
  });
  return authRepository.currentUser;
});
