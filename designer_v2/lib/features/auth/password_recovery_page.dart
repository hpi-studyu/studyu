import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_widgets.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class PasswordRecoveryPage extends ConsumerStatefulWidget {
  const PasswordRecoveryPage({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends ConsumerState<PasswordRecoveryPage> {
  late TextEditingController passwordController;
  late TextEditingController passwordConfirmController;
  late bool isFormValid;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    passwordConfirmController = TextEditingController();
    isFormValid = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(
      authControllerProvider,
          (_, state) => state.showResultUI(context),
    );
    final authController = ref.watch(authControllerProvider.notifier);
    return Form(
      key: _formKey,
      onChanged: () => setState(() => isFormValid = _formKey.currentState!.validate()),
      child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text('Choose a new password'.hardcoded, style: FlutterFlowTheme.of(context).title1)),
            const SizedBox(height: 20),
            PasswordWidget(passwordController: passwordController),
            PasswordWidget(passwordController: passwordConfirmController, validator: passwordConfirmValidator),
            const SizedBox(height: 20),
            ButtonWidget(ref: ref, isFormValid: isFormValid, buttonText: 'Confirm setting a new password'.hardcoded, onPressed: () => authController.updateUser(passwordController.text)),
          ]
      ),
    );
  }

  String? passwordConfirmValidator(String? password) {
    String? passwordVal = FieldValidators.passwordValidator(password);
    if (passwordVal == null) {
      if (password != passwordController.text) {
        return 'Passwords have to match';
      }
      return null;
    }
    return passwordVal;
  }
}
