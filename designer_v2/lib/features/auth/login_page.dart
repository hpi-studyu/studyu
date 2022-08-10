import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_required_state.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_widgets.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
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
  late ThemeData theme;

  late FormGroup authForm;

  @override
  void initState() {
    super.initState();
    authForm = ref.read(authFormControlProvider('login'))!;
    _loadRememberMe();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Column(
        children: <Widget>[
          Center(child: Text('Login'.hardcoded, style: theme.textTheme.headlineLarge /*style: FlutterFlowTheme.of(context).title1,*/)),
          const SizedBox(height: 20),
          const TextFormFieldWidget(),
          const PasswordWidget(),
          _rememberMeWidget(authForm),
          _forgotPassword(authForm),
          const SizedBox(height: 5),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              // TODO Loading indicator on the button does not appear after design merge
              // todo also page loading after submitting looks weird
              final authState = ref.watch(authControllerProvider);
              return PrimaryButton(
                icon: Icons.login,
                text: 'Sign In'.hardcoded,
                isLoading: authState.isLoading,
                onPressed: authForm.valid ? _formReturnAction : null,
                tooltipDisabled: 'All fields must be filled out',
              );
            },
          ),
        ]
    );
  }

  _formReturnAction() async {
    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.signInWith(
        authForm.control('email').value, authForm.control('password').value);
    if (success) {
      _setRememberMe();
    }
  }

  // todo move all rememberme stuff to form_controller and add a provider
  void _setRememberMe() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("rememberMe", authForm.control('rememberMe').value);
      prefs.setString('email', authForm.control('email').value);
      prefs.setString('password', authForm.control('password').value);
    },
    );
  }

  void _loadRememberMe() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("email");
      final password = prefs.getString("password");
      final rememberMe = prefs.getBool("rememberMe") ?? false;
      if (rememberMe) {
        authForm.control('rememberMe').value = true;
        authForm.control('email').value = email ?? "";
        authForm.control('password').value = password ?? "";
      }
    } catch (e) {
      authForm.control('email').value = "";
      authForm.control('password').value = "";
    }
  }

  Widget _rememberMeWidget(FormGroup authForm) {
    // change background color: https://stackoverflow.com/questions/64590691/how-to-fill-color-inside-of-checkbox-in-flutter
    // todo this does not seem to inherit theme
    return ReactiveCheckboxListTile(
        formControlName: 'rememberMe',
        //onChanged: (val) => authForm.control('rememberMe').value = val.value,
        title: Text(
          'Remember me'.hardcoded, style: theme.textTheme.titleLarge,
          /*style: FlutterFlowTheme.of(context).subtitle2.override(
            fontFamily: 'Roboto',
            color: const Color(0xFF7B8995),
          ),*/
        ),
    );
  }

  Widget _forgotPassword(FormGroup authForm) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
            alignment: Alignment.centerLeft,
            child: TextButton(
                onPressed: () => ref.read(routerProvider).dispatch(
                    RoutingIntents.passwordForgot(authForm.control('email').value)),
                child: Text("Forgot your password?".hardcoded, /*style: FlutterFlowTheme.of(context).bodyText2*/)
            ),
        )
    );
  }
}
