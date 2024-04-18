import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:studyu_flutter_common/studyu_flutter_common.dart';

const fakeStudyUEmailDomain = 'fake-studyu-email-domain.com';
String selectedSubjectIdKey = 'selected_study_object_id';
const userEmailKey = 'user_email';
const userPasswordKey = 'user_password';
const cacheSubjectKey = "cache_subject";

Future<void> storeFakeUserEmailAndPassword(String email, String password) async {
  SecureStorage.write(userEmailKey, email);
  SecureStorage.write(userPasswordKey, password);
}

Future<bool> signInParticipant() async {
  if (await SecureStorage.containsKey(userEmailKey) && await SecureStorage.containsKey(userPasswordKey)) {
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
  return SecureStorage.read(userEmailKey);
}

Future<String?> getFakeUserPassword() async {
  return SecureStorage.read(userPasswordKey);
}

bool isUserLoggedIn() {
  return Supabase.instance.client.auth.currentSession != null;
}

Future<String?> getActiveSubjectId() async {
  return SecureStorage.read(selectedSubjectIdKey);
}

Future<void> storeActiveSubjectId(String studyObjectId) async {
  SecureStorage.write(selectedSubjectIdKey, studyObjectId);
}

Future<void> deleteActiveStudyReference() async {
  await SecureStorage.delete(selectedSubjectIdKey);
}

Future<void> deleteLocalData() async {
  await SecureStorage.delete(userEmailKey);
  await SecureStorage.delete(userPasswordKey);
  await SecureStorage.delete(selectedSubjectIdKey);
  await SecureStorage.delete(cacheSubjectKey);
}

void previewSubjectIdKey() {
  selectedSubjectIdKey = 'preview_$selectedSubjectIdKey';
}
