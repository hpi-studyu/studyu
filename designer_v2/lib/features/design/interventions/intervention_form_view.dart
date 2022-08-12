import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/common_views/side_sheet_modal.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class InterventionFormView extends ConsumerWidget {
  const InterventionFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final InterventionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FormTableLayout(rows: [
          FormTableRow(
              label: "Title".hardcoded,
              //labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              labelHelpText: "TODO Intervention task title help text".hardcoded,
              input: Row(
                children: [
                  // TODO: responsive layout (input field gets too small)
                  Expanded(
                      child: ReactiveTextField(
                    formControl: formViewModel.interventionTitleControl,
                  )),
                  ReactiveFormConsumer(builder: (context, form, child) {
                    return (formViewModel.interventionIconControl.value != null)
                        ? const SizedBox(width: 4.0)
                        : const SizedBox(width: 8.0);
                  }),
                  IntrinsicWidth(
                    child: ReactiveIconPicker(
                      formControl: formViewModel.interventionIconControl,
                      iconOptions: IconPack.material,
                    ),
                  )
                ],
              )),
          FormTableRow(
            label: "Description".hardcoded,
            labelHelpText:
                "TODO Intervention task description help text".hardcoded,
            input: ReactiveTextField(
              formControl: formViewModel.interventionDescriptionControl,
            ),
          ),
        ]),
        const SizedBox(height: 28.0),
        FormTableLayout(rows: [
          FormTableRow(
              label: "Treatments".hardcoded,
              input: Container(),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold))
        ]),
        const Divider(),
        const SizedBox(height: 6.0),
        TextParagraph(
            text: "You can define one or more tasks that your participants should "
                    "complete during the intervention phase. Participants will be "
                    "prompted to complete these tasks in the StudyU app.\nYou can "
                    "track compliance by requiring participants to mark these tasks "
                    "as completed."
                .hardcoded),
        const SizedBox(height: 6.0),
        ReactiveFormConsumer(
            // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
            // By default, ReactiveFormArray only updates when adding/removing controls
            builder: (context, form, child) {
          return ReactiveFormArray(
            formArray: formViewModel.interventionTasksArray,
            builder: (context, formArray, child) {
              return FormArrayTable<InterventionTaskFormViewModel>(
                items: formViewModel.tasksCollection.formViewModels,
                onSelectItem: (viewModel) =>
                    _onSelectItem(viewModel, context, ref),
                getActionsAt: (viewModel, _) =>
                    formViewModel.availablePopupActions(viewModel),
                onNewItem: () => _onNewItem(context, ref),
                onNewItemLabel: 'Add treatment'.hardcoded,
                rowTitle: (viewModel) =>
                    viewModel.formData?.taskTitle ??
                    'Missing item title'.hardcoded,
                emptyIcon: Icons.content_paste_off_rounded,
                emptyTitle: "No treatments defined".hardcoded,
                emptyDescription:
                    "You must define at least one task for your participants to complete during this intervention phase"
                        .hardcoded,
              );
            },
          );
        }),
      ],
    );
  }

  _onNewItem(BuildContext context, WidgetRef ref) {
    final routeArgs = formViewModel.buildNewFormRouteArgs();
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  _onSelectItem(
      InterventionTaskFormViewModel item, BuildContext context, WidgetRef ref) {
    final routeArgs = formViewModel.buildFormRouteArgs(item);
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  _showSidesheetWithArgs(InterventionTaskFormRouteArgs routeArgs,
      BuildContext context, WidgetRef ref) {
    final interventionTaskFormViewModel =
        ref.read(interventionTaskFormViewModelProvider(routeArgs));
    showFormSideSheet<InterventionTaskFormViewModel>(
      context: context,
      formViewModel: interventionTaskFormViewModel,
      formViewBuilder: (formViewModel) =>
          InterventionTaskFormView(formViewModel: formViewModel),
      ignoreAppBar: true,
    );
  }
}
