import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

import '../../common_views/primary_button.dart';

class InviteCodeFormView extends ConsumerWidget {
  const InviteCodeFormView({required this.studyId, Key? key}) : super(key: key);

  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(studyRecruitControllerProvider(studyId).notifier);
    final form = controller.inviteCodeForm;

    return ReactiveForm(
      formGroup: form.form,
      child: Column(
        children: [
          FormTableLayout(
            rows: [
              FormTableRow(
                label: "Access Code".hardcoded,
                labelHelpText: "TODO Access code help text".hardcoded,
                input: ReactiveTextField(
                    formControl: form.codeControl,
                    decoration: InputDecoration(
                      helperText: "",
                      suffixIcon: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          splashRadius: 18.0,
                          onPressed: form.regenerateCode,
                          icon: const Icon(Icons.refresh_rounded),
                      )),
                    ),
                ),
              )
            ]
          ),
          FormTableLayout(
              rows: [
                FormTableRow(
                  label: "Intervention A".hardcoded,
                  input: ReactiveDropdownField<String>(
                    formControl: form.interventionAControl,
                    hint: Text('Select intervention...'.hardcoded),
                    decoration: const NullHelperDecoration(),
                    items: form.interventionControlOptions.map(
                      (option) => DropdownMenuItem(
                        value: option.value,
                        child: Text(option.label),
                      )).toList(),
                  ),
                ),
                FormTableRow(
                  label: "Intervention B".hardcoded,
                  input: ReactiveDropdownField<String>(
                    formControl: form.interventionBControl,
                    hint: Text('Select intervention...'.hardcoded),
                    decoration: const NullHelperDecoration(),
                    items: form.interventionControlOptions.map(
                        (option) => DropdownMenuItem(
                      value: option.value,
                      child: Text(option.label),
                    )).toList(),
                  ),
                )
              ]
          ),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              return PrimaryButton(
                text: "Save".hardcoded,
                icon: null,
                onPressed: (form.valid) ? () => print("valid") : null,
              );
            }
          ),
        ],
      )
    );

    return ReactiveForm(
        formGroup: form.form,
        child: Column(
          children: <Widget>[
            ReactiveTextField(
              formControl: form.codeControl,
            ),
            SizedBox(height: 24,),
            ReactiveSwitch(
              formControl: form.isPreconfiguredScheduleControl
            ),
            ReactiveDropdownField<String>(
              formControl: form.interventionAControl,
              hint: Text('Select payment...'),
              items: [
                DropdownMenuItem(
                  value: '0',
                  child: Text('Free'),
                ),
                DropdownMenuItem(
                  value: '1',
                  child: Text('Visa'),
                ),
              ],
            ),
            ReactiveDropdownField<String>(
              formControl: form.interventionAControl,
              hint: Text('Select payment...'),
              items: [
                DropdownMenuItem(
                  value: '0',
                  child: Text('Free'),
                ),
                DropdownMenuItem(
                  value: '1',
                  child: Text('Visa'),
                ),
              ],
            ),
          ],
        )
    );
  }
}
