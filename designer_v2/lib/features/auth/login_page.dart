import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_required_state.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_widgets.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends AuthRequiredState<LoginPage>  {
  @override
  Widget build(BuildContext context) {
    return const LoginPageContent();
  }
}

class LoginPageContent extends ConsumerStatefulWidget {
  const LoginPageContent({Key? key}) : super(key: key);

  @override
  _LoginPageContentState createState() => _LoginPageContentState();
}

class _LoginPageContentState extends ConsumerState<LoginPageContent> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late bool rememberMeValue;
  late bool isFormValid;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadRememberMe();

    rememberMeValue = false;
    emailController = TextEditingController();
    passwordController = TextEditingController();
    isFormValid = false;
  }

  // todo move all rememberme stuff to form_controller and add a provider
  void _setRememberMe() {
    SharedPreferences.getInstance().then((prefs) {
        prefs.setBool("remember_me", rememberMeValue);
        prefs.setString('email', emailController.text);
        prefs.setString('password', passwordController.text);
      },
    );
  }

  void _loadRememberMe() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("email");
      final password = prefs.getString("password");
      final rememberMe = prefs.getBool("remember_me") ?? false;

      if (rememberMe) {
        setState(() {
          rememberMeValue = true;
        });
        emailController.text = email ?? "";
        passwordController.text = password ?? "";
      }
    } catch (e) {
      emailController.text = "";
      passwordController.text = "";
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child: Text('Login'.hardcoded, style: FlutterFlowTheme.of(context).title1,)),
              const SizedBox(height: 20),
              TextFormFieldWidget(emailController: emailController, validator: FieldValidators.emailValidator),
              PasswordWidget(passwordController: passwordController),
              _rememberMeWidget(),
              _forgotPassword(),
              const SizedBox(height: 5),
              ButtonWidget(ref: ref, isFormValid: isFormValid, buttonText: 'Sign In'.hardcoded, onPressed: _formReturnAction),
            ]
        )
    );
  }

  _formReturnAction() async {
    final authController = ref.watch(authControllerProvider.notifier);
    final success = await authController.signInWith(emailController.text, passwordController.text);
    if (success) {
      _setRememberMe();
    }
  }

  Widget _rememberMeWidget() {
    return CheckboxListTile(
        value: rememberMeValue,
        onChanged: (newValue) =>
            setState(() {
              rememberMeValue = newValue!;
            }),
        title: Text(
          'Remember me'.hardcoded,
          style: FlutterFlowTheme.of(context).subtitle2.override( // todo fix
            fontFamily: 'Roboto',
            color: const Color(0xFF7B8995),
          ),
        )
    );
  }

  Widget _forgotPassword() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
            alignment: Alignment.centerLeft,
            child: TextButton(
                onPressed: () => ref.read(routerProvider).dispatch(
                    RoutingIntents.passwordForgot(emailController.text)),
                child: Text("Forgot your password?".hardcoded, style: FlutterFlowTheme.of(context).bodyText2)
            ),
        )
    );
  }
}
