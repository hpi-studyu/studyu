import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class CloseConfirmationDialog extends StudyPageWidget {
  const CloseConfirmationDialog(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(studyControllerProvider(studyId).notifier);
    final state = ref.watch(studyControllerProvider(studyId));
    final formKey = GlobalKey<FormState>();
    String? inputStudyName;

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (Study study) {
        return StandardDialog(
          titleText: tr.dialog_study_close_title,
          body: Form(
            key: formKey,
            child: Column(
              children: [
                Text(tr.dialog_study_close_description),
                const SizedBox(height: 16.0),
                SelectableText(
                  'Enter the title of the study "${study.title}" to confirm that you want to close it:',
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title of the study to close',
                  ),
                  validator: (value) {
                    if (value == null || value != study.title) {
                      return 'Study title does not match';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    inputStudyName = value;
                  },
                ),
              ],
            ),
          ),
          actionButtons: [
            const DismissButton(),
            PrimaryButton(
              text: tr.dialog_close,
              icon: null,
              onPressedFuture: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  if (inputStudyName == study.title) {
                    await controller.closeStudy();
                  }
                }
              },
            ),
          ],
          maxWidth: 650,
          minWidth: 610,
          minHeight: 200,
        );
      },
    );
  }
}
