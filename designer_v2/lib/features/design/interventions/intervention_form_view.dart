import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/common_views/styling_information.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';

class InterventionFormView extends ConsumerStatefulWidget {
  const InterventionFormView({required this.formViewModel, Key? key}) : super(key: key);

  final InterventionFormViewModel formViewModel;

  @override
  ConsumerState<InterventionFormView> createState() => _InterventionFormViewState();
}

class _InterventionFormViewState extends ConsumerState<InterventionFormView> {
  bool isStylingInformationDismissed = true;

  onDismissedCallback() => setState(() {
        isStylingInformationDismissed = !isStylingInformationDismissed;
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              control: widget.formViewModel.interventionTitleControl,
              label: tr.form_field_intervention_title,
              labelHelpText: tr.form_field_intervention_title_tooltip,
              input: Row(
                children: [
                  // TODO: responsive layout (input field gets too small)
                  Expanded(
                    child: ReactiveTextField(
                      formControl: widget.formViewModel.interventionTitleControl,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(200),
                      ],
                      validationMessages: widget.formViewModel.interventionTitleControl.validationMessages,
                    ),
                  ),
                  ReactiveFormConsumer(builder: (context, form, child) {
                    return (widget.formViewModel.interventionIconControl.value != null)
                        ? const SizedBox(width: 4.0)
                        : const SizedBox(width: 8.0);
                  }),
                  IntrinsicWidth(
                    child: ReactiveIconPicker(
                      formControl: widget.formViewModel.interventionIconControl,
                      iconOptions: IconPack.material,
                    ),
                  )
                ],
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.interventionDescriptionControl,
              labelBuilder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormLabel(
                    labelText: tr.form_field_intervention_description,
                    helpText: tr.form_field_intervention_description_tooltip,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(left: 3.0),
                    child: Opacity(
                      opacity: ThemeConfig.kMuteFadeFactor,
                      child: Tooltip(
                        message: "Use html to style your content",
                        child: Hyperlink(
                          text: "styleable",
                          onClick: () => setState(() {
                            isStylingInformationDismissed = !isStylingInformationDismissed;
                          }),
                          visitedColor: null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              input: ReactiveTextField(
                formControl: widget.formViewModel.interventionDescriptionControl,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2000),
                ],
                validationMessages: widget.formViewModel.interventionDescriptionControl.validationMessages,
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
        HtmlStylingBanner(
          isDismissed: isStylingInformationDismissed,
          onDismissed: onDismissedCallback,
        ),
        const SizedBox(height: 28.0),
        ReactiveFormConsumer(
            // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
            // By default, ReactiveFormArray only updates when adding/removing controls
            builder: (context, form, child) {
          return ReactiveFormArray(
            formArray: widget.formViewModel.interventionTasksArray,
            builder: (context, formArray, child) {
              return FormArrayTable<InterventionTaskFormViewModel>(
                control: widget.formViewModel.interventionTasksArray,
                items: widget.formViewModel.tasksCollection.formViewModels,
                onSelectItem: (viewModel) => _onSelectItem(viewModel, context, ref),
                getActionsAt: (viewModel, _) => widget.formViewModel.availablePopupActions(viewModel),
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
    final routeArgs = widget.formViewModel.buildNewFormRouteArgs();
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  _onSelectItem(InterventionTaskFormViewModel item, BuildContext context, WidgetRef ref) {
    final routeArgs = widget.formViewModel.buildFormRouteArgs(item);
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  _showSidesheetWithArgs(InterventionTaskFormRouteArgs routeArgs, BuildContext context, WidgetRef ref) {
    final interventionTaskFormViewModel = ref.read(interventionTaskFormViewModelProvider(routeArgs));
    showFormSideSheet<InterventionTaskFormViewModel>(
      context: context,
      formViewModel: interventionTaskFormViewModel,
      formViewBuilder: (formViewModel) => InterventionTaskFormView(formViewModel: formViewModel),
      ignoreAppBar: true,
    );
  }
}
