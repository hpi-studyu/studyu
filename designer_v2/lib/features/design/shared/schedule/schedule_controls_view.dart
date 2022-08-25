import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/time_of_day.dart';

class ScheduleControls extends FormConsumerWidget {
  const ScheduleControls({required this.formViewModel, Key? key})
      : super(key: key);

  final WithScheduleControls formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionHeader(title: "Scheduling".hardcoded),
        const SizedBox(height: 12.0),
        FormTableLayout(rows: [
          FormTableRow(
            control: formViewModel.hasReminderControl,
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
                    text: "Send notification ".hardcoded),
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
                        builder: (BuildContext context,
                            ReactiveTimePickerDelegate picker, Widget? child) {
                          return ReactiveTextField<Time>(
                            formControl: formViewModel.reminderTimeControl,
                            valueAccessor: TimeValueAccessor(),
                            decoration: InputDecoration(
                                hintText: "hh:mm".hardcoded,
                                suffixIcon: Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                      splashRadius: 18.0,
                                      onPressed: picker.showPicker,
                                      icon: const Icon(Icons.access_time),
                                    ))),
                          );
                        },
                      )),
                    ],
                  ),
                )
              ],
            ),
          ),
          FormTableRow(
            control: formViewModel.isTimeRestrictedControl,
            label: "Time restriction".hardcoded,
            labelHelpText: "TODO Time restriction help text".hardcoded,
            input: ReactiveSwitch(
              formControl: formViewModel.isTimeRestrictedControl,
            ),
          ),
          ..._conditionalTimeRestrictions(context),
        ]),
      ],
    );
  }

  List<FormTableRow> _conditionalTimeRestrictions(BuildContext context) {
    if (!formViewModel.isTimeRestricted) {
      return [];
    }
    return [
      FormTableRow(
          control: formViewModel.restrictedTimeStartControl,
          label: " ",
          input: Row(
            children: [
              Flexible(
                child: ReactiveTimePicker(
                formControl: formViewModel.restrictedTimeStartControl,
                initialEntryMode: TimePickerEntryMode.input,
                builder: (BuildContext context,
                    ReactiveTimePickerDelegate picker, Widget? child) {
                  return ReactiveTextField<Time>(
                    formControl: formViewModel.restrictedTimeStartControl,
                    valueAccessor: TimeValueAccessor(),
                    decoration:
                        (formViewModel.restrictedTimeStartControl.enabled)
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
                                    )))
                            : const InputDecoration(),
                  );
                },
              )),
              const SizedBox(width: 10.0),
              Flexible(
                  child: ReactiveTimePicker(
                formControl: formViewModel.restrictedTimeEndControl,
                initialEntryMode: TimePickerEntryMode.input,
                builder: (BuildContext context,
                    ReactiveTimePickerDelegate picker, Widget? child) {
                  return ReactiveTextField<Time>(
                    formControl: formViewModel.restrictedTimeEndControl,
                    valueAccessor: TimeValueAccessor(),
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
                                )))
                        : const InputDecoration(),
                  );
                },
              )),
            ],
          )),
    ];
  }
}
