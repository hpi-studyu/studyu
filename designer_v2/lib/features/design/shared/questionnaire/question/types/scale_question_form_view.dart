import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/bool_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/shared_question_views.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

abstract class IScaleQuestionFormViewModel {
  bool get isMidValuesClearedInfoVisible;
}

class ScaleQuestionFormView extends QuestionTypeFormView {
  const ScaleQuestionFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return content(context);
  }

  @override
  Widget content(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(
          rowLayout: FormTableRowLayout.vertical,
          rows: [
            buildQuestionTextControlRow(formViewModel: formViewModel),
          ],
        ),
        const SizedBox(height: 18.0),
        FormSectionHeader(
          title: "Response options",
          helpText:
              "Define the options that participants can answer your question with"
                  .hardcoded,
          divider: false,
        ),
        const SizedBox(height: 12.0),
        const SizedBox(height: 8.0),
        _buildLabelValueControlsPair(
          labelControl: formViewModel.scaleMinLabelControl,
          valueControl: formViewModel.scaleMinValueControl,
          labelControlLabel: "Custom low label".hardcoded,
          labelControlHelpText:
              "Enter a custom label to display at the value's "
                      "position on the scale, \notherwise the numeric value is "
                      "displayed as the label"
                  .hardcoded,
          valueControlLabel: "Low value".hardcoded,
          valueControlHelpText: null,
        ),
        const SizedBox(height: 8.0),
        /*
        ExpansionTile(
          title: FormSectionHeader(
            title: "See mid-value".hardcoded,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.normal),
            divider: false,
          ),
          tilePadding: EdgeInsets.zero,
          children: [
            Text("TODO"),
            Text("TODO"),
          ],
        ),

         */
        /*
        ExpansionPanelList(
          elevation: 0,
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Row(
                  children: [
                FormSectionHeader(
                title: "See in-between values".hardcoded,
                  titleTextStyle: const TextStyle(fontWeight: FontWeight.normal),
                  divider: false,
                ),
                    ExpandIcon(onPressed: (_) {}, isExpanded: false,),
                  ],
                );
              },
              body: Column(
                children: [
                  Text("TODO"),
                  Text("TODO"),
                ],
              ),
              canTapOnHeader: true,
            )
          ],
        ),

         */
        FormSectionHeader(
          title: "See in-between values".hardcoded,
          titleTextStyle: const TextStyle(fontWeight: FontWeight.normal),
          divider: false,
        ),
        ReactiveFormConsumer(
          builder: (context, formArray, child) {
            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              //padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
              child: BannerBox(
                style: BannerStyle.info,
                body: TextParagraph(
                    text:
                        "The in-between values and labels are cleared "
                        "automatically to reflect the low & high of the "
                        "scale." .hardcoded),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0, vertical: 12.0),
                noPrefix: true,
                isDismissed: !formViewModel.isMidValuesClearedInfoVisible,
                dismissIconSize: Theme.of(context).iconTheme.size ?? 14.0,
              ),
            );
          },
        ),
        ReactiveFormArray(
          formArray: formViewModel.scaleMidValueControls,
          builder: (context, formArray, child) {
            if (formArray.controls.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(formArray.controls.length, (i) {
                final valueControl = formViewModel
                    .scaleMidValueControls.controls[i] as FormControl;
                final labelControl = formViewModel
                    .scaleMidLabelControls.controls[i] as FormControl;

                return _buildLabelValueControlsPair(
                  labelControl: labelControl,
                  valueControl: valueControl,
                );
              }),
            );
          },
        ),
        const SizedBox(height: 8.0),
        const SizedBox(height: 8.0),
        _buildLabelValueControlsPair(
          labelControl: formViewModel.scaleMaxLabelControl,
          valueControl: formViewModel.scaleMaxValueControl,
          labelControlLabel: "Custom high label".hardcoded,
          labelControlHelpText:
              "Enter a custom label to display at the value's "
                      "position on the scale, \notherwise the numeric value is "
                      "displayed as the label"
                  .hardcoded,
          valueControlLabel: "High value".hardcoded,
          valueControlHelpText: null,
        ),
      ],
    );
  }

  Widget _buildLabelValueControlsPair({
    required FormControl labelControl,
    required FormControl valueControl,
    String? labelControlLabel,
    String? labelControlHelpText,
    String? valueControlLabel,
    String? valueControlHelpText,
  }) {
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              FormTableRow(
                control: labelControl,
                label: labelControlLabel,
                labelHelpText: labelControlHelpText,
                input: ReactiveTextField(
                  key: UniqueKey(),
                  formControl: labelControl,
                  validationMessages: labelControl.validationMessages,
                  decoration: InputDecoration(
                    hintText: "Optional label".hardcoded,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12.0),
        Flexible(
          flex: 3,
          child: FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              FormTableRow(
                control: valueControl,
                label: valueControlLabel,
                labelHelpText: valueControlHelpText,
                input: ReactiveTextField(
                  key: ValueKey(valueControl.value),
                  formControl: valueControl,
                  validationMessages: valueControl.validationMessages,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
