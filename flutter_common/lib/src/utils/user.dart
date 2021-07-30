import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UserQueries {
  static const fakeStudyUEmailDomain = 'fake-studyu-email-domain.com';
  static const selectedSubjectIdKey = 'selected_study_object_id';
  static const userEmailKey = 'user_email';
  static const userPasswordKey = 'user_password';

  static Future<void> storeFakeUserEmailAndPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs
      ..setString(userEmailKey, email)
      ..setString(userPasswordKey, password);
  }

  static Future<bool> signInParticipant() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(userEmailKey) && prefs.containsKey(userPasswordKey)) {
      final res = await Supabase.instance.client.auth
          .signIn(email: await getFakeUserEmail(), password: await getFakeUserPassword());
      if (res.error == null && Supabase.instance.client.auth.session() != null) {
        return true;
      }
      print(res.error!.message);
    }
    return false;
  }

  // Using a fake user email to enable anonymous users, while working with row-level security on postgres
  static Future<bool> anonymousSignUp() async {
    final fakeUserEmail = '${Uuid().v4()}@$fakeStudyUEmailDomain';
    final fakeUserPassword = Uuid().v4();
    final res = await Supabase.instance.client.auth.signUp(fakeUserEmail, fakeUserPassword);

    if (res.error == null) {
      await storeFakeUserEmailAndPassword(fakeUserEmail, fakeUserPassword);
      return await signInParticipant();
    }
    return false;
  }

  static Future<String?> getFakeUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getFakeUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPasswordKey);
  }

  static bool isUserLoggedIn() {
    return Supabase.instance.client.auth.session() != null;
  }

  static Future<String?> getActiveSubjectId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedSubjectIdKey);
  }

  static Future<void> storeActiveSubjectId(String studyObjectId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(selectedSubjectIdKey, studyObjectId);
  }

  static Future<void> deleteActiveStudyReference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(selectedSubjectIdKey);
  }

  static Future<void> deleteLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userEmailKey);
    await prefs.remove(userPasswordKey);
    await prefs.remove(selectedSubjectIdKey);
  }
}
