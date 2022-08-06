import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

import 'package:url_launcher/url_launcher.dart';

import 'form_widgets.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {

  late TextEditingController emailController;
  late TextEditingController passwordController;
  late bool isFormValid;
  late bool tosAgreement;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    tosAgreement = false;
    isFormValid = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(
      authControllerProvider,
          (_, state) => state.showResultUI(context),
    );
    return _formWidget();
  }

  Widget _tosWidget() {
    return CheckboxListTile(
      value: tosAgreement,
      onChanged: (newValue) =>
          setState(() {
            tosAgreement = newValue!;
          }),
      title: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'I have read and accept the ',
            ),
            TextSpan(
              text: 'terms of use',
              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () { launchUrl(Uri.parse('https://www13.hpi.uni-potsdam.de/fileadmin/user_upload/fachgebiete/lippert/studyu/StudyU_Designer_terms_en.pdf'.hardcoded)); },
            ),
            const TextSpan(
              text: ' and ',
            ),
            TextSpan(
              text: 'privacy policy',
              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () { launchUrl(Uri.parse('https://www13.hpi.uni-potsdam.de/fileadmin/user_upload/fachgebiete/lippert/studyu/StudyU_Designer_privacy_en.pdf'.hardcoded)); },
            ),
            const TextSpan(
              text: '.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _formWidget() {
    return Form(
      key: _formKey,
      onChanged: () => setState(() => isFormValid = _formKey.currentState!.validate() && tosAgreement),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text('Signup'.hardcoded, style: FlutterFlowTheme.of(context).title1,)),
            const SizedBox(height: 20),
            TextFormFieldWidget(emailController: emailController),
            PasswordWidget(passwordController: passwordController),
            _tosWidget(),
            const SizedBox(height: 20),
            buttonWidget(ref, isFormValid, 'Create Account', formReturnAction),
          ]
      ),
    );
  }

  void formReturnAction() {
    final authController = ref.watch(authControllerProvider.notifier);
    authController.signUp(emailController.text, passwordController.text);
  }
}