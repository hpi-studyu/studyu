import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_fields.dart';
import 'package:studyu_designer_v2/features/auth/auth_state.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class PasswordRecoveryForm extends StatefulWidget {
  const PasswordRecoveryForm({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends AuthState<PasswordRecoveryForm> {
  @override
  Widget build(BuildContext context) {
    return const _PasswordRecoveryFormBody();
  }
}

class _PasswordRecoveryFormBody extends FormConsumerRefWidget {
  const _PasswordRecoveryFormBody({Key? key}) : super(key: key);

  final AuthFormKey formKey = AuthFormKey.passwordRecovery;

  @override
  Widget build(BuildContext context, FormGroup form, WidgetRef ref) {
    final state = ref.watch(authFormControllerProvider(formKey));
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PasswordTextField(
          formControl: controller.passwordControl,
          labelText: 'New password'.hardcoded,
          hintText: 'Enter new password'.hardcoded,
        ),
        const SizedBox(height: 12.0),
        PasswordTextField(
          formControl: controller.passwordConfirmationControl,
          labelText: 'Confirm new password'.hardcoded,
          hintText: 'Enter new password again'.hardcoded,
        ),
        const SizedBox(height: 24.0),
        ReactiveFormConsumer(builder: (context, form, child) {
          return Center(
            child: PrimaryButton(
              icon: null,
              text: 'Reset password'.hardcoded,
              isLoading: state.isLoading,
              enabled: form.valid,
              onPressedFuture: () => ref
                  .read(authFormControllerProvider(formKey).notifier)
                  .recoverPassword(),
              tooltipDisabled:
                  'Please fill out all fields as required'.hardcoded,
              innerPadding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            ),
          );
        }),
        const SizedBox(height: 24.0),
        const Divider(height: 1),
        const SizedBox(height: 12.0),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("Log into your workspace?".hardcoded),
            const SizedBox(width: 4.0),
            Hyperlink(
              text: 'Sign in'.hardcoded,
              onClick: () =>
                  ref.read(routerProvider).dispatch(RoutingIntents.login),
            ),
          ],
        )
      ],
    );
  }
}
