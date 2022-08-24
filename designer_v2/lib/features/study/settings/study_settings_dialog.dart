import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/study/settings/study_settings_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudySettingsDialog extends StudyPageWidget {
  const StudySettingsDialog(studyId, {Key? key}) : super(studyId, key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formViewModel =
        ref.watch(studySettingsFormViewModelProvider(studyId));

    return ReactiveForm(
      formGroup: formViewModel.form,
      child: StandardDialog(
        titleText: "Study settings".hardcoded,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12.0),
            FormSectionHeader(title: "Study Registry".hardcoded),
            const SizedBox(height: 6.0),
            TextParagraph(
                text: "The study registry is a public collection of studies "
                        "conducted on the StudyU platform. In the spirit of "
                        "open science, it fosters collaboration & transparency "
                        "among all researchers & clinicians on the platform."
                    .hardcoded),
            const SizedBox(height: 24.0),
            ReactiveFormConsumer(builder: (context, form, child) {
              return FormTableLayout(rows: [
                FormTableRow(
                    label: "Publish study".hardcoded,
                    labelHelpText: "Other researchers & clinicians will be able "
                            "to access, test, review or create a \ncopy of our study "
                            "design. They won't be able to access any data related "
                            "to \nin-progress studies such as participants or "
                            "study results (your study's \nRecruit, Monitor & "
                            "Analyze pages will be unavailable)."
                        .hardcoded,
                    input: Align(
                      alignment: Alignment.centerRight,
                      child: ReactiveSwitch(
                        formControl: formViewModel.isPublishedToRegistryControl,
                      ),
                    )),
                FormTableRow(
                    label: "Publish results".hardcoded,
                    labelHelpText: "Make your anonymized study results & data "
                            "available in the study registry. \n"
                            "Other researchers & clinicians will can access, export and "
                            "analyze \nthe results from your study "
                            "(the Analyze tab will be available). \n"
                            "This will automatically publish your study design to the registry."
                        .hardcoded,
                    input: Align(
                      alignment: Alignment.centerRight,
                      child: ReactiveSwitch(
                        formControl:
                            formViewModel.isPublishedToRegistryResultsControl,
                      ),
                    )),
              ]);
            }),
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
