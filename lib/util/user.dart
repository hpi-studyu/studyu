import 'package:parse_server_sdk/parse_server_sdk.dart';

class UserUtils {

  static const selectedStudyObjectIdKey = 'selected_study_object_id';

  static Future<bool> isUserLoggedIn() async {
    return (await ParseUser.currentUser()) != null;
  }

  static Future<ParseUser> getOrCreateUser() async {
    var currentUser = await ParseUser.currentUser() as ParseUser;

    if (currentUser == null) {
      final response = await ParseUser(null, null, null).loginAnonymous();
      if (response.success) {
        currentUser = response.result;
      }
    }
    return currentUser;
  }

  static void logout() async {
    final currentUser = await ParseUser.currentUser() as ParseUser;
    currentUser.logout(deleteLocalUserData: true);
  }
}
