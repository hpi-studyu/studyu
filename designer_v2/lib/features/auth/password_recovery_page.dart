import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_state.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_widgets.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends AuthState<PasswordRecoveryPage> {
  @override
  Widget build(BuildContext context) {
    return const PasswordRecoveryPageContent();
  }
}

class PasswordRecoveryPageContent extends ConsumerStatefulWidget {
  const PasswordRecoveryPageContent({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryPageContentState createState() => _PasswordRecoveryPageContentState();
}

class _PasswordRecoveryPageContentState extends ConsumerState<PasswordRecoveryPageContent> {
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
            Center(child: Text('Choose a new password'.hardcoded, style: FlutterFlowTheme.of(context).title1)),
            const SizedBox(height: 20),
            PasswordWidget(passwordController: passwordController),
            PasswordWidget(passwordController: passwordConfirmController, validator: passwordConfirmValidator),
            const SizedBox(height: 20),
            ButtonWidget(ref: ref, isFormValid: isFormValid, buttonText: 'Confirm setting a new password'.hardcoded, onPressed: _formReturnAction),
            const SizedBox(height: 20),
            _backButton()
          ]
      ),
    );
  }

  Widget _backButton() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () => ref.read(routerProvider).dispatch(
                  RoutingIntents.studies),
              child: Text("Go to study overview".hardcoded, style: FlutterFlowTheme.of(context).bodyText2)
          ),
        )
    );
  }

  void _formReturnAction() async {
    final authController = ref.watch(authControllerProvider.notifier);
    final success = await authController.updateUser(passwordController.text);
    if (mounted) {
      if (success) {
        formSuccessAction(context, 'Password was reset successfully'.hardcoded);
        // todo create rememberme provider
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final rememberMe = prefs.getBool("remember_me") ?? false;
        if (rememberMe) {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('password', passwordController.text);
          });
        }
        ref.read(routerProvider).dispatch(RoutingIntents.studies);
      }
    }
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
