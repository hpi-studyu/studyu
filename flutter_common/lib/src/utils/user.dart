import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const fakeStudyUEmailDomain = 'fake-studyu-email-domain.com';
String selectedSubjectIdKey = 'selected_study_object_id';
const userEmailKey = 'user_email';
const userPasswordKey = 'user_password';
const cacheSubjectKey = "cache_subject";

Future<void> storeFakeUserEmailAndPassword(String email, String password) async {
  final prefs = await SharedPreferences.getInstance();
  prefs
    ..setString(userEmailKey, email)
    ..setString(userPasswordKey, password);
}

Future<bool> signInParticipant() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(userEmailKey) && prefs.containsKey(userPasswordKey)) {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: await getFakeUserEmail(),
        password: (await getFakeUserPassword())!,
      );
      if (Supabase.instance.client.auth.currentSession != null) {
        return true;
      }
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
    }
  }
  return false;
}

// Using a fake user email to enable anonymous users, while working with row-level security on postgres
Future<bool> anonymousSignUp() async {
  final fakeUserEmail = '${const Uuid().v4()}@$fakeStudyUEmailDomain';
  final fakeUserPassword = const Uuid().v4();
  try {
    await Supabase.instance.client.auth.signUp(email: fakeUserEmail, password: fakeUserPassword);
    await storeFakeUserEmailAndPassword(fakeUserEmail, fakeUserPassword);
    return signInParticipant();
  } catch (error, stacktrace) {
    SupabaseQuery.catchSupabaseException(error, stacktrace);
    return false;
  }
}

Future<String?> getFakeUserEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(userEmailKey);
}

Future<String?> getFakeUserPassword() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(userPasswordKey);
}

bool isUserLoggedIn() {
  return Supabase.instance.client.auth.currentSession != null;
}

Future<String?> getActiveSubjectId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(selectedSubjectIdKey);
}

Future<void> storeActiveSubjectId(String studyObjectId) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(selectedSubjectIdKey, studyObjectId);
}

Future<void> deleteActiveStudyReference() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(selectedSubjectIdKey);
}

Future<void> deleteLocalData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(userEmailKey);
  await prefs.remove(userPasswordKey);
  await prefs.remove(selectedSubjectIdKey);
  await prefs.remove(cacheSubjectKey);
}

void previewSubjectIdKey() {
  selectedSubjectIdKey = 'preview_$selectedSubjectIdKey';
}
