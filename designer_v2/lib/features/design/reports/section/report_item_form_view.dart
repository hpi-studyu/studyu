import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/section_type.dart';

class ReportSectionFormView extends ConsumerStatefulWidget {
  const ReportSectionFormView({required this.formViewModel, super.key});

  final ReportSectionFormViewModel formViewModel;

  @override
  ConsumerState<ReportSectionFormView> createState() => _ReportItemFormViewState();


}
class _ReportItemFormViewState extends ConsumerState<ReportSectionFormView> {
  ReportSectionFormViewModel get formViewModel => widget.formViewModel;

  late bool isQuestionHelpTextFieldVisible = formViewModel.sectionInfoTextControl.value?.isNotEmpty ?? false;

  WidgetBuilder get sectionTypeBodyBuilder {
    final Map<ReportSectionType, WidgetBuilder> questionTypeWidgets = {
      ReportSectionType.average: (_) => ChoiceQuestionFormView(formViewModel: formViewModel),
      ReportSectionType.linearRegression: (_) => BoolQuestionFormView(formViewModel: formViewModel),
    };
    final questionType = formViewModel.sectionType;

    if (!questionTypeWidgets.containsKey(questionType)) {
      throw Exception("Failed to build widget for SurveyQuestionType $questionType because"
          "there is no registered WidgetBuilder");
    }
    final builder = questionTypeWidgets[questionType]!;
    return builder;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FormTableLayout(
        rowLayout: FormTableRowLayout.vertical,
        rows: [
          FormTableRow(
              control: formViewModel.titleControl,
              label: 'ReportItemTitle',
              labelHelpText: 'ReportItemTooltip',
              input: Row(children: const [
                Text("Hi"),
              ]))
        ],
      )
    ]);
  }

  Widget _buildSectionBody() {
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
  }

}
