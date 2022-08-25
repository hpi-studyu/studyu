import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/app_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

import 'auth_formfield_views.dart';
import 'auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends AuthState<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return const PageContent();
  }
}

class PageContent extends ConsumerStatefulWidget {
  const PageContent({Key? key}) : super(key: key);

  @override
  _PageContentState createState() => _PageContentState();
}

class _PageContentState extends ConsumerState<PageContent> {
  late FormGroup authForm;

  @override
  void initState() {
    super.initState();
    authForm = ref.read(authFormControlProvider('signup'))!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Center(
              child: Text(tr.signup, style: Theme.of(context).textTheme.headlineLarge /*style: FlutterFlowTheme.of(context).title1,)*/)
          ),
          const SizedBox(height: 20),
          const EmailTextField(),
          const PasswordTextField(),
          // todo labelText is .hardcoded
          const PasswordTextField(formControlName: 'passwordConfirmation', labelText: "Password Confirmation",),
          _tosWidget(),
          const SizedBox(height: 20),
          ReactiveFormConsumer(
            builder: (context, formN, child) {
              final authState = ref.watch(authControllerProvider);
              return PrimaryButton(
                icon: Icons.add,
                text: tr.create_account,
                isLoading: authState.isLoading,
                enabled: authForm.valid,
                onPressedFuture: () => _formReturnAction(),
                tooltipDisabled: authForm.control('termsOfService').value ? 'All fields must be filled out' : 'Terms of use and privacy policy need to be accepted',
              );
            },
          ),
        ]
    );
  }

  Widget _tosWidget() {
    final appConfig = ref.watch(appConfigProvider);
    final locale = ref.watch(localeProvider);
    appConfig.maybeWhen(data: (value) => print(value.contact), orElse: () => print("null"));
    return ReactiveCheckboxListTile(
      formControlName: 'termsOfService',
      //onChanged: (val) => authForm.control('termsOfService').value = val.value,
      title: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.titleMedium,
          children: [
            const TextSpan(
              text: 'I have read and accept the ',
            ),
            TextSpan(
              text: 'terms of use',
              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () { launchUrl(appConfig.maybeWhen(data: (value) => Uri.parse(value.designerTerms[locale.languageCode] ?? ""), orElse: () => Uri.parse(''))); },
            ),
            const TextSpan(
              text: ' and ',
            ),
            TextSpan(
              text: 'privacy policy',
              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () { launchUrl(appConfig.maybeWhen(data: (value) => Uri.parse(value.designerPrivacy[locale.languageCode] ?? ""), orElse: () => Uri.parse(''))); },
            ),
            const TextSpan(
              text: ' ', // Prevent clickable area stretching
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _formReturnAction() async {
    final authController = ref.watch(authControllerProvider.notifier);
    await authController.signUp(authForm.control('email').value, authForm.control('password').value);
  }
}
