import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/study/settings/study_settings_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class CloseConfirmationDialog extends StudyPageWidget {
  const CloseConfirmationDialog(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(studyControllerProvider(studyId).notifier);
    final formViewModel =
        ref.watch(studySettingsFormViewModelProvider(studyId));

    return ReactiveForm(
      formGroup: formViewModel.form,
      child: StandardDialog(
        titleText: tr.dialog_study_close_title,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: tr.dialog_study_close_description,
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ],
        ),
        actionButtons: [
          const DismissButton(),
          ReactiveFormConsumer(builder: (context, form, child) {
            return PrimaryButton(
              text: tr.dialog_close,
              icon: null,
              onPressedFuture: () => controller.closeStudy(),
            );
          }),
        ],
        maxWidth: 650,
        minWidth: 610,
        minHeight: 200,
      ),
    );
  }
}
