import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/collapse.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';


abstract class IScaleQuestionFormViewModel {
  bool get isMidValuesClearedInfoVisible;
}

class ScaleQuestionFormView extends ConsumerStatefulWidget {
  const ScaleQuestionFormView({
    required this.formViewModel,
    Key? key,
  }) : super(key: key);

  final QuestionFormViewModel formViewModel;

  @override
  ConsumerState<ScaleQuestionFormView> createState() =>
      _ScaleQuestionFormViewState();
}

class _ScaleQuestionFormViewState extends ConsumerState<ScaleQuestionFormView> {
  QuestionFormViewModel get formViewModel => widget.formViewModel;

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        const SizedBox(height: 16.0),
        Collapsible(
          title: "See mid-values".hardcoded,
          contentBuilder: (context, _) => _buildMidValuesSection(context),
        ),
        const SizedBox(height: 12.0),
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

  Widget _buildMidValuesSection(BuildContext context) {
    return Column(
      children: [
        ReactiveFormConsumer(
          builder: (context, formArray, child) {
            return (!formViewModel.isReadonly)
                ? Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: BannerBox(
                      style: BannerStyle.info,
                      body: TextParagraph(
                          text: "The mid-values values and labels are cleared "
                                  "automatically to reflect the low & high of the "
                                  "scale."
                              .hardcoded),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 12.0),
                      noPrefix: true,
                      isDismissed: !formViewModel.isMidValuesClearedInfoVisible,
                      dismissIconSize: Theme.of(context).iconTheme.size ?? 14.0,
                    ),
                  )
                : const SizedBox.shrink();
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
              // tr.text and tr.question_text_help_text removed .hardcoded
              FormTableRow(
                control: labelControl,
                label: labelControlLabel,
                labelHelpText: labelControlHelpText,
                input: ReactiveTextField(
                  key: UniqueKey(),
                  formControl: labelControl,
                  validationMessages: labelControl.validationMessages,
                  decoration: (!formViewModel.isReadonly)
                      ? InputDecoration(
                          hintText: "Optional label".hardcoded,
                        )
                      : const InputDecoration(),
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
              // tr.type removed .hardcoded
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
