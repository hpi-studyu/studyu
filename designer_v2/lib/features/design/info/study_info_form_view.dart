import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/character_count_text_field.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyDesignInfoFormView extends StudyDesignPageWidget {
  const StudyDesignInfoFormView(super.studyId, {super.key});

  static const _singleLineFieldHeight = 56.0;
  static const _studyTitleMaxLength = 100;
  static const _studyDescriptionMaxLength = 500;
  static const _contactFieldMaxLength = 100;
  static const _websiteMaxLength = 300;
  static const _additionalInfoMaxLength = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.watch(
          studyInfoFormViewModelProvider(studyId),
        );
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(text: tr.form_study_design_info_description),
              const SizedBox(height: 24.0),
              FormTableLayout(
                rows: [
                  FormTableRow(
                    control: formViewModel.titleControl,
                    label: tr.form_field_study_title,
                    labelHelpText: tr.form_field_study_title_tooltip,
                    input: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO: responsive layout (input field gets too small)
                        Expanded(
                          child: CharacterCountTextField(
                            formControl: formViewModel.titleControl,
                            hintText: tr.form_field_study_title,
                            maxLength: _studyTitleMaxLength,
                            validationMessages:
                                formViewModel.titleControl.validationMessages,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        ReactiveValueListenableBuilder<IconOption>(
                          formControl: formViewModel.iconControl,
                          builder: (context, control, child) {
                            return SizedBox(
                              height: StudyDesignInfoFormView
                                  ._singleLineFieldHeight,
                              child: Center(
                                child: ReactiveIconPicker(
                                  formControl: formViewModel.iconControl,
                                  iconOptions: IconPack.material,
                                  selectedIconSize: 24.0,
                                  validationMessages: formViewModel
                                      .iconControl
                                      .validationMessages,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.descriptionControl,
                    label: tr.form_field_study_description,
                    labelHelpText: tr.form_field_study_description_tooltip,
                    input: CharacterCountTextField(
                      formControl: formViewModel.descriptionControl,
                      hintText: tr.form_field_study_description_hint,
                      maxLength: _studyDescriptionMaxLength,
                      validationMessages:
                          formViewModel.descriptionControl.validationMessages,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: 5,
                    ),
                  ),
                ],
                columnWidths: const {
                  0: FixedColumnWidth(185.0),
                  1: FlexColumnWidth(),
                },
              ),
              const SizedBox(height: 32.0),
              FormSectionHeader(title: tr.form_section_publisher),
              const SizedBox(height: 12.0),
              TextParagraph(text: tr.form_section_publisher_description),
              const SizedBox(height: 24.0),
              FormTableLayout(
                rows: [
                  FormTableRow(
                    control: formViewModel.organizationControl,
                    label: tr.form_field_organization,
                    input: CharacterCountTextField(
                      formControl: formViewModel.organizationControl,
                      hintText: tr.form_field_organization,
                      maxLength: _contactFieldMaxLength,
                      validationMessages:
                          formViewModel.organizationControl.validationMessages,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.reviewBoardControl,
                    label: tr.form_field_review_board,
                    input: CharacterCountTextField(
                      formControl: formViewModel.reviewBoardControl,
                      hintText: tr.form_field_review_board,
                      maxLength: _contactFieldMaxLength,
                      validationMessages:
                          formViewModel.reviewBoardControl.validationMessages,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.reviewBoardNumberControl,
                    label: tr.form_field_review_board_number,
                    input: CharacterCountTextField(
                      formControl: formViewModel.reviewBoardNumberControl,
                      hintText: tr.form_field_review_board_number,
                      maxLength: _contactFieldMaxLength,
                      validationMessages: formViewModel
                          .reviewBoardNumberControl
                          .validationMessages,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.researchersControl,
                    label: tr.form_field_researchers,
                    input: CharacterCountTextField(
                      formControl: formViewModel.researchersControl,
                      hintText: tr.form_field_researchers,
                      maxLength: _contactFieldMaxLength,
                      validationMessages:
                          formViewModel.researchersControl.validationMessages,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.websiteControl,
                    label: tr.form_field_website,
                    input: CharacterCountTextField(
                      formControl: formViewModel.websiteControl,
                      hintText: tr.form_field_website,
                      maxLength: _websiteMaxLength,
                      showErrors: (control) => control.invalid && control.dirty,
                      validationMessages:
                          formViewModel.websiteControl.validationMessages,
                      helperTextBuilder: (control) =>
                          control.invalid && control.dirty
                          ? tr.sync_dirty
                          : null,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.emailControl,
                    label: tr.form_field_contact_email,
                    input: CharacterCountTextField(
                      formControl: formViewModel.emailControl,
                      hintText: tr.form_field_contact_email,
                      maxLength: _contactFieldMaxLength,
                      showErrors: (control) => control.invalid && control.dirty,
                      validationMessages:
                          formViewModel.emailControl.validationMessages,
                      helperTextBuilder: (control) =>
                          control.invalid && control.dirty
                          ? tr.sync_dirty
                          : null,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.phoneControl,
                    label: tr.form_field_contact_phone,
                    input: CharacterCountTextField(
                      formControl: formViewModel.phoneControl,
                      hintText: tr.form_field_contact_phone,
                      maxLength: _contactFieldMaxLength,
                      validationMessages:
                          formViewModel.phoneControl.validationMessages,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.additionalInfoControl,
                    label: tr.form_field_contact_additional_info,
                    input: CharacterCountTextField(
                      formControl: formViewModel.additionalInfoControl,
                      hintText: tr.form_field_contact_additional_info,
                      maxLength: _additionalInfoMaxLength,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: 5,
                    ),
                  ),
                ],
                columnWidths: const {
                  0: FixedColumnWidth(180.0),
                  1: FlexColumnWidth(),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
