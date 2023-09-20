import 'package:flutter_test/flutter_test.dart';

class StudiesRobot {
  const StudiesRobot(this.tester);

  final WidgetTester tester;

  Future<void> validateOnStudiesScreen() async {
    expect(find.text('My Studies'), findsWidgets); 
  }

  Future<void> tapSignOutButton() async {
    await tester.tap(find.text('Sign out'));
  }
}