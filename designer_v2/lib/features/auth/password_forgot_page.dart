import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_state.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_widgets.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

import '../../routing/router.dart';
import '../../routing/router_intent.dart';

class PasswordForgotPage extends StatefulWidget {
  final String? email;
  const PasswordForgotPage({this.email, Key? key}) : super(key: key);

  @override
  _PasswordForgotPageState createState() => _PasswordForgotPageState();
}

class _PasswordForgotPageState extends AuthState<PasswordForgotPage> {
  @override
  Widget build(BuildContext context) {
    return PasswordForgotPageContent(widget.email);
  }
}

class PasswordForgotPageContent extends ConsumerStatefulWidget {
  final String? email;
  const PasswordForgotPageContent(this.email, {Key? key}) : super(key: key);

  @override
  _PasswordForgotPageContentState createState() => _PasswordForgotPageContentState();
}

class _PasswordForgotPageContentState extends ConsumerState<PasswordForgotPageContent> {
  late TextEditingController emailController;
  late bool isFormValid;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    if (widget.email != null) {
      if (FieldValidators.emailValidator(widget.email) == null) {
        emailController.text = widget.email!;
        isFormValid = true;
      } else {
        isFormValid = false;
      }
    } else {
      isFormValid = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
          (_, state) => state.showResultUI(context),
    );
    return Form(
      key: _formKey,
      onChanged: () => setState(() => isFormValid = _formKey.currentState!.validate()),
      child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text('Forgot Password'.hardcoded, style: FlutterFlowTheme.of(context).title1,)),
            const SizedBox(height: 20),
            TextFormFieldWidget(emailController: emailController, validator: FieldValidators.emailValidator,),
            const SizedBox(height: 20),
            ButtonWidget(ref: ref, isFormValid: isFormValid, buttonText: 'Forgot Password'.hardcoded, onPressed: _formReturnAction),
            const SizedBox(height: 20),
            _backButton(),
          ]
      ),
    );
  }

  Future<void> _formReturnAction() async {
    final authController = ref.watch(authControllerProvider.notifier);
    final success = await authController.resetPasswordForEmail(emailController.text);
    if (mounted) {
      if (success) {
        formSuccessAction(context, 'Check your email for a password reset link!'.hardcoded);
      }
    }
  }

  Widget _backButton() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () => ref.read(routerProvider).dispatch(
                  RoutingIntents.login),
              child: Text("Back to login".hardcoded, style: FlutterFlowTheme.of(context).bodyText2)
          ),
        )
    );
  }
}
