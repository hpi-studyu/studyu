import 'package:flutter_test/flutter_test.dart';

class AppRobot {
  const AppRobot(this.tester);

  final WidgetTester tester;

  Future<void> validateOnSplashScreen() async {
    expect(find.text('Loading...'), findsOneWidget);
  }

  Future<void> validateOnAuthScreen() async {
    expect(find.text('Learn'), findsOneWidget);
  }
}