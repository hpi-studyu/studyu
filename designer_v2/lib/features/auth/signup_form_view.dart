import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_fields.dart';
import 'package:studyu_designer_v2/features/auth/auth_state.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/app_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class _SignupFormBody extends FormConsumerRefWidget {
  _SignupFormBody({Key? key}) : super(key: key);

  final AuthFormKey formKey = AuthFormKey.signup;

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
        const SizedBox(height: 12.0),
        PasswordTextField(
          formControl: controller.passwordControl,
        ),
        const SizedBox(height: 12.0),
        PasswordTextField(
          formControl: controller.passwordConfirmationControl,
          labelText: 'Confirm password'.hardcoded,
          hintText: 'Enter password again'.hardcoded,
        ),
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: ReactiveCheckbox(
                key: ObjectKey(controller.termsOfServiceControl),
                formControl: controller.termsOfServiceControl,
              ),
            ),
            const SizedBox(width: 6.0),
            Flexible(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FormControlLabel(
                    formControl: controller.termsOfServiceControl,
                    text: "I have read and agree to StudyU's ".hardcoded,
                  ),
                  Hyperlink(
                    text: 'terms of use'.hardcoded,
                    onClick: () => _onClickTermsOfUse(ref),
                    style: TextStyle(
                      fontSize: theme.textTheme.caption!.fontSize,
                      height: theme.textTheme.caption!.height,
                    ),
                  ),
                  FormControlLabel(
                    formControl: controller.termsOfServiceControl,
                    text: ' and '.hardcoded,
                  ),
                  Hyperlink(
                    text: 'privacy policy'.hardcoded,
                    onClick: () => _onClickPrivacyPolicy(ref),
                    style: TextStyle(
                      fontSize: theme.textTheme.caption!.fontSize,
                      height: theme.textTheme.caption!.height,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 24.0),
        ReactiveFormConsumer(builder: (context, form, child) {
          return Center(
            child: PrimaryButton(
              text: "Create account".hardcoded,
              isLoading: state.isLoading,
              enabled: form.valid,
              onPressedFuture: () => ref
                  .read(authFormControllerProvider(formKey).notifier)
                  .signUp(),
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
            Text("Already have an account?".hardcoded),
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

  _onClickTermsOfUse(WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    final locale = ref.watch(localeProvider);

    launchUrl(appConfig.maybeWhen(
      data: (value) =>
          Uri.parse(value.designerTerms[locale.languageCode] ?? ""),
      orElse: () => Uri.parse(''),
    ));
  }

  _onClickPrivacyPolicy(WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    final locale = ref.watch(localeProvider);

    launchUrl(appConfig.maybeWhen(
      data: (value) =>
          Uri.parse(value.designerPrivacy[locale.languageCode] ?? ""),
      orElse: () => Uri.parse(''),
    ));
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends AuthState<SignupForm> {
  @override
  Widget build(BuildContext context) {
    return _SignupFormBody();
  }
}
