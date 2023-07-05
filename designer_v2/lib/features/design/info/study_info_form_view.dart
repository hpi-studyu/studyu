import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/common_views/multi_select.dart';
import 'package:studyu_designer_v2/common_views/study_tag_badge.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/study_tag_repository.dart';

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
              TextParagraph(text: tr.form_study_design_info_description),
              const SizedBox(height: 24.0),
              FormTableLayout(rows: [
                FormTableRow(
                  control: formViewModel.titleControl,
                  label: tr.form_field_study_title,
                  labelHelpText: tr.form_field_study_title_tooltip,
                  input: Row(
                    children: [
                      // TODO: responsive layout (input field gets too small)
                      Expanded(
                          child: ReactiveTextField(
                        formControl: formViewModel.titleControl,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        validationMessages:
                            formViewModel.titleControl.validationMessages,
                      )),
                      ReactiveFormConsumer(builder: (context, form, child) {
                        return (formViewModel.iconControl.value != null)
                            ? const SizedBox(width: 4.0)
                            : const SizedBox(width: 8.0);
                      }),
                      IntrinsicWidth(
                        child: ReactiveIconPicker(
                          formControl: formViewModel.iconControl,
                          iconOptions: IconPack.material,
                          validationMessages:
                              formViewModel.iconControl.validationMessages,
                        ),
                      )
                    ],
                  ),
                ),
                FormTableRow(
                  control: formViewModel.descriptionControl,
                  label: tr.form_field_study_description,
                  labelHelpText: tr.form_field_study_description_tooltip,
                  input: ReactiveTextField(
                    formControl: formViewModel.descriptionControl,
                    validationMessages:
                        formViewModel.descriptionControl.validationMessages,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: 5,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(500),
                    ],
                    decoration: InputDecoration(
                        hintText: tr.form_field_study_description_hint),
                  ),
                ),
                FormTableRow(
                  control: formViewModel.tagsControl,
                  label: 'Tags',
                  labelHelpText: 'tr.form_field_study_tags_tooltip',
                  input: ReactiveFormConsumer(
                      builder: (context, form, child) {
                        final tags = ref.read(studyTagRepositoryProvider);
                        final selectedTags = formViewModel.tagsControl.value!
                            .map((e) => MultiSelectItem<StudyTag>(value: e, name: e.name))
                            .toList();
                        selectedTags.sort((a, b) => a.name.compareTo(b.name));

                        return Row(children: [
                          Wrap(
                            spacing: 8.0,
                            children: List<Widget>.generate(
                                formViewModel.tagsControl.value!.length, (index) {
                              return StudyTagBadge(
                                tag: formViewModel.tagsControl.value!.elementAt(index),
                                onRemove: () async {
                                  final newTags = List<StudyTag>.from(
                                      formViewModel.tagsControl.value!);
                                  newTags.removeAt(index);
                                  formViewModel.tagsControl.value = newTags;
                                },
                              );
                            }),
                          ),
                          const Spacer(),
                          FutureBuilder<List<StudyTag>>(
                              future: tags.getAllAvailableStudyTags(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<StudyTag>> snapshot) {
                                if (snapshot.hasData) {
                                  final allTags = snapshot.data!
                                      .map((e) => MultiSelectItem<StudyTag>(
                                      value: e, name: e.name))
                                      .toList();
                                  allTags.sort((a, b) => a.name.compareTo(b.name));
                                  return MultiSelectWidget<StudyTag>(
                                    items: allTags.toList(),
                                    selectedOptions: selectedTags,
                                    onConfirm: (selectedItems) async {
                                      formViewModel.tagsControl.value =
                                          selectedItems
                                              .map((e) => e.value)
                                              .toList();
                                    },
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              }),
                        ]);
                      }),
                ),
              ], columnWidths: const {
                0: FixedColumnWidth(185.0),
                1: FlexColumnWidth(),
              }),
              const SizedBox(height: 32.0),
              FormSectionHeader(title: tr.form_section_publisher),
              const SizedBox(height: 12.0),
              TextParagraph(text: tr.form_section_publisher_description),
              const SizedBox(height: 24.0),
              FormTableLayout(rows: [
                FormTableRow(
                  control: formViewModel.organizationControl,
                  label: tr.form_field_organization,
                  input: ReactiveTextField(
                    formControl: formViewModel.organizationControl,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    validationMessages:
                        formViewModel.organizationControl.validationMessages,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.reviewBoardControl,
                  label: tr.form_field_review_board,
                  input: ReactiveTextField(
                    formControl: formViewModel.reviewBoardControl,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    validationMessages:
                        formViewModel.reviewBoardControl.validationMessages,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.reviewBoardNumberControl,
                  label: tr.form_field_review_board_number,
                  input: ReactiveTextField(
                    formControl: formViewModel.reviewBoardNumberControl,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    validationMessages: formViewModel
                        .reviewBoardNumberControl.validationMessages,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.researchersControl,
                  label: tr.form_field_researchers,
                  input: ReactiveTextField(
                    formControl: formViewModel.researchersControl,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    validationMessages:
                        formViewModel.researchersControl.validationMessages,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.websiteControl,
                  label: tr.form_field_website,
                  input: ReactiveTextField(
                    formControl: formViewModel.websiteControl,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(300),
                    ],
                    validationMessages:
                        formViewModel.websiteControl.validationMessages,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.emailControl,
                  label: tr.form_field_contact_email,
                  input: ReactiveTextField(
                    formControl: formViewModel.emailControl,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    validationMessages:
                        formViewModel.emailControl.validationMessages,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.phoneControl,
                  label: tr.form_field_contact_phone,
                  input: ReactiveTextField(
                    formControl: formViewModel.phoneControl,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                    validationMessages:
                        formViewModel.phoneControl.validationMessages,
                  ),
                ),
                FormTableRow(
                  control: formViewModel.additionalInfoControl,
                  label: tr.form_field_contact_additional_info,
                  input: ReactiveTextField(
                    formControl: formViewModel.additionalInfoControl,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: 5,
                    inputFormatters: [LengthLimitingTextInputFormatter(500)],
                  ),
                ),
              ], columnWidths: const {
                0: FixedColumnWidth(180.0),
                1: FlexColumnWidth(),
              }),
            ],
          ),
        );
      },
    );
  }
}
