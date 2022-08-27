import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class ConsentItemFormView extends StatelessWidget {
  const ConsentItemFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final ConsentItemFormViewModel formViewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              control: formViewModel.titleControl,
              label: "Title".hardcoded,
              labelHelpText: "TODO Consent item title help text".hardcoded,
              input: Row(
                children: [
                  Expanded(
                    child: ReactiveTextField(
                      formControl: formViewModel.titleControl,
                    ),
                  ),
                  ReactiveFormConsumer(
                    builder: (context, form, child) {
                      return (formViewModel.iconControl.value != null)
                          ? const SizedBox(width: 4.0)
                          : const SizedBox(width: 8.0);
                    },
                  ),
                  IntrinsicWidth(
                    child: ReactiveIconPicker(
                      formControl: formViewModel.iconControl,
                      iconOptions: IconPack.material,
                    ),
                  )
                ],
              ),
            ),
            FormTableRow(
              control: formViewModel.descriptionControl,
              label: "Text".hardcoded,
              labelHelpText:
                  "TODO Consent item text help text".hardcoded,
              input: ReactiveTextField(
                formControl: formViewModel.descriptionControl,
                keyboardType: TextInputType.multiline,
                minLines: 10,
                maxLines: 30,
                decoration: InputDecoration(
                  hintText:
                      "Provide the complete text that your participant must read & agree to"
                          .hardcoded,
                ),
              ),
            ),
          ],
          columnWidths: const {
            0: MaxColumnWidth(FixedColumnWidth(90.0), IntrinsicColumnWidth()),
            1: FlexColumnWidth(),
          },
        ),
      ],
    );
  }
}
