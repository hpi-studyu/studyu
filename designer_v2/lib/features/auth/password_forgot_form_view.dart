import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_fields.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class PasswordForgotForm extends FormConsumerRefWidget {
  const PasswordForgotForm({super.key});

  final AuthFormKey formKey = AuthFormKey.passwordForgot;

  @override
  Widget build(BuildContext context, FormGroup form, WidgetRef ref) {
    final state = ref.watch(authFormControllerProvider(formKey));
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmailTextField(
          formControl: controller.emailControl,
        ),
        const SizedBox(height: 24.0),
        ReactiveFormConsumer(builder: (context, form, child) {
          return Center(
            child: PrimaryButton(
              icon: null,
              text: tr.action_button_password_reset,
              isLoading: state.isLoading,
              enabled: form.valid,
              onPressedFuture: () => ref.read(authFormControllerProvider(formKey).notifier).sendPasswordResetLink(),
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
            Text(tr.link_login_description2),
            const SizedBox(width: 4.0),
            Hyperlink(
              text: tr.link_login,
              onClick: () => ref.read(routerProvider).dispatch(RoutingIntents.login),
            ),
          ],
        )
      ],
    );
  }
}
