import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_fields.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class LoginForm extends FormConsumerRefWidget {
  const LoginForm({super.key});

  final AuthFormKey formKey = AuthFormKey.login;

  @override
  Widget build(BuildContext context, FormGroup form, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(authFormControllerProvider(formKey));
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmailTextField(
          formControl: controller.emailControl,
        ),
        //const SizedBox(height: 16.0),
        const SizedBox(height: 4.0),
        PasswordTextField(
          formControl: controller.passwordControl,
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IntrinsicWidth(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ReactiveCheckbox(
                    key: ObjectKey(controller.rememberMeControl),
                    formControl: controller.rememberMeControl,
                  ),
                  const SizedBox(width: 3.0),
                  FormControlLabel(
                    formControl: controller.rememberMeControl,
                    text: tr.form_field_remember_me,
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
            ),
            Hyperlink(
              text: tr.link_forgot_password,
              style: TextStyle(fontSize: theme.textTheme.bodySmall!.fontSize),
              onClick: () => ref.read(routerProvider).dispatch(RoutingIntents.passwordForgot),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        ReactiveFormConsumer(builder: (context, form, child) {
          return Center(
            child: PrimaryButton(
              icon: Icons.login,
              text: tr.action_button_login,
              isLoading: state.isLoading,
              enabled: form.valid,
              onPressedFuture: () => ref.read(authFormControllerProvider(formKey).notifier).signIn(),
              tooltipDisabled: tr.form_invalid_prompt,
              innerPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            ),
          );
        }),
        const SizedBox(height: 24.0),
        const Divider(height: 1),
        const SizedBox(height: 12.0),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(tr.link_signup_description),
            const SizedBox(width: 4.0),
            Hyperlink(
              text: tr.link_signup,
              onClick: () => ref.read(routerProvider).dispatch(RoutingIntents.signup),
            ),
          ],
        )
      ],
    );
  }
}
