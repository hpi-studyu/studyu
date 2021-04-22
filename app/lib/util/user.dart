import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyou_core/env.dart' as env;
import 'package:uuid/uuid.dart';

class UserQueries {
  static const fakeStudyUEmailDomain = 'fake-studyu-email-domain.com';
  static const selectedStudyObjectIdKey = 'selected_study_object_id';
  static const userEmailKey = 'user_email';
  static const userPasswordKey = 'user_password';
  static const sessionKey = 'session';

  static Future<void> storeFakeUserEmailAndPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs..setString(userEmailKey, email)..setString(userPasswordKey, password);
  }

  static Future<void> storeSession(String session) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(sessionKey, session);
  }

  static Future<bool> recoverSession() async {
    final prefs = await SharedPreferences.getInstance();
    final res = await env.client.auth.recoverSession(prefs.getString(sessionKey));

    if (res.error == null && env.client.auth.session() != null) {
      storeSession(env.client.auth.session().persistSessionString);
      return true;
    }
    return false;
  }

  // Using a fake user email to enable anonymous users, while working with row-level security on postgres
  static Future<bool> anonymousSignUp() async {
    final fakeUserEmail = '${Uuid().v4()}@$fakeStudyUEmailDomain';
    final fakeUserPassword = Uuid().v4();
    final res = await env.client.auth.signUp(fakeUserEmail, fakeUserPassword);

    if (res.error == null && env.client.auth.session() != null) {
      storeSession(env.client.auth.session().persistSessionString);
      storeFakeUserEmailAndPassword(fakeUserEmail, fakeUserPassword);
      return true;
    }
    return false;
  }

  static Future<String> getFakeUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String> getFakeUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPasswordKey);
  }

  /// Generated after user accepts terms & conditions and is signed up with fake anonymous account
  static bool isUserLoggedIn() {
    return env.client.auth.user() != null && env.client.auth.user().id != null;
  }

  static Future<String> getActiveStudyObjectId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedStudyObjectIdKey);
  }

  static Future<void> storeActiveUserStudyId(String studyObjectId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(selectedStudyObjectIdKey, studyObjectId);
  }

  static Future<void> deleteActiveStudyReference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(selectedStudyObjectIdKey);
  }

  static Future<void> deleteLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userEmailKey);
    await prefs.remove(userPasswordKey);
    await prefs.remove(sessionKey);
    await prefs.remove(selectedStudyObjectIdKey);
  }
}
