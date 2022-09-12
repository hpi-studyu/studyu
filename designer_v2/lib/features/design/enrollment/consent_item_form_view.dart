import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
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
          rowLayout: FormTableRowLayout.vertical,
          rows: [
            FormTableRow(
              control: formViewModel.titleControl,
              label: "Title".hardcoded,
              labelHelpText: "Enter a short title for the terms the participant must read & accept.\nFor each consent text, a card with the title & icon is shown on the app's consent screen.".hardcoded,
              input: Row(
                children: [
                  Expanded(
                    child: ReactiveTextField(
                      formControl: formViewModel.titleControl,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validationMessages:
                          formViewModel.titleControl.validationMessages,
                      decoration: InputDecoration(
                        hintText:
                        "Enter a short title"
                            .hardcoded,
                      ),
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
              labelHelpText: "Enter the terms the participant must read & accept when enrolling in the study.\nThe terms are shown when clicking on the corresponding card in the app's consent screen.".hardcoded,
              input: ReactiveTextField(
                formControl: formViewModel.descriptionControl,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10000),
                ],
                validationMessages:
                    formViewModel.descriptionControl.validationMessages,
                keyboardType: TextInputType.multiline,
                minLines: 10,
                maxLines: 30,
                decoration: InputDecoration(
                  hintText:
                      "Enter the full terms to be read & accepted"
                          .hardcoded,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
