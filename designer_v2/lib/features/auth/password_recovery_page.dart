import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_widgets.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class PasswordRecoveryPage extends ConsumerStatefulWidget {
  const PasswordRecoveryPage({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends ConsumerState<PasswordRecoveryPage> {
  late TextEditingController emailController;
  late TextEditingController emailConfirmController;
  late bool isFormValid;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    emailConfirmController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider.notifier);
    return Form(
      key: _formKey,
      onChanged: () => setState(() => isFormValid = _formKey.currentState!.validate()),
      child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text('Choose a new password'.hardcoded, style: FlutterFlowTheme.of(context).title1)),
            const SizedBox(height: 20),
            TextFormFieldWidget(emailController: emailController, validator: FieldValidators.emailValidator),
            TextFormFieldWidget(emailController: emailConfirmController, validator: emailConfirmValidator),
            const SizedBox(height: 20),
            buttonWidget(ref, isFormValid, 'Confirm setting a new password'.hardcoded, () => authController.resetPasswordForEmail(
                emailController.text)),
          ]
      ),
    );
  }

  String? emailConfirmValidator(String? email) {
    String? emailVal = FieldValidators.emailValidator(email);
    if (emailVal != null) {
      if (email != emailConfirmController.text) {
        return 'Emails are not the same';
      }
    }
    return null;
  }
}
