import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_state.dart';
import 'package:studyu_designer_v2/features/auth/form_controller.dart';
import 'package:studyu_designer_v2/features/auth/form_widgets.dart';
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
  late AuthController authController;
  late FormGroup authForm;

  @override
  void initState() {
    super.initState();
    authController = ref.read(authControllerProvider.notifier);
    authForm = ref.read(authFormControlProvider('recoverPassword'))!;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: Text('Choose a new password'.hardcoded, /*style: FlutterFlowTheme.of(context).title1*/)),
                const SizedBox(height: 20),
                const PasswordWidget(),
                // todo labelText is .hardcoded
                const PasswordWidget(formControlName: 'passwordConfirmation', labelText: "Password Confirmation",),
                const SizedBox(height: 20),
                ReactiveFormConsumer(
                  builder: (context, formN, child) {
                    final authState = ref.watch(authControllerProvider);
                    return PrimaryButton(
                      icon: Icons.send,
                      text: 'Confirm setting a new password'.hardcoded,
                      isLoading: authState.isLoading,
                      onPressed: authForm.valid ? _formReturnAction : null,
                      tooltipDisabled: 'All fields must be filled out',
                    );
                  },
                ),
                const SizedBox(height: 20),
                _backButton()
              ]
          ),
        ]
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
              child: Text("Go to study overview".hardcoded, /*style: FlutterFlowTheme.of(context).bodyText2*/)
          ),
        )
    );
  }

  void _formReturnAction() async {
    final authController = ref.watch(authControllerProvider.notifier);
    final success = await authController.updateUser(authForm.control('password').value);
    if (mounted) {
      if (success) {
        formSuccessAction(context, 'Password was reset successfully'.hardcoded);
        // todo create rememberme provider
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final rememberMe = prefs.getBool("remember_me") ?? false;
        if (rememberMe) {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('password', authForm.control('password').value);
          });
        }
        ref.read(routerProvider).dispatch(RoutingIntents.studies);
      }
    }
  }
}
