import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_fields.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/language_picker.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';

class AccountSettingsDialog extends ConsumerWidget {
  const AccountSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const formKey = AuthFormKey.passwordReset;
    final state = ref.watch(authFormControllerProvider(formKey));
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);

    return PointerInterceptor(
      child: SelectionArea(
        child: StandardDialog(
          titleText: tr.navlink_account_settings,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              FormTableLayout(
                rows: [
                  FormTableRow(
                    label: tr.language,
                    input: const Align(
                      alignment: Alignment.centerRight,
                      child: LanguagePicker(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 16.0),
              ReactiveFormConfig(
                validationMessages: AuthFormController.authValidationMessages,
                child: ReactiveForm(
                  formGroup: controller.getForm()!,
                  child: Column(
                    children: [
                      Text(
                        tr.change_password,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16.0),
                      PasswordTextField(
                        formControl: controller.getOldPasswordControl(),
                        labelText: tr.form_field_password_current,
                        hintText: tr.form_field_password_current_hint,
                      ),
                      const SizedBox(height: 12.0),
                      PasswordTextField(
                        formControl: controller.getPasswordControl(),
                        labelText: tr.form_field_password_new,
                        hintText: tr.form_field_password_new_hint,
                      ),
                      PasswordTextField(
                        formControl: controller
                            .getPasswordConfirmationControl(),
                        labelText: tr.form_field_password_new_confirm,
                        hintText: tr.form_field_password_new_confirm_hint,
                      ),
                      const SizedBox(height: 16.0),
                      ReactiveFormConsumer(
                        builder: (context, form, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              text: tr.form_field_reset_password,
                              icon: Icons.lock_reset,
                              enabled: form.valid,
                              isLoading: state.isLoading,
                              onPressedFuture: () async {
                                final controller = ref.read(
                                  authFormControllerProvider(formKey).notifier,
                                );

                                final result = await controller.resetPassword();

                                if (!context.mounted) return;

                                Navigator.maybePop(context);

                                final notificationService = ref.read(
                                  notificationServiceProvider,
                                );

                                notificationService.show(
                                  result
                                      ? Notifications.passwordResetSuccess
                                      : Notifications.credentialsInvalid,
                                );
                              },
                              tooltipDisabled: tr.form_invalid_prompt,
                              innerPadding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 10.0,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(),
                      const SizedBox(height: 16.0),
                      versionText(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actionButtons: [DismissButton(text: tr.dialog_close)],
          minWidth: 650,
          maxWidth: 750,
          minHeight: 450,
        ),
      ),
    );
  }
}
