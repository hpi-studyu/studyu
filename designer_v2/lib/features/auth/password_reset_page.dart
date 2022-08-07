import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_widgets.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

import 'auth_required_state.dart';

class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({Key? key}) : super(key: key);

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  _PasswordResetPageState();

  late TextEditingController emailController;
  late bool isFormValid;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
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
            Center(child: Text('Reset Password'.hardcoded, style: FlutterFlowTheme.of(context).title1,)),
            const SizedBox(height: 20),
            TextFormFieldWidget(emailController: emailController, validator: FieldValidators.emailValidator,),
            const SizedBox(height: 20),
            ButtonWidget(ref: ref, isFormValid: isFormValid, buttonText: 'Reset Password'.hardcoded, onPressed: () => authController.resetPasswordForEmail(emailController.text)),
          ]
      ),
    );
  }
}
