import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/common_views/side_sheet_modal.dart';
import 'package:studyu_designer_v2/features/design/common_views/form_array_table.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

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
                label: tr.survey_title,
                //labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelHelpText: tr.survey_help_text,
                input: ReactiveTextField(
                  formControl: formViewModel.surveyTitleControl,
                ),
              ),
              FormTableRow(
                label: tr.intro_text,
                labelHelpText: tr.intro_help_text,
                input: ReactiveTextField(
                  formControl: formViewModel.surveyIntroTextControl,
                ),
              ),
              FormTableRow(
                label: tr.outro_text,
                labelHelpText: tr.outro_help_text,
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
                return FormArrayTable<SurveyQuestionFormData>(
                  items: formViewModel.surveyQuestionsData,
                  onSelectItem: (item) => _onSelectItem(item, context, ref),
                  getActionsAt: (item, _) => formViewModel.availablePopupActions(item),
                  onNewItem: () => _onNewItem(context, ref),
                  onNewItemLabel: 'Add question',
                  rowTitle: (data) => data.questionText,
                  sectionTitle: tr.questions,
                  emptyIcon: Icons.content_paste_off_rounded,
                  emptyTitle: tr.no_questions,
                  emptyDescription: tr.no_questions_defined_text,
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
                label: tr.sheduling,
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
                label: tr.app_reminder,
                labelHelpText: tr.app_reminder_helptext,
                input: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ReactiveCheckbox(
                      formControl: formViewModel.hasReminderControl,
                    ),
                    const SizedBox(width: 3.0),
                    FormControlLabel(
                      formControl: formViewModel.hasReminderControl,
                      text: tr.send_notification
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
                                      hintText: tr.hh_mm,
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
                label: tr.time_restriction,
                labelHelpText: tr.time_rescrition_notification_text,
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
                          labelText: tr.from,
                          helperText: "",
                          hintText: tr.hh_mm,
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
                          labelText: tr.to,
                          helperText: "",
                          hintText: tr.hh_mm,
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

  _onSelectItem(SurveyQuestionFormData item, BuildContext context, WidgetRef ref) {
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
