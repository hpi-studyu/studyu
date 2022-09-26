import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class InterventionFormView extends ConsumerWidget {
  const InterventionFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final InterventionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              control: formViewModel.interventionTitleControl,
              label: tr.form_field_intervention_title,
              labelHelpText: tr.form_field_intervention_title_tooltip,
              input: Row(
                children: [
                  // TODO: responsive layout (input field gets too small)
                  Expanded(
                    child: ReactiveTextField(
                      formControl: formViewModel.interventionTitleControl,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(200),
                      ],
                      validationMessages: formViewModel
                          .interventionTitleControl.validationMessages,
                    ),
                  ),
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
              ),
            ),
            FormTableRow(
              control: formViewModel.interventionDescriptionControl,
              label: tr.form_field_intervention_description,
              labelHelpText: tr.form_field_intervention_description_tooltip,
              input: ReactiveTextField(
                formControl: formViewModel.interventionDescriptionControl,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2000),
                ],
                validationMessages: formViewModel
                    .interventionDescriptionControl.validationMessages,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 5,
                decoration: InputDecoration(
                    hintText: tr.form_field_intervention_description_hint,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28.0),
        ReactiveFormConsumer(
            // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
            // By default, ReactiveFormArray only updates when adding/removing controls
            builder: (context, form, child) {
          return ReactiveFormArray(
            formArray: formViewModel.interventionTasksArray,
            builder: (context, formArray, child) {
              return FormArrayTable<InterventionTaskFormViewModel>(
                control: formViewModel.interventionTasksArray,
                items: formViewModel.tasksCollection.formViewModels,
                onSelectItem: (viewModel) =>
                    _onSelectItem(viewModel, context, ref),
                getActionsAt: (viewModel, _) =>
                    formViewModel.availablePopupActions(viewModel),
                onNewItem: () => _onNewItem(context, ref),
                onNewItemLabel: tr.form_array_intervention_tasks_new,
                rowTitle: (viewModel) => viewModel.formData?.taskTitle ?? '',
                sectionTitle: tr.form_array_intervention_tasks,
                sectionDescription: tr.form_array_intervention_tasks_description,
                emptyIcon: Icons.content_paste_off_rounded,
                emptyTitle: tr.form_array_intervention_tasks_empty_title,
                emptyDescription: tr.form_array_intervention_tasks_empty_description,
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
