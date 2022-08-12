import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/side_sheet_modal.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class MeasurementSurveyFormView extends ConsumerWidget {
  const MeasurementSurveyFormView({
    required this.formViewModel,
    Key? key
  }) : super(key: key);

  final MeasurementSurveyFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FormTableLayout(
            rows: [
              FormTableRow(
                label: "Survey title".hardcoded,
                //labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelHelpText: "TODO Survey title help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.surveyTitleControl,
                ),
              ),
              FormTableRow(
                label: "Intro text".hardcoded,
                labelHelpText: "TODO Intro text help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.surveyIntroTextControl,
                ),
              ),
              FormTableRow(
                label: "Outro text".hardcoded,
                labelHelpText: "TODO Outro text help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.surveyOutroTextControl,
                ),
              ),
            ]
        ),
        const SizedBox(height: 28.0),
        ReactiveFormConsumer(
          // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
          // By default, ReactiveFormArray only updates when adding/removing controls
          builder: (context, form, child) {
            return ReactiveFormArray(
              formArray: formViewModel.surveyQuestionsArray,
              builder: (context, formArray, child) {
                return FormArrayTable<SurveyQuestionFormViewModel>(
                  items: formViewModel.surveyQuestionModels,
                  onSelectItem: (viewModel) => _onSelectItem(viewModel, context, ref),
                  getActionsAt: (viewModel, _) => formViewModel.availablePopupActions(viewModel),
                  onNewItem: () => _onNewItem(context, ref),
                  onNewItemLabel: 'Add question'.hardcoded,
                  rowTitle: (viewModel) => viewModel.formData?.questionText ?? 'Missing item title'.hardcoded,
                  sectionTitle: "Questions".hardcoded,
                  emptyIcon: Icons.content_paste_off_rounded,
                  emptyTitle: "No questions defined".hardcoded,
                  emptyDescription: "You need to define at least one question to determine the effect of your intervention(s).".hardcoded,
                );
              },
            );
          }
        ),
        const SizedBox(height: 28.0),
        ReactiveFormConsumer(
          builder: (context, form, child) {
            return _scheduleSection(context);
          }
        )
      ],
    );
  }

  Widget _scheduleSection(BuildContext context) {
    //formViewModel.reminderTimeControl.markAsDisabled();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormTableLayout(
            rows: [
              FormTableRow(
                label: "Scheduling".hardcoded,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                input: Container(),
              ),
            ]
        ),
        const Divider(),
        const SizedBox(height: 12.0),
        FormTableLayout(
            rows: [
              FormTableRow(
                label: "App reminder".hardcoded,
                labelHelpText: "TODO reminder notification help text".hardcoded,
                input: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ReactiveCheckbox(
                      formControl: formViewModel.hasReminderControl,
                    ),
                    const SizedBox(width: 3.0),
                    FormControlLabel(
                      formControl: formViewModel.hasReminderControl,
                      text: "Send notification ".hardcoded
                    ),
                    const SizedBox(width: 8.0),
                    Opacity(
                      opacity: (formViewModel.hasReminder) ? 1 : 0.5,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IntrinsicWidth(
                              child: ReactiveTimePicker(
                                formControl: formViewModel.reminderTimeControl,
                                initialEntryMode: TimePickerEntryMode.input,
                                builder: (BuildContext context, ReactiveTimePickerDelegate picker, Widget? child) {
                                  return ReactiveTextField(
                                    formControl: formViewModel.reminderTimeControl,
                                    decoration: InputDecoration(
                                      hintText: "hh:mm".hardcoded,
                                      suffixIcon: Material(
                                          color: Colors.transparent,
                                          child: IconButton(
                                            splashRadius: 18.0,
                                            onPressed: picker.showPicker,
                                            icon: const Icon(Icons.access_time),
                                          )
                                      )
                                    ),
                                  );
                                },
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              FormTableRow(
                label: "Time restriction".hardcoded,
                labelHelpText: "TODO Time restriction help text".hardcoded,
                input: ReactiveSwitch(
                  formControl: formViewModel.isTimeRestrictedControl,
                ),
              ),
              ..._conditionalTimeRestrictions(context),
            ]
        ),
      ],
    );
  }

  List<FormTableRow> _conditionalTimeRestrictions(BuildContext context) {
    if (!formViewModel.isTimeRestricted) {
      return [];
    }
    return [
      FormTableRow(
        label: " ",
        input: Row(
          children: [
            Flexible(
                child: ReactiveTimePicker(
                  formControl: formViewModel.restrictedTimeStartControl,
                  initialEntryMode: TimePickerEntryMode.input,
                  builder: (BuildContext context, ReactiveTimePickerDelegate picker, Widget? child) {
                    return ReactiveTextField(
                      formControl: formViewModel.restrictedTimeStartControl,
                      decoration: (formViewModel.restrictedTimeStartControl.enabled)
                          ? InputDecoration(
                          labelText: "From".hardcoded,
                          helperText: "",
                          hintText: "hh:mm".hardcoded,
                          suffixIcon: Material(
                              color: Colors.transparent,
                              child: IconButton(
                                splashRadius: 18.0,
                                onPressed: picker.showPicker,
                                icon: const Icon(Icons.access_time),
                              )
                          )
                      ) : const InputDecoration(),
                    );
                  },
                )
            ),
            const SizedBox(width: 10.0),
            Flexible(
                child: ReactiveTimePicker(
                  formControl: formViewModel.restrictedTimeEndControl,
                  initialEntryMode: TimePickerEntryMode.input,
                  builder: (BuildContext context, ReactiveTimePickerDelegate picker, Widget? child) {
                    return ReactiveTextField(
                      formControl: formViewModel.restrictedTimeEndControl,
                      decoration: (formViewModel.restrictedTimeEndControl.enabled)
                          ? InputDecoration(
                          labelText: "To".hardcoded,
                          helperText: "",
                          hintText: "hh:mm".hardcoded,
                          suffixIcon: Material(
                              color: Colors.transparent,
                              child: IconButton(
                                splashRadius: 18.0,
                                onPressed: picker.showPicker,
                                icon: const Icon(Icons.access_time),
                              )
                          )
                      ) : const InputDecoration(),
                    );
                  },
                )
            ),
          ],
        )
      ),
    ];
  }

  _onNewItem(BuildContext context, WidgetRef ref) {
    final routeArgs = formViewModel.buildNewFormRouteArgs();
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  _onSelectItem(SurveyQuestionFormViewModel item, BuildContext context, WidgetRef ref) {
    final routeArgs = formViewModel.buildFormRouteArgs(item);
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  _showSidesheetWithArgs(
      SurveyQuestionFormRouteArgs routeArgs,
      BuildContext context,
      WidgetRef ref)
  {
    final surveyQuestionFormViewModel = ref.read(
        surveyQuestionFormViewModelProvider(routeArgs));
    showFormSideSheet<SurveyQuestionFormViewModel>(
      context: context,
      formViewModel: surveyQuestionFormViewModel,
      formViewBuilder: (formViewModel) => SurveyQuestionFormView(
          formViewModel: formViewModel),
      ignoreAppBar: true,
    );
  }
}
