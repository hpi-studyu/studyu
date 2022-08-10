import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_state.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_widgets.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/validation.dart';

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
  late AuthController authController;
  late FormGroup authForm;

  @override
  void initState() {
    super.initState();
    authController = ref.read(authControllerProvider.notifier);
    authForm = ref.read(authFormControlProvider('forgotPassword'))!;
    // todo use formcontrol validator
    if (widget.email != null && FieldValidators.emailValidator(widget.email) == null) {
        authForm.control('email').value = widget.email!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Center(
              child: Text('Forgot Password'.hardcoded, style: Theme.of(context).textTheme.headlineLarge /*style: FlutterFlowTheme.of(context).title1,*/)
          ),
          const SizedBox(height: 20),
          const TextFormFieldWidget(),
          const SizedBox(height: 20),
          ReactiveFormConsumer(
            builder: (context, formN, child) {
              final authState = ref.watch(authControllerProvider);
              return PrimaryButton(
                icon: Icons.question_mark,
                text: 'Forgot Password'.hardcoded,
                isLoading: authState.isLoading,
                onPressed: authForm.valid ? _formReturnAction : null,
                tooltipDisabled: 'All fields must be filled out',
              );
            },
          ),
          const SizedBox(height: 20),
          _backButton(),
        ]
    );
  }

  Future<void> _formReturnAction() async {
    final authController = ref.watch(authControllerProvider.notifier);
    final success = await authController.resetPasswordForEmail(authForm.control('email').value);
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
              child: Text("Back to login".hardcoded, /*style: FlutterFlowTheme.of(context).bodyText2*/)
          ),
        )
    );
  }
}
