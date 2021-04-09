import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserQueries {
  static const selectedStudyObjectIdKey = 'selected_study_object_id';
  static const userIdKey = 'user_id';

  static Future<void> generateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(userIdKey, Uuid().v4());
  }

  static Future<String> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  /// Generated after user accepts terms & conditions
  static Future<bool> isUserIdPresent() async {
    return (await loadUserId()) != null;
  }

  static Future<String> loadActiveStudyObjectId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedStudyObjectIdKey);
  }

  static Future<void> saveActiveUserStudyId(String studyObjectId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(selectedStudyObjectIdKey, studyObjectId);
  }

  static Future<void> deleteActiveStudyReference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(selectedStudyObjectIdKey);
  }

  static Future<void> deleteLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
    await prefs.remove(selectedStudyObjectIdKey);
  }
}
