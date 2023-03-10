import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ConsentItemFormView extends StatelessWidget {
  const ConsentItemFormView({required this.formViewModel, super.key});

  final ConsentItemFormViewModel formViewModel;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(builder: (context, formGroup, child)
    {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              FormTableRow(
                control: formViewModel.titleControl,
                label: tr.form_field_consent_title,
                labelHelpText: tr.form_field_consent_title_tooltip,
                input: Row(
                  children: [
                    Expanded(
                      child: ReactiveTextField(
                        formControl: formViewModel.titleControl,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        validationMessages: formViewModel.titleControl
                            .validationMessages,
                        decoration: InputDecoration(
                          hintText: tr.form_field_consent_title_hint,
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
                label: tr.form_field_consent_text,
                labelHelpText: tr.form_field_consent_text_tooltip,
                input: ReactiveTextField(
                  formControl: formViewModel.descriptionControl,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10000),
                  ],
                  validationMessages: formViewModel.descriptionControl
                      .validationMessages,
                  keyboardType: TextInputType.multiline,
                  minLines: 10,
                  maxLines: 30,
                  decoration: InputDecoration(
                    hintText: tr.form_field_consent_text_hint,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
