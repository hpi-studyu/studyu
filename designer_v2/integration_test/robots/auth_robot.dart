import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';

class AuthRobot {
  const AuthRobot(this.tester);

  final WidgetTester tester;

  Future<void> enterEmail(String email) async {
    await tester.enterText(find.widgetWithText(ReactiveTextField, 'Email'), email);
  }

  Future<void> enterPassword(String password) async {
    await tester.enterText(find.widgetWithText(ReactiveTextField, 'Password'), password);
  }

  Future<void> enterPasswordConfirmation(String password) async {
    await tester.enterText(find.widgetWithText(ReactiveTextField, 'Confirm password'), password);
  }

  Future<void> tapTermsCheckbox() async {
    await tester.tap(find.byType(ReactiveCheckbox));
  }

  Future<void> tapSignInButton() async {
    await tester.tap(find.widgetWithText(PrimaryButton, 'Sign in'));
  }

  Future<void> tapSignUpButton() async {
    await tester.tap(find.widgetWithText(PrimaryButton, 'Create account'));
  }

  Future<void> navigateToSignUpScreen() async {
    await tester.tap(find.text('Sign up'));
  } 
}