import 'package:parse_server_sdk/parse_server_sdk.dart';

class UserQueries {
  static const selectedStudyObjectIdKey = 'selected_study_object_id';

  static Future<bool> isUserLoggedIn() async {
    return (await ParseUser.currentUser()) != null;
  }

  static Future<ParseUser> getOrCreateUser() async {
    ParseUser currentUser = await ParseUser.currentUser();

    if (currentUser == null) {
      final response = await ParseUser(null, null, null).loginAnonymous();
      if (response.success) {
        currentUser = response.result;
      }
    }
    return currentUser;
  }

  static Future<void> logout() async {
    final ParseUser currentUser = await ParseUser.currentUser();
    currentUser.logout(deleteLocalUserData: true);
  }

  static Future<void> deleteUserAccount() async {
    final ParseUser currentUser = await ParseUser.currentUser();
    currentUser.delete();
    currentUser.logout(deleteLocalUserData: true);
  }
}
