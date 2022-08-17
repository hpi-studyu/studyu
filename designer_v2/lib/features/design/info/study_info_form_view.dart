import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudyDesignInfoFormView extends StudyDesignPageWidget {
  const StudyDesignInfoFormView(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.read(studyInfoFormViewModelProvider(studyId));
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                  text: "Provide general information about your study for "
                      "participants as well as other researchers and clinicians.".hardcoded),
              const SizedBox(height: 32.0),
              FormTableLayout(rows: [
                FormTableRow(
                  control: formViewModel.titleControl,
                  label: "Title".hardcoded,
                  labelHelpText: "TODO Study title help text".hardcoded,
                  input: Row(
                    children: [
                      // TODO: responsive layout (input field gets too small)
                      Expanded(
                        child: ReactiveTextField(
                          formControl: formViewModel.titleControl,
                        )
                      ),
                      ReactiveFormConsumer(builder: (context, form, child) {
                        return (formViewModel.iconControl.value != null)
                            ? const SizedBox(width: 4.0)
                            : const SizedBox(width: 8.0);
                      }),
                      IntrinsicWidth(
                        child: ReactiveIconPicker(
                          formControl: formViewModel.iconControl,
                          iconOptions: IconPack.material,
                        ),
                      )
                    ],
                  ),
                ),
                FormTableRow(
                  control: formViewModel.descriptionControl,
                  label: "Description".hardcoded,
                  labelHelpText: "TODO Study description text help text".hardcoded,
                  input: ReactiveTextField(
                    formControl: formViewModel.descriptionControl,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: "Give a short summary of your study to participants".hardcoded
                    ),
                  ),
                ),
              ], columnWidths: const {
                0: FixedColumnWidth(185.0),
                1: FlexColumnWidth(),
              }),
              const SizedBox(height: 24.0),
              FormSectionHeader(title: "Contact information".hardcoded),
              const SizedBox(height: 12.0),
              TextParagraph(
                  text: "Participants will be able to contact you "
                      "via the StudyU app using this information. Other clinicians "
                      "or researchers will only be able to contact you if you "
                      "agree to publish your study to the study repository."
                      "".hardcoded),
              const SizedBox(height: 32.0),
              FormTableLayout(rows: [
                FormTableRow(
                  control: formViewModel.organizationControl,
                  label: "Responsible organization".hardcoded,
                  input: ReactiveTextField(
                    formControl: formViewModel.organizationControl,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.institutionalReviewBoardControl,
                  label: "Institutional Review Board".hardcoded,
                  input: ReactiveTextField(
                    formControl: formViewModel.institutionalReviewBoardControl,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.institutionalReviewBoardNumberControl,
                  label: "Institutional Review Board\nProtocol Number".hardcoded,
                  input: ReactiveTextField(
                    formControl: formViewModel.institutionalReviewBoardNumberControl,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.researchersControl,
                  label: "Responsible\nresearcher(s)".hardcoded,
                  input: ReactiveTextField(
                    formControl: formViewModel.researchersControl,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.websiteControl,
                  label: "Website".hardcoded,
                  input: ReactiveTextField(
                    formControl: formViewModel.websiteControl,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.emailControl,
                  label: "Email".hardcoded,
                  input: ReactiveTextField(
                    formControl: formViewModel.emailControl,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.phoneControl,
                  label: "Phone".hardcoded,
                  input: ReactiveTextField(
                    formControl: formViewModel.phoneControl,
                  ),
                ),
              ], columnWidths: const {
                0: FixedColumnWidth(185.0),
                1: FlexColumnWidth(),
              }),
            ],
          ),
        );
      },
    );
  }
}
