import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class UserQueries {
  static const selectedStudyObjectIdKey = 'selected_study_object_id';

  static Future<bool> isUserLoggedIn() async {
    return (await ParseUser.currentUser()) != null;
  }

  static Future<ParseUser> getOrCreateUser() async {
    ParseUser currentUser = await ParseUser.currentUser();

    if (currentUser == null) {
      final response = await ParseUser(null, null, null).loginAnonymous(doNotSendInstallationID: true);
      if (response.success) {
        currentUser = response.result;
      }
    }
    return currentUser;
  }

  static Future<void> logout() async {
    final ParseUser currentUser = await ParseUser.currentUser();
    currentUser.logout();
  }

  static Future<void> deleteUserAccount() async {
    final ParseUser currentUser = await ParseUser.currentUser();
    currentUser
      ..delete()
      ..logout();
  }
}
