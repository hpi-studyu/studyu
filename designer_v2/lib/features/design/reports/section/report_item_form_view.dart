import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/average_section_form_view.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/linearRegression_section_form_view.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/section_type.dart';
import 'package:studyu_designer_v2/theme.dart';

class ReportSectionFormView extends ConsumerStatefulWidget {
  const ReportSectionFormView({required this.formViewModel, super.key});

  final ReportSectionFormViewModel formViewModel;

  @override
  ConsumerState<ReportSectionFormView> createState() => _ReportItemFormViewState();


}
class _ReportItemFormViewState extends ConsumerState<ReportSectionFormView> {
  ReportSectionFormViewModel get formViewModel => widget.formViewModel;

  //late bool isQuestionHelpTextFieldVisible = formViewModel.sectionInfoTextControl.value?.isNotEmpty ?? false;

  WidgetBuilder get sectionTypeBodyBuilder {
    final Map<ReportSectionType, WidgetBuilder> sectionTypeWidgets = {
      ReportSectionType.average: (_) => AverageSectionFormView(formViewModel: formViewModel),
      ReportSectionType.linearRegression: (_) => LinearRegressionSectionFormView(formViewModel: formViewModel),
    };
    final sectionType = formViewModel.sectionType;

    if (!sectionTypeWidgets.containsKey(sectionType)) {
      throw Exception("Failed to build widget for ReportSectionType $sectionType because"
          "there is no registered WidgetBuilder");
    }
    final builder = sectionTypeWidgets[sectionType]!;
    return builder;
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(builder: (context, formGroup, child) {
      // Wrap everything in a [ReactiveFormConsumer] for convenience so that the
      // sidesheet content is re-rendered when the form changes
      //
      // Note: if this becomes a performance issue, remove the
      // ReactiveFormConsumer here & use consumers / listeners selectively for
      // the UI parts that need to be rebuild
      return Column(
      children: [
        _buildSectionText(context),
        _buildSectionTypeHeader(context),
        sectionTypeBodyBuilder(context),
      ]);
    });
  }

  _buildSectionText(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
          control: formViewModel.titleControl,
          label: 'tr.form_field_consent_title',
          labelHelpText: 'tr.form_field_consent_title_tooltip',
          input: /*Expanded(
            child: */ReactiveTextField(
              formControl: formViewModel.titleControl,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              //validationMessages: formViewModel.titleControl.validationMessages,
              decoration: const InputDecoration(
                hintText: 'tr.form_field_consent_title_hint',
              ),
            ),
          ),
        //),
        FormTableRow(
          control: formViewModel.descriptionControl,
          label: 'tr.form_field_consent_text',
          labelHelpText: 'tr.form_field_consent_text_tooltip',
          input: ReactiveTextField(
            formControl: formViewModel.descriptionControl,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10000),
            ],
            //validationMessages: formViewModel.descriptionControl.validationMessages,
            keyboardType: TextInputType.multiline,
            minLines: 10,
            maxLines: 30,
            decoration: const InputDecoration(
              hintText: 'tr.form_field_consent_text_hint',
            ),
          ),
        ),
      ],
    );
  }

  _buildSectionTypeHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: 'tr.form_field_question_response_options',
              labelHelpText: 'tr.form_field_question_response_options_tooltip',
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              // TODO: extract custom dropdown component with theme + focus fix
              input: Theme(
                data: theme.copyWith(inputDecorationTheme: ThemeConfig.dropdownInputDecorationTheme(theme)),
                child: ReactiveDropdownField<ReportSectionType>(
                  formControl: formViewModel.sectionTypeControl,
                  items: ReportSectionFormViewModel.sectionTypeControlOptions.map((option) {
                    final menuItemTheme = ThemeConfig.dropdownMenuItemTheme(theme);
                    final iconTheme = menuItemTheme.iconTheme ?? theme.iconTheme;

                    return DropdownMenuItem(
                      value: option.value,
                      child: Row(
                        children: [
                          (option.value.icon != null)
                              ? Icon(option.value.icon,
                              size: iconTheme.size, color: iconTheme.color, shadows: iconTheme.shadows)
                              : const SizedBox.shrink(),
                          const SizedBox(width: 16.0),
                          Text(option.label)
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        TextParagraph(
          text: 'tr.form_field_question_response_options_description',
          style: ThemeConfig.bodyTextMuted(theme),
        )
      ],
    );
  }

  // todo delme designer v1
  /*Widget _buildSectionBody() {
    switch (widget.section.runtimeType) {
      case AverageSection:
        return AverageSectionEditorSection(
          section: widget.section as AverageSection,
        );
      case LinearRegressionSection:
        return LinearRegressionSectionEditorSection(
          section: widget.section as LinearRegressionSection,
        );
      default:
        return null;
    }
  }

  void _changeSectionType(String newType) {
    ReportSection newSection;

    if (newType == LinearRegressionSection.sectionType) {
      newSection = LinearRegressionSection.withId();
    } else {
      newSection = AverageSection.withId();
    }

    newSection
      ..title = widget.section.title
      ..description = widget.section.description;

    widget.updateSection(newSection);
  }*/
}
