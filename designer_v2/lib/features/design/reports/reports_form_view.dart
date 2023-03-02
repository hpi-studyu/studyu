import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class StudyDesignReportsFormView extends StudyDesignPageWidget {
  const StudyDesignReportsFormView(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));
    final theme = Theme.of(context);

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.read(reportsFormViewModelProvider(studyId));
        final items = formViewModel.reportSectionFormViewModels.formViewModels;
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(text: 'tr.form_study_design_measurements_description'),
              const SizedBox(height: 32.0),
              ReactiveFormConsumer(
                  // [ReactiveFormConsumer] is needed to rerender when descendant controls are updated
                  // By default, ReactiveFormArray only updates when adding/removing controls
                  builder: (context, form, child) {
                return ReactiveFormArray(
                  formArray: formViewModel.reportsArray,
                  builder: (context, formArray, child) {
                    return FormArrayTable<ReportSectionFormViewModel>(
                      control: formViewModel.reportsArray,
                      items: items,
                      // onSelectItem: formViewModel.onSelectItem,
                      onSelectItem: (viewModel) {
                        final routeArgs = formViewModel.buildResultItemFormRouteArgs(viewModel);
                        _showResultItemSidesheetWithArgs(routeArgs, context, ref);
                      },
                      getActionsAt: (viewModel, _) => formViewModel.availablePopupActions(viewModel),
                      // onNewItem: formViewModel.onNewItem,
                      onNewItem: () {
                        final routeArgs = formViewModel.buildNewResultItemFormRouteArgs();
                        _showResultItemSidesheetWithArgs(routeArgs, context, ref);
                      },
                      onNewItemLabel: 'New Report',
                      //tr.form_array_reports_new,
                      rowTitle: (viewModel) => viewModel.formData?.title ?? '',
                      sectionTitle: 'Reports',
                      //tr.form_array_reports,
                      sectionTitleDivider: false,
                      emptyIcon: Icons.content_paste_off_rounded,
                      emptyTitle: 'Report Title',
                      //tr.form_array_reports_empty_title,
                      emptyDescription: 'Report Description',
                      //tr.form_array_reports_empty_description,
                      hideLeadingTrailingWhenEmpty: true,
                      rowPrefix: (context, viewModel, rowIdx) {
                        return Row(
                          children: [
                            Text(
                              ''.alphabetLetterFrom(rowIdx).toUpperCase(),
                              style: TextStyle(
                                color: ThemeConfig.dropdownMenuItemTheme(theme).iconTheme!.color,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                          ],
                        );
                      },
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  _showResultItemSidesheetWithArgs(
    ReportSectionFormRouteArgs routeArgs,
    BuildContext context,
    WidgetRef ref,
  ) {
    final formViewModel = ref.read(reportSectionFormViewModelProvider(routeArgs));

    showFormSideSheet<ReportSectionFormViewModel>(
      context: context,
      formViewModel: formViewModel,
      formViewBuilder: (formViewModel) => ReportSectionFormView(formViewModel: formViewModel),
    );
  }
}
