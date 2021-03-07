import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class UserQueries {
  static const selectedStudyObjectIdKey = 'selected_study_object_id';

  static Future<bool> isUserLoggedIn() async {
    return (await ParseUser.currentUser()) != null;
  }

  static Future<ParseUser> getOrCreateUser() async {
    ParseUser currentUser = await ParseUser.currentUser() as ParseUser;

    if (currentUser == null) {
      final response = await ParseUser(null, null, null).loginAnonymous(doNotSendInstallationID: true);
      if (response.success) {
        currentUser = response.result as ParseUser;
      }
    }
    return currentUser;
  }

  static Future<void> logout() async {
    (await ParseUser.currentUser() as ParseUser).logout();
  }

  static Future<void> deleteUserAccount() async {
    (await ParseUser.currentUser() as ParseUser)
      ..delete()
      ..logout();
  }
}
