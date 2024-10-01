import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/study/settings/study_settings_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudySettingsDialog extends StudyPageWidget {
  const StudySettingsDialog(super.studyCreationArgs, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formViewModel =
        ref.watch(studySettingsFormViewModelProvider(studyCreationArgs));

    return ReactiveForm(
      formGroup: formViewModel.form,
      child: StandardDialog(
        titleText: tr.study_settings,
        body: Column(
          children: [
            ReactiveFormConsumer(
              builder: (context, form, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12.0),
                    FormSectionHeader(
                      title: tr.navlink_public_studies,
                      showLock: formViewModel.study.value?.isStandalone != true,
                      lockControl: formViewModel.lockPublishSettingsControl,
                      lockHelpText: tr.form_section_publish_lock_help,
                      lockedStateText: tr.form_section_publish_lock_locked,
                      unlockedStateText: tr.form_section_publish_lock_unlocked,
                    ),
                    const SizedBox(height: 6.0),
                    TextParagraph(text: tr.navlink_public_studies_description),
                    const SizedBox(height: 24.0),
                    FormTableLayout(
                      rows: [
                        FormTableRow(
                          label: tr.study_settings_publish_study,
                          labelHelpText:
                              tr.study_settings_publish_study_tooltip,
                          input: Align(
                            alignment: Alignment.centerRight,
                            child: ReactiveSwitch(
                              formControl:
                                  formViewModel.isPublishedToRegistryControl,
                            ),
                          ),
                        ),
                        FormTableRow(
                          label: tr.study_settings_publish_results,
                          labelHelpText:
                              tr.study_settings_publish_results_tooltip,
                          input: Align(
                            alignment: Alignment.centerRight,
                            child: ReactiveSwitch(
                              formControl: formViewModel
                                  .isPublishedToRegistryResultsControl,
                            ),
                          ),
                        ),
                      ],
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12.0),
          ],
        ),
        actionButtons: buildFormButtons(formViewModel, formViewModel.formMode),
        minWidth: 650,
        maxWidth: 750,
        minHeight: 450,
      ),
    );
  }
}
