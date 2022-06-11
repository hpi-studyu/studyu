import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String name;
  final String email;

  const User({required this.name, required this.email});
}

class UserState extends StateNotifier<User?> {
  UserState() : super(null);

  Future<void> login(String email, String password) async {
    // This mocks some sort of request / response
    state = User(
      name: email,
      email: password,
    );
  }

  Future<void> logout() async {
    // In this example user==null if we're logged out
    state = null; // No request is mocked here but I guess we could
  }
}

final userProvider = StateNotifierProvider<UserState, User?>((ref) {
  return UserState();
});